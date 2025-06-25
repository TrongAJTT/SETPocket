import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'p2p_models.g.dart';

enum NetworkSecurityLevel {
  secure, // Mobile data or secured WiFi
  unsecure, // Open WiFi
  unknown, // Cannot determine
}

enum ConnectionStatus {
  disconnected,
  discovering,
  connected,
  pairing,
  paired,
}

enum ConnectionDisplayStatus {
  discovered, // Newly discovered device (blue)
  connectedOnline, // Stored connection, online (green)
  connectedOffline, // Stored connection, offline (gray)
}

enum DataTransferStatus {
  pending,
  requesting,
  waitingForApproval, // Waiting for receiver approval
  transferring,
  completed,
  failed,
  cancelled,
  rejected, // Rejected by receiver
}

enum FileTransferRejectReason {
  userRejected,
  timeout,
  fileSizeExceeded,
  totalSizeExceeded,
  storageInsufficient,
  unsupportedFileType,
  unknown,
}

@HiveType(typeId: 47)
class P2PUser extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String displayName;

  @HiveField(2)
  String appInstallationId;

  @HiveField(3)
  String ipAddress;

  @HiveField(4)
  int port;

  @HiveField(5)
  DateTime lastSeen;

  @HiveField(6)
  bool isOnline;

  @HiveField(7)
  bool isPaired;

  @HiveField(8)
  bool isTrusted;

  @HiveField(9)
  bool autoConnect;

  @HiveField(10)
  DateTime? pairedAt;

  @HiveField(11)
  bool isStored; // Indicates if this is a stored/saved connection

  P2PUser({
    String? id,
    required this.displayName,
    required this.appInstallationId,
    required this.ipAddress,
    required this.port,
    DateTime? lastSeen,
    this.isOnline = false,
    this.isPaired = false,
    this.isTrusted = false,
    this.autoConnect = false,
    this.pairedAt,
    this.isStored = false,
  })  : id = id ?? const Uuid().v4(),
        lastSeen = lastSeen ?? DateTime.now();

  // Backward compatibility getter
  String get deviceId => appInstallationId;

  /// Get connection status for UI display
  ConnectionDisplayStatus get connectionDisplayStatus {
    if (isStored) {
      return isOnline
          ? ConnectionDisplayStatus.connectedOnline
          : ConnectionDisplayStatus.connectedOffline;
    } else {
      return ConnectionDisplayStatus.discovered;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'appInstallationId': appInstallationId,
        // Keep old field for backward compatibility
        'deviceId': appInstallationId,
        'appSessionId': appInstallationId, // For backward compatibility
        'ipAddress': ipAddress,
        'port': port,
        'lastSeen': lastSeen.toIso8601String(),
        'isOnline': isOnline,
        'isPaired': isPaired,
        'isTrusted': isTrusted,
        'autoConnect': autoConnect,
        'pairedAt': pairedAt?.toIso8601String(),
        'isStored': isStored,
      };

  factory P2PUser.fromJson(Map<String, dynamic> json) => P2PUser(
        id: json['id'],
        displayName: json['displayName'],
        // Try new field first, fallback to old fields for backward compatibility
        appInstallationId: json['appInstallationId'] ??
            json['appSessionId'] ??
            json['deviceId'],
        ipAddress: json['ipAddress'],
        port: json['port'],
        lastSeen: DateTime.parse(json['lastSeen']),
        isOnline: json['isOnline'] ?? false,
        isPaired: json['isPaired'] ?? false,
        isTrusted: json['isTrusted'] ?? false,
        autoConnect: json['autoConnect'] ?? false,
        pairedAt:
            json['pairedAt'] != null ? DateTime.parse(json['pairedAt']) : null,
        isStored: json['isStored'] ?? false,
      );
}

