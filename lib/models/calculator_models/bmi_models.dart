import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'bmi_models.g.dart';

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

enum AgeGroup {
  under18,
  adult18Plus,
}

// Embedded class for BMI calculation data (không cần @embedded vì không sử dụng trong Isar collection trực tiếp)
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

@embedded
class BmiData {
  double height = 0.0;
  double weight = 0.0;
  @enumerated
  AgeGroup ageGroup = AgeGroup.adult18Plus;
  @enumerated
  UnitSystem unitSystem = UnitSystem.metric;
  @enumerated
  Gender gender = Gender.other;
  DateTime calculatedAt = DateTime.now();

  BmiData();

  // Helper constructor để tạo object với parameters
  BmiData.create({
    required double height,
    required double weight,
    required AgeGroup ageGroup,
    required UnitSystem unitSystem,
    required Gender gender,
    required DateTime calculatedAt,
  }) {
    this.height = height;
    this.weight = weight;
    this.ageGroup = ageGroup;
    this.unitSystem = unitSystem;
    this.gender = gender;
    this.calculatedAt = calculatedAt;
  }

  Map<String, dynamic> toJson() => {
        'height': height,
        'weight': weight,
        'ageGroup': ageGroup.index,
        'gender': gender.index,
        'unitSystem': unitSystem.index,
        'calculatedAt': calculatedAt.millisecondsSinceEpoch,
      };

  factory BmiData.fromJson(Map<String, dynamic> json) {
    final data = BmiData();
    data.height = json['height'].toDouble();
    data.weight = json['weight'].toDouble();
    data.ageGroup =
        AgeGroup.values[json['ageGroup'] ?? AgeGroup.adult18Plus.index];
    data.gender = Gender.values[json['gender']];
    data.unitSystem = UnitSystem.values[json['unitSystem']];
    data.calculatedAt =
        DateTime.fromMillisecondsSinceEpoch(json['calculatedAt']);
    return data;
  }
}

@embedded
class BmiCalculationData {
  double bmi = 0.0;
  @enumerated
  BmiCategory category = BmiCategory.normalWeight;
  String interpretation = '';
  List<String> recommendations = [];

  BmiCalculationData();

  // Helper constructor để tạo object với parameters
  BmiCalculationData.create({
    required double bmi,
    required BmiCategory category,
    required String interpretation,
    required List<String> recommendations,
  }) {
    this.bmi = bmi;
    this.category = category;
    this.interpretation = interpretation;
    this.recommendations = recommendations;
  }

  BmiCalculation toBmiCalculation() {
    return BmiCalculation(
      bmi: bmi,
      category: category,
      categoryColor: _getCategoryColor(category),
      interpretation: interpretation,
      recommendations: recommendations,
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

@collection
class BmiHistoryEntry {
  Id id = Isar.autoIncrement; // Thêm Id field bắt buộc cho Isar collection

  late BmiData data;
  late BmiCalculationData calculationData;

  BmiHistoryEntry();

  // Constructor với parameters
  BmiHistoryEntry.create({
    required this.data,
    required this.calculationData,
  });

  // Getter để lấy BmiCalculation với Color
  @ignore
  BmiCalculation get calculation => calculationData.toBmiCalculation();

  Map<String, dynamic> toJson() => {
        'id': id,
        'data': data.toJson(),
        'calculation': {
          'bmi': calculationData.bmi,
          'category': calculationData.category.index,
          'interpretation': calculationData.interpretation,
          'recommendations': calculationData.recommendations,
        },
      };

  factory BmiHistoryEntry.fromJson(Map<String, dynamic> json) {
    final data = BmiData.fromJson(json['data']);
    final calcJson = json['calculation'];

    return BmiHistoryEntry.create(
      data: data,
      calculationData: BmiCalculationData.create(
        bmi: calcJson['bmi'].toDouble(),
        category: BmiCategory.values[calcJson['category']],
        interpretation: calcJson['interpretation'],
        recommendations: List<String>.from(calcJson['recommendations']),
      ),
    );
  }
}
