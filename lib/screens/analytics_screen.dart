import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/budget_provider.dart';
import '../theme/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 2);

    final expenseMap = budget.categoryExpenseMap;
    final totalExpense = budget.totalExpense;

    // Savings rate calculation
    final savingsRate = budget.totalIncome > 0
        ? (((budget.totalIncome - budget.totalExpense) / budget.totalIncome) * 100).clamp(-100.0, 100.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bütçe & Harcama Analizi'),
      ),
      body: budget.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Financial Health Metrics Cards
                  Row(
                    children: [
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
                              const Text('Tasarruf Oranı', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 6),
                              Text(
                                '%${savingsRate.toStringAsFixed(1)}',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: savingsRate >= 0 ? AppColors.income : AppColors.expense,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                savingsRate >= 20 ? 'Çok İyi Durumdasınız' : (savingsRate >= 0 ? 'Dengeli' : 'Bütçe Aşımı'),
                                style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
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
                              const Text('Günlük Ort. Gider', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 6),
                              Text(
                                currencyFormatter.format(totalExpense > 0 ? (totalExpense / 30) : 0),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.expense,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '30 günlük ortalama',
                                style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Category Breakdown Chart Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gider Dağılımı',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kategori bazlı harcama yüzdeleri',
                          style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 24),

                        if (totalExpense <= 0 || expenseMap.isEmpty)
                          Container(
                            height: 180,
                            alignment: Alignment.center,
                            child: const Text('Bu ay henüz gider kaydı bulunmuyor'),
                          )
                        else ...[
                          // Pie Chart
                          SizedBox(
                            height: 200,
                            child: PieChart(
                              PieChartData(
                                pieTouchData: PieTouchData(
                                  touchCallback: (event, pieTouchResponse) {
                                    setState(() {
                                      if (!event.isInterestedForInteractions ||
                                          pieTouchResponse == null ||
                                          pieTouchResponse.touchedSection == null) {
                                        _touchedIndex = -1;
                                        return;
                                      }
                                      _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                    });
                                  },
                                ),
                                borderData: FlBorderData(show: false),
                                sectionsSpace: 3,
                                centerSpaceRadius: 46,
                                sections: _generatePieSections(budget, expenseMap, totalExpense),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Category Legend List
                          ...expenseMap.entries.map((entry) {
                            final cat = budget.getCategoryById(entry.key);
                            if (cat == null) return const SizedBox.shrink();
                            final percent = (entry.value / totalExpense) * 100;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: cat.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      cat.name,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Text(
                                    '%${percent.toStringAsFixed(1)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    currencyFormatter.format(entry.value),
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  List<PieChartSectionData> _generatePieSections(
      BudgetProvider budget, Map<String, double> map, double total) {
    int index = 0;
    return map.entries.map((entry) {
      final isTouched = index == _touchedIndex;
      final cat = budget.getCategoryById(entry.key);
      final color = cat?.color ?? AppColors.primary;
      final percent = (entry.value / total) * 100;
      final radius = isTouched ? 50.0 : 42.0;

      index++;
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percent.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: isTouched ? 14 : 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}
