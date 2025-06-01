import 'api_service.dart';

class AuthService {
  // Registrer en ny beboer
  static Future<Map<String, dynamic>> registerResident({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String roomNumber,
    required String contactName,
    required String contactPhone,
  }) async {
    return await ApiService.post(
      endpoint: '/auth/register_resident.php',
      body: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'room_number': roomNumber,
        'contact_name': contactName,
        'contact_phone': contactPhone,
      },
    );
  }

  // Tjek om email er tilgængelig
  static Future<Map<String, dynamic>> checkEmailAvailability({
    required String email,
  }) async {
    return await ApiService.get(
      endpoint: '/auth/register_resident.php',
      queryParams: {'check_email': email},
    );
  }

  // Tjek om værelsenummer er tilgængeligt
  static Future<Map<String, dynamic>> checkRoomAvailability({
    required String roomNumber,
  }) async {
    return await ApiService.get(
      endpoint: '/auth/register_resident.php',
      queryParams: {'check_room': roomNumber},
    );
  }
}
