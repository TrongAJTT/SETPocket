import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:isar/isar.dart';
import 'package:setpocket/controllers/p2p_controller.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/models/p2p/p2p_chat.dart';
import 'package:setpocket/models/p2p/p2p_models.dart';
import 'package:setpocket/screens/p2lan_transfer/p2p_chat_settings_layout.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/services/p2p_settings_adapter.dart';
import 'package:setpocket/utils/async_utils.dart';
import 'package:setpocket/utils/clipboard_utils.dart';
import 'package:setpocket/utils/generic_dialog_utils.dart';
import 'package:setpocket/utils/localization_utils.dart';
import 'package:setpocket/utils/media_utils.dart';
import 'package:setpocket/utils/size_utils.dart';
import 'package:setpocket/utils/snackbar_utils.dart';
import 'package:setpocket/utils/url_utils.dart';
import 'package:setpocket/variables.dart';
import 'package:setpocket/widgets/generic/generic_context_menu.dart';
import 'package:setpocket/widgets/generic/generic_dialog.dart';
import 'package:setpocket/widgets/generic/generic_settings_helper.dart';
import 'package:setpocket/widgets/generic/icon_button_list.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:clipboard/clipboard.dart';
import 'package:uuid/uuid.dart';

class ChatTabNavigator extends StatefulWidget {
  final P2PController controller;
  final GlobalKey<NavigatorState> navigatorKey;
  const ChatTabNavigator(
      {super.key, required this.controller, required this.navigatorKey});

  @override
  State<ChatTabNavigator> createState() => _ChatTabNavigatorState();
}

class _ChatTabNavigatorState extends State<ChatTabNavigator>
    with AutomaticKeepAliveClientMixin {
  final PageStorageBucket _bucket = PageStorageBucket();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PageStorage(
      bucket: _bucket,
      child: Navigator(
        key: widget.navigatorKey,
        onGenerateRoute: (settings) {
          if (settings.name == '/' || settings.name == null) {
            return MaterialPageRoute(
              builder: (context) =>
                  P2LanChatListScreen(controller: widget.controller),
            );
          }
          if (settings.name == '/chatDetail' && settings.arguments is String) {
            final chatId = settings.arguments as String;
            final chatService = widget.controller.p2pChatService;
            return MaterialPageRoute(
              builder: (context) {
                return FutureBuilder<List<P2PChat>>(
                  future: chatService.getAllChatsWithoutMessages(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final chats = snapshot.data ?? [];
                    final chat = chats.firstWhere(
                      (c) => c.id.toString() == chatId,
                      orElse: () => P2PChat.empty(),
                    );
                    if (!chat.isEmpty()) {
                      return P2LanChatDetailScreen(
                        controller: widget.controller,
                        chat: chat,
                      );
                    } else {
                      return P2LanChatListScreen(controller: widget.controller);
                    }
                  },
                );
              },
            );
          }
          return MaterialPageRoute(
            builder: (context) =>
                P2LanChatListScreen(controller: widget.controller),
          );
        },
      ),
    );
  }
}

/// Section: Chat List Screen

class P2LanChatListScreen extends StatelessWidget {
  final P2PController controller;
  const P2LanChatListScreen({super.key, required this.controller});

