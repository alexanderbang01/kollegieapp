import 'api_service.dart';

class ResidentsService {
  // Hent alle beboere
  static Future<Map<String, dynamic>> getResidents({
    String? searchQuery,
    int page = 1,
    int limit = 50,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (searchQuery != null && searchQuery.isNotEmpty) {
      queryParams['search'] = searchQuery;
    }

    return await ApiService.get(
      endpoint: '/residents/get_residents.php',
      queryParams: queryParams,
    );
  }

  // Søg beboere
  static Future<Map<String, dynamic>> searchResidents({
    required String query,
  }) async {
    return await getResidents(searchQuery: query);
  }

  // Hent specifik beboer detaljer
  static Future<Map<String, dynamic>> getResidentDetails({
    required int residentId,
  }) async {
    return await ApiService.get(
      endpoint: '/residents/get_resident_details.php',
      queryParams: {'id': residentId.toString()},
    );
  }

  // Hent beboere for kontaktformål (forenklet data)
  static Future<Map<String, dynamic>> getContactResidents() async {
    return await ApiService.get(
      endpoint: '/residents/get_residents.php',
      queryParams: {
        'contact_format': 'true', // Returnerer kun kontakt-relevante felter
        'limit': '100', // Hent alle for kontakter
      },
    );
  }

  // Hent beboere efter værelsenummer
  static Future<Map<String, dynamic>> getResidentsByRoom({
    required String roomNumber,
  }) async {
    return await ApiService.get(
      endpoint: '/residents/get_residents.php',
      queryParams: {'room': roomNumber},
    );
  }

  // Tjek om email allerede eksisterer
  static Future<Map<String, dynamic>> checkEmailAvailability({
    required String email,
    int? excludeResidentId,
  }) async {
    final queryParams = {'email': email};

    if (excludeResidentId != null) {
      queryParams['exclude_id'] = excludeResidentId.toString();
    }

    return await ApiService.get(
      endpoint: '/residents/check_email.php',
      queryParams: queryParams,
    );
  }

  // Tjek om værelsenummer er ledigt
  static Future<Map<String, dynamic>> checkRoomAvailability({
    required String roomNumber,
    int? excludeResidentId,
  }) async {
    final queryParams = {'room_number': roomNumber};

    if (excludeResidentId != null) {
      queryParams['exclude_id'] = excludeResidentId.toString();
    }

    return await ApiService.get(
      endpoint: '/residents/check_room.php',
      queryParams: queryParams,
    );
  }

  // Hent beboer statistikker
  static Future<Map<String, dynamic>> getResidentStats() async {
    return await ApiService.get(endpoint: '/residents/get_stats.php');
  }

  // Få beboere sorteret efter navn
  static Future<Map<String, dynamic>> getResidentsSorted({
    String sortBy = 'name', // 'name', 'room', 'email'
    String sortOrder = 'asc', // 'asc', 'desc'
    int page = 1,
    int limit = 50,
  }) async {
    return await ApiService.get(
      endpoint: '/residents/get_residents.php',
      queryParams: {
        'sort_by': sortBy,
        'sort_order': sortOrder,
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );
  }
}