@HiveType(typeId: 48)
class PairingRequest extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String fromUserId;

  @HiveField(2)
  String fromUserName;

  @HiveField(3)
  String fromAppInstallationId;

  @HiveField(4)
  String fromIpAddress;

  @HiveField(5)
  int fromPort;

  @HiveField(6)
  DateTime requestTime;

  @HiveField(7)
  bool wantsSaveConnection;

  @HiveField(8)
  bool isProcessed;

  PairingRequest({
    String? id,
    required this.fromUserId,
    required this.fromUserName,
    required this.fromAppInstallationId,
    required this.fromIpAddress,
    required this.fromPort,
    DateTime? requestTime,
    this.wantsSaveConnection = false,
    this.isProcessed = false,
  })  : id = id ?? const Uuid().v4(),
        requestTime = requestTime ?? DateTime.now();

  // Backward compatibility getter
  String get fromDeviceId => fromAppInstallationId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'fromUserId': fromUserId,
        'fromUserName': fromUserName,
        'fromAppInstallationId': fromAppInstallationId,
        // Keep old fields for backward compatibility
        'fromDeviceId': fromAppInstallationId,
        'fromAppSessionId': fromAppInstallationId,
        'fromIpAddress': fromIpAddress,
        'fromPort': fromPort,
        'requestTime': requestTime.toIso8601String(),
        'wantsSaveConnection': wantsSaveConnection,
        'isProcessed': isProcessed,
      };

  factory PairingRequest.fromJson(Map<String, dynamic> json) => PairingRequest(
        id: json['id'],
        fromUserId: json['fromUserId'],
        fromUserName: json['fromUserName'],
        // Try new field first, fallback to old fields for backward compatibility
        fromAppInstallationId: json['fromAppInstallationId'] ??
            json['fromAppSessionId'] ??
            json['fromDeviceId'],
        fromIpAddress: json['fromIpAddress'],
        fromPort: json['fromPort'],
        requestTime: DateTime.parse(json['requestTime']),
        wantsSaveConnection: json['wantsSaveConnection'] ?? false,
        isProcessed: json['isProcessed'] ?? false,
      );
}

@HiveType(typeId: 49)
class DataTransferTask extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String fileName;

  @HiveField(2)
  String filePath;

  @HiveField(3)
  int fileSize;

  @HiveField(4)
  String targetUserId;

  @HiveField(5)
  String targetUserName;

  @HiveField(6)
  DataTransferStatus status;

  @HiveField(7)
  int transferredBytes;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  DateTime? startedAt;

  @HiveField(10)
  DateTime? completedAt;

  @HiveField(11)
  String? errorMessage;

  @HiveField(12)
  bool isOutgoing;

  @HiveField(13)
  String? savePath;

  @HiveField(14)
  String? batchId; // Links to file transfer request

  DataTransferTask({
    String? id,
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.targetUserId,
    required this.targetUserName,
    this.status = DataTransferStatus.pending,
    this.transferredBytes = 0,
    DateTime? createdAt,
    this.startedAt,
    this.completedAt,
    this.errorMessage,
    required this.isOutgoing,
    this.savePath,
    this.batchId,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  double get progress => fileSize > 0 ? transferredBytes / fileSize : 0.0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'fileName': fileName,
        'filePath': filePath,
        'fileSize': fileSize,
        'targetUserId': targetUserId,
        'targetUserName': targetUserName,
        'status': status.index,
        'transferredBytes': transferredBytes,
        'createdAt': createdAt.toIso8601String(),
        'startedAt': startedAt?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'errorMessage': errorMessage,
        'isOutgoing': isOutgoing,
        'savePath': savePath,
        'batchId': batchId,
      };

  factory DataTransferTask.fromJson(Map<String, dynamic> json) =>
      DataTransferTask(
        id: json['id'],
        fileName: json['fileName'],
        filePath: json['filePath'],
        fileSize: json['fileSize'],
        targetUserId: json['targetUserId'],
        targetUserName: json['targetUserName'],
        status: DataTransferStatus.values[json['status']],
        transferredBytes: json['transferredBytes'],
        createdAt: DateTime.parse(json['createdAt']),
        startedAt: json['startedAt'] != null
            ? DateTime.parse(json['startedAt'])
            : null,
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null,
        errorMessage: json['errorMessage'],
        isOutgoing: json['isOutgoing'],
        savePath: json['savePath'],
        batchId: json['batchId'],
      );
}

class NetworkInfo {
  final String? wifiName;
  final String? wifiSSID;
  final String? ipAddress;
  final String? gatewayAddress;
  final bool isWiFi;
  final bool isMobile;
  final bool isSecure;
  final NetworkSecurityLevel securityLevel;
  final int? signalStrength;
  final String? securityType;

  NetworkInfo({
    this.wifiName,
    this.wifiSSID,
    this.ipAddress,
    this.gatewayAddress,
    required this.isWiFi,
    required this.isMobile,
    required this.isSecure,
    required this.securityLevel,
    this.signalStrength,
    this.securityType,
  });
}

