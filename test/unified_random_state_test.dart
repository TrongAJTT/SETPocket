import 'package:flutter_test/flutter_test.dart';
import 'package:setpocket/models/random_models/unified_random_state.dart';
import 'package:setpocket/models/random_models/random_state_models.dart';
import 'dart:convert';

void main() {
  group('UnifiedRandomState Tests', () {
    test('should create UnifiedRandomState with correct data', () {
      final testData = {'test': 'value', 'number': 42};
      final state = UnifiedRandomState.create(
        toolId: RandomToolIds.password,
        stateData: jsonEncode(testData),
      );

      expect(state.toolId, equals(RandomToolIds.password));
      expect(state.getStateAsMap(), equals(testData));
      expect(state.version, equals(1));
    });

    test('should handle JSON serialization correctly', () {
      final state = UnifiedRandomState();
      final testData = {
        'passwordLength': 16,
        'includeUppercase': true,
        'includeNumbers': false,
      };

      state.setStateFromMap(testData);

      expect(state.getStateAsMap(), equals(testData));
      expect(state.stateData, contains('passwordLength'));
      expect(state.stateData, contains('16'));
    });

    test('should handle empty/invalid JSON gracefully', () {
      final state = UnifiedRandomState.create(
        toolId: 'test',
        stateData: 'invalid json',
      );

      expect(state.getStateAsMap(), equals({}));
    });

    test('should update lastUpdated when setting state', () {
      final state = UnifiedRandomState();
      final originalTime = state.lastUpdated;

      // Wait a bit to ensure time difference
      Future.delayed(const Duration(milliseconds: 1), () {
        state.setStateFromMap({'test': 'value'});
        expect(state.lastUpdated.isAfter(originalTime), isTrue);
      });
    });

    test('should contain all expected tool IDs', () {
      final allIds = RandomToolIds.getAllToolIds();

      expect(allIds, contains(RandomToolIds.password));
      expect(allIds, contains(RandomToolIds.number));
      expect(allIds, contains(RandomToolIds.latinLetter));
      expect(allIds, contains(RandomToolIds.diceRoll));
      expect(allIds, contains(RandomToolIds.playingCard));
      expect(allIds, contains(RandomToolIds.color));
      expect(allIds, contains(RandomToolIds.date));
      expect(allIds, contains(RandomToolIds.time));
      expect(allIds, contains(RandomToolIds.dateTime));
      expect(allIds, contains(RandomToolIds.uuid));
      expect(allIds, contains(RandomToolIds.coinFlip));
      expect(allIds, contains(RandomToolIds.yesNo));
      expect(allIds, contains(RandomToolIds.rockPaperScissors));

      expect(allIds.length, equals(13));
    });

    test('should create copyWith correctly', () {
      final original = UnifiedRandomState.create(
        toolId: RandomToolIds.password,
        stateData: '{"test": "original"}',
      );

      final copy = original.copyWith(
        toolId: RandomToolIds.number,
        stateData: '{"test": "modified"}',
      );

      expect(copy.toolId, equals(RandomToolIds.number));
      expect(copy.stateData, equals('{"test": "modified"}'));
      expect(copy.version, equals(original.version));
    });
  });

  group('RandomStateModels Integration Tests', () {
    test('should convert PasswordGeneratorState to/from JSON correctly', () {
      final original = PasswordGeneratorState.createDefault()
        ..passwordLength = 20
        ..includeUppercase = false
        ..includeSpecial = true;

      final json = original.toJson();
      final restored = PasswordGeneratorState.fromJson(json);

      expect(restored.passwordLength, equals(20));
      expect(restored.includeUppercase, equals(false));
      expect(restored.includeSpecial, equals(true));
    });

    test('should convert NumberGeneratorState to/from JSON correctly', () {
      final original = NumberGeneratorState.createDefault()
        ..isInteger = false
        ..minValue = 5.5
        ..maxValue = 99.9
        ..quantity = 10
        ..allowDuplicates = false;

      final json = original.toJson();
      final restored = NumberGeneratorState.fromJson(json);

      expect(restored.isInteger, equals(false));
      expect(restored.minValue, equals(5.5));
      expect(restored.maxValue, equals(99.9));
      expect(restored.quantity, equals(10));
      expect(restored.allowDuplicates, equals(false));
    });

    test('should handle LatinLetterGeneratorState with new fields correctly',
        () {
      final state = LatinLetterGeneratorState()
        ..uppercase = true
        ..lowercase = false
        ..quantity = 10
        ..allowDuplicates = false
        ..skipAnimation = true
        ..lastUpdated = DateTime.now();

      final json = state.toJson();
      expect(json['uppercase'], true);
      expect(json['lowercase'], false);
      expect(json['quantity'], 10);
      expect(json['allowDuplicates'], false);
      expect(json['skipAnimation'], true);

      final stateFromJson = LatinLetterGeneratorState.fromJson(json);
      expect(stateFromJson.uppercase, true);
      expect(stateFromJson.lowercase, false);
      expect(stateFromJson.quantity, 10);
      expect(stateFromJson.allowDuplicates, false);
      expect(stateFromJson.skipAnimation, true);
    });

    test('should handle TimeGeneratorState with includeSeconds correctly', () {
      final state = TimeGeneratorState()
        ..startHour = 9
        ..startMinute = 30
        ..endHour = 17
        ..endMinute = 45
        ..timeCount = 3
        ..allowDuplicates = false
        ..includeSeconds = true
        ..lastUpdated = DateTime.now();

      final json = state.toJson();
      expect(json['includeSeconds'], true);

      final stateFromJson = TimeGeneratorState.fromJson(json);
      expect(stateFromJson.includeSeconds, true);
      expect(stateFromJson.startHour, 9);
      expect(stateFromJson.timeCount, 3);
    });

    test('should handle DateTimeGeneratorState with includeSeconds correctly',
        () {
      final now = DateTime.now();
      final state = DateTimeGeneratorState()
        ..startDateTime = now.subtract(const Duration(days: 10))
        ..endDateTime = now.add(const Duration(days: 10))
        ..dateTimeCount = 3
        ..allowDuplicates = false
        ..includeSeconds = true
        ..lastUpdated = now;

      final json = state.toJson();
      expect(json['includeSeconds'], true);

      final stateFromJson = DateTimeGeneratorState.fromJson(json);
      expect(stateFromJson.includeSeconds, true);
      expect(stateFromJson.dateTimeCount, 3);
      expect(stateFromJson.allowDuplicates, false);
    });

    test('should use default values for new fields when missing from JSON', () {
      // Test LatinLetterGeneratorState without new fields
      final latinJson = {
        'uppercase': true,
        'quantity': 5,
        'allowDuplicates': true,
      };
      final latinState = LatinLetterGeneratorState.fromJson(latinJson);
      expect(latinState.lowercase, true); // default value
      expect(latinState.skipAnimation, false); // default value

      // Test TimeGeneratorState without includeSeconds
      final timeJson = {
        'startHour': 10,
        'startMinute': 0,
        'endHour': 18,
        'endMinute': 30,
        'timeCount': 5,
        'allowDuplicates': true,
      };
      final timeState = TimeGeneratorState.fromJson(timeJson);
      expect(timeState.includeSeconds, false); // default value

      // Test DateTimeGeneratorState without includeSeconds
      final dateTimeJson = {
        'startDateTime': DateTime.now()
            .subtract(const Duration(days: 365))
            .toIso8601String(),
        'endDateTime':
            DateTime.now().add(const Duration(days: 365)).toIso8601String(),
        'dateTimeCount': 5,
        'allowDuplicates': true,
      };
      final dateTimeState = DateTimeGeneratorState.fromJson(dateTimeJson);
      expect(dateTimeState.includeSeconds, false); // default value
    });
  });
}
