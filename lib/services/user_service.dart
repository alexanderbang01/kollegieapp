import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class UserService {
  // Check om brugeren er registreret
  static Future<bool> isUserRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_registered') ?? false;
  }

  // Hent brugerdata
  static Future<Map<String, String?>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'firstName': prefs.getString('user_first_name'),
      'lastName': prefs.getString('user_last_name'),
      'email': prefs.getString('user_email'),
      'phone': prefs.getString('user_phone'),
      'roomNumber': prefs.getString('user_room_number'),
      'contactName': prefs.getString('user_contact_name'),
      'contactPhone': prefs.getString('user_contact_phone'),
      'userType': prefs.getString('user_type'),
      'userId': prefs.getString('user_id'),
    };
  }

  // Hent fulde navn
  static Future<String> getFullName() async {
    final userData = await getUserData();
    final firstName = userData['firstName'] ?? '';
    final lastName = userData['lastName'] ?? '';
    return '$firstName $lastName'.trim();
  }

  // Hent bruger ID
  static Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    if (userId == null) {
      userId = '1';
      await prefs.setString('user_id', userId);
    }
    return userId;
  }

  // Hent bruger type
  static Future<String> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_type') ?? 'resident';
  }

  // Gem bruger ID (når vi får det fra serveren)
  static Future<void> setUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
  }

  // Log ud bruger (ryd registrering)
  static Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Slet brugerens konto (kun for residents)
  static Future<bool> deleteAccount() async {
    try {
      final userId = await getUserId();
      final userType = await getUserType();

      // Kun residents kan slette deres konto
      if (userType != 'resident') {
        return false;
      }

      final response = await ApiService.delete(
        endpoint: '/residents/delete_account.php',
        authorization: 'Bearer $userId:$userType',
      );

      if (response['success'] == true) {
        // Ryd lokal data efter succesfuld sletning
        await clearUserData();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Ryd alle lokale brugerdata
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Opdater brugerdata
  static Future<void> updateUserData(Map<String, String> data) async {
    final prefs = await SharedPreferences.getInstance();

    for (String key in data.keys) {
      if (data[key] != null) {
        await prefs.setString('user_$key', data[key]!);
      }
    }
  }

  // Opdater specifik brugerdata med bedre key mapping
  static Future<void> updateUserDataAdvanced(Map<String, String> data) async {
    final prefs = await SharedPreferences.getInstance();

    // Map fra input keys til SharedPreferences keys
    final keyMap = {
      'firstName': 'user_first_name',
      'lastName': 'user_last_name',
      'email': 'user_email',
      'phone': 'user_phone',
      'roomNumber': 'user_room_number',
      'contactName': 'user_contact_name',
      'contactPhone': 'user_contact_phone',
      'userType': 'user_type',
      'userId': 'user_id',
    };

    for (String inputKey in data.keys) {
      final prefKey = keyMap[inputKey] ?? 'user_$inputKey';
      if (data[inputKey] != null) {
        await prefs.setString(prefKey, data[inputKey]!);
      }
    }
  }

  // Gem komplet registreringsdata
  static Future<void> saveRegistrationData({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String roomNumber,
    required String contactName,
    required String contactPhone,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('user_id', userId);
    await prefs.setString('user_first_name', firstName);
    await prefs.setString('user_last_name', lastName);
    await prefs.setString('user_email', email);
    await prefs.setString('user_phone', phone);
    await prefs.setString('user_room_number', roomNumber);
    await prefs.setString('user_contact_name', contactName);
    await prefs.setString('user_contact_phone', contactPhone);
    await prefs.setString('user_type', 'resident');
    await prefs.setBool('is_registered', true);
  }

  // Generer initialer fra navn
  static Future<String> getUserInitials() async {
    final userData = await getUserData();
    final firstName = userData['firstName'] ?? '';
    final lastName = userData['lastName'] ?? '';

    String initials = '';
    if (firstName.isNotEmpty) {
      initials += firstName[0].toUpperCase();
    }
    if (lastName.isNotEmpty) {
      initials += lastName[0].toUpperCase();
    }

    return initials.isNotEmpty ? initials : 'U';
  }

  // Check om vi har alle nødvendige data
  static Future<bool> hasCompleteUserData() async {
    final userData = await getUserData();

    return userData['firstName']?.isNotEmpty == true &&
        userData['lastName']?.isNotEmpty == true &&
        userData['email']?.isNotEmpty == true &&
        userData['phone']?.isNotEmpty == true &&
        userData['roomNumber']?.isNotEmpty == true;
  }
}
