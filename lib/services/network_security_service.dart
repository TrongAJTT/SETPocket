import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart' as network_info_plus;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:setpocket/models/p2p_models.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/services/app_installation_service.dart';

class NetworkSecurityService {
  static final network_info_plus.NetworkInfo _networkInfo =
      network_info_plus.NetworkInfo();
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static const MethodChannel _channel =
      MethodChannel('com.setpocket.app/network_security');

  /// Check current network security level
  static Future<NetworkInfo> checkNetworkSecurity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult.contains(ConnectivityResult.mobile)) {
        // Mobile data is considered secure (carrier handles security)
        return NetworkInfo(
          isWiFi: false,
          isMobile: true,
          isSecure: true,
          securityLevel: NetworkSecurityLevel.secure,
        );
      }

      if (connectivityResult.contains(ConnectivityResult.wifi)) {
        final wifiInfo = await _getWiFiInfo();
        return wifiInfo;
      }

      if (connectivityResult.contains(ConnectivityResult.ethernet)) {
        // Ethernet is generally secure (physical connection required)
        return await _getEthernetInfo();
      }

      // No connection or unknown type
      return NetworkInfo(
        isWiFi: false,
        isMobile: false,
        isSecure: false,
        securityLevel: NetworkSecurityLevel.unknown,
      );
    } catch (e) {
      AppLogger.instance.error('Error checking network security: $e');
      return NetworkInfo(
        isWiFi: false,
        isMobile: false,
        isSecure: false,
        securityLevel: NetworkSecurityLevel.unknown,
      );
    }
  }

  static Future<NetworkInfo> _getEthernetInfo() async {
    try {
      // Try to get detailed network info from native platform first
      if (Platform.isAndroid || Platform.isWindows) {
        try {
          final result = await _channel.invokeMethod('getNetworkInfo');
          if (result is Map) {
            final isConnected = result['isConnected'] as bool? ?? false;
            final isEthernet = result['isEthernet'] as bool? ?? false;

            if (isConnected && isEthernet) {
              final ipAddress = result['ipAddress'] as String?;
              final gatewayAddress = result['gatewayAddress'] as String?;

              return NetworkInfo(
                ipAddress: ipAddress,
                gatewayAddress: gatewayAddress,
                isWiFi: false,
                isMobile: false,
                isSecure: true, // Ethernet is secure (physical connection)
                securityLevel: NetworkSecurityLevel.secure,
                securityType: 'ETHERNET',
              );
            }
          }
        } catch (e) {
          AppLogger.instance.warning('Failed to get native network info: $e');
        }
      }

      // Fallback - basic ethernet info
      final ipAddress =
          await _networkInfo.getWifiIP(); // This works for ethernet too
      final gatewayAddress = await _networkInfo.getWifiGatewayIP();

      return NetworkInfo(
        ipAddress: ipAddress,
        gatewayAddress: gatewayAddress,
        isWiFi: false,
        isMobile: false,
        isSecure: true, // Ethernet connections are generally secure
        securityLevel: NetworkSecurityLevel.secure,
        securityType: 'ETHERNET',
      );
    } catch (e) {
      AppLogger.instance.error('Error getting Ethernet info: $e');
      return NetworkInfo(
        isWiFi: false,
        isMobile: false,
        isSecure: true, // Default to secure for ethernet
        securityLevel: NetworkSecurityLevel.secure,
        securityType: 'ETHERNET',
      );
    }
  }

  static Future<NetworkInfo> _getWiFiInfo() async {
    try {
      // Try to get WiFi security info from native platform first (Android)
      bool isSecure = true;
      String securityType = 'UNKNOWN';

      if (Platform.isAndroid) {
        try {
          final result = await _channel.invokeMethod('getWifiSecurityInfo');
          if (result is Map) {
            isSecure = result['isSecure'] as bool? ?? true;
            securityType = result['securityType'] as String? ?? 'UNKNOWN';
            logInfo(
                'Native WiFi security check: secure=$isSecure, type=$securityType');
          }
        } catch (e) {
          logWarning('Failed to get native WiFi security info: $e');
          // Fallback to assuming secure
          isSecure = true;
        }
      }

      // Get standard WiFi info
      final wifiName = await _networkInfo.getWifiName();
      final wifiSSID = await _networkInfo.getWifiBSSID();
      final ipAddress = await _networkInfo.getWifiIP();
      final gatewayAddress = await _networkInfo.getWifiGatewayIP();

      return NetworkInfo(
        wifiName: wifiName,
        wifiSSID: wifiSSID,
        ipAddress: ipAddress,
        gatewayAddress: gatewayAddress,
        isWiFi: true,
        isMobile: false,
        isSecure: isSecure,
        securityLevel: isSecure
            ? NetworkSecurityLevel.secure
            : NetworkSecurityLevel.unsecure,
        securityType: securityType,
      );
    } catch (e) {
      AppLogger.instance.error('Error getting WiFi info: $e');
      return NetworkInfo(
        isWiFi: true,
        isMobile: false,
        isSecure: false,
        securityLevel: NetworkSecurityLevel.unknown,
      );
    }
  }

  /// Get stable app installation ID (replaces device ID with app-specific stable identifier)
  static Future<String> getAppInstallationId() async {
    try {
      return await AppInstallationService.instance.getAppInstallationId();
    } catch (e) {
      AppLogger.instance.error('Failed to get app installation ID: $e');
      return 'TEMP${DateTime.now().millisecondsSinceEpoch % 1000000}';
    }
  }

  /// Get readable app installation ID
  static Future<String> getReadableAppInstallationId() async {
    return AppInstallationService.instance.getAppInstallationWordId();
  }

  /// Get device display name
  static Future<String> getDeviceName() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.model;
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        return windowsInfo.computerName;
      } else {
        return 'Unknown Device';
      }
    } catch (e) {
      AppLogger.instance.error('Error getting device name: $e');
      return 'Unknown Device';
    }
  }

  /// Get local IP address
  static Future<String?> getLocalIpAddress() async {
    try {
      return await _networkInfo.getWifiIP();
    } catch (e) {
      AppLogger.instance.error('Error getting local IP address: $e');
      return null;
    }
  }

  /// Check if network is available for P2P
  static Future<bool> isNetworkAvailableForP2P() async {
    final networkInfo = await checkNetworkSecurity();
    return networkInfo.isWiFi ||
        networkInfo.isMobile ||
        (networkInfo.securityType == 'ETHERNET');
  }

  // Helper methods for logging
  static void logInfo(String message) {
    AppLogger.instance.info('NetworkSecurityService: $message');
  }

  static void logWarning(String message) {
    AppLogger.instance.warning('NetworkSecurityService: $message');
  }
}
