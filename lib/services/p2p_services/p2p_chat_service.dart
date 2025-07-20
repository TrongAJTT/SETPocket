import 'dart:io';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:setpocket/models/app_installation.dart';
import 'package:setpocket/models/p2p/p2p_chat.dart';
import 'package:setpocket/models/p2p/p2p_models.dart';
import 'package:setpocket/services/app_logger.dart';

class P2PChatService extends ChangeNotifier {
  /// Lấy 1 trang tin nhắn của đoạn chat, mặc định lấy từ dưới lên (mới nhất)
  List<P2PCMessage> getMessagesPage(P2PChat chat,
      {int page = 0, int pageSize = 30}) {
    final allMessages = chat.messages.toList();
    if (allMessages.isEmpty) return [];
    final total = allMessages.length;
    final end = total - page * pageSize;
    final start = end - pageSize;
    final realStart = start < 0 ? 0 : start;
    final realEnd = end < 0 ? 0 : end;
    if (realEnd <= realStart) return [];
    return allMessages.sublist(realStart, realEnd);
  }

  Future<int> addMessageAndNotify(
      P2PCMessage msg, P2PChat chat, P2PCMessageStatus status) async {
    late int id;
    await isar.writeTxn(() async {
      msg.status = status;
      id = await isar.p2PCMessages.put(msg);
      chat.messages.add(msg);
      await chat.messages.save();
    });
    await chat.messages.load();
    await loadAllChats();
    notifyListeners();
    return id;
  }

  Future<void> updateMessageStatus(
      P2PCMessage msg, P2PChat chat, P2PCMessageStatus status) async {
    await isar.writeTxn(() async {
      msg.status = status;
      await isar.p2PCMessages.put(msg);
    });
    notifyListeners();
  }

  P2PChat? getChatById(String chatId) => _chatMap[chatId];
  final Isar isar;
  final Map<String, P2PChat> _chatMap = {};
  late final String _currentUserId;

  P2PChatService(this.isar) {
    final installation = isar.appInstallations.where().findFirstSync();
    _currentUserId = installation!.installationId!;
    loadAllChats();
  }

  Future<List<P2PChat>> getAllChatsWithoutMessages() async {
    final chats = await isar.p2PChats.where().findAll();
    return chats.map((chat) {
      final displayName = chat.displayName.isNotEmpty
          ? chat.displayName
          : 'User ${chat.userBId}';
      return P2PChat()
        ..id = chat.id
        ..userAId = chat.userAId
        ..userBId = chat.userBId
        ..displayName = displayName
        ..createdAt = chat.createdAt
        ..retention = chat.retention;
    }).toList();
  }

  Future<List<P2PChat>> loadAllChats() async {
    final chats = await isar.p2PChats.where().findAll();
    _chatMap.clear();
    for (final chat in chats) {
      _chatMap[chat.id.toString()] = chat;
    }
    notifyListeners();
    return chats;
  }

  Future<P2PChat> addChat(String userId,
      {MessageRetention retention = MessageRetention.days30}) async {
    final existing = await findChatByUsers(userId);
    String displayName = 'User $userId';
    try {
      final user = isar.p2PUsers.filter().idEqualTo(userId).findFirstSync();
      if (user != null && user.displayName.isNotEmpty) {
        displayName = user.displayName;
      }
    } catch (_) {}
    if (existing != null) {
      logInfo('Chat already exists between $_currentUserId and $userId');
      return existing;
    }
    final chat = P2PChat()
      ..userAId = _currentUserId
      ..userBId = userId
      ..displayName = displayName
      ..createdAt = DateTime.now()
      ..retention = retention;
    await isar.writeTxn(() async {
      await isar.p2PChats.put(chat);
    });
    _chatMap[chat.id.toString()] = chat;
    notifyListeners();
    logInfo('Added new chat between $_currentUserId and $userId');
    return chat;
  }

  // This method is used to add messages to the received chat
  Future<int> addMessage(P2PCMessage msg, P2PChat chat) async {
    late int id;
    await isar.writeTxn(() async {
      msg.status = P2PCMessageStatus.onDevice; // Set status to on-device
      msg.sentAt = DateTime.now(); // Sync date time to avoid date region issues
      id = await isar.p2PCMessages.put(msg);
      chat.messages.add(msg);
      await chat.messages.save();
    });
    logInfo('>>> Message added with ID: $id');
    notifyListeners();
    return id;
  }

  bool chatIdExists(String chatId) => _chatMap.containsKey(chatId);

  Future<P2PChat?> findChatByUsers(String userId) async {
    final chats = await isar.p2PChats
        .filter()
        .userAIdEqualTo(_currentUserId)
        .userBIdEqualTo(userId)
        .findAll();
    if (chats.isNotEmpty) return chats.first;
    final chatsReverse = await isar.p2PChats
        .filter()
        .userAIdEqualTo(_currentUserId)
        .userBIdEqualTo(userId)
        .findAll();
    if (chatsReverse.isNotEmpty) return chatsReverse.first;
    return null;
  }