class P2PMessage {
  final String type;
  final String fromUserId;
  final String toUserId;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  P2PMessage({
    required this.type,
    required this.fromUserId,
    required this.toUserId,
    required this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'type': type,
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'data': data,
        'timestamp': timestamp.toIso8601String(),
      };

  factory P2PMessage.fromJson(Map<String, dynamic> json) => P2PMessage(
        type: json['type'],
        fromUserId: json['fromUserId'],
        toUserId: json['toUserId'],
        data: Map<String, dynamic>.from(json['data']),
        timestamp: DateTime.parse(json['timestamp']),
      );
}

/// Model for file information in transfer request
class FileTransferInfo {
  final String fileName;
  final int fileSize;

  const FileTransferInfo({
    required this.fileName,
    required this.fileSize,
  });

  Map<String, dynamic> toJson() => {
        'fileName': fileName,
        'fileSize': fileSize,
      };

  factory FileTransferInfo.fromJson(Map<String, dynamic> json) =>
      FileTransferInfo(
        fileName: json['fileName'] as String,
        fileSize: json['fileSize'] as int,
      );
}

/// File transfer request model
@HiveType(typeId: 53)
class FileTransferRequest extends HiveObject {
  @HiveField(0)
  String requestId;

  @HiveField(1)
  String batchId; // ID for grouping multiple files in one transfer session

  @HiveField(2)
  String fromUserId;

  @HiveField(3)
  String fromUserName;

  @HiveField(4)
  List<FileTransferInfo> files;

  @HiveField(5)
  int totalSize;

  @HiveField(6)
  String protocol; // 'tcp' or 'udp' or 'quic' (plan)

  @HiveField(7)
  DateTime requestTime;

  @HiveField(8)
  bool isProcessed;

  @HiveField(9)
  int? maxChunkSize; // Sender's preferred chunk size in KB

  @HiveField(10)
  DateTime?
      receivedTime; // Time when request was received at the receiver device

  FileTransferRequest({
    String? requestId,
    String? batchId,
    required this.fromUserId,
    required this.fromUserName,
    required this.files,
    required this.totalSize,
    this.protocol = 'tcp',
    DateTime? requestTime,
    this.isProcessed = false,
    this.maxChunkSize,
    this.receivedTime,
  })  : requestId = requestId ?? const Uuid().v4(),
        batchId = batchId ?? const Uuid().v4(),
        requestTime = requestTime ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'requestId': requestId,
        'batchId': batchId,
        'fromUserId': fromUserId,
        'fromUserName': fromUserName,
        'files': files.map((f) => f.toJson()).toList(),
        'totalSize': totalSize,
        'protocol': protocol,
        'requestTime': requestTime.toIso8601String(),
        'isProcessed': isProcessed,
        'maxChunkSize': maxChunkSize,
        'receivedTime': receivedTime?.toIso8601String(),
      };

  factory FileTransferRequest.fromJson(Map<String, dynamic> json) =>
      FileTransferRequest(
        requestId: json['requestId'] as String,
        batchId: json['batchId'] as String,
        fromUserId: json['fromUserId'] as String,
        fromUserName: json['fromUserName'] as String,
        files: (json['files'] as List<dynamic>)
            .map((f) => FileTransferInfo.fromJson(f as Map<String, dynamic>))
            .toList(),
        totalSize: json['totalSize'] as int,
        protocol: json['protocol'] as String? ?? 'tcp',
        requestTime: DateTime.parse(json['requestTime'] as String),
        isProcessed: json['isProcessed'] as bool? ?? false,
        maxChunkSize: json['maxChunkSize'] as int?,
        receivedTime: json['receivedTime'] != null
            ? DateTime.parse(json['receivedTime'] as String)
            : null,
      );
}

/// File transfer response model
class FileTransferResponse {
  final String requestId;
  final String batchId;
  final bool accepted;
  final FileTransferRejectReason? rejectReason;
  final String? rejectMessage;
  final String? downloadPath; // Path where files will be saved if accepted

  const FileTransferResponse({
    required this.requestId,
    required this.batchId,
    required this.accepted,
    this.rejectReason,
    this.rejectMessage,
    this.downloadPath,
  });

  Map<String, dynamic> toJson() => {
        'requestId': requestId,
        'batchId': batchId,
        'accepted': accepted,
        'rejectReason': rejectReason?.name,
        'rejectMessage': rejectMessage,
        'downloadPath': downloadPath,
      };

