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
  transferring,
  completed,
  failed,
  cancelled,
}

@HiveType(typeId: 47)
class P2PUser extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String displayName;

  @HiveField(2)
  String deviceId;

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
    required this.deviceId,
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
        'deviceId': deviceId,
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
        deviceId: json['deviceId'],
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
  String fromDeviceId;

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
    required this.fromDeviceId,
    required this.fromIpAddress,
    required this.fromPort,
    DateTime? requestTime,
    this.wantsSaveConnection = false,
    this.isProcessed = false,
  })  : id = id ?? const Uuid().v4(),
        requestTime = requestTime ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'fromUserId': fromUserId,
        'fromUserName': fromUserName,
        'fromDeviceId': fromDeviceId,
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
        fromDeviceId: json['fromDeviceId'],
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

// Message types
class P2PMessageTypes {
  static const String discovery = 'discovery';
  static const String discoveryResponse = 'discovery_response';
  static const String pairingRequest = 'pairing_request';
  static const String pairingResponse = 'pairing_response';
  static const String dataTransferRequest = 'data_transfer_request';
  static const String dataTransferResponse = 'data_transfer_response';
  static const String dataChunk = 'data_chunk';
  static const String dataTransferComplete = 'data_transfer_complete';
  static const String dataTransferCancel = 'data_transfer_cancel';
  static const String heartbeat = 'heartbeat';
  static const String disconnect = 'disconnect';
  static const String trustRequest = 'trust_request';
  static const String trustResponse = 'trust_response';
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

  P2PFileStorageSettings({
    required this.downloadPath,
    this.askBeforeDownload = true,
    this.createDateFolders = false,
    this.maxFileSize = 100, // 100MB default
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
