import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/models/calculator_models/bmi_models.dart';
import 'package:setpocket/models/unified_history_data.dart';
import 'package:setpocket/services/calculator_services/calculator_tools_service.dart';
import 'package:setpocket/services/generation_history_service.dart';
import 'package:setpocket/services/isar_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:setpocket/models/calculator_models/calculator_tools_data.dart';
import 'package:setpocket/services/settings_models_service.dart';

class BmiService {
  static const String _historyKey = 'bmi_history';
  static const String _preferencesKey = 'bmi_preferences';
  static const String _toolId = CalculatorToolCodes.bmi;

  // BMI calculation based on WHO standards with age and gender considerations
  static BmiCalculation calculateBmi(
    double height,
    double weight,
    AgeGroup ageGroup,
    Gender gender,
    UnitSystem unitSystem,
    AppLocalizations l10n,
  ) {
    // Convert AgeGroup to age for internal calculations
    int age = ageGroup == AgeGroup.under18 ? 16 : 25; // Representative ages

    // Convert to metric if needed
    double heightInCm = height;
    double weightInKg = weight;

    if (unitSystem == UnitSystem.imperial) {
      heightInCm = height * 2.54; // inches to cm
      weightInKg = weight * 0.453592; // pounds to kg
    }

    // Calculate BMI
    double bmi = weightInKg / ((heightInCm / 100) * (heightInCm / 100));

    // Use different calculation methods based on age group
    if (ageGroup == AgeGroup.under18) {
      return _calculatePediatricBmi(bmi, ageGroup, gender, l10n);
    } else {
      return _calculateAdultBmi(bmi, ageGroup, gender, l10n);
    }
  }

  static BmiCalculation _calculateAdultBmi(
      double bmi, AgeGroup ageGroup, Gender gender, AppLocalizations l10n) {
    // Determine category with age considerations
    BmiCategory category = _getBmiCategory(bmi, ageGroup);
    Color categoryColor = _getCategoryColor(category);

    // Generate interpretation with detailed context
    String interpretation = _getInterpretation(category, bmi, ageGroup, l10n);

    // Generate comprehensive recommendations
    List<String> recommendations =
        _getRecommendations(category, ageGroup, l10n);

    return BmiCalculation(
      bmi: bmi,
      category: category,
      categoryColor: categoryColor,
      interpretation: interpretation,
      recommendations: recommendations,
    );
  }

