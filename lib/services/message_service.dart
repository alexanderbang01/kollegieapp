import 'api_service.dart';

class MessageService {
  // Generer authorization token (user_id:user_type)
  static String _getAuthToken(String userId, String userType) {
    return '$userId:$userType';
  }

  // Hent alle samtaler for en bruger
  static Future<Map<String, dynamic>> getConversations({
    required String userId,
    required String userType,
  }) async {
    return await ApiService.get(
      endpoint: '/messages/get_conversations.php',
      authorization: _getAuthToken(userId, userType),
    );
  }

  // Hent beskeder for en specifik samtale
  static Future<Map<String, dynamic>> getMessages({
    required String userId,
    required String userType,
    required String contactId,
    required String contactType,
  }) async {
    return await ApiService.get(
      endpoint: '/messages/get_messages.php',
      authorization: _getAuthToken(userId, userType),
      queryParams: {'contact_id': contactId, 'contact_type': contactType},
    );
  }

  // Send en ny besked
  static Future<Map<String, dynamic>> sendMessage({
    required String userId,
    required String userType,
    required String message,
    required String recipientId,
    required String recipientType,
  }) async {
    return await ApiService.post(
      endpoint: '/messages/send_message.php',
      authorization: _getAuthToken(userId, userType),
      body: {
        'message': message,
        'recipient_id': int.parse(recipientId),
        'recipient_type': recipientType,
      },
    );
  }

  // Opdater en eksisterende besked
  static Future<Map<String, dynamic>> updateMessage({
    required String userId,
    required String userType,
    required String messageId,
    required String newContent,
  }) async {
    return await ApiService.put(
      endpoint: '/messages/update_message.php',
      authorization: _getAuthToken(userId, userType),
      body: {'message_id': int.parse(messageId), 'content': newContent},
    );
  }

  // Slet en besked
  static Future<Map<String, dynamic>> deleteMessage({
    required String userId,
    required String userType,
    required String messageId,
  }) async {
    return await ApiService.delete(
      endpoint: '/messages/delete_message.php',
      authorization: _getAuthToken(userId, userType),
      body: {'message_id': int.parse(messageId)},
    );
  }

  // Marker beskeder som læst
  static Future<Map<String, dynamic>> markAsRead({
    required String userId,
    required String userType,
    required String contactId,
    required String contactType,
  }) async {
    return await ApiService.post(
      endpoint: '/messages/mark_read.php',
      authorization: _getAuthToken(userId, userType),
      body: {'contact_id': int.parse(contactId), 'contact_type': contactType},
    );
  }
}
