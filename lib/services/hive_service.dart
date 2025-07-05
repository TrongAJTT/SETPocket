// import 'dart:io';
// import 'package:hive/hive.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:setpocket/services/app_logger.dart';
// import 'package:setpocket/services/app_installation_service.dart';

// TEMPORARILY DISABLED DURING HIVE -> ISAR MIGRATION
class HiveService {
  /// Initialize Hive database with custom path - DISABLED
  static Future<void> initialize() async {
    logInfo('HiveService: Initialize called - DISABLED during Isar migration');
  }

  /// All other methods - DISABLED during migration
  static Future<void> closeAll() async {
    logInfo('HiveService: CloseAll called - DISABLED during Isar migration');
  }

  static Future<void> clearBox(String boxName) async {
    logInfo('HiveService: ClearBox called - DISABLED during Isar migration');
  }

  static Future<int> getBoxSize(String boxName) async {
    logInfo('HiveService: GetBoxSize called - DISABLED during Isar migration');
    return 0;
  }

  static int getBoxItemCount(String boxName) {
    logInfo('HiveService: GetBoxItemCount called - DISABLED during Isar migration');
    return 0;
  }

  static bool get isInitialized => false; // Always false during migration

  static Future<String> getHivePath() async {
    logInfo('HiveService: GetHivePath called - DISABLED during Isar migration');
    return 'DISABLED';
  }

  static Future<Map<String, dynamic>> getStorageInfo() async {
    logInfo('HiveService: GetStorageInfo called - DISABLED during Isar migration');
    return {'status': 'DISABLED during Isar migration'};
  }
}
