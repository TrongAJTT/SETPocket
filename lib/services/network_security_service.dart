import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart' as network_info_plus;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:setpocket/models/p2p_models.dart';
import 'package:setpocket/services/app_logger.dart';

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
            final hasInternet = result['hasInternet'] as bool? ?? false;

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
      // Try to get detailed WiFi info from native platform first
      if (Platform.isAndroid || Platform.isWindows) {
        try {
          final result = await _channel.invokeMethod('checkWifiSecurity');
          if (result is Map) {
            final hasPermission = result['hasPermission'] as bool? ?? false;
            if (hasPermission) {
              final isConnected = result['isConnected'] as bool? ?? false;
              final isWiFi = result['isWiFi'] as bool? ?? false;

              if (isConnected && isWiFi) {
                final ssid = result['ssid'] as String?;
                final securityType = result['securityType'] as String?;
                final isSecure = result['isSecure'] as bool? ?? false;
                final ipAddress = result['ipAddress'] as String?;
                final signalLevel = result['signalLevel'] as int? ?? 0;

                return NetworkInfo(
                  wifiName: ssid,
                  wifiSSID: ssid,
                  ipAddress: ipAddress,
                  isWiFi: true,
                  isMobile: false,
                  isSecure: isSecure,
                  securityLevel: isSecure
                      ? NetworkSecurityLevel.secure
                      : NetworkSecurityLevel.unsecure,
                  signalStrength: signalLevel,
                  securityType: securityType,
                );
              }
            }
          }
        } catch (e) {
          AppLogger.instance.warning('Failed to get native WiFi info: $e');
        }
      }

      // Fallback to standard method
      // Request location permission for WiFi info on Android
      if (Platform.isAndroid) {
        final status = await Permission.locationWhenInUse.request();
        if (!status.isGranted) {
          AppLogger.instance.warning(
              'Location permission denied, cannot get WiFi security info');
          return NetworkInfo(
            isWiFi: true,
            isMobile: false,
            isSecure: false,
            securityLevel: NetworkSecurityLevel.unknown,
          );
        }
      }

      final wifiName = await _networkInfo.getWifiName();
      final wifiSSID = await _networkInfo.getWifiBSSID();
      final ipAddress = await _networkInfo.getWifiIP();
      final gatewayAddress = await _networkInfo.getWifiGatewayIP();

      // Check WiFi security using platform-specific methods
      bool isSecure = false;
      if (Platform.isAndroid) {
        isSecure = await _checkAndroidWiFiSecurity();
      } else if (Platform.isWindows) {
        isSecure = await _checkWindowsWiFiSecurity();
      }

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

  static Future<bool> _checkAndroidWiFiSecurity() async {
    try {
      // Use native Android method to check WiFi security
      final result = await _channel.invokeMethod('checkWifiSecurity');
      if (result is Map) {
        final hasPermission = result['hasPermission'] as bool? ?? false;
        if (!hasPermission) {
          AppLogger.instance.warning('WiFi permission not granted');
          return false;
        }

        final isConnected = result['isConnected'] as bool? ?? false;
        final isWiFi = result['isWiFi'] as bool? ?? false;
        final isSecure = result['isSecure'] as bool? ?? false;

        if (isConnected && isWiFi) {
          final securityType = result['securityType'] as String? ?? 'UNKNOWN';
          final ssid = result['ssid'] as String? ?? 'Unknown';

          AppLogger.instance
              .info('WiFi Security: $securityType for network: $ssid');
          return isSecure;
        }
      }
      return false;
    } catch (e) {
      AppLogger.instance.error('Error checking Android WiFi security: $e');
      // Fallback to basic check
      try {
        final wifiName = await _networkInfo.getWifiName();
        return wifiName != null && wifiName.isNotEmpty;
      } catch (fallbackError) {
        return false;
      }
    }
  }

  static Future<bool> _checkWindowsWiFiSecurity() async {
    try {
      // Use native Windows method to check WiFi security
      final result = await _channel.invokeMethod('checkWifiSecurity');
      if (result is Map) {
        final hasPermission = result['hasPermission'] as bool? ?? false;
        if (!hasPermission) {
          AppLogger.instance.warning('WiFi permission not granted');
          return false;
        }

        final isConnected = result['isConnected'] as bool? ?? false;
        final isWiFi = result['isWiFi'] as bool? ?? false;
        final isSecure = result['isSecure'] as bool? ?? false;

        if (isConnected && isWiFi) {
          final securityType = result['securityType'] as String? ?? 'UNKNOWN';
          final ssid = result['ssid'] as String? ?? 'Unknown';

          AppLogger.instance
              .info('Windows WiFi Security: $securityType for network: $ssid');
          return isSecure;
        }
      }
      return false;
    } catch (e) {
      AppLogger.instance.error('Error checking Windows WiFi security: $e');
      // Fallback to basic check
      try {
        final wifiName = await _networkInfo.getWifiName();
        return wifiName != null && wifiName.isNotEmpty;
      } catch (fallbackError) {
        return false;
      }
    }
  }

  /// Get device unique identifier
  static Future<String> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        return windowsInfo.computerName;
      } else {
        return 'unknown_device';
      }
    } catch (e) {
      AppLogger.instance.error('Error getting device ID: $e');
      return 'unknown_device_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Get device display name
  static Future<String> getDeviceName() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return '${androidInfo.brand} ${androidInfo.model}';
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

  /// Check if required permissions are granted
  static Future<bool> checkPermissions() async {
    try {
      if (Platform.isAndroid) {
        // We only need Location for WiFi scanning and Nearby Devices for modern Android.
        // Storage permissions should be requested on-demand when sending a file.
        final permissionsToRequest = <Permission>[];

        if (await Permission.locationWhenInUse.isDenied) {
          permissionsToRequest.add(Permission.locationWhenInUse);
        }

        // For Android 12 (SDK 31) and above, NEARBY_WIFI_DEVICES is needed.
        // permission_handler handles the platform version check internally.
        if (await Permission.nearbyWifiDevices.isDenied) {
          permissionsToRequest.add(Permission.nearbyWifiDevices);
        }

        if (permissionsToRequest.isNotEmpty) {
          final statuses = await permissionsToRequest.request();
          // Check if all requested permissions were granted.
          return statuses.values.every((status) => status.isGranted);
        }
      }
      // If no permissions needed to be requested, or not on Android, return true.
      return true;
    } catch (e) {
      AppLogger.instance.error('Error checking permissions: $e');
      return false;
    }
  }

  /// Request required permissions
  static Future<Map<Permission, PermissionStatus>> requestPermissions() async {
    if (Platform.isAndroid) {
      final permissions = [
        Permission.storage,
        Permission.manageExternalStorage,
        Permission.locationWhenInUse,
        Permission.nearbyWifiDevices,
      ];

      return await permissions.request();
    }
    return {};
  }

  /// Get local IP address
  static Future<String?> getLocalIpAddress() async {
    try {
      return await _networkInfo.getWifiIP();
    } catch (e) {
      AppLogger.instance.error('Error getting local IP: $e');
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
}