  static BmiCalculation _calculatePediatricBmi(
      double bmi, AgeGroup ageGroup, Gender gender, AppLocalizations l10n) {
    // For pediatric group, use simplified categorization since we don't have exact age
    BmiCategory category = _getPediatricBmiCategorySimplified(bmi);
    Color categoryColor = _getCategoryColor(category);

    // Generate pediatric-specific interpretation
    String interpretation =
        _getPediatricInterpretationSimplified(category, ageGroup, gender, l10n);

    // Generate pediatric-specific recommendations
    List<String> recommendations = _getPediatricRecommendationsSimplified(
        category, ageGroup, gender, l10n);

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
      BmiCategory category, int age, AppLocalizations l10n) {
    List<String> recommendations = [];

    // Age-appropriate recommendations
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

  // Simplified pediatric BMI category determination since we don't have exact age
  static BmiCategory _getPediatricBmiCategorySimplified(double bmi) {
    // Use general thresholds for children/teens
    if (bmi < 16.0) return BmiCategory.underweight;
    if (bmi < 22.0) return BmiCategory.normalWeight;
    if (bmi < 26.0) return BmiCategory.overweightI;
    return BmiCategory.obeseI;
  }

  static String _getPediatricInterpretationSimplified(BmiCategory category,
      AgeGroup ageGroup, Gender gender, AppLocalizations l10n) {
    String categoryName = _getPediatricCategoryName(category, l10n);
    // Use general interpretation for pediatric since exact percentile calculation requires specific age
    String baseInterpretation =
        'BMI category: $categoryName (Under 18 category)';

    // Add pediatric-specific context
    String pediatricNote =
        ' Please consult with healthcare provider for pediatric BMI assessment.';

    return baseInterpretation + pediatricNote;
  }

  static List<String> _getPediatricRecommendationsSimplified(
      BmiCategory category,
      AgeGroup ageGroup,
      Gender gender,
      AppLocalizations l10n) {
    List<String> recommendations = [];

    // General pediatric recommendations since we don't have exact age
    switch (category) {
      case BmiCategory.underweight:
        recommendations.addAll([
          'Consult with pediatrician about healthy weight gain strategies',
          'Focus on nutrient-dense foods and appropriate portions',
          'Ensure adequate physical activity appropriate for age',
        ]);
        break;
      case BmiCategory.normalWeight:
        recommendations.addAll([
          'Maintain current healthy habits',
          'Continue balanced nutrition and regular physical activity',
          'Regular health check-ups with healthcare provider',
        ]);
        break;
      case BmiCategory.overweightI:
      case BmiCategory.overweightII:
        recommendations.addAll([
          'Consult with pediatrician about healthy weight management',
          'Focus on family-based lifestyle changes',
          'Increase physical activity and reduce sedentary time',
        ]);
        break;
      case BmiCategory.obeseI:
      case BmiCategory.obeseII:
      case BmiCategory.obeseIII:
        recommendations.addAll([
          'Seek professional medical guidance immediately',
          'Consider structured weight management program',
          'Family-based approach to lifestyle modifications',
        ]);
        break;
    }

    // Always add consultation note for pediatric
    recommendations.add(
        'Professional medical consultation is recommended for all pediatric BMI assessments.');

    return recommendations;
  }

  static BmiCategory _getBmiCategory(double bmi, AgeGroup ageGroup) {
    // Use standard WHO classifications for adults
    if (ageGroup == AgeGroup.adult18Plus) {
      if (bmi < 18.5) return BmiCategory.underweight;
      if (bmi < 25.0) return BmiCategory.normalWeight;
      if (bmi < 27.5) return BmiCategory.overweightI; // 25.0-27.4
      if (bmi < 30.0) return BmiCategory.overweightII; // 27.5-29.9
      if (bmi < 35.0) return BmiCategory.obeseI; // 30.0-34.9
      if (bmi < 40.0) return BmiCategory.obeseII; // 35.0-39.9
      return BmiCategory.obeseIII; // ≥ 40.0
    } else {
      // For pediatric group, use simplified thresholds
      return _getPediatricBmiCategorySimplified(bmi);
    }
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

  static String _getInterpretation(BmiCategory category, double bmi,
      AgeGroup ageGroup, AppLocalizations l10n) {
    final bmiText = bmi.toStringAsFixed(1);
    String baseInterpretation;

    // Base interpretations based on age group
    if (ageGroup == AgeGroup.under18) {
      // Pediatric interpretations - simplified since we don't have exact age
      String categoryName = _getDetailedCategoryName(category, l10n);
      baseInterpretation = 'BMI category: $categoryName (Under 18 category)';
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

    // Add age group-specific considerations
    if (ageGroup == AgeGroup.under18) {
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
      BmiCategory category, AgeGroup ageGroup, AppLocalizations l10n) {
    List<String> recommendations = [];

    // Age group-specific introductions
    if (ageGroup == AgeGroup.under18) {
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

    // Add age group-specific recommendations
    if (ageGroup == AgeGroup.under18) {
      recommendations.add(
          'Professional medical consultation is recommended for pediatric BMI assessment.');
    }

    return recommendations;
  }

  // History management - Updated to use only UnifiedHistoryData like other calculators
  static Future<List<UnifiedHistoryData>> getHistory() async {
    try {
      final isar = IsarService.isar;
      return await isar.unifiedHistoryDatas
          .filter()
          .typeEqualTo('bmi_calculator')
          .sortByTimestampDesc()
          .findAll();
    } catch (e) {
      debugPrint('Error loading BMI history: $e');
      return [];
    }
  }

  static Future<void> saveToHistory(BmiHistoryEntry entry) async {
    try {
      // Check if history is enabled
      final settings =
          await ExtensibleSettingsService.getCalculatorToolsSettings();
      if (!settings.rememberHistory) return;

      // Create input and result data following the unified format
      final inputsData = {
        'height': entry.data.height,
        'weight': entry.data.weight,
        'ageGroup': entry.data.ageGroup.name,
        'gender': entry.data.gender.name,
        'unitSystem': entry.data.unitSystem.name,
      };

      final resultsData = {
        'bmi': entry.calculationData.bmi,
        'category': entry.calculationData.category.name,
        'interpretation': entry.calculationData.interpretation,
        'recommendations': entry.calculationData.recommendations,
      };

      // Follow Financial/Discount Calculator format: embed inputsData and resultsData inside 'value' field
      final valueData = {
        'inputsData': inputsData,
        'resultsData': resultsData,
      };

      final historyData = UnifiedHistoryData(
        type: 'bmi_calculator',
        title:
            'BMI ${entry.calculationData.bmi.toStringAsFixed(1)} - ${entry.calculationData.category.name}',
        value: jsonEncode(valueData),
        timestamp: entry.data.calculatedAt,
        subType: 'bmi',
        displayTitle:
            'BMI ${entry.calculationData.bmi.toStringAsFixed(1)} - ${entry.calculationData.category.name}',
        inputsData: inputsData,
        resultsData: resultsData,
      );

      await GenerationHistoryService.addHistoryItem(historyData);
    } catch (e) {
      debugPrint('Error saving BMI history: $e');
      rethrow;
    }
  }

  static Future<void> removeFromHistory(String id) async {
    try {
      final isar = IsarService.isar;
      final entryId = int.tryParse(id);
      if (entryId != null) {
        await isar.writeTxn(() async {
          await isar.unifiedHistoryDatas.delete(entryId);
        });
      }
    } catch (e) {
      debugPrint('Error removing BMI history: $e');
      rethrow;
    }
  }

  static Future<void> clearHistory() async {
    try {
      await GenerationHistoryService.clearHistory('bmi_calculator');
    } catch (e) {
      debugPrint('Error clearing BMI history: $e');
      rethrow;
    }
  }

  // Preferences management (This is now the single source of truth)
  static Future<Map<String, dynamic>> getPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'unitSystem': prefs.getInt('bmi_unitSystem') ?? UnitSystem.metric.index,
        'autoSaveToHistory': prefs.getBool('bmi_autoSaveToHistory') ?? false,
        'rememberLastValues': prefs.getBool('bmi_rememberLastValues') ?? true,
        'lastHeight': prefs.getDouble('bmi_lastHeight'),
        'lastWeight': prefs.getDouble('bmi_lastWeight'),
        'lastAgeGroup': prefs.getInt('bmi_lastAgeGroup'),
        'lastGender': prefs.getInt('bmi_lastGender'),
      };
    } catch (e) {
      debugPrint('Error loading BMI preferences: $e');
      return {
        'unitSystem': UnitSystem.metric.index,
        'rememberLastValues': true,
        'autoSaveToHistory': false,
      };
    }
  }

  static Future<void> savePreferences(Map<String, dynamic> preferences) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      for (final entry in preferences.entries) {
        final value = entry.value;
        if (value is int) {
          await prefs.setInt('bmi_${entry.key}', value);
        } else if (value is double) {
          await prefs.setDouble('bmi_${entry.key}', value);
        } else if (value is bool) {
          await prefs.setBool('bmi_${entry.key}', value);
        } else if (value is String) {
          await prefs.setString('bmi_${entry.key}', value);
        }
      }
    } catch (e) {
      debugPrint('Error saving BMI preferences: $e');
      rethrow;
    }
  }