  // Nút tao tác bên lề
  Widget _buildActionButtons(BuildContext context, P2PChat chat) {
    final loc = AppLocalizations.of(context)!;
    final visibleCount = MediaQuery.of(context).size.width > 600 ? 3 : 0;
    return IconButtonList(
      buttons: [
        // TODO: Support sync chat with other users in the future
        // IconButtonListItem(
        //   icon: Icons.person,
        //   label: 'Sync this chat with other users',
        //   onPressed: () {
        //
        //   },
        // ),
        IconButtonListItem(
          icon: Icons.clear,
          label: loc.deleteChat,
          onPressed: () {
            GenericDialogUtils.showSimpleHoldClearDialog(
                context: context,
                title: loc.deleteChatWith(chat.displayName),
                content: loc.deleteChatDesc,
                duration: const Duration(seconds: 1),
                onConfirm: () =>
                    controller.p2pChatService.deleteChatAndNotify(chat));
          },
        ),
      ],
      visibleCount: visibleCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: FutureBuilder<List<P2PChat>>(
          future: controller.p2pChatService.loadAllChats(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text(loc.noChatExists);
            } else {
              final chats = snapshot.data!;
              return ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  final title = chat.displayName;
                  final lastMessage = chat.messages.isNotEmpty
                      ? chat.messages.last.content
                      : loc.noMessages;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Colors.primaries[index % Colors.primaries.length],
                      child: Text(title.isNotEmpty ? title[0] : '?'),
                    ),
                    title: Text(title),
                    subtitle: Text(
                        lastMessage.isEmpty ? loc.noMessages : lastMessage),
                    trailing: _buildActionButtons(context, chat),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => P2LanChatDetailScreen(
                            chat: chat,
                            controller: controller,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

/// SECTION: Chat Detail Screen

class P2LanChatDetailScreen extends StatefulWidget {
  final P2PChat chat;
  final P2PController controller;
  const P2LanChatDetailScreen(
      {super.key, required this.chat, required this.controller});

  @override
  State<P2LanChatDetailScreen> createState() => _P2LanChatDetailScreenState();
}

class _P2LanChatDetailScreenState extends State<P2LanChatDetailScreen>
    with ClipboardWatcherMixin {
  // Controllers for scroll and text input
  final _scrollController = ScrollController();
  final _textController = TextEditingController();
  final _textFocusNode = FocusNode();
  late AppLocalizations _loc;

  // File picker state
  final List<PlatformFile> _selectedFiles = [];
  final List<PlatformFile> _selectedMedia = [];

  // State management for scroll position and visibility
  bool _isFocusNewest = true;
  bool _showScrollToBottom = false;
  final _flagPushClipboard = ValueNotifier<bool>(true);
  final _flagPopClipboard = ValueNotifier<bool>(true);
  int _lastMessageCount = 0;

  List<P2PCMessage> _visibleMessages = [];
  int _currentPage = 0;
  static const int _pageSize = 30;
  bool _isLoadingMore = false;

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _textController.dispose();
    _textFocusNode.dispose();
    _removeClipboardListener();
  }

  @override
  void initState() {
    super.initState();
    // Initialize the clipboard listener
    _scrollController.addListener(_handleScroll);
    // Scroll to bottom on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initLoadMessages();
    });
    // Add listener to text controller to update UI on text change
    _textController.addListener(() {
      setState(() {});
    });
    // Set up clipboard listener if clipboard sharing is enabled
    if (widget.chat.clipboardSharing) {
      _setClipboardListener();
    }
    // Add listener to scroll controller to load more messages on scroll
    _scrollController.addListener(_handleLoadMoreScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loc = AppLocalizations.of(context)!;
  }

  void _initLoadMessages() {
    final chatService = widget.controller.p2pChatService;
    final chatId = widget.chat.id.toString();
    final chat = chatService.chatIdExists(chatId)
        ? chatService.getChatById(chatId) ?? widget.chat
        : widget.chat;
    setState(() {
      _currentPage = 0;
      _visibleMessages = widget.controller.p2pChatService
          .getMessagesPage(chat, page: _currentPage, pageSize: _pageSize);
    });
    // Only scroll to bottom if there are messages and controller is attached
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_visibleMessages.isNotEmpty && _scrollController.hasClients) {
        _scrollToBottom(force: true);
      }
    });
  }

