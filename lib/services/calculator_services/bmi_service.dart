import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:setpocket/models/bmi_models.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/services/hive_service.dart';

class BmiService {
  static const String _historyKey = 'bmi_history';
  static const String _preferencesKey = 'bmi_preferences';

  // BMI calculation based on WHO standards with age and gender considerations
  static BmiCalculation calculateBmi(
    double height,
    double weight,
    int age,
    Gender gender,
    UnitSystem unitSystem,
    AppLocalizations l10n,
  ) {
    // Convert to metric if needed
    double heightCm = unitSystem == UnitSystem.metric
        ? height
        : convertHeight(height, UnitSystem.imperial, UnitSystem.metric);
    double weightKg = unitSystem == UnitSystem.metric
        ? weight
        : convertWeight(weight, UnitSystem.imperial, UnitSystem.metric);

    // Calculate BMI
    double heightM = heightCm / 100;
    double bmi = weightKg / (heightM * heightM);

    // Use different calculation methods based on age
    if (age < 18) {
      return _calculatePediatricBmi(bmi, age, gender, l10n);
    } else {
      return _calculateAdultBmi(bmi, age, gender, l10n);
    }
  }

  static BmiCalculation _calculateAdultBmi(
      double bmi, int age, Gender gender, AppLocalizations l10n) {
    // Determine category with age considerations
    BmiCategory category = _getBmiCategory(bmi, age);
    Color categoryColor = _getCategoryColor(category);

    // Generate interpretation with detailed context
    String interpretation = _getInterpretation(category, bmi, age, l10n);

    // Generate comprehensive recommendations
    List<String> recommendations = _getRecommendations(category, age, l10n);

    return BmiCalculation(
      bmi: bmi,
      category: category,
      categoryColor: categoryColor,
      interpretation: interpretation,
      recommendations: recommendations,
    );
  }

  static BmiCalculation _calculatePediatricBmi(
      double bmi, int age, Gender gender, AppLocalizations l10n) {
    // Calculate approximate percentile for pediatric BMI
    double percentile = _calculateBmiPercentile(bmi, age, gender);

    // Determine category based on percentile
    BmiCategory category = _getPediatricBmiCategory(percentile);
    Color categoryColor = _getCategoryColor(category);

    // Generate pediatric-specific interpretation
    String interpretation =
        _getPediatricInterpretation(percentile, category, age, gender, l10n);

    // Generate pediatric-specific recommendations
    List<String> recommendations =
        _getPediatricRecommendations(category, age, gender, l10n);

    return BmiCalculation(
      bmi: bmi,
      category: category,
      categoryColor: categoryColor,
      interpretation: interpretation,
      recommendations: recommendations,
    );
  }

  static double _calculateBmiPercentile(double bmi, int age, Gender gender) {
    // Simplified approximation of BMI percentiles based on CDC data
    // This is a basic approximation - real implementation would use CDC lookup tables

    // Age-adjusted BMI thresholds (approximated)
    Map<int, Map<Gender, List<double>>> ageThresholds = {
      // Format: age: {gender: [5th, 50th, 85th, 95th percentiles]}
      5: {
        Gender.male: [13.3, 15.4, 17.4, 19.3],
        Gender.female: [13.2, 15.2, 17.1, 19.2],
        Gender.other: [13.3, 15.3, 17.3, 19.3], // Use average
      },
      10: {
        Gender.male: [14.2, 16.7, 20.0, 23.0],
        Gender.female: [14.0, 16.9, 20.3, 23.2],
        Gender.other: [14.1, 16.8, 20.2, 23.1],
      },
      15: {
        Gender.male: [17.2, 20.2, 23.6, 26.8],
        Gender.female: [17.0, 20.7, 24.0, 27.1],
        Gender.other: [17.1, 20.5, 23.8, 27.0],
      },
      17: {
        Gender.male: [18.2, 21.6, 25.0, 28.3],
        Gender.female: [17.9, 21.8, 25.3, 28.8],
        Gender.other: [18.1, 21.7, 25.2, 28.6],
      }
    };

    // Find closest age group
    int closestAge = 17;
    for (int ageKey in ageThresholds.keys) {
      if (age <= ageKey) {
        closestAge = ageKey;
        break;
      }
    }

    List<double> thresholds = ageThresholds[closestAge]![gender] ??
        ageThresholds[closestAge]![Gender.other]!;

    // Calculate approximate percentile
    if (bmi < thresholds[0]) {
      return 2.5; // Below 5th percentile
    } else if (bmi < thresholds[1]) {
      return 25.0; // 5th to 50th percentile
    } else if (bmi < thresholds[2]) {
      return 70.0; // 50th to 85th percentile
    } else if (bmi < thresholds[3]) {
      return 90.0; // 85th to 95th percentile
    } else {
      return 97.5; // Above 95th percentile
    }
  }

