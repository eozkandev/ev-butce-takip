import 'package:flutter/material.dart';

enum TransactionType { income, expense }

class CategoryItem {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final TransactionType type;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'iconCode': icon.codePoint,
        'colorValue': color.toARGB32(),
        'type': type.name,
      };

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['id'] as String,
      name: json['name'] as String,
      // ignore: non_const_argument_for_const_parameter
      icon: IconData(json['iconCode'] as int, fontFamily: 'MaterialIcons'),
      color: Color(json['colorValue'] as int),
      type: json['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
    );
  }

  static List<CategoryItem> get defaultExpenseCategories => [
        const CategoryItem(
          id: 'exp_rent',
          name: 'Kira & Aidat',
          icon: Icons.home_rounded,
          color: Color(0xFF6366F1), // Indigo
          type: TransactionType.expense,
        ),
        const CategoryItem(
          id: 'exp_bills',
          name: 'Faturalar',
          icon: Icons.receipt_long_rounded,
          color: Color(0xFFF59E0B), // Amber
          type: TransactionType.expense,
        ),
        const CategoryItem(
          id: 'exp_market',
          name: 'Market & Mutfak',
          icon: Icons.shopping_cart_rounded,
          color: Color(0xFF10B981), // Emerald
          type: TransactionType.expense,
        ),
        const CategoryItem(
          id: 'exp_transport',
          name: 'Ulaşım & Akaryakıt',
          icon: Icons.directions_car_rounded,
          color: Color(0xFF3B82F6), // Blue
          type: TransactionType.expense,
        ),
        const CategoryItem(
          id: 'exp_health',
          name: 'Sağlık',
          icon: Icons.medical_services_rounded,
          color: Color(0xFFEF4444), // Red
          type: TransactionType.expense,
        ),
        const CategoryItem(
          id: 'exp_education',
          name: 'Eğitim & Çocuk',
          icon: Icons.school_rounded,
          color: Color(0xFF8B5CF6), // Violet
          type: TransactionType.expense,
        ),
        const CategoryItem(
          id: 'exp_entertainment',
          name: 'Eğlence & Sosyal',
          icon: Icons.movie_filter_rounded,
          color: Color(0xFFEC4899), // Pink
          type: TransactionType.expense,
        ),
        const CategoryItem(
          id: 'exp_other',
          name: 'Diğer Giderler',
          icon: Icons.category_rounded,
          color: Color(0xFF64748B), // Slate
          type: TransactionType.expense,
        ),
      ];

  static List<CategoryItem> get defaultIncomeCategories => [
        const CategoryItem(
          id: 'inc_salary',
          name: 'Maaş',
          icon: Icons.account_balance_wallet_rounded,
          color: Color(0xFF10B981), // Emerald
          type: TransactionType.income,
        ),
        const CategoryItem(
          id: 'inc_freelance',
          name: 'Ek Gelir / Serbest',
          icon: Icons.laptop_mac_rounded,
          color: Color(0xFF06B6D4), // Cyan
          type: TransactionType.income,
        ),
        const CategoryItem(
          id: 'inc_investment',
          name: 'Yatırım / Kâr Payı',
          icon: Icons.trending_up_rounded,
          color: Color(0xFF8B5CF6), // Purple
          type: TransactionType.income,
        ),
        const CategoryItem(
          id: 'inc_other',
          name: 'Diğer Gelirler',
          icon: Icons.attach_money_rounded,
          color: Color(0xFF14B8A6), // Teal
          type: TransactionType.income,
        ),
      ];
}
