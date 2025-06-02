import 'dart:math';
import 'package:flutter/material.dart';

/// Utility class for all random generation functionality
class RandomGenerator {
  static final Random _random = Random();

  // Password generator
  static String generatePassword({
    required int length,
    required bool includeLowercase,
    required bool includeUppercase,
    required bool includeNumbers,
    required bool includeSpecial,
  }) {
    // At least one category should be selected
    if (!includeLowercase &&
        !includeUppercase &&
        !includeNumbers &&
        !includeSpecial) {
      throw ArgumentError('At least one character set must be selected');
    }

    final lowercase = 'abcdefghijklmnopqrstuvwxyz';
    final uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final numbers = '0123456789';
    final special = '!@#\$%^&*()-_=+[]{}|;:,.<>?/';

    String allowedChars = '';
    if (includeLowercase) allowedChars += lowercase;
    if (includeUppercase) allowedChars += uppercase;
    if (includeNumbers) allowedChars += numbers;
    if (includeSpecial) allowedChars += special;

    if (allowedChars.isEmpty) {
      return '';
    }

    StringBuffer password = StringBuffer();
    for (int i = 0; i < length; i++) {
      int randomIndex = _random.nextInt(allowedChars.length);
      password.write(allowedChars[randomIndex]);
    }

    return password.toString();
  }

  // Number generator
  static List<num> generateNumbers({
    required bool isInteger,
    required num min,
    required num max,
    required int count,
    required bool allowDuplicates,
  }) {
    if (min > max) {
      throw ArgumentError(
          'Minimum value must be less than or equal to maximum value');
    }

    if (count <= 0) {
      return [];
    }

    // If not allowing duplicates, check if we can generate enough unique numbers
    if (!allowDuplicates) {
      int possibleUniqueValues;
      if (isInteger) {
        possibleUniqueValues = (max.toInt() - min.toInt() + 1);
      } else {
        // For floating point, there's virtually infinite values between min and max
        possibleUniqueValues = count; // Just set to count to allow it
      }

      if (count > possibleUniqueValues) {
        throw ArgumentError(
            'Cannot generate $count unique numbers in range $min to $max');
      }
    }

    List<num> numbers = [];

    if (allowDuplicates) {
      for (int i = 0; i < count; i++) {
        if (isInteger) {
          numbers.add(min.toInt() + _random.nextInt((max - min).toInt() + 1));
        } else {
          numbers.add(min + _random.nextDouble() * (max - min));
        }
      }
    } else {
      // Generate unique numbers
      Set<num> uniqueNumbers = {};
      while (uniqueNumbers.length < count) {
        if (isInteger) {
          uniqueNumbers
              .add(min.toInt() + _random.nextInt((max - min).toInt() + 1));
        } else {
          uniqueNumbers.add(min + _random.nextDouble() * (max - min));
        }
      }
      numbers = uniqueNumbers.toList();
    }

    return numbers;
  }

  // Yes or No
  static bool generateYesNo() {
    return _random.nextBool();
  }

  // Coin flip
  static bool generateCoinFlip() {
    return _random.nextBool(); // true = heads, false = tails
  }

  // Rock-Paper-Scissors
  static int generateRockPaperScissors() {
    return _random.nextInt(3); // 0: Rock, 1: Paper, 2: Scissors
  }

  // Dice roll
  static List<int> generateDiceRolls({required int count, required int sides}) {
    if (count <= 0) {
      return [];
    }

    if (sides <= 0) {
      throw ArgumentError('Dice must have at least 1 side');
    }

    List<int> rolls = [];
    for (int i = 0; i < count; i++) {
      rolls.add(1 + _random.nextInt(sides));
    }

    return rolls;
  }

  // Color generator
  static Color generateColor({bool withAlpha = false}) {
    int r = _random.nextInt(256);
    int g = _random.nextInt(256);
    int b = _random.nextInt(256);
    int a = withAlpha ? _random.nextInt(256) : 255;

    return Color.fromARGB(a, r, g, b);
  }

  // Latin letter generator
  static String generateLatinLetters(int count) {
    if (count <= 0) {
      return '';
    }

    const String letters =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    StringBuffer result = StringBuffer();

    for (int i = 0; i < count; i++) {
      result.write(letters[_random.nextInt(letters.length)]);
    }

    return result.toString();
  }

