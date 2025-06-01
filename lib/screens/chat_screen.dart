import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/constants.dart';
import '../services/message_service.dart';
import '../services/user_service.dart';
import '../models/message_model.dart';
import '../widgets/success_notification.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> conversation;
  final String currentUserId;
  final String currentUserType;

  const ChatScreen({
    Key? key,
    required this.conversation,
    required this.currentUserId,
    required this.currentUserType,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();

  List<Message> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  String _userInitials = '';
  String? _userProfileImageUrl;
  Timer? _messageTimer;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadMessages();
    _startMessagePolling();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    _messageTimer?.cancel();
    super.dispose();
  }

  void _startMessagePolling() {
    _messageTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        _loadMessages(showLoading: false);
      }
    });
  }

  Future<void> _loadUserData() async {
    final initials = await UserService.getUserInitials();
    final profileImageUrl = await UserService.getProfileImageUrl();

    setState(() {
      _userInitials = initials;
      _userProfileImageUrl = profileImageUrl;
    });
  }

  String _generateInitials(String name) {
    if (name.isEmpty) return 'U';

    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    } else {
      return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
    }
  }

  String _getContactProfileImageUrl() {
    final profileImage = widget.conversation['profileImage'];
    if (profileImage != null && profileImage.isNotEmpty) {
      if (!profileImage.startsWith('http')) {
        return 'http://localhost/kollegieapp-webadmin$profileImage';
      }
      return profileImage;
    }
    return '';
  }

  Future<void> _loadMessages({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final response = await MessageService.getMessages(
        userId: widget.currentUserId,
        userType: widget.currentUserType,
        contactId: widget.conversation['id'].toString(),
        contactType: widget.conversation['type'],
      );

      if (response['success'] == true) {
        final List<dynamic> messagesData = response['data'] ?? [];
        final newMessages = messagesData
            .map((data) => Message.fromJson(data))
            .toList();

        // Kun opdater hvis der er ændringer
        if (!_messagesEqual(newMessages, _messages)) {
          setState(() {
            _messages = newMessages;
            if (showLoading) _isLoading = false;
          });

          _scrollToBottom();
        } else if (showLoading) {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        if (showLoading) {
          setState(() {
            _messages = [];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (showLoading) {
        setState(() {
          _messages = [];
          _isLoading = false;
        });
      }
    }
  }

  bool _messagesEqual(List<Message> newMessages, List<Message> oldMessages) {
    if (newMessages.length != oldMessages.length) return false;

    for (int i = 0; i < newMessages.length; i++) {
      if (newMessages[i].id != oldMessages[i].id ||
          newMessages[i].text != oldMessages[i].text) {
        return false;
      }
    }
    return true;
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isSending) return;

    final messageText = _messageController.text.trim();

    setState(() {
      _isSending = true;
    });

    _messageController.clear();

    try {
      final response = await MessageService.sendMessage(
        userId: widget.currentUserId,
        userType: widget.currentUserType,
        message: messageText,
        recipientId: widget.conversation['id'].toString(),
        recipientType: widget.conversation['type'],
      );

      if (response['success'] == true) {
        await _loadMessages();
      } else {
        if (mounted) {
          SuccessNotification.show(
            context,
            title: 'Kunne ikke sende besked',
            message: response['message'] ?? 'Der opstod en fejl ved afsendelse',
            icon: Icons.error_outline,
            color: Colors.red,
          );
        }

        _messageController.text = messageText;
      }
    } catch (e) {
      if (mounted) {
        SuccessNotification.show(
          context,
          title: 'Netværksfejl',
          message: 'Tjek din internetforbindelse og prøv igen',
          icon: Icons.wifi_off,
          color: Colors.red,
        );
      }

      _messageController.text = messageText;
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isStaff = widget.conversation['type'] == 'staff';
    final String contactName = widget.conversation['name'] ?? 'Ukendt';
    final String contactInitials = _generateInitials(contactName);
    final String contactProfileImageUrl = _getContactProfileImageUrl();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: isStaff
                  ? theme.colorScheme.primary.withOpacity(0.3)
                  : theme.colorScheme.secondary.withOpacity(0.3),
              backgroundImage: contactProfileImageUrl.isNotEmpty
                  ? NetworkImage(contactProfileImageUrl)
                  : null,
              child: contactProfileImageUrl.isEmpty
                  ? Text(
                      contactInitials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contactName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    widget.conversation['role'] ?? '',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: theme.brightness == Brightness.light
            ? theme.colorScheme.primary
            : const Color(0xFF1C1C1E),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildBody()),
          _buildMessageInput(theme),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Indlæser beskeder...'),
          ],
        ),
      );
    }

    if (_messages.isEmpty) {
      return _buildEmptyChat();
    }

    return _buildMessagesList();
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Start en samtale',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Send din første besked til ${widget.conversation['name']}',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(Message message) {
    final theme = Theme.of(context);
    final bool isCurrentUser = message.isCurrentUser;
    final String contactName = widget.conversation['name'] ?? 'Ukendt';
    final String contactInitials = _generateInitials(contactName);
    final String contactProfileImageUrl = _getContactProfileImageUrl();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              backgroundImage: contactProfileImageUrl.isNotEmpty
                  ? NetworkImage(contactProfileImageUrl)
                  : null,
              child: contactProfileImageUrl.isEmpty
                  ? Text(
                      contactInitials,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? theme.colorScheme.primary
                    : theme.brightness == Brightness.light
                    ? Colors.grey.shade100
                    : Colors.grey.shade800,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isCurrentUser ? 20 : 4),
                  bottomRight: Radius.circular(isCurrentUser ? 4 : 20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isCurrentUser
                          ? Colors.white
                          : theme.brightness == Brightness.light
                          ? Colors.black87
                          : Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatMessageTime(message.timestamp),
                    style: TextStyle(
                      color: isCurrentUser
                          ? Colors.white.withOpacity(0.7)
                          : Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.7),
              backgroundImage: _userProfileImageUrl != null
                  ? NetworkImage(_userProfileImageUrl!)
                  : null,
              child: _userProfileImageUrl == null
                  ? Text(
                      _userInitials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    )
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light
            ? Colors.white
            : const Color(0xFF1C1C1E),
        border: Border(
          top: BorderSide(color: Colors.grey.shade300, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.light
                      ? Colors.grey.shade100
                      : Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  focusNode: _messageFocusNode,
                  decoration: const InputDecoration(
                    hintText: 'Skriv en besked...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(),
                  enabled: !_isSending,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _isSending ? null : _sendMessage,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _isSending
                      ? Colors.grey.shade400
                      : theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMessageTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
