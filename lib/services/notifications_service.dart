import 'api_service.dart';

class NotificationsService {
  // Hent notifikationer for en bruger
  static Future<Map<String, dynamic>> getNotifications({
    required String userId,
    int limit = 10,
    int page = 1,
  }) async {
    return await ApiService.get(
      endpoint: '/notifications/get_notifications.php',
      queryParams: {
        'user_id': userId,
        'limit': limit.toString(),
        'page': page.toString(),
      },
    );
  }

  // Hent antal ulæste notifikationer
  static Future<Map<String, dynamic>> getUnreadCount({
    required String userId,
  }) async {
    return await ApiService.get(
      endpoint: '/notifications/get_notifications.php',
      queryParams: {'user_id': userId, 'unread_count': 'true'},
    );
  }

  // Marker notifikation som læst
  static Future<Map<String, dynamic>> markAsRead({
    required String userId,
    required int notificationId,
  }) async {
    return await ApiService.post(
      endpoint: '/notifications/mark_read.php',
      body: {'user_id': userId, 'notification_id': notificationId},
    );
  }

  // Marker alle notifikationer som læst
  static Future<Map<String, dynamic>> markAllAsRead({
    required String userId,
  }) async {
    return await ApiService.post(
      endpoint: '/notifications/mark_read.php',
      body: {'user_id': userId, 'mark_all': true},
    );
  }

  // Slet notifikation
  static Future<Map<String, dynamic>> deleteNotification({
    required String userId,
    required int notificationId,
  }) async {
    return await ApiService.delete(
      endpoint: '/notifications/delete_notification.php',
      body: {'user_id': userId, 'notification_id': notificationId},
    );
  }
}
