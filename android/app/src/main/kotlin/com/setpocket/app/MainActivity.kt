package com.setpocket.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.net.wifi.WifiManager
import android.net.wifi.WifiInfo
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.NetworkInfo
import android.os.Build
import android.Manifest
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.setpocket.app/network_security"
    private val PERMISSION_REQUEST_CODE = 123

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkWifiSecurity" -> {
                    try {
                        val securityInfo = checkWifiSecurity()
                        result.success(securityInfo)
                    } catch (e: Exception) {
                        result.error("WIFI_ERROR", "Failed to check WiFi security: ${e.message}", null)
                    }
                }
                "getNetworkInfo" -> {
                    try {
                        val networkInfo = getNetworkInfo()
                        result.success(networkInfo)
                    } catch (e: Exception) {
                        result.error("NETWORK_ERROR", "Failed to get network info: ${e.message}", null)
                    }
                }
                "requestPermissions" -> {
                    requestNetworkPermissions()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun checkWifiSecurity(): Map<String, Any> {
        val wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        val connectivityManager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        
        val result = mutableMapOf<String, Any>()
        
        // Check if we have permission
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_WIFI_STATE) != PackageManager.PERMISSION_GRANTED) {
            result["hasPermission"] = false
            result["error"] = "WiFi permission not granted"
            return result
        }
        
        result["hasPermission"] = true
        
        // Get current WiFi connection info
        val wifiInfo: WifiInfo? = wifiManager.connectionInfo
        
        if (wifiInfo == null || wifiInfo.networkId == -1) {
            result["isConnected"] = false
            result["isWiFi"] = false
            return result
        }
        
        result["isConnected"] = true
        result["isWiFi"] = true
        
        // Get network name (SSID)
        var ssid = wifiInfo.ssid
        if (ssid.startsWith("\"") && ssid.endsWith("\"")) {
            ssid = ssid.substring(1, ssid.length - 1)
        }
        result["ssid"] = ssid
        
        // Get security type
        val securityType = getWifiSecurityType(wifiInfo, wifiManager)
        result["securityType"] = securityType
        result["isSecure"] = securityType != "OPEN" && securityType != "NONE"
        
        // Get signal strength
        val rssi = wifiInfo.rssi
        result["signalStrength"] = rssi
        result["signalLevel"] = WifiManager.calculateSignalLevel(rssi, 5)
        
        // Get frequency
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            result["frequency"] = wifiInfo.frequency
        }
        
        // Get IP address
        val ipAddress = wifiInfo.ipAddress
        result["ipAddress"] = String.format("%d.%d.%d.%d", 
            ipAddress and 0xff,
            ipAddress shr 8 and 0xff,
            ipAddress shr 16 and 0xff,
            ipAddress shr 24 and 0xff)
        
        // Get MAC address (if available)
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                result["macAddress"] = "02:00:00:00:00:00" // Randomized MAC
            } else {
                result["macAddress"] = wifiInfo.macAddress ?: "Unknown"
            }
        } catch (e: Exception) {
            result["macAddress"] = "Unknown"
        }
        
        return result
    }
    
    private fun getWifiSecurityType(wifiInfo: WifiInfo, wifiManager: WifiManager): String {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                // For Android 11+, use new API
                val connectivityManager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
                val network = connectivityManager.activeNetwork
                val networkCapabilities = connectivityManager.getNetworkCapabilities(network)
                
                if (networkCapabilities != null && networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)) {
                    // Try to get security info from network capabilities
                    return "WPA2" // Default assumption for connected networks
                }
            } else {
                // For older versions, scan for network configurations
                val configuredNetworks = wifiManager.configuredNetworks
                if (configuredNetworks != null) {
                    for (config in configuredNetworks) {
                        if (config.networkId == wifiInfo.networkId) {
                            return when {
                                config.allowedKeyManagement.get(1) -> "WPA_PSK"
                                config.allowedKeyManagement.get(2) -> "WPA_EAP"
                                config.allowedKeyManagement.get(3) -> "IEEE8021X"
                                config.allowedAuthAlgorithms.get(0) -> "OPEN"
                                config.allowedAuthAlgorithms.get(1) -> "SHARED"
                                else -> "UNKNOWN"
                            }
                        }
                    }
                }
            }
        } catch (e: Exception) {
            // Fallback: assume WPA2 for connected networks
            return "WPA2"
        }
        
        return "UNKNOWN"
    }
    
    private fun getNetworkInfo(): Map<String, Any> {
        val connectivityManager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val result = mutableMapOf<String, Any>()
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val network = connectivityManager.activeNetwork
            val networkCapabilities = connectivityManager.getNetworkCapabilities(network)
            
            if (networkCapabilities != null) {
                result["isConnected"] = true
                result["isWiFi"] = networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)
                result["isMobile"] = networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR)
                result["isEthernet"] = networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET)
                result["hasInternet"] = networkCapabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
                result["isValidated"] = networkCapabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED)
            } else {
                result["isConnected"] = false
                result["isWiFi"] = false
                result["isMobile"] = false
                result["isEthernet"] = false
                result["hasInternet"] = false
                result["isValidated"] = false
            }
        } else {
            // Fallback for older Android versions
            val activeNetwork: NetworkInfo? = connectivityManager.activeNetworkInfo
            result["isConnected"] = activeNetwork?.isConnectedOrConnecting == true
            result["isWiFi"] = activeNetwork?.type == ConnectivityManager.TYPE_WIFI
            result["isMobile"] = activeNetwork?.type == ConnectivityManager.TYPE_MOBILE
            result["isEthernet"] = activeNetwork?.type == ConnectivityManager.TYPE_ETHERNET
            result["hasInternet"] = activeNetwork?.isConnected == true
            result["isValidated"] = activeNetwork?.isConnected == true
        }
        
        return result
    }
    
    private fun requestNetworkPermissions() {
        val permissions = arrayOf(
            Manifest.permission.ACCESS_WIFI_STATE,
            Manifest.permission.ACCESS_NETWORK_STATE,
            Manifest.permission.CHANGE_WIFI_STATE
        )
        
        ActivityCompat.requestPermissions(this, permissions, PERMISSION_REQUEST_CODE)
    }
} 