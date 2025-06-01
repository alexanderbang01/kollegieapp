import 'api_service.dart';

class NewsService {
  // Hent nyheder med pagination
  static Future<Map<String, dynamic>> getNews({
    String? userId,
    bool featuredOnly = false,
    int page = 1,
    int limit = 20,
  }) async {
    return await ApiService.get(
      endpoint: '/news/get_news.php',
      queryParams: {
        'user_id': userId ?? '1',
        'featured_only': featuredOnly.toString(),
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );
  }

  // Hent seneste nyheder for home screen
  static Future<Map<String, dynamic>> getLatestNews({
    String? userId,
    int limit = 2,
  }) async {
    return await getNews(
      userId: userId,
      featuredOnly: false,
      page: 1,
      limit: limit,
    );
  }

  // Hent kun fremhævede nyheder
  static Future<Map<String, dynamic>> getFeaturedNews({
    String? userId,
    int limit = 10,
  }) async {
    return await getNews(
      userId: userId,
      featuredOnly: true,
      page: 1,
      limit: limit,
    );
  }

  // Marker nyhed som læst
  static Future<Map<String, dynamic>> markNewsAsRead({
    required String userId,
    required int newsId,
  }) async {
    return await ApiService.post(
      endpoint: '/news/mark_as_read.php',
      authorization: '$userId:resident',
      body: {'news_id': newsId},
    );
  }
}