  factory FileTransferResponse.fromJson(Map<String, dynamic> json) =>
      FileTransferResponse(
        requestId: json['requestId'] as String,
        batchId: json['batchId'] as String,
        accepted: json['accepted'] as bool,
        rejectReason: json['rejectReason'] != null
            ? FileTransferRejectReason.values
                .firstWhere((e) => e.name == json['rejectReason'])
            : null,
        rejectMessage: json['rejectMessage'] as String?,
        downloadPath: json['downloadPath'] as String?,
      );
}

// Message types
class P2PMessageTypes {
  static const String discovery = 'discovery';
  static const String discoveryResponse = 'discovery_response';
  static const String discoveryScanRequest = 'discovery_scan_request';
  static const String profileSyncRequest = 'profile_sync_request';
  static const String pairingRequest = 'pairing_request';
  static const String pairingResponse = 'pairing_response';
  static const String dataTransferInit = 'data_transfer_init';
  static const String dataTransferRequest = 'data_transfer_request';
  static const String dataTransferResponse = 'data_transfer_response';
  static const String dataChunk = 'data_chunk';
  static const String dataTransferComplete = 'data_transfer_complete';
  static const String dataTransferCancel = 'data_transfer_cancel';
  static const String heartbeat = 'heartbeat';
  static const String disconnect = 'disconnect';
  static const String trustRequest = 'trust_request';
  static const String trustResponse = 'trust_response';
  // File transfer pre-request messages
  static const String fileTransferRequest = 'file_transfer_request';
  static const String fileTransferResponse = 'file_transfer_response';
}

@HiveType(typeId: 52)
class P2PFileStorageSettings extends HiveObject {
  @HiveField(0)
  String downloadPath;

  @HiveField(1)
  bool askBeforeDownload;

  @HiveField(2)
  bool createDateFolders;

  @HiveField(3)
  int maxFileSize; // in MB

  @HiveField(4)
  int maxConcurrentTasks;

  P2PFileStorageSettings({
    required this.downloadPath,
    this.askBeforeDownload = true,
    this.createDateFolders = false,
    this.maxFileSize = 100, // 100MB default
    this.maxConcurrentTasks = 3, // 3 concurrent tasks default
  });

  Map<String, dynamic> toJson() => {
        'downloadPath': downloadPath,
        'askBeforeDownload': askBeforeDownload,
        'createDateFolders': createDateFolders,
        'maxFileSize': maxFileSize,
      };

  factory P2PFileStorageSettings.fromJson(Map<String, dynamic> json) =>
      P2PFileStorageSettings(
        downloadPath: json['downloadPath'],
        askBeforeDownload: json['askBeforeDownload'] ?? true,
        createDateFolders: json['createDateFolders'] ?? false,
        maxFileSize: json['maxFileSize'] ?? 100,
      );
}

@HiveType(typeId: 58)
class P2PDataTransferSettings extends HiveObject {
  @HiveField(0)
  String downloadPath;

  @HiveField(1)
  bool createDateFolders;

  /// Maximum individual file size in BYTES.
  @HiveField(2)
  int maxReceiveFileSize;

  /// Maximum total size for a batch transfer in BYTES.
  @HiveField(3)
  int maxTotalReceiveSize;

  @HiveField(4)
  int maxConcurrentTasks;

  @HiveField(5)
  String sendProtocol;

  /// Maximum chunk size for sending files in KILOBYTES.
  @HiveField(6)
  int maxChunkSize;

  P2PDataTransferSettings({
    required this.downloadPath,
    required this.createDateFolders,
    required this.maxReceiveFileSize,
    required this.maxTotalReceiveSize,
    required this.maxConcurrentTasks,
    required this.sendProtocol,
    required this.maxChunkSize,
  });

  // Helper getters for UI display
  double get maxReceiveFileSizeInMB => maxReceiveFileSize / (1024 * 1024);
  double get maxTotalReceiveSizeInGB =>
      maxTotalReceiveSize / (1024 * 1024 * 1024);

  P2PDataTransferSettings copyWith({
    String? downloadPath,
    bool? createDateFolders,
    int? maxReceiveFileSize,
    int? maxTotalReceiveSize,
    int? maxConcurrentTasks,
    String? sendProtocol,
    int? maxChunkSize,
  }) {
    return P2PDataTransferSettings(
      downloadPath: downloadPath ?? this.downloadPath,
      createDateFolders: createDateFolders ?? this.createDateFolders,
      maxReceiveFileSize: maxReceiveFileSize ?? this.maxReceiveFileSize,
      maxTotalReceiveSize: maxTotalReceiveSize ?? this.maxTotalReceiveSize,
      maxConcurrentTasks: maxConcurrentTasks ?? this.maxConcurrentTasks,
      sendProtocol: sendProtocol ?? this.sendProtocol,
      maxChunkSize: maxChunkSize ?? this.maxChunkSize,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'downloadPath': downloadPath,
      'createDateFolders': createDateFolders,
      'maxReceiveFileSize': maxReceiveFileSize,
      'maxTotalReceiveSize': maxTotalReceiveSize,
      'maxConcurrentTasks': maxConcurrentTasks,
      'sendProtocol': sendProtocol,
      'maxChunkSize': maxChunkSize,
    };
  }

