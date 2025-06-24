import 'api_service.dart';

class EmployeesService {
  // Hent alle medarbejdere (fra users tabellen) - respekterer sorteringsrækkefølge fra web admin
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
      endpoint:
          '/employees/get_employees.php', // Brug employees endpoint som respekterer sortering
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
      endpoint: '/employees/get-employee-details.php',
      queryParams: {'id': employeeId.toString()},
    );
  }

  // Hent kontaktpersoner til kontakt-skærmen (med sortering fra admin)
  static Future<Map<String, dynamic>> getContactEmployees() async {
    return await ApiService.get(
      endpoint: '/employees/get_employees.php',
      queryParams: {'contact_format': 'true', 'limit': '100'},
    );
  }

  // Hent medarbejdere direkte fra users endpoint (uden sortering - bruges til backup)
  static Future<Map<String, dynamic>> getUsersAsEmployees({
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
      endpoint: '/users/get_users.php',
      queryParams: queryParams,
    );
  }
}
