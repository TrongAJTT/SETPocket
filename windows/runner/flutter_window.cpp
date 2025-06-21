#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"

// Add includes for Windows WiFi API
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <wlanapi.h>
#include <iphlpapi.h>
#include <netlistmgr.h>
#include <comdef.h>

#pragma comment(lib, "wlanapi.lib")
#pragma comment(lib, "iphlpapi.lib")
#pragma comment(lib, "ole32.lib")

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here is arbitrary since we maintain a 1:1 ratio between Pixels
  // and DIPs.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  
  // Register method channel for network security
  SetupMethodChannel();
  
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // callback is called.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}

void FlutterWindow::SetupMethodChannel() {
  const std::string channel_name = "com.setpocket.app/network_security";
  
  auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      flutter_controller_->engine()->messenger(), channel_name,
      &flutter::StandardMethodCodec::GetInstance());

  channel->SetMethodCallHandler([this](const flutter::MethodCall<flutter::EncodableValue>& call,
                                      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    this->HandleMethodCall(call, std::move(result));
  });

  method_channel_ = std::move(channel);
}

void FlutterWindow::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  
  const std::string& method = method_call.method_name();

  if (method == "checkWifiSecurity") {
    auto wifi_info = CheckWifiSecurity();
    result->Success(wifi_info);
  } else if (method == "getNetworkInfo") {
    auto network_info = GetNetworkInfo();
    result->Success(network_info);
  } else if (method == "requestPermissions") {
    // Windows doesn't require special permissions for WiFi info
    result->Success(flutter::EncodableValue(true));
  } else {
    result->NotImplemented();
  }
}

flutter::EncodableValue FlutterWindow::CheckWifiSecurity() {
  flutter::EncodableMap result;
  
  try {
    result[flutter::EncodableValue("hasPermission")] = flutter::EncodableValue(true);
    
    // Initialize WLAN API
    HANDLE hClient = NULL;
    DWORD dwMaxClient = 2;
    DWORD dwCurVersion = 0;
    DWORD dwResult = WlanOpenHandle(dwMaxClient, NULL, &dwCurVersion, &hClient);
    
    if (dwResult != ERROR_SUCCESS) {
      result[flutter::EncodableValue("isConnected")] = flutter::EncodableValue(false);
      result[flutter::EncodableValue("error")] = flutter::EncodableValue("Failed to open WLAN handle");
      return flutter::EncodableValue(result);
    }

    // Get interface list
    PWLAN_INTERFACE_INFO_LIST pIfList = NULL;
    dwResult = WlanEnumInterfaces(hClient, NULL, &pIfList);
    
    if (dwResult != ERROR_SUCCESS || pIfList->dwNumberOfItems == 0) {
      result[flutter::EncodableValue("isConnected")] = flutter::EncodableValue(false);
      result[flutter::EncodableValue("isWiFi")] = flutter::EncodableValue(false);
      WlanCloseHandle(hClient, NULL);
      return flutter::EncodableValue(result);
    }

    // Check first connected interface
    bool foundConnection = false;
    for (DWORD i = 0; i < pIfList->dwNumberOfItems; i++) {
      PWLAN_INTERFACE_INFO pIfInfo = &pIfList->InterfaceInfo[i];
      
      if (pIfInfo->isState == wlan_interface_state_connected) {
        foundConnection = true;
        
        // Get connection attributes
        PWLAN_CONNECTION_ATTRIBUTES pConnectInfo = NULL;
        DWORD connectInfoSize = sizeof(WLAN_CONNECTION_ATTRIBUTES);
        WLAN_OPCODE_VALUE_TYPE opCode = wlan_opcode_value_type_invalid;
        
        dwResult = WlanQueryInterface(hClient, &pIfInfo->InterfaceGuid,
                                    wlan_intf_opcode_current_connection,
                                    NULL, &connectInfoSize,
                                    (PVOID*)&pConnectInfo, &opCode);
        
        if (dwResult == ERROR_SUCCESS && pConnectInfo != NULL) {
          result[flutter::EncodableValue("isConnected")] = flutter::EncodableValue(true);
          result[flutter::EncodableValue("isWiFi")] = flutter::EncodableValue(true);
          
          // Get SSID
          std::string ssid((char*)pConnectInfo->wlanAssociationAttributes.dot11Ssid.ucSSID,
                          pConnectInfo->wlanAssociationAttributes.dot11Ssid.uSSIDLength);
          result[flutter::EncodableValue("ssid")] = flutter::EncodableValue(ssid);
          
          // Get security type
          std::string securityType = GetSecurityTypeString(pConnectInfo->wlanSecurityAttributes.dot11AuthAlgorithm);
          result[flutter::EncodableValue("securityType")] = flutter::EncodableValue(securityType);
          result[flutter::EncodableValue("isSecure")] = flutter::EncodableValue(securityType != "OPEN");
          
          // Get signal quality (0-100)
          result[flutter::EncodableValue("signalLevel")] = flutter::EncodableValue((int)pConnectInfo->wlanAssociationAttributes.wlanSignalQuality);
          result[flutter::EncodableValue("signalStrength")] = flutter::EncodableValue((int)pConnectInfo->wlanAssociationAttributes.ulRxRate);
          
          WlanFreeMemory(pConnectInfo);
        }
        break;
      }
    }
    
    if (!foundConnection) {
      result[flutter::EncodableValue("isConnected")] = flutter::EncodableValue(false);
      result[flutter::EncodableValue("isWiFi")] = flutter::EncodableValue(false);
    }
    
    WlanFreeMemory(pIfList);
    WlanCloseHandle(hClient, NULL);
    
  } catch (const std::exception& e) {
    result[flutter::EncodableValue("error")] = flutter::EncodableValue(std::string("Exception: ") + e.what());
    result[flutter::EncodableValue("isConnected")] = flutter::EncodableValue(false);
  }
  
  return flutter::EncodableValue(result);
}