  // Media filters
  static const List<String> _imageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'bmp',
    'webp',
  ];

  // Video extensions, but not available at the moment
  static const List<String> _videoExtensions = [
    'mp4',
    'mov',
    'avi',
    'mkv',
    'webm',
    'flv',
    'wmv',
    '3gp',
    'mpeg',
    'mpg'
  ];

  void _handleLoadMoreScroll() async {
    if (_scrollController.hasClients && !_isLoadingMore) {
      if (_scrollController.position.pixels <=
          _scrollController.position.minScrollExtent + 20) {
        setState(() {
          _isLoadingMore = true;
        });
        final start = DateTime.now();
        final moreMessages = await _loadMoreMessages();
        final elapsed = DateTime.now().difference(start);
        if (elapsed < const Duration(seconds: 1)) {
          await Future.delayed(const Duration(seconds: 1) - elapsed);
        }
        bool shouldScroll = false;
        setState(() {
          if (moreMessages != null && moreMessages.isNotEmpty) {
            _visibleMessages = [...moreMessages, ..._visibleMessages];
            _currentPage += 1;
            shouldScroll = true;
          }
          _isLoadingMore = false;
        });
        // Chỉ scroll nếu vừa load thêm tin nhắn cũ
        if (shouldScroll) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              double offset = _scrollController.offset + 500;
              double maxOffset = _scrollController.position.maxScrollExtent;
              if (offset > maxOffset) offset = maxOffset;
              _scrollController.animateTo(
                offset,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      }
    }
  }

  Future<List<P2PCMessage>?> _loadMoreMessages() async {
    final chatService = widget.controller.p2pChatService;
    final chatId = widget.chat.id.toString();
    final chat = chatService.chatIdExists(chatId)
        ? chatService.getChatById(chatId) ?? widget.chat
        : widget.chat;
    final nextPage = _currentPage + 1;
    final moreMessages = await Future.value(
      widget.controller.p2pChatService
          .getMessagesPage(chat, page: nextPage, pageSize: _pageSize),
    );
    if (moreMessages.isEmpty) return null;
    return moreMessages;
  }

  Future<void> _handlePopClipboardAndSendMessage(
      ClipboardContent clipboard) async {
    // Set push flag to false to prevent multiple pushes
    _flagPushClipboard.value = false;
    // Handle clipboard content based on type
    String setSyncId = const Uuid().v4();
    if (clipboard.isText) {
      _textController.text = clipboard.asText;
      await _sendChatMessage(setSyncId: setSyncId);
    } else {
      final imageBytes = clipboard.asImage;
      String tempFileName =
          'clipboard_image_${DateTime.now().millisecondsSinceEpoch}.png';
      // Get p2lan directory
      final p2pLanDir = (await P2PSettingsAdapter.getSettings()).downloadPath;
      UriUtils.createImageFileFromUint8List(
          data: imageBytes, fileName: tempFileName, directory: p2pLanDir);
      // Get file path
      final filePath = p2pLanDir + Platform.pathSeparator + tempFileName;
      // Select media file
      setState(() {
        _selectedMedia.add(PlatformFile(
          path: filePath,
          name: tempFileName,
          size: imageBytes.length,
        ));
      });
      // Send message
      await _sendChatMessage(setSyncId: setSyncId);
      // Await for the message to be sent to the other user
      await Future.delayed(
          const Duration(seconds: p2pChatMediaWaitTimeBeforeDelete));
    }
    // Clear selected media if settings deleteAfterShare is true
    if (widget.chat.deleteAfterShare) {
      final message = await widget.controller.p2pChatService
          .getMessageBaseOnSyncId(chat: widget.chat, syncId: setSyncId);
      if (message != null) {
        await widget.controller.p2pChatService.removeMessageAndNotify(
            chat: widget.chat, message: message, deleteFileIfExist: true);
      } else {
        logError(
            'Message with syncId $setSyncId not found in chat ${widget.chat.id}');
      }
    }
    // Set push flag to true
    _flagPushClipboard.value = true;
  }

  @override
  onClipboardChanged(ClipboardChangeEvent event) async {
    if (_flagPopClipboard.value &&
        widget.controller.isUserOnline(widget.chat.userBId)) {
      final content = event.newContent;
      if (content.isText || content.isImage) {
        _handlePopClipboardAndSendMessage(content);
      }
    }
  }

  Future<void> _removeClipboardListener() async {
    logInfo('Removing clipboard listener');
    // Stop monitoring
    stopListeningClipboard();
  }

  Future<void> _setClipboardListener() async {
    logInfo('Setting clipboard listener');
    // Start monitoring clipboard changes
    startListeningClipboard(pollingInterval: const Duration(seconds: 3));
  }

  Future<void> _pushIntoClipboard(P2PCMessage msg) async {
    // Disable pop clipboard to prevent multiple copies
    _flagPopClipboard.value = false;
    // Process the message based on its type
    late bool copyResult;
    logDebug('Pushing message to clipboard: ${msg.content}');
    if (msg.type == P2PCMessageType.text) {
      // If the message is text, copy it directly
      FlutterClipboard.copy(msg.content);
      copyResult = true;
      logDebug('Text copied to clipboard: ${msg.content}');
    } else {
      // If the message is a file, check if the file exists, then copy its content
      await TaskQueueManager.runTaskAfterAndRepeatMax(
          delay: const Duration(seconds: 2),
          task: () async {
            // Update the message to ensure it has the latest syncId
            msg = widget.chat.messages
                    .filter()
                    .syncIdEqualTo(msg.syncId)
                    .findFirstSync() ??
                msg;
            // Check if the message has a valid file path
            if (msg.filePath != null && msg.filePath!.isNotEmpty) {
              final file = File(msg.filePath!);
              try {
                if (await file.exists()) {
                  final bytes = await file.readAsBytes();
                  await Pasteboard.writeImage(bytes);
                  logDebug('Image copied to clipboard successfully.');
                  copyResult = true;
                  return true;
                } else {
                  logError('File does not exist: ${msg.filePath}');
                  copyResult = false;
                  return false;
                }
              } catch (e) {
                logError('Error copying image to clipboard: $e');
                copyResult = false;
                return false;
              }
            } else {
              logError(
                  'Message does not have a valid file path: ${msg.filePath}');
              copyResult = false;
              return false;
            }
          },
          maxRepeats: 3);
    }
    // If deleteAfterCopy is true, remove the message after copying
    if (widget.chat.deleteAfterCopy && copyResult) {
      await widget.controller.p2pChatService.removeMessageAndNotify(
          chat: widget.chat, message: msg, deleteFileIfExist: false);
    }
    // Set the flag to true after copying
    TaskQueueManager.runTaskAfter(
        delay: const Duration(seconds: p2pChatClipboardPollingInterval),
        task: () async {
          _flagPopClipboard.value = true;
        });
  }

  Future<void> _handleClipboardPushed(P2PCMessage msg) async {
    if (widget.controller
            .isUserOnline(widget.chat.userBId) && // Other user must be online
        widget.chat
            .autoCopyIncomingMessages && // Chat must have auto copy enabled
        msg.isCopiable() && // Message must be copiable
        msg.senderId == widget.chat.userBId &&
        msg.sentAt.isAfter(// Only push if the message is recent
            DateTime.now().subtract(const Duration(seconds: 7)))) {
      if (_flagPushClipboard.value) {
        _pushIntoClipboard(msg);
      } else {
        TaskQueueManager().observeValueOnce<bool>(
            notifier: _flagPushClipboard,
            callback: (val) => _pushIntoClipboard(msg));
      }
    }
  }

  bool _isImageFile(PlatformFile file) {
    final ext = file.extension?.toLowerCase() ?? '';
    return _imageExtensions.contains(ext);
  }

  bool _isVideoFile(PlatformFile file) {
    final ext = file.extension?.toLowerCase() ?? '';
    return _videoExtensions.contains(ext);
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    // Check if the current scroll position is close to the bottom
    final isAtBottom = (maxScroll - currentScroll).abs() < 50;
    if (isAtBottom && !_isFocusNewest) {
      setState(() {
        _isFocusNewest = true;
        _showScrollToBottom = false;
      });
    } else if (!isAtBottom && _isFocusNewest) {
      setState(() {
        _isFocusNewest = false;
        _showScrollToBottom = true;
      });
    } else if (!isAtBottom && !_showScrollToBottom) {
      setState(() {
        _showScrollToBottom = true;
      });
    } else if (isAtBottom && _showScrollToBottom) {
      setState(() {
        _showScrollToBottom = false;
      });
    }
  }

  void _scrollToBottom({bool force = false}) {
    if (!_scrollController.hasClients) return;
    if (_visibleMessages.isEmpty && !force) return;
    logDebug('Scrolling to bottom');
    // Scroll to the last message (not extentTotal, which may be inaccurate if not rendered)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
        setState(() {
          _isFocusNewest = true;
          _showScrollToBottom = false;
        });
      } catch (e) {
        logError('Scroll to bottom error: $e');
      }
    });
  }

  Future<void> _sendChatMessage({String setSyncId = 'random'}) async {
    final text = _textController.text;
    final chat = widget.chat;
    final controller = widget.controller;
    final myId = chat.userAId;
    final peerId = chat.userBId;

    // Select all files and media to send
    final allFiles = [..._selectedFiles, ..._selectedMedia];
    if (allFiles.isNotEmpty) {
      for (final file in allFiles) {
        P2PCMessage msg;
        if (_isImageFile(file)) {
          msg = P2PCMessage.createMediaImageMessage(
            senderId: myId,
            filePath: file.path ?? '',
            chat: chat,
            syncId: setSyncId,
          );
        } else if (_isVideoFile(file)) {
          msg = P2PCMessage.createMediaVideoMessage(
            senderId: myId,
            filePath: file.path ?? '',
            chat: chat,
            syncId: setSyncId,
          );
        } else {
          msg = P2PCMessage.createFileMessage(
            senderId: myId,
            filePath: file.path ?? '',
            chat: chat,
            fileName: file.name,
            syncId: setSyncId,
          );
        }
        final peerUser = controller.getUserById(peerId);
        if (peerUser == null) continue;
        final messageData = P2PMessage(
            type: P2PMessageTypes.sendChatMessage,
            fromUserId: myId,
            toUserId: chat.userBId,
            data: msg.toJson());
        final sendResult = await controller.p2pService.networkService
            .sendMessageToUser(peerUser, messageData.toJson());
        if (sendResult) {
          logDebug('Sent file/media to peer and reset result');
          final chatService = widget.controller.p2pChatService;
          await chatService.addMessageAndNotify(
              msg, chat, P2PCMessageStatus.onDevice);
          // Set the file path for the message
          await controller.p2pService.sendMultipleFiles(
              filePaths: [file.path ?? ''],
              targetUser: peerUser,
              transferOnly: false);
        }
      }
      setState(() {
        _selectedFiles.clear();
        _selectedMedia.clear();
      });
    }

    // Gửi text nếu có
    if (text.trim().isNotEmpty) {
      // if (text.length > 2048) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text('Tin nhắn quá dài (tối đa 2048 ký tự)!'),
      //       backgroundColor: Colors.red,
      //     ),
      //   );
      //   return;
      // }
      final msg = P2PCMessage.createTextMessage(
          senderId: myId, content: text, chat: chat, syncId: setSyncId);
      _textController.clear();
      final peerUser = controller.getUserById(peerId);
      if (peerUser == null) return;
      final messageData = P2PMessage(
          type: P2PMessageTypes.sendChatMessage,
          fromUserId: myId,
          toUserId: chat.userBId,
          data: msg.toJson());
      final sendResult = await controller.p2pService.networkService
          .sendMessageToUser(peerUser, messageData.toJson());
      if (sendResult) {
        logDebug('Sent message to peer and reset result');
        final chatService = widget.controller.p2pChatService;
        await chatService.addMessageAndNotify(
            msg, chat, P2PCMessageStatus.onDevice);
        if (mounted) setState(() {});
      }
    }
  }

  Future<void> _showFileLostDialog(P2PCMessage msg) async {
    await showDialog(
      context: context,
      builder: (ctx) => GenericDialog(
        header: GenericDialogHeader(title: _loc.fileLostRequest),
        body: Text(_loc.fileLostRequestDesc),
        footer: GenericDialogFooter.twoCustomButtons(
          context: context,
          leftButton: TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(_loc.close),
          ),
          rightButton: TextButton(
            onPressed: () {
              _requestFile(msg.syncId);
              Navigator.of(ctx).pop();
            },
            child: Text(_loc.fileLostRequest),
          ),
        ),
        decorator: GenericDialogDecorator(
            width: DynamicDimension.flexibilityMax(90, 500),
            displayTopDivider: true),
      ),
    );
  }

  Future<void> _requestFile(String syncId) async {
    // Send a request to the peer to resend the file
    final peerUser = widget.controller.getUserById(widget.chat.userBId)!;

    final messageData = P2PMessage(
        type: P2PMessageTypes.chatRequestFileBackward,
        fromUserId: widget.chat.userAId,
        toUserId: widget.chat.userBId,
        data: {
          'syncId': syncId,
        });
    final sendResult = await widget.controller.p2pService.networkService
        .sendMessageToUser(peerUser, messageData.toJson());
    if (sendResult) {
      logDebug('Sent file request backward to peer and get result');
    }

    return Future.value();
  }

  Widget _buildMessageWidget(P2PCMessage msg, bool isMe) {
    switch (msg.type) {
      case P2PCMessageType.text:
        return _buildTextMessageWidget(msg, isMe);
      case P2PCMessageType.mediaImage:
      case P2PCMessageType.mediaVideo:
        return _buildMediaMessageWidget(msg, isMe);
      case P2PCMessageType.file:
        return _buildFileMessageWidget(msg, isMe);
    }
  }

  Widget _buildSubtitleWidget(P2PCMessageStatus status, int fileSize) {
    return status == P2PCMessageStatus.onDevice
        ? Text(
            '${(fileSize / 1024).toStringAsFixed(1)} KB',
            style: TextStyle(
                fontSize: 12,
                color: Theme.of(context)
                    .colorScheme
                    .onSecondary), // Use theme color
          )
        : Text(
            status == P2PCMessageStatus.lost
                ? _loc.fileLost
                : _loc.fileLostOnBothSides,
            style: const TextStyle(fontSize: 12, color: Colors.red),
            overflow: TextOverflow.ellipsis);
  }

  Future<void> _copyMessage(P2PCMessage msg) async {
    // Disable pop clipboard to prevent multiple copies
    _flagPopClipboard.value = false;
    // Process based on message type
    if (msg.type == P2PCMessageType.text) {
      FlutterClipboard.copy(msg.content);
    } else {
      if (msg.filePath != null && msg.filePath!.isNotEmpty) {
        final file = File(msg.filePath!);
        if (file.existsSync()) {
          // If the file exists, copy its content to clipboard
          Pasteboard.writeImage(await file.readAsBytes());
        } else {
          widget.controller.p2pChatService
              .updateMessageStatus(msg, widget.chat, P2PCMessageStatus.lost);
          // If the file does not exist, show an error
          SnackbarUtils.showTyped(context, _loc.fileLost, SnackBarType.error);
        }
      } else {
        widget.controller.p2pChatService
            .updateMessageStatus(msg, widget.chat, P2PCMessageStatus.lost);
        SnackbarUtils.showTyped(context, _loc.noPathToCopy, SnackBarType.error);
      }
    }
    // Re-enable pop clipboard after copying
    TaskQueueManager.runTaskAfter(
        delay: const Duration(seconds: p2pChatClipboardPollingInterval),
        task: () async => _flagPopClipboard.value = true);
  }

  void _showMessagesContextMenu(P2PCMessage msg, Offset? position) {
    final options = [
      if (msg.isCopiable() && msg.isNotLost())
        OptionItem(
            label: _loc.copy, icon: Icons.copy, onTap: () => _copyMessage(msg)),
      OptionItem(
          label: _loc.deleteMessage,
          icon: Icons.delete,
          onTap: () {
            GenericDialogUtils.showSimpleGenericClearDialog(
              context: context,
              title: _loc.deleteMessage,
              description: _loc.deleteMessageDesc,
              onConfirm: () async {
                await widget.controller.p2pChatService.removeMessageAndNotify(
                    chat: widget.chat, message: msg, deleteFileIfExist: false);
              },
            );
          }),
      if (msg.containsFileAndNotLost())
        OptionItem(
            label: _loc.deleteMessageAndFile,
            icon: Icons.delete_forever,
            onTap: () {
              GenericDialogUtils.showSimpleGenericClearDialog(
                context: context,
                title: _loc.deleteMessageAndFile,
                description: _loc.deleteMessageAndFileDesc,
                onConfirm: () async {
                  await widget.controller.p2pChatService.removeMessageAndNotify(
                      chat: widget.chat, message: msg, deleteFileIfExist: true);
                },
              );
            }),
      if (msg.containsFileAndNotLost() && Platform.isWindows)
        OptionItem(
            label: 'Mở trong trình xem',
            icon: Icons.folder_open,
            onTap: () => UriUtils.openInFileExplorer(msg.filePath!)),
    ];
    GenericContextMenu.show(
        context: context,
        actions: options,
        position: position,
        topWidget: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(_loc
              .sendAt(LocalizationUtils.formatDateTime(context, msg.sentAt))),
        ),
        onInit: () => _textFocusNode.unfocus(),
        desktopDialogWidth: 240);
  }

  Widget _buildTextMessageWidget(P2PCMessage msg, bool isMe) {
    final theme = Theme.of(context);
    final faded = msg.status == P2PCMessageStatus.waiting;
    final content = msg.content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final urlRegex = RegExp(r'(https?:\/\/[^\s]+)');
    final urls = urlRegex
        .allMatches(content)
        .map((m) => m.group(0))
        .whereType<String>()
        .toList();
    return GestureDetector(
      onLongPressStart: (detail) =>
          _showMessagesContextMenu(msg, detail.globalPosition),
      onSecondaryTapDown: (detail) =>
          _showMessagesContextMenu(msg, detail.globalPosition),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isMe ? Colors.blue[100] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Opacity(
                  opacity: faded ? 0.5 : 1.0,
                  child: MarkdownBody(
                    data: content,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(color: theme.colorScheme.onSecondary),
                    ),
                    softLineBreak: true,
                  ),
                ),
              ),
            ),
          ),
          if (urls.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.only(top: 2, left: 8, right: 8, bottom: 2),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: urls
                    .map((url) => MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              UriUtils.launchInBrowser(url, context);
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.link,
                                      color: Colors.blue, size: 18),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      url,
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaMessageWidget(P2PCMessage msg, bool isMe) {
    P2PCMessageStatus status = msg.status;
    bool fileExists = true;
    if (msg.status == P2PCMessageStatus.lost ||
        msg.status == P2PCMessageStatus.lostBoth) {
      fileExists = false;
    } else if (msg.status == P2PCMessageStatus.onDevice) {
      fileExists =
          msg.filePath == null ? false : File(msg.filePath!).existsSync();
      if (!fileExists) {
        status = P2PCMessageStatus.lost;
        widget.controller.p2pChatService
            .updateMessageStatus(msg, widget.chat, status);
      }
    }
    if (!fileExists) {
      return GestureDetector(
        onLongPressStart: (details) =>
            _showMessagesContextMenu(msg, details.globalPosition),
        onSecondaryTapDown: (details) =>
            _showMessagesContextMenu(msg, details.globalPosition),
        child: Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: FractionallySizedBox(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            widthFactor: 0.8,
            child: ListTile(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Theme.of(context).colorScheme.tertiary,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              leading: Icon(
                  msg.type == P2PCMessageType.mediaImage
                      ? Icons.image
                      : Icons.video_call,
                  color: fileExists ? Colors.blue : Colors.red),
              title: Text(
                msg.content,
                style: TextStyle(
                  color: fileExists ? Colors.black : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              onTap: () async {
                if (status == P2PCMessageStatus.lost) {
                  _showFileLostDialog(msg);
                }
              },
              subtitle: _buildSubtitleWidget(status, 0),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              visualDensity: VisualDensity.compact,
              minVerticalPadding: 0,
              dense: true,
            ),
          ),
        ),
      );
    }
    return GestureDetector(
      onLongPressStart: (details) =>
          _showMessagesContextMenu(msg, details.globalPosition),
      onSecondaryTapDown: (details) =>
          _showMessagesContextMenu(msg, details.globalPosition),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Theme.of(context).colorScheme.secondary,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(0),
          ),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                if (msg.type == P2PCMessageType.mediaImage) {
                  // Open image in full screen
                  MediaUtils.openImageInFullscreen(
                    context: context,
                    filePath: msg.filePath!,
                  );
                }
              },
              child: msg.type == P2PCMessageType.mediaImage
                  ? // Image
                  Image.file(
                      File(msg.filePath!),
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    )
                  : // TODO: Video
                  const Text(
                      'Not supported yet',
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFileMessageWidget(P2PCMessage msg, bool isMe) {
    P2PCMessageStatus status = msg.status;
    bool fileExists = true;
    if (msg.status == P2PCMessageStatus.lost ||
        msg.status == P2PCMessageStatus.lostBoth) {
      fileExists = false;
    } else if (msg.status == P2PCMessageStatus.onDevice) {
      fileExists =
          msg.filePath == null ? false : File(msg.filePath!).existsSync();
      if (!fileExists) {
        status = P2PCMessageStatus.lost;
        widget.controller.p2pChatService
            .updateMessageStatus(msg, widget.chat, status);
      }
    }
    final fileSize = fileExists ? File(msg.filePath!).lengthSync() : 0;
    final icon = fileExists ? Icons.insert_drive_file : Icons.error;
    return GestureDetector(
      onLongPressStart: (details) =>
          _showMessagesContextMenu(msg, details.globalPosition),
      onSecondaryTapDown: (details) =>
          _showMessagesContextMenu(msg, details.globalPosition),
      onTap: () async {
        if (msg.status == P2PCMessageStatus.lost) {
          await _showFileLostDialog(msg);
        } else if (fileExists &&
            msg.filePath != null &&
            msg.filePath!.isNotEmpty) {
          // Mở file bằng app hệ điều hành
          try {
            await UriUtils.openFile(msg.filePath!, context: context);
          } catch (e) {
            if (mounted) {
              await showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(_loc.errorOpeningFile),
                  content: Text(_loc.errorOpeningFileDetails(e.toString())),
                  actions: [
                    TextButton(
                      onPressed: () {
                        widget.controller.p2pChatService.updateMessageStatus(
                            msg, widget.chat, P2PCMessageStatus.lost);
                        Navigator.of(ctx).pop();
                      },
                      child: Text(_loc.close),
                    ),
                  ],
                ),
              );
            }
          }
        }
      },
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: FractionallySizedBox(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          widthFactor: 0.8,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
            decoration: BoxDecoration(
              color: fileExists
                  ? (isMe ? Colors.blue[50] : Colors.grey[200])
                  : Colors.red[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: Icon(icon, color: fileExists ? Colors.blue : Colors.red),
              title: Text(
                msg.content,
                style: TextStyle(
                  color: fileExists ? Colors.black : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              subtitle: _buildSubtitleWidget(status, fileSize),
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              minVerticalPadding: 0,
              dense: true,
            ),
          ),
        ),
      ),
    );
  }

  IconButton _buildFilePickerButton(bool isEnable, AppLocalizations loc) {
    return IconButton(
      icon: const Icon(Icons.attach_file),
      tooltip: _loc.attachFile,
      onPressed: isEnable
          ? () async {
              final result =
                  await FilePicker.platform.pickFiles(allowMultiple: true);
              if (result != null && result.files.isNotEmpty) {
                setState(() {
                  _selectedFiles.addAll(
                      result.files.where((f) => !_selectedFiles.contains(f)));
                });
              }
            }
          : null,
    );
  }

  IconButton _buildMediaPickerButton(bool isEnable, AppLocalizations loc) {
    return IconButton(
      icon: const Icon(Icons.photo),
      tooltip: _loc.attachMedia,
      onPressed: isEnable
          ? () async {
              final result = await FilePicker.platform.pickFiles(
                allowMultiple: true,
                type: FileType.custom,
                allowedExtensions: [
                  ..._imageExtensions,
                  // TODO: Support video files in the future
                  // ..._videoExtensions
                ],
              );
              if (result != null && result.files.isNotEmpty) {
                setState(() {
                  _selectedMedia.addAll(
                      result.files.where((f) => !_selectedMedia.contains(f)));
                });
              }
            }
          : null,
    );
  }

  Widget _buildPreviewBar(AppLocalizations loc) {
    if (_selectedFiles.isEmpty && _selectedMedia.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedFiles.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _buildFilePickerButton(true, loc),
                ..._selectedFiles.map((file) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.insert_drive_file,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 4),
                          SizedBox(
                            width: 120,
                            child: Text(
                              file.name,
                              style: const TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedFiles.remove(file);
                                });
                              },
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          if (_selectedMedia.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _buildMediaPickerButton(true, loc),
                ..._selectedMedia.map((file) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _isImageFile(file)
                              ? const Icon(Icons.image,
                                  color: Colors.white, size: 18)
                              : const Icon(Icons.videocam,
                                  color: Colors.white, size: 18),
                          const SizedBox(width: 4),
                          SizedBox(
                            width: 80,
                            child: Text(
                              file.name,
                              style: const TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          if (_isImageFile(file) && file.path != null)
                            Container(
                              width: 32,
                              height: 32,
                              margin: const EdgeInsets.only(right: 4),
                              child: Image.file(
                                File(file.path!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          if (_isVideoFile(file) && file.path != null)
                            Container(
                              width: 32,
                              height: 32,
                              margin: const EdgeInsets.only(right: 4),
                              child: const Center(
                                child: Icon(Icons.play_arrow,
                                    color: Colors.white, size: 20),
                              ),
                            ),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedMedia.remove(file);
                                });
                              },
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ]
        ],
      ),
    );
  }

  Future<void> _saveSettings(P2PChat updatedChat) async {
    // Xử lý tiến trình nền
    if (updatedChat.clipboardSharing != widget.chat.clipboardSharing) {
      if (updatedChat.clipboardSharing) {
        // Nếu bật chia sẻ clipboard, thì bật luôn lắng nghe clipboard
        await _setClipboardListener();
      } else {
        // Nếu tắt chia sẻ clipboard, thì tắt lắng nghe clipboard
        await _removeClipboardListener();
      }
    }
    // Cập nhật đoạn chat
    widget.controller.p2pChatService
        .updateChatSettings(widget.chat, updatedChat);
    // Hiện thông báo thành công
    if (mounted) {
      SnackbarUtils.showTyped(
        context,
        _loc.chatCustomizationSaved,
        SnackBarType.info,
      );
    }
  }

  Future<void> _navigateToChatSettings() async {
    GenericSettingsHelper.showSettings(
        context,
        GenericSettingsConfig<P2PChat>(
            title: _loc.chatCustomization,
            settingsLayout: Padding(
              padding: const EdgeInsets.all(16),
              child: P2PChatSettingsLayout(
                chat: widget.chat,
                onSave: _saveSettings,
              ),
            ),
            onSettingsChanged: _saveSettings));
  }

  @override
  Widget build(BuildContext context) {
    final chatService = widget.controller.p2pChatService;
    final chatId = widget.chat.id.toString();
    final loc = AppLocalizations.of(context)!;

    return AnimatedBuilder(
      animation: chatService,
      builder: (context, _) {
        // Always get latest chat instance from service
        final chat = chatService.chatIdExists(chatId)
            ? chatService.getChatById(chatId) ?? widget.chat
            : widget.chat;
        final isOnline = widget.controller.isUserOnline(chat.userBId);
        final myId = chat.userAId;
        // Get all messages for the chat
        final allMessages = chat.messages.toList();
        if (_visibleMessages.isEmpty ||
            (allMessages.isNotEmpty &&
                _visibleMessages.isNotEmpty &&
                allMessages.last.id != _visibleMessages.last.id)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initLoadMessages();
          });
          if (allMessages.isNotEmpty) {
            _handleClipboardPushed(allMessages.last);
          }
        }
        _lastMessageCount = allMessages.length;
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Text(chat.displayName),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 10,
                  backgroundColor: isOnline ? Colors.green : Colors.grey,
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                color: Theme.of(context).dividerColor,
                height: 1,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_applications),
                tooltip: _loc.chatCustomization,
                onPressed: _navigateToChatSettings,
              ),
            ],
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        ListView.builder(
                          controller: _scrollController,
                          reverse: false,
                          padding: const EdgeInsets.all(16),
                          itemCount: _visibleMessages.length,
                          itemBuilder: (context, i) {
                            final msg = _visibleMessages[i];
                            final isMe = msg.senderId == myId;
                            return _buildMessageWidget(msg, isMe);
                          },
                        ),
                        if (_isLoadingMore)
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              color: Colors.white.withValues(alpha: .8),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _loc.loadingOldMessages,
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Theme.of(context).colorScheme.onSecondary,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPreviewBar(loc),
                        Row(
                          children: [
                            Expanded(
                              child: KeyboardListener(
                                focusNode: FocusNode(),
                                onKeyEvent: (event) {
                                  // Check for Ctrl+Enter combination
                                  if (isOnline &&
                                      event is KeyDownEvent &&
                                      HardwareKeyboard
                                          .instance.isControlPressed &&
                                      event.logicalKey ==
                                          LogicalKeyboardKey.enter) {
                                    _sendChatMessage();
                                  }
                                },
                                child: TextField(
                                  controller: _textController,
                                  focusNode: _textFocusNode,
                                  enabled: isOnline,
                                  maxLength: 2048,
                                  maxLines: null,
                                  keyboardType: TextInputType.multiline,
                                  decoration: InputDecoration(
                                    fillColor:
                                        Theme.of(context).colorScheme.surface,
                                    counterText: '',
                                  ),
                                ),
                              ),
                            ),
                            if (_selectedFiles.isEmpty)
                              _buildFilePickerButton(isOnline, loc),
                            if (_selectedMedia.isEmpty)
                              _buildMediaPickerButton(isOnline, loc),
                            if (_textController.text.isNotEmpty ||
                                _selectedFiles.isNotEmpty ||
                                _selectedMedia.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.send),
                                tooltip: _loc.sendMessage,
                                onPressed: isOnline ? _sendChatMessage : null,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_showScrollToBottom)
                Positioned(
                  bottom: 70,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8),
                      ),
                      icon: const Icon(Icons.arrow_downward),
                      label: Text(_loc.scrollToBottom),
                      onPressed: _scrollToBottom,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