  static BmiCategory _getPediatricBmiCategory(double percentile) {
    if (percentile < 5) return BmiCategory.underweight;
    if (percentile < 85) return BmiCategory.normalWeight;
    if (percentile < 95) return BmiCategory.overweightI;
    return BmiCategory.obeseI;
  }

  static String _getPediatricInterpretation(double percentile,
      BmiCategory category, int age, Gender gender, AppLocalizations l10n) {
    String categoryName = _getPediatricCategoryName(category, l10n);
    String baseInterpretation = l10n.bmiPediatricInterpretation(
        percentile.toStringAsFixed(0), categoryName);

    // Add pediatric-specific context
    String pediatricNote = ' ${l10n.bmiPediatricNote}';
    String growthPattern = ' ${l10n.bmiGrowthPattern}';

    return baseInterpretation + pediatricNote + growthPattern;
  }

  static String _getPediatricCategoryName(
      BmiCategory category, AppLocalizations l10n) {
    switch (category) {
      case BmiCategory.underweight:
        return l10n.bmiPercentileUnderweight.toLowerCase();
      case BmiCategory.normalWeight:
        return l10n.bmiPercentileNormal.toLowerCase();
      case BmiCategory.overweightI:
      case BmiCategory.overweightII:
        return l10n.bmiPercentileOverweightI.toLowerCase();
      case BmiCategory.obeseI:
      case BmiCategory.obeseII:
      case BmiCategory.obeseIII:
        return l10n.bmiPercentileObeseI.toLowerCase();
    }
  }

  static List<String> _getPediatricRecommendations(
      BmiCategory category, int age, Gender gender, AppLocalizations l10n) {
    List<String> recommendations = [];

    // Age-appropriate recommendations
    switch (category) {
      case BmiCategory.underweight:
        recommendations.addAll([
          l10n.bmiUnderweightRec1,
          l10n.bmiUnderweightRec2,
          l10n.bmiGrowthPattern,
        ]);
        break;
      case BmiCategory.normalWeight:
        recommendations.addAll([
          l10n.bmiNormalRec1,
          l10n.bmiNormalRec2,
          l10n.bmiYouthRec,
        ]);
        break;
      case BmiCategory.overweightI:
      case BmiCategory.overweightII:
        recommendations.addAll([
          l10n.bmiOverweightRec1,
          l10n.bmiOverweightRec2,
          l10n.bmiGrowthPattern,
        ]);
        break;
      case BmiCategory.obeseI:
      case BmiCategory.obeseII:
      case BmiCategory.obeseIII:
        recommendations.addAll([
          l10n.bmiObeseRec1,
          l10n.bmiObeseRec2,
          l10n.bmiGrowthPattern,
        ]);
        break;
    }

    // Always add consultation recommendation for pediatric
    recommendations.add(l10n.bmiConsultationRec);

    return recommendations;
  }

