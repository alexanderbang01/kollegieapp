import 'api_service.dart';

class EmployeesService {
  // Hent alle medarbejdere (fra users tabellen)
  static Future<Map<String, dynamic>> getEmployees({
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
      endpoint: '/users/get_users.php', // Ændret til users endpoint
      queryParams: queryParams,
    );
  }

  // Søg medarbejdere
  static Future<Map<String, dynamic>> searchEmployees({
    required String query,
  }) async {
    return await getEmployees(searchQuery: query);
  }

  // Hent specifik medarbejder detaljer
  static Future<Map<String, dynamic>> getEmployeeDetails({
    required int employeeId,
  }) async {
    return await ApiService.get(
      endpoint: '/users/get_user_details.php',
      queryParams: {'id': employeeId.toString()},
    );
  }

  static Future<Map<String, dynamic>> getContactEmployees() async {
    return await ApiService.get(
      endpoint: '/users/get_users.php',
      queryParams: {'contact_format': 'true', 'limit': '100'},
    );
  }
}