flutter::EncodableValue FlutterWindow::GetNetworkInfo() {
  flutter::EncodableMap result;
  
  try {
    // Initialize COM for Network List Manager
    CoInitialize(NULL);
    
    INetworkListManager* pNetworkListManager = NULL;
    HRESULT hr = CoCreateInstance(CLSID_NetworkListManager, NULL, CLSCTX_ALL,
                                 IID_INetworkListManager, (LPVOID*)&pNetworkListManager);
    
    if (SUCCEEDED(hr)) {
      // Check connectivity
      NLM_CONNECTIVITY connectivity;
      hr = pNetworkListManager->GetConnectivity(&connectivity);
      
      if (SUCCEEDED(hr)) {
        bool isConnected = (connectivity & NLM_CONNECTIVITY_IPV4_INTERNET) ||
                          (connectivity & NLM_CONNECTIVITY_IPV6_INTERNET);
        result[flutter::EncodableValue("isConnected")] = flutter::EncodableValue(isConnected);
        result[flutter::EncodableValue("hasInternet")] = flutter::EncodableValue(isConnected);
        result[flutter::EncodableValue("isValidated")] = flutter::EncodableValue(isConnected);
      }
      
      // Check network connection types using Network List Manager
      IEnumNetworkConnections* pEnumNetworkConnections = NULL;
      hr = pNetworkListManager->GetNetworkConnections(&pEnumNetworkConnections);
      
      bool isWiFi = false;
      bool isMobile = false;
      bool isEthernet = false;
      
      if (SUCCEEDED(hr)) {
        INetworkConnection* pNetworkConnection = NULL;
        ULONG celtFetched = 0;
        
                 while (pEnumNetworkConnections->Next(1, &pNetworkConnection, &celtFetched) == S_OK) {
           NLM_CONNECTIVITY connConnectivity;
           if (SUCCEEDED(pNetworkConnection->GetConnectivity(&connConnectivity))) {
                         if (connConnectivity & (NLM_CONNECTIVITY_IPV4_INTERNET | NLM_CONNECTIVITY_IPV6_INTERNET)) {
              // Get adapter type
              GUID adapterId;
              if (SUCCEEDED(pNetworkConnection->GetAdapterId(&adapterId))) {
                // Use WMI or registry to determine adapter type
                // For now, use a simplified approach by checking WLAN connection
                HANDLE hClient = NULL;
                DWORD dwResult = WlanOpenHandle(2, NULL, NULL, &hClient);
                if (dwResult == ERROR_SUCCESS) {
                  PWLAN_INTERFACE_INFO_LIST pIfList = NULL;
                  dwResult = WlanEnumInterfaces(hClient, NULL, &pIfList);
                  if (dwResult == ERROR_SUCCESS && pIfList->dwNumberOfItems > 0) {
                    // Check if any WiFi interface is connected
                    for (DWORD i = 0; i < pIfList->dwNumberOfItems; i++) {
                      if (pIfList->InterfaceInfo[i].isState == wlan_interface_state_connected) {
                        isWiFi = true;
                        break;
                      }
                    }
                    WlanFreeMemory(pIfList);
                  }
                  WlanCloseHandle(hClient, NULL);
                }
                
                // If not WiFi and we have internet connectivity, assume Ethernet
                if (!isWiFi && (connConnectivity & (NLM_CONNECTIVITY_IPV4_INTERNET | NLM_CONNECTIVITY_IPV6_INTERNET))) {
                  isEthernet = true;
                }
              }
            }
          }
          pNetworkConnection->Release();
        }
        pEnumNetworkConnections->Release();
      }
      
      // Additional check using GetAdaptersInfo for more precise detection
      ULONG ulOutBufLen = sizeof(IP_ADAPTER_INFO);
      PIP_ADAPTER_INFO pAdapterInfo = (IP_ADAPTER_INFO*)malloc(ulOutBufLen);

      if (GetAdaptersInfo(pAdapterInfo, &ulOutBufLen) == ERROR_BUFFER_OVERFLOW) {
          free(pAdapterInfo);
          pAdapterInfo = (IP_ADAPTER_INFO*)malloc(ulOutBufLen);
      }
      
      if (pAdapterInfo && GetAdaptersInfo(pAdapterInfo, &ulOutBufLen) == NO_ERROR) {
          PIP_ADAPTER_INFO pAdapter = pAdapterInfo;
          while (pAdapter) {
              if (pAdapter->Type == MIB_IF_TYPE_ETHERNET && strcmp(pAdapter->IpAddressList.IpAddress.String, "0.0.0.0") != 0) {
                  isEthernet = true;
                  result[flutter::EncodableValue("ipAddress")] = flutter::EncodableValue(std::string(pAdapter->IpAddressList.IpAddress.String));
                  result[flutter::EncodableValue("gatewayAddress")] = flutter::EncodableValue(std::string(pAdapter->GatewayList.IpAddress.String));
                  break; // Found the primary ethernet adapter
              } else if (pAdapter->Type == IF_TYPE_IEEE80211 && strcmp(pAdapter->IpAddressList.IpAddress.String, "0.0.0.0") != 0) {
                  isWiFi = true;
                  result[flutter::EncodableValue("ipAddress")] = flutter::EncodableValue(std::string(pAdapter->IpAddressList.IpAddress.String));
                  result[flutter::EncodableValue("gatewayAddress")] = flutter::EncodableValue(std::string(pAdapter->GatewayList.IpAddress.String));
                  break; // Found the primary wifi adapter
              }
              pAdapter = pAdapter->Next;
          }
      }
      
      if (pAdapterInfo) {
          free(pAdapterInfo);
      }
      
      result[flutter::EncodableValue("isWiFi")] = flutter::EncodableValue(isWiFi);
      result[flutter::EncodableValue("isMobile")] = flutter::EncodableValue(isMobile);
      result[flutter::EncodableValue("isEthernet")] = flutter::EncodableValue(isEthernet);
      
      pNetworkListManager->Release();
    } else {
      result[flutter::EncodableValue("isConnected")] = flutter::EncodableValue(false);
      result[flutter::EncodableValue("isWiFi")] = flutter::EncodableValue(false);
      result[flutter::EncodableValue("isMobile")] = flutter::EncodableValue(false);
      result[flutter::EncodableValue("isEthernet")] = flutter::EncodableValue(false);
      result[flutter::EncodableValue("hasInternet")] = flutter::EncodableValue(false);
      result[flutter::EncodableValue("isValidated")] = flutter::EncodableValue(false);
    }
    
    CoUninitialize();
    
  } catch (const std::exception& e) {
    result[flutter::EncodableValue("error")] = flutter::EncodableValue(std::string("Exception: ") + e.what());
  }
  
  return flutter::EncodableValue(result);
}

std::string FlutterWindow::GetSecurityTypeString(DOT11_AUTH_ALGORITHM authAlgo) {
  switch (authAlgo) {
    case DOT11_AUTH_ALGO_80211_OPEN:
      return "OPEN";
    case DOT11_AUTH_ALGO_80211_SHARED_KEY:
      return "WEP";
    case DOT11_AUTH_ALGO_WPA:
      return "WPA";
    case DOT11_AUTH_ALGO_WPA_PSK:
      return "WPA_PSK";
    case DOT11_AUTH_ALGO_WPA_NONE:
      return "WPA_NONE";
    case DOT11_AUTH_ALGO_RSNA:
      return "WPA2";
    case DOT11_AUTH_ALGO_RSNA_PSK:
      return "WPA2_PSK";
    case DOT11_AUTH_ALGO_WPA3:
      return "WPA3";
    case DOT11_AUTH_ALGO_WPA3_SAE:
      return "WPA3_SAE";
    default:
      return "UNKNOWN";
  }
}