  static BmiCategory _getBmiCategory(double bmi, int age) {
    // Special considerations for elderly (65+)
    if (age >= 65) {
      if (bmi < 22.0) return BmiCategory.underweight;
      if (bmi <= 27.0) return BmiCategory.normalWeight;
      if (bmi <= 30.0) return BmiCategory.overweightI;
      if (bmi <= 35.0) return BmiCategory.obeseI;
      if (bmi <= 40.0) return BmiCategory.obeseII;
      return BmiCategory.obeseIII;
    }

    // Detailed WHO classifications for adults (18-64)
    if (bmi < 18.5) return BmiCategory.underweight;
    if (bmi < 25.0) return BmiCategory.normalWeight;
    if (bmi < 27.5) return BmiCategory.overweightI; // 25.0-27.4
    if (bmi < 30.0) return BmiCategory.overweightII; // 27.5-29.9
    if (bmi < 35.0) return BmiCategory.obeseI; // 30.0-34.9
    if (bmi < 40.0) return BmiCategory.obeseII; // 35.0-39.9
    return BmiCategory.obeseIII; // ≥ 40.0
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

  static String _getInterpretation(
      BmiCategory category, double bmi, int age, AppLocalizations l10n) {
    final bmiText = bmi.toStringAsFixed(1);
    String baseInterpretation;

    // Base interpretations based on age considerations
    if (age < 18) {
      // Pediatric interpretations
      final percentile = _calculatePediatricBmiPercentile(bmi, age);
      baseInterpretation = l10n.bmiPediatricInterpretation(
          percentile.toStringAsFixed(1),
          _getDetailedCategoryName(category, l10n));
    } else {
      // Adult interpretations - consolidate similar categories for messaging
      switch (category) {
        case BmiCategory.underweight:
          baseInterpretation = l10n.bmiUnderweightInterpretation;
          break;
        case BmiCategory.normalWeight:
          baseInterpretation = l10n.bmiNormalInterpretation(bmiText);
          break;
        case BmiCategory.overweightI:
        case BmiCategory.overweightII:
          baseInterpretation = l10n.bmiOverweightInterpretation(bmiText);
          break;
        case BmiCategory.obeseI:
        case BmiCategory.obeseII:
        case BmiCategory.obeseIII:
          baseInterpretation = l10n.bmiObeseInterpretation(bmiText);
          break;
      }
    }

    // Add age-specific considerations
    if (age >= 65) {
      return '$baseInterpretation ${l10n.bmiElderlyNote}';
    }
    if (age < 25) {
      return '$baseInterpretation ${l10n.bmiYouthNote}';
    }

    return baseInterpretation;
  }

  static double _calculatePediatricBmiPercentile(double bmi, int age) {
    // Simplified approximation for pediatric BMI percentiles
    // In real implementation, this would use CDC growth charts
    if (bmi < 16.0) return 5.0; // Underweight
    if (bmi < 18.5) return 50.0; // Normal
    if (bmi < 22.0) return 90.0; // 85th-95th percentile
    return 97.0; // Above 95th percentile
  }

  static String _getDetailedCategoryName(
      BmiCategory category, AppLocalizations l10n) {
    switch (category) {
      case BmiCategory.underweight:
        return l10n.bmiPercentileUnderweight.toLowerCase();
      case BmiCategory.normalWeight:
        return l10n.bmiPercentileNormal.toLowerCase();
      case BmiCategory.overweightI:
      case BmiCategory.overweightII:
        return l10n.bmiPercentileOverweightI.toLowerCase();
      case BmiCategory.obeseI:
      case BmiCategory.obeseII:
      case BmiCategory.obeseIII:
        return l10n.bmiPercentileObeseI.toLowerCase();
    }
  }

  static List<String> _getRecommendations(
      BmiCategory category, int age, AppLocalizations l10n) {
    List<String> recommendations = [];

    // Age-specific introductions
    if (age < 18) {
      recommendations.add(l10n.bmiGrowthPattern);
    }

    // Category-specific recommendations - consolidate similar categories
    switch (category) {
      case BmiCategory.underweight:
        recommendations.addAll([
          l10n.bmiUnderweightRec1,
          l10n.bmiUnderweightRec2,
          l10n.bmiUnderweightRec3,
        ]);
        break;
      case BmiCategory.normalWeight:
        recommendations.addAll([
          l10n.bmiNormalRec1,
          l10n.bmiNormalRec2,
          l10n.bmiNormalRec3,
        ]);
        break;
      case BmiCategory.overweightI:
      case BmiCategory.overweightII:
        recommendations.addAll([
          l10n.bmiOverweightRec1,
          l10n.bmiOverweightRec2,
          l10n.bmiOverweightRec3,
        ]);
        break;
      case BmiCategory.obeseI:
      case BmiCategory.obeseII:
      case BmiCategory.obeseIII:
        recommendations.addAll([
          l10n.bmiObeseRec1,
          l10n.bmiObeseRec2,
          l10n.bmiObeseRec3,
        ]);
        break;
    }

    return recommendations;
  }

  // History management
  static Future<List<BmiHistoryEntry>> getHistory() async {
    try {
      // TODO: Implement Isar-based BMI history storage
      return [];
    } catch (e) {
      debugPrint('Error loading BMI history: $e');
      return [];
    }
  }

  static Future<void> saveToHistory(BmiHistoryEntry entry) async {
    try {
      // TODO: Implement Isar-based BMI history storage
    } catch (e) {
      debugPrint('Error saving BMI history: $e');
    }
  }

  static Future<void> removeFromHistory(String id) async {
    try {
      // TODO: Implement Isar-based BMI history storage
    } catch (e) {
      debugPrint('Error removing BMI history: $e');
    }
  }

  static Future<void> clearHistory() async {
    try {
      // TODO: Implement Isar-based BMI history storage
    } catch (e) {
      debugPrint('Error clearing BMI history: $e');
    }
  }

  // Preferences management
  static Future<Map<String, dynamic>> getPreferences() async {
    try {
      return {
        'unitSystem': UnitSystem.metric.index,
        'rememberLastValues': true,
        'autoSaveToHistory': true,
      };
    } catch (e) {
      debugPrint('Error loading BMI preferences: $e');
      return {
        'unitSystem': UnitSystem.metric.index,
        'rememberLastValues': true,
        'autoSaveToHistory': true,
      };
    }
  }

  static Future<void> savePreferences(Map<String, dynamic> preferences) async {
    try {
      // TODO: Implement Isar-based BMI preferences storage
    } catch (e) {
      debugPrint('Error saving BMI preferences: $e');
    }
  }

  static Future<void> clearPreferences() async {
    try {
      // TODO: Implement Isar-based BMI preferences storage
    } catch (e) {
      debugPrint('Error clearing BMI preferences: $e');
    }
  }

  // Cache management methods
  static Future<bool> hasData() async {
    try {
      // TODO: Implement Isar-based BMI data check
      return false;
    } catch (e) {
      debugPrint('Error checking BMI data existence: $e');
      return false;
    }
  }

  static Future<int> getDataSize() async {
    try {
      return 0;
    } catch (e) {
      debugPrint('Error calculating BMI data size: $e');
      return 0;
    }
  }

  // Utility methods
  static String formatHeight(double height, UnitSystem unitSystem) {
    if (unitSystem == UnitSystem.imperial) {
      final totalInches = height;
      final feet = (totalInches / 12).floor();
      final inches = (totalInches % 12).round();
      return "$feet'$inches\"";
    } else {
      return "${height.toStringAsFixed(0)} cm";
    }
  }

  static String formatWeight(double weight, UnitSystem unitSystem) {
    if (unitSystem == UnitSystem.imperial) {
      return "${weight.toStringAsFixed(1)} lbs";
    } else {
      return "${weight.toStringAsFixed(1)} kg";
    }
  }

  static double convertHeight(double height, UnitSystem from, UnitSystem to) {
    if (from == to) return height;

    if (from == UnitSystem.metric && to == UnitSystem.imperial) {
      return height / 2.54; // cm to inches
    } else {
      return height * 2.54; // inches to cm
    }
  }

  static double convertWeight(double weight, UnitSystem from, UnitSystem to) {
    if (from == to) return weight;

    if (from == UnitSystem.metric && to == UnitSystem.imperial) {
      return weight / 0.453592; // kg to pounds
    } else {
      return weight * 0.453592; // pounds to kg
    }
  }

  // BMI info and educational content
  static List<Map<String, dynamic>> getBmiRanges(AppLocalizations l10n) {
    return getBmiRangesForAge(l10n, 18); // Default to adult
  }

  static List<Map<String, dynamic>> getBmiRangesForAge(
      AppLocalizations l10n, int age) {
    if (age < 18) {
      return _getPediatricBmiRanges(l10n);
    } else {
      return _getAdultBmiRanges(l10n);
    }
  }

  static List<Map<String, dynamic>> _getAdultBmiRanges(AppLocalizations l10n) {
    return [
      {
        'category': l10n.underweight,
        'range': '< 18.5',
        'color': Colors.blue,
        'description': l10n.bmiUnderweightDesc,
      },
      {
        'category': l10n.normalWeight,
        'range': '18.5 - 24.9',
        'color': Colors.green,
        'description': l10n.bmiNormalDesc,
      },
      {
        'category': l10n.overweightI,
        'range': '25.0 - 27.4',
        'color': Colors.orange,
        'description': l10n.bmiOverweightDesc,
      },
      {
        'category': l10n.overweightII,
        'range': '27.5 - 29.9',
        'color': Colors.orange.shade700,
        'description': l10n.bmiOverweightDesc,
      },
      {
        'category': l10n.obeseI,
        'range': '30.0 - 34.9',
        'color': Colors.red,
        'description': l10n.bmiObeseDesc,
      },
      {
        'category': l10n.obeseII,
        'range': '35.0 - 39.9',
        'color': Colors.red.shade700,
        'description': l10n.bmiObeseDesc,
      },
      {
        'category': l10n.obeseIII,
        'range': '≥ 40.0',
        'color': Colors.red.shade900,
        'description': l10n.bmiObeseDesc,
      },
    ];
  }

  static List<Map<String, dynamic>> _getPediatricBmiRanges(
      AppLocalizations l10n) {
    return [
      {
        'category': l10n.underweight,
        'range': l10n.bmiPercentileUnderweight,
        'color': Colors.blue,
        'description': l10n.bmiUnderweightDesc,
      },
      {
        'category': l10n.normalWeight,
        'range': l10n.bmiPercentileNormal,
        'color': Colors.green,
        'description': l10n.bmiNormalDesc,
      },
      {
        'category': l10n.overweightI,
        'range': l10n.bmiPercentileOverweightI,
        'color': Colors.orange,
        'description': l10n.bmiOverweightDesc,
      },
      {
        'category': l10n.obeseI,
        'range': l10n.bmiPercentileObeseI,
        'color': Colors.red,
        'description': l10n.bmiObeseDesc,
      },
    ];
  }

  static String getBmiRangeTitle(AppLocalizations l10n, int age) {
    return age < 18 ? l10n.bmiPediatricTitle : l10n.bmiAdultTitle;
  }

  static String getBmiRangeNote(AppLocalizations l10n, int age) {
    return age < 18
        ? l10n.bmiPercentileNote
        : 'Tiêu chuẩn WHO cho người trưởng thành (18-64 tuổi)';
  }

  // Add detailed BMI information for different age groups
  static Map<String, dynamic> getBmiDetailedInfo(AppLocalizations l10n) {
    return {
      'formula': l10n.bmiFormula,
      'adultRanges': getBmiRanges(l10n),
      'elderlyNote': l10n.bmiElderlyNote,
      'youthNote': l10n.bmiYouthNote,
      'limitations': [
        l10n.bmiLimitation1,
        l10n.bmiLimitation2,
        l10n.bmiLimitation3,
        l10n.bmiLimitation4,
      ],
      'whenToConsult': [
        l10n.bmiConsult1,
        l10n.bmiConsult2,
        l10n.bmiConsult3,
      ],
    };
  }
}
