import 'api_service.dart';

class EventsService {
  // Hent begivenheder med pagination
  static Future<Map<String, dynamic>> getEvents({
    String? userId,
    String? userType,
    bool showPast = false,
    int page = 1,
    int limit = 20,
  }) async {
    return await ApiService.get(
      endpoint: '/events/get_events.php',
      queryParams: {
        'show_past': showPast.toString(),
        'user_id': userId ?? '1',
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );
  }

  // Hent kommende begivenheder
  static Future<Map<String, dynamic>> getUpcomingEvents({
    String? userId,
    String? userType,
    int limit = 2, // Standard 2 for home screen
  }) async {
    return await getEvents(
      userId: userId,
      userType: userType,
      showPast: false,
      page: 1,
      limit: limit,
    );
  }

  // Hent tidligere begivenheder
  static Future<Map<String, dynamic>> getPastEvents({
    String? userId,
    String? userType,
    int page = 1,
    int limit = 20,
  }) async {
    return await getEvents(
      userId: userId,
      userType: userType,
      showPast: true,
      page: page,
      limit: limit,
    );
  }

  // I lib/services/events_service.dart - erstat disse metoder:

  static Future<Map<String, dynamic>> registerForEvent({
    required String userId,
    required String userType,
    required int eventId,
  }) async {
    return await ApiService.post(
      endpoint: '/events/event_registration.php',
      authorization: '$userId:$userType',
      body: {'event_id': eventId},
    );
  }

  static Future<Map<String, dynamic>> unregisterFromEvent({
    required String userId,
    required String userType,
    required int eventId,
  }) async {
    return await ApiService.delete(
      endpoint: '/events/event_registration.php',
      authorization: '$userId:$userType',
      body: {'event_id': eventId},
    );
  }

  static Future<Map<String, dynamic>> toggleEventRegistration({
    required String userId,
    required String userType,
    required int eventId,
    required bool isCurrentlyRegistered,
  }) async {
    if (isCurrentlyRegistered) {
      return await unregisterFromEvent(
        userId: userId,
        userType: userType,
        eventId: eventId,
      );
    } else {
      return await registerForEvent(
        userId: userId,
        userType: userType,
        eventId: eventId,
      );
    }
  }
}
