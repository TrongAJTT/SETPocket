import 'package:flutter/material.dart';

enum Gender {
  male,
  female,
  other,
}

enum BmiCategory {
  underweight,
  normalWeight,
  overweightI,
  overweightII,
  obeseI,
  obeseII,
  obeseIII,
}

enum UnitSystem {
  metric,
  imperial,
}

class BmiCalculation {
  final double bmi;
  final BmiCategory category;
  final Color categoryColor;
  final String interpretation;
  final List<String> recommendations;

  const BmiCalculation({
    required this.bmi,
    required this.category,
    required this.categoryColor,
    required this.interpretation,
    required this.recommendations,
  });
}

class BmiData {
  final double height;
  final double weight;
  final int age;
  final Gender gender;
  final UnitSystem unitSystem;
  final DateTime calculatedAt;

  const BmiData({
    required this.height,
    required this.weight,
    required this.age,
    required this.gender,
    required this.unitSystem,
    required this.calculatedAt,
  });

  Map<String, dynamic> toJson() => {
        'height': height,
        'weight': weight,
        'age': age,
        'gender': gender.index,
        'unitSystem': unitSystem.index,
        'calculatedAt': calculatedAt.millisecondsSinceEpoch,
      };

  factory BmiData.fromJson(Map<String, dynamic> json) => BmiData(
        height: json['height'].toDouble(),
        weight: json['weight'].toDouble(),
        age: json['age'],
        gender: Gender.values[json['gender']],
        unitSystem: UnitSystem.values[json['unitSystem']],
        calculatedAt: DateTime.fromMillisecondsSinceEpoch(json['calculatedAt']),
      );
}

class BmiHistoryEntry {
  final String id;
  final BmiData data;
  final BmiCalculation calculation;

  const BmiHistoryEntry({
    required this.id,
    required this.data,
    required this.calculation,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'data': data.toJson(),
        'calculation': {
          'bmi': calculation.bmi,
          'category': calculation.category.index,
          'interpretation': calculation.interpretation,
          'recommendations': calculation.recommendations,
        },
      };

  factory BmiHistoryEntry.fromJson(Map<String, dynamic> json) {
    final data = BmiData.fromJson(json['data']);
    final calcJson = json['calculation'];

    return BmiHistoryEntry(
      id: json['id'],
      data: data,
      calculation: BmiCalculation(
        bmi: calcJson['bmi'].toDouble(),
        category: BmiCategory.values[calcJson['category']],
        categoryColor:
            _getCategoryColor(BmiCategory.values[calcJson['category']]),
        interpretation: calcJson['interpretation'],
        recommendations: List<String>.from(calcJson['recommendations']),
      ),
    );
  }

  static Color _getCategoryColor(BmiCategory category) {
    switch (category) {
      case BmiCategory.underweight:
        return Colors.blue;
      case BmiCategory.normalWeight:
        return Colors.green;
      case BmiCategory.overweightI:
        return Colors.orange;
      case BmiCategory.overweightII:
        return Colors.orange.shade700;
      case BmiCategory.obeseI:
        return Colors.red;
      case BmiCategory.obeseII:
        return Colors.red.shade700;
      case BmiCategory.obeseIII:
        return Colors.red.shade900;
    }
  }
}
