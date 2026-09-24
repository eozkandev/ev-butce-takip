import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/budget_provider.dart';
import '../providers/auth_provider.dart';
import '../models/category_item.dart';
import '../models/transaction_item.dart';
import '../theme/app_theme.dart';
class HomeDashboardScreen extends StatelessWidget {
  final Function(int) onNavigateTab;

  const HomeDashboardScreen({
    super.key,
    required this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetProvider>();
    final auth = context.read<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 2);
    final monthFormatter = DateFormat('MMMM yyyy', 'tr_TR');

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.account_balance_wallet_rounded, size: 20, color: AppColors.primaryLight),
            ),
            const SizedBox(width: 10),
            const Text('Ev Bütçe Takip'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Uygulamayı Kilitle',
            icon: const Icon(Icons.lock_outline_rounded),
            onPressed: () => auth.lockApp(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: budget.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => budget.init(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Month Selector Banner
                    _buildMonthSelector(context, budget, monthFormatter),
                    const SizedBox(height: 16),

                    // Net Balance Card
                    _buildNetBalanceCard(context, budget, currencyFormatter, isDark),
                    const SizedBox(height: 14),

                    // Income & Expense Summary Dual Cards
                    _buildDualSummaryCards(budget, currencyFormatter, isDark),
                    const SizedBox(height: 24),

                    // Budget Goal Tracking
                    _buildBudgetLimitsSection(context, budget, currencyFormatter, isDark),
                    const SizedBox(height: 24),

                    // Recent Transactions Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Son İşlemler',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                        TextButton(
                          onPressed: () => onNavigateTab(1),
                          child: const Text('Tümünü Gör'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Recent Transactions List
                    _buildRecentTransactionsList(context, budget, currencyFormatter, isDark),
                    const SizedBox(height: 80), // Fab space
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMonthSelector(
      BuildContext context, BudgetProvider budget, DateFormat monthFormatter) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkBorder
              : AppColors.lightBorder,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: () {
              final prev = DateTime(
                budget.selectedMonth.year,
                budget.selectedMonth.month - 1,
              );
              budget.setSelectedMonth(prev);
            },
          ),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primaryLight),
              const SizedBox(width: 8),
              Text(
                monthFormatter.format(budget.selectedMonth),
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: () {
              final next = DateTime(
                budget.selectedMonth.year,
                budget.selectedMonth.month + 1,
              );
              budget.setSelectedMonth(next);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNetBalanceCard(
      BuildContext context, BudgetProvider budget, NumberFormat formatter, bool isDark) {
    final isPositive = budget.netBalance >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFFFFFFF), const Color(0xFFF8FAFC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Aylık Net Durum',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isPositive ? AppColors.income : AppColors.expense).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      size: 15,
                      color: isPositive ? AppColors.income : AppColors.expense,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isPositive ? 'Fazla Verildi' : 'Bütçe Aşımı',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isPositive ? AppColors.income : AppColors.expense,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            formatter.format(budget.netBalance),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
              color: isPositive ? AppColors.income : AppColors.expense,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDualSummaryCards(
      BudgetProvider budget, NumberFormat formatter, bool isDark) {
    return Row(
      children: [
        // Gelir Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.income.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_downward_rounded, size: 16, color: AppColors.income),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Gelirler',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  formatter.format(budget.totalIncome),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.income,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Gider Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.expense.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_upward_rounded, size: 16, color: AppColors.expense),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Giderler',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  formatter.format(budget.totalExpense),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.expense,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetLimitsSection(
      BuildContext context, BudgetProvider budget, NumberFormat formatter, bool isDark) {
    if (budget.budgetGoals.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori Bütçe Hedefleri',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.3),
        ),
        const SizedBox(height: 12),
        ...budget.budgetGoals.take(3).map((goal) {
          final cat = budget.getCategoryById(goal.categoryId);
          if (cat == null) return const SizedBox.shrink();

          final spent = budget.categoryExpenseMap[goal.categoryId] ?? 0;
          final ratio = (spent / goal.monthlyLimit).clamp(0.0, 1.0);
          final isExceeded = spent > goal.monthlyLimit;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: cat.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(cat.icon, size: 16, color: cat.color),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        cat.name,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ),
                    Text(
                      '${formatter.format(spent)} / ${formatter.format(goal.monthlyLimit)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isExceeded ? AppColors.expense : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 6,
                    backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isExceeded ? AppColors.expense : cat.color,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRecentTransactionsList(
      BuildContext context, BudgetProvider budget, NumberFormat formatter, bool isDark) {
    final recent = budget.currentMonthTransactions.take(5).toList();

    if (recent.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.receipt_outlined, size: 48, color: isDark ? Colors.white30 : Colors.black26),
            const SizedBox(height: 10),
            const Text(
              'Bu ay henüz bir işlem kaydedilmedi',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return Column(
      children: recent.map((t) {
        final cat = budget.getCategoryById(t.categoryId);
        final isIncome = t.type == TransactionType.income;

        return Card(
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
            subtitle: Text(
              '${DateFormat('dd MMM yyyy', 'tr_TR').format(t.date)} • ${t.paymentMethod.displayName}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            trailing: Text(
              '${isIncome ? '+' : '-'}${formatter.format(t.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: isIncome ? AppColors.income : AppColors.expense,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