  Future<P2PCMessage?> getLatestMessageWithUser(String userId) async {
    final chat = _chatMap.values
        .firstWhere((c) => c.userBId == userId, orElse: () => P2PChat.empty());
    if (chat.isEmpty()) return null;
    return chat.messages.lastOrNull;
  }

  Future<String?> handleCheckMessageFileExist(
      String userBId, String syncId) async {
    try {
      final chat = _chatMap.values.firstWhere((c) => c.userBId == userBId);
      logDebug('Checking file existence for user $userBId, syncId: $syncId');
      final msg = chat.messages.firstWhere((m) => m.syncId == syncId);
      logDebug('Message file path: ${msg.filePath}');
      if (msg.filePath != null && msg.filePath!.isNotEmpty) {
        // Check if the file exists before returning the path
        final file = File(msg.filePath!);
        if (await file.exists()) {
          return msg.filePath;
        } else {
          // File does not exist, update message status
          await updateMessageStatus(msg, chat, P2PCMessageStatus.lostBoth);
          return null;
        }
      }
      // If filePath is null or empty, return null
      return null;
    } catch (e) {
      logError('Error handling message file existence: $e');
      return null;
    }
  }

  Future<void> handleFileRequestLost(String userBId, String syncId) async {
    try {
      // Find the chat and message by userBId and syncId
      logDebug('Handling file request lost for user $userBId, syncId: $syncId');
      final chat = _chatMap.values.firstWhere((c) => c.userBId == userBId);
      final msg = chat.messages.firstWhere((m) => m.syncId == syncId);
      await updateMessageStatus(msg, chat, P2PCMessageStatus.lostBoth);
      notifyListeners();
      logInfo('File request lost for user $userBId, syncId: $syncId');
    } catch (e) {
      logError('Error handling file request lost: $e');
    }
  }

  Future<void> handleChatResponseExist(String userBId, String syncId) async {
    try {
      final chat = _chatMap.values.firstWhere((c) => c.userBId == userBId);
      final msg = chat.messages.firstWhere((m) => m.syncId == syncId);
      await updateMessageStatus(msg, chat, P2PCMessageStatus.lostBoth);
      notifyListeners();
      logInfo('Chat response lost for user $userBId, syncId: $syncId');
    } catch (e) {
      logError('Error handling chat response lost: $e');
    }
  }

  Future<void> updateChatSettings(
      P2PChat currentChat, P2PChat updatedChat) async {
    try {
      await isar.writeTxn(() async {
        currentChat.updateSettings(updatedChat);
        await isar.p2PChats.put(currentChat);
      });
      _chatMap[currentChat.id.toString()] = currentChat;
      notifyListeners();
    } catch (e) {
      logError('Error updating chat settings: $e');
    }
  }

  Future<void> removeMessageAndNotify(
      {required P2PChat chat,
      required P2PCMessage message,
      required deleteFileIfExist}) async {
    await isar.writeTxn(() async {
      await isar.p2PCMessages.delete(message.id);
      chat.messages.remove(message);
      await chat.messages.save();
      if (deleteFileIfExist &&
          (message.type == P2PCMessageType.file ||
              message.type == P2PCMessageType.mediaImage ||
              message.type == P2PCMessageType.mediaVideo)) {
        final file = File(message.filePath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
    });
    _chatMap[chat.id.toString()] = chat; // Force reload chat in UI
    notifyListeners();
  }

  Future<P2PCMessage?> getMessageBaseOnSyncId(
      {required P2PChat chat, required String syncId}) async {
    if (chat.messages.isEmpty) return null;
    return await chat.messages.filter().syncIdEqualTo(syncId).findFirst();
  }

  Future<void> deleteChatAndNotify(P2PChat chat) async {
    try {
      // // Get all messages in the chat that has files
      // final messagesWithFiles = (chat.messages
      //         .where((msg) =>
      //             (msg.type == P2PCMessageType.file ||
      //                 msg.type == P2PCMessageType.mediaImage ||
      //                 msg.type == P2PCMessageType.mediaVideo) &&
      //             msg.status == P2PCMessageStatus.onDevice)
      //         .toList())
      //     .map((msg) => msg.filePath)
      //     .toList();
      // // Delete files in the background
      // backgroudnDeleteFiles(messagesWithFiles);
      // Delete the chat from the database
      await isar.writeTxn(() async {
        await isar.p2PChats.delete(chat.id);
        _chatMap.remove(chat.id.toString());
      });
      // Notify listeners to update the UI
      notifyListeners();
    } catch (e) {
      logError('Error deleting chat: $e');
    }
  }
}