  static Future<void> clearPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('bmi_unitSystem');
      await prefs.remove('bmi_autoSaveToHistory');
      await prefs.remove('bmi_rememberLastValues');
      await prefs.remove('bmi_lastHeight');
      await prefs.remove('bmi_lastWeight');
      await prefs.remove('bmi_lastAgeGroup');
      await prefs.remove('bmi_lastGender');
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

  // State management for calculator inputs
  static Future<Map<String, dynamic>?> getCalculatorState() async {
    try {
      final state = await CalculatorToolsService.getToolState(_toolId);
      return state;
    } catch (e) {
      debugPrint('Error loading BMI calculator state: $e');
      return null;
    }
  }

  static Future<void> saveCalculatorState({
    required double? height,
    required double? weight,
    required AgeGroup ageGroup,
    required UnitSystem unitSystem,
    required Gender gender,
    BmiCalculation? lastCalculation,
  }) async {
    try {
      final state = {
        'height': height,
        'weight': weight,
        'ageGroup': ageGroup.index,
        'unitSystem': unitSystem.index,
        'gender': gender.index,
        'lastCalculation': lastCalculation != null
            ? {
                'bmi': lastCalculation.bmi,
                'category': lastCalculation.category.index,
                'interpretation': lastCalculation.interpretation,
              }
            : null,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      };

      await CalculatorToolsService.saveToolState(_toolId, state);
    } catch (e) {
      debugPrint('Error saving BMI calculator state: $e');
      rethrow;
    }
  }

  static Future<void> clearCalculatorState() async {
    try {
      await CalculatorToolsService.clearToolState(_toolId);
    } catch (e) {
      debugPrint('Error clearing BMI calculator state: $e');
      rethrow;
    }
  }

  // BMI info and educational content
  static List<Map<String, dynamic>> getBmiRanges(AppLocalizations l10n) {
    return getBmiRangesForAgeGroup(
        l10n, AgeGroup.adult18Plus); // Default to adult
  }

  static List<Map<String, dynamic>> getBmiRangesForAgeGroup(
      AppLocalizations l10n, AgeGroup ageGroup) {
    if (ageGroup == AgeGroup.under18) {
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

  static String getBmiRangeTitle(AppLocalizations l10n, AgeGroup ageGroup) {
    return ageGroup == AgeGroup.under18
        ? l10n.bmiPediatricTitle
        : l10n.bmiAdultTitle;
  }

  static String getBmiRangeNote(AppLocalizations l10n, AgeGroup ageGroup) {
    return ageGroup == AgeGroup.under18
        ? l10n.bmiPercentileNote
        : 'Tiêu chuẩn WHO cho người trưởng thành (18+ tuổi)';
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
