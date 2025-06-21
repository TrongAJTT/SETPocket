import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:setpocket/services/network_security_service.dart';
import 'package:setpocket/services/app_logger.dart';

class NetworkDebugUtils {
  /// Debug network connectivity and log detailed information
  static Future<void> debugNetworkConnectivity() async {
    try {
      AppLogger.instance.info('=== Network Debug Started ===');

      // Test basic connectivity
      final connectivity = Connectivity();
      final results = await connectivity.checkConnectivity();

      AppLogger.instance.info('Connectivity Results: $results');

      for (final result in results) {
        AppLogger.instance.info('- ${result.toString()}');

        switch (result) {
          case ConnectivityResult.wifi:
            AppLogger.instance.info('  → WiFi connection detected');
            break;
          case ConnectivityResult.mobile:
            AppLogger.instance.info('  → Mobile data connection detected');
            break;
          case ConnectivityResult.ethernet:
            AppLogger.instance.info('  → Ethernet connection detected');
            break;
          case ConnectivityResult.none:
            AppLogger.instance.info('  → No connection');
            break;
          default:
            AppLogger.instance.info('  → Other connection type: $result');
        }
      }

      // Test our network security service
      AppLogger.instance.info('\n=== Testing NetworkSecurityService ===');

      final networkInfo = await NetworkSecurityService.checkNetworkSecurity();

      AppLogger.instance.info('NetworkInfo Results:');
      AppLogger.instance.info('- isWiFi: ${networkInfo.isWiFi}');
      AppLogger.instance.info('- isMobile: ${networkInfo.isMobile}');
      AppLogger.instance.info('- isSecure: ${networkInfo.isSecure}');
      AppLogger.instance.info('- securityType: ${networkInfo.securityType}');
      AppLogger.instance.info('- securityLevel: ${networkInfo.securityLevel}');
      AppLogger.instance.info('- wifiName: ${networkInfo.wifiName}');
      AppLogger.instance.info('- wifiSSID: ${networkInfo.wifiSSID}');
      AppLogger.instance.info('- ipAddress: ${networkInfo.ipAddress}');
      AppLogger.instance
          .info('- gatewayAddress: ${networkInfo.gatewayAddress}');
      AppLogger.instance
          .info('- signalStrength: ${networkInfo.signalStrength}');

      // Check if suitable for P2P
      final isP2PReady =
          await NetworkSecurityService.isNetworkAvailableForP2P();
      AppLogger.instance.info('- isP2PReady: $isP2PReady');

      AppLogger.instance.info('=== Network Debug Completed ===');
    } catch (e, stackTrace) {
      AppLogger.instance.error('Error in network debug: $e');
      AppLogger.instance.error('Stack trace: $stackTrace');
    }
  }

  /// Get a human-readable network status
  static Future<String> getNetworkStatusDescription() async {
    try {
      final connectivity = Connectivity();
      final results = await connectivity.checkConnectivity();

      if (results.isEmpty || results.contains(ConnectivityResult.none)) {
        return 'No network connection';
      }

      final types = results.map((r) => r.toString().split('.').last).join(', ');
      return 'Connected via: $types';
    } catch (e) {
      return 'Error checking network: $e';
    }
  }
}