  // Playing cards generator
  static List<String> generatePlayingCards(int count) {
    if (count <= 0) {
      return [];
    }

    final suits = ['♠', '♥', '♦', '♣'];
    final ranks = [
      'A',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      'J',
      'Q',
      'K'
    ];

    // Create standard deck of 52 cards
    List<String> deck = [];
    for (var suit in suits) {
      for (var rank in ranks) {
        deck.add('$rank$suit');
      }
    }

    // Shuffle the deck
    deck.shuffle(_random);

    // Return requested number of cards, but limit to 52 (standard deck)
    count = count > 52 ? 52 : count;
    return deck.sublist(0, count);
  }

  // Date generator
  static List<DateTime> generateRandomDates({
    required DateTime startDate,
    required DateTime endDate,
    required int count,
    required bool allowDuplicates,
  }) {
    if (startDate.isAfter(endDate)) {
      throw ArgumentError('Start date must be before end date');
    }

    if (count <= 0) {
      return [];
    }

    final int rangeDays = endDate.difference(startDate).inDays;

    // Check if we can generate enough unique dates
    if (!allowDuplicates && count > rangeDays + 1) {
      throw ArgumentError('Cannot generate $count unique dates in range');
    }

    List<DateTime> dates = [];

    if (allowDuplicates) {
      for (int i = 0; i < count; i++) {
        final daysToAdd = _random.nextInt(rangeDays + 1);
        dates.add(startDate.add(Duration(days: daysToAdd)));
      }
    } else {
      // Generate unique dates
      Set<int> uniqueDays = {};
      while (uniqueDays.length < count) {
        uniqueDays.add(_random.nextInt(rangeDays + 1));
      }

      for (int days in uniqueDays) {
        dates.add(startDate.add(Duration(days: days)));
      }
    }

    return dates;
  }

  // Time generator
  static List<TimeOfDay> generateRandomTimes({
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int count,
    required bool allowDuplicates,
  }) {
    // Convert TimeOfDay to minutes for easier comparison
    int startMinutes = startTime.hour * 60 + startTime.minute;
    int endMinutes = endTime.hour * 60 + endTime.minute;

    // Adjust if end is before start (crossing midnight)
    if (endMinutes < startMinutes) {
      endMinutes += 24 * 60; // Add a full day
    }

    int rangeMinutes = endMinutes - startMinutes;

    // Check if we can generate enough unique times
    if (!allowDuplicates && count > rangeMinutes + 1) {
      throw ArgumentError('Cannot generate $count unique times in range');
    }

    if (count <= 0) {
      return [];
    }

    List<TimeOfDay> times = [];

    if (allowDuplicates) {
      for (int i = 0; i < count; i++) {
        final minutesToAdd = _random.nextInt(rangeMinutes + 1);
        final totalMinutes = (startMinutes + minutesToAdd) % (24 * 60);
        times.add(
            TimeOfDay(hour: totalMinutes ~/ 60, minute: totalMinutes % 60));
      }
    } else {
      // Generate unique times
      Set<int> uniqueMinutes = {};
      while (uniqueMinutes.length < count) {
        uniqueMinutes.add(_random.nextInt(rangeMinutes + 1));
      }

      for (int minutes in uniqueMinutes) {
        final totalMinutes = (startMinutes + minutes) % (24 * 60);
        times.add(
            TimeOfDay(hour: totalMinutes ~/ 60, minute: totalMinutes % 60));
      }
    }

    return times;
  }

  // Date and Time generator
  static List<DateTime> generateRandomDateTimes({
    required DateTime startDateTime,
    required DateTime endDateTime,
    required int count,
    required bool allowDuplicates,
  }) {
    if (startDateTime.isAfter(endDateTime)) {
      throw ArgumentError('Start datetime must be before end datetime');
    }

    if (count <= 0) {
      return [];
    }

    int rangeSeconds = endDateTime.difference(startDateTime).inSeconds;

    // For date times, there are so many possible values that duplicates are very unlikely
    // So we'll just generate random times
    List<DateTime> dateTimes = [];

    for (int i = 0; i < count; i++) {
      final secondsToAdd = _random.nextInt(rangeSeconds + 1);
      dateTimes.add(startDateTime.add(Duration(seconds: secondsToAdd)));
    }

    if (!allowDuplicates && dateTimes.length != count) {
      // In the extremely unlikely case of duplicates, recursively call again
      return generateRandomDateTimes(
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        count: count,
        allowDuplicates: allowDuplicates,
      );
    }

    return dateTimes;
  }
}
