import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/budget_provider.dart';
import '../models/category_item.dart';
import '../models/transaction_item.dart';
import '../theme/app_theme.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _searchQuery = '';
  TransactionType? _selectedTypeFilter; // null means all

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 2);

    final filteredList = budget.transactions.where((t) {
      if (_selectedTypeFilter != null && t.type != _selectedTypeFilter) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final titleMatch = t.title.toLowerCase().contains(_searchQuery.toLowerCase());
        final noteMatch = t.note?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
        final cat = budget.getCategoryById(t.categoryId);
        final catMatch = cat?.name.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
        return titleMatch || noteMatch || catMatch;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('İşlem Geçmişi'),
      ),
      body: Column(
        children: [
          // Search & Filter header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'İşlem ara (market, kira, maaş...)',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Tümü'),
                        selected: _selectedTypeFilter == null,
                        onSelected: (_) => setState(() => _selectedTypeFilter = null),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Gelirler'),
                        selected: _selectedTypeFilter == TransactionType.income,
                        selectedColor: AppColors.income.withValues(alpha: 0.2),
                        checkmarkColor: AppColors.income,
                        onSelected: (_) => setState(() => _selectedTypeFilter = TransactionType.income),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Giderler'),
                        selected: _selectedTypeFilter == TransactionType.expense,
                        selectedColor: AppColors.expense.withValues(alpha: 0.2),
                        checkmarkColor: AppColors.expense,
                        onSelected: (_) => setState(() => _selectedTypeFilter = TransactionType.expense),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Transaction Count Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Toplam ${filteredList.length} kayıt',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 54, color: isDark ? Colors.white30 : Colors.black26),
                        const SizedBox(height: 12),
                        const Text('Eşleşen işlem bulunamadı', style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final t = filteredList[index];
                      final cat = budget.getCategoryById(t.categoryId);
                      final isIncome = t.type == TransactionType.income;

                      return Dismissible(
                        key: Key(t.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: AppColors.expense,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('İşlemi Sil'),
                              content: const Text('Bu finansal kaydı silmek istediğinize emin misiniz?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: TextButton.styleFrom(foregroundColor: AppColors.expense),
                                  child: const Text('Sil'),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (_) {
                          budget.deleteTransaction(t.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Kayıt silindi')),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: (cat?.color ?? AppColors.primary).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                cat?.icon ?? Icons.category_rounded,
                                color: cat?.color ?? AppColors.primary,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              t.title,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${DateFormat('dd MMM yyyy', 'tr_TR').format(t.date)} • ${t.paymentMethod.displayName}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  ),
                                ),
                                if (t.note != null && t.note!.isNotEmpty)
                                  Text(
                                    t.note!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                      color: isDark ? Colors.white60 : Colors.black54,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Text(
                              '${isIncome ? '+' : '-'}${currencyFormatter.format(t.amount)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: isIncome ? AppColors.income : AppColors.expense,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