  factory P2PDataTransferSettings.fromJson(Map<String, dynamic> json) {
    return P2PDataTransferSettings(
      downloadPath: json['downloadPath'],
      createDateFolders: json['createDateFolders'],
      maxReceiveFileSize: json['maxReceiveFileSize'],
      maxTotalReceiveSize: json['maxTotalReceiveSize'],
      maxConcurrentTasks: json['maxConcurrentTasks'],
      sendProtocol: json['sendProtocol'],
      maxChunkSize: json['maxChunkSize'],
    );
  }
}

/// Discovery response codes for optimized discovery
enum DiscoveryResponseCode {
  /// Device is completely new (not in storage)
  deviceNew,

  /// Device exists in storage (coming back online)
  deviceUpdate,

  /// Error occurred during processing
  error,
}

/// Discovery scan request for optimized single-device broadcasting
class DiscoveryScanRequest {
  final String fromUserId;
  final String fromUserName;
  final String fromAppInstallationId;
  final String ipAddress;
  final int port;
  final int timestamp;

  const DiscoveryScanRequest({
    required this.fromUserId,
    required this.fromUserName,
    required this.fromAppInstallationId,
    required this.ipAddress,
    required this.port,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'fromAppInstallationId': fromAppInstallationId,
      'ipAddress': ipAddress,
      'port': port,
      'timestamp': timestamp,
    };
  }

  factory DiscoveryScanRequest.fromJson(Map<String, dynamic> json) {
    return DiscoveryScanRequest(
      fromUserId: json['fromUserId'] as String,
      fromUserName: json['fromUserName'] as String,
      fromAppInstallationId: json['fromAppInstallationId'] as String,
      ipAddress: json['ipAddress'] as String,
      port: json['port'] as int,
      timestamp: json['timestamp'] as int,
    );
  }
}

/// Discovery response with profile info and status code
class DiscoveryResponse {
  final String toUserId;
  final DiscoveryResponseCode responseCode;
  final P2PUser userProfile;
  final String? errorMessage;
  final int timestamp;

  const DiscoveryResponse({
    required this.toUserId,
    required this.responseCode,
    required this.userProfile,
    this.errorMessage,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'toUserId': toUserId,
      'responseCode': responseCode.name,
      'userProfile': userProfile.toJson(),
      'errorMessage': errorMessage,
      'timestamp': timestamp,
    };
  }

  factory DiscoveryResponse.fromJson(Map<String, dynamic> json) {
    return DiscoveryResponse(
      toUserId: json['toUserId'] as String,
      responseCode: DiscoveryResponseCode.values.firstWhere(
        (e) => e.name == json['responseCode'],
        orElse: () => DiscoveryResponseCode.error,
      ),
      userProfile:
          P2PUser.fromJson(json['userProfile'] as Map<String, dynamic>),
      errorMessage: json['errorMessage'] as String?,
      timestamp: json['timestamp'] as int,
    );
  }
}

/// Enhanced P2PUser with discovery state tracking
extension P2PUserDiscoveryState on P2PUser {
  /// Check if this is a newly discovered device (blue background)
  bool get isNewDevice => !isStored && isOnline && !isPaired;

  /// Check if this is an online saved device (green background)
  bool get isOnlineSaved => isStored && isOnline;

  /// Check if this is an offline saved device (gray background)
  bool get isOfflineSaved => isStored && !isOnline;

  /// Get device category for UI grouping
  P2PDeviceCategory get deviceCategory {
    if (isNewDevice) return P2PDeviceCategory.newDevices;
    if (isOnlineSaved) return P2PDeviceCategory.onlineDevices;
    if (isOfflineSaved) return P2PDeviceCategory.savedDevices;
    return P2PDeviceCategory.unknown;
  }
}

/// Device categories for UI organization
enum P2PDeviceCategory {
  onlineDevices, // Green - online saved devices
  newDevices, // Blue - newly discovered devices
  savedDevices, // Gray - offline saved devices
  unknown,
}
