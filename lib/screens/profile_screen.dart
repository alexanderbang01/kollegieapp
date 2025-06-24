import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Tilføjet for input formatters
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../widgets/navigation_menu.dart';
import '../widgets/success_notification.dart';
import '../services/user_service.dart';

// Custom formatter for værelsenummer - kun tillader 3 cifre
class _RoomNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Fjern alle ikke-numeriske tegn
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Begræns til maksimalt 3 cifre
    final limitedText = text.length > 3 ? text.substring(0, 3) : text;

    return newValue.copyWith(
      text: limitedText,
      selection: TextSelection.collapsed(offset: limitedText.length),
    );
  }
}

// Custom formatter for telefonnummer - kun tillader 8 cifre med mellemrum hver anden cifre
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Fjern alle ikke-numeriske tegn
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Begræns til maksimalt 8 cifre
    final limitedText = text.length > 8 ? text.substring(0, 8) : text;

    // Formater med mellemrum hver anden cifre (XX XX XX XX)
    String formattedText = '';
    for (int i = 0; i < limitedText.length; i++) {
      if (i > 0 && i % 2 == 0) {
        formattedText += ' ';
      }
      formattedText += limitedText[i];
    }

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Loading states
  bool _isLoading = true;
  bool _isUpdating = false;

  // User data
  Map<String, String?> _userData = {};
  String _userInitials = '';

  // Edit states for each card
  bool _isEditingPersonal = false;
  bool _isEditingRoom = false;
  bool _isEditingContact = false;

  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _roomNumberController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _roomNumberController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  // Helper funktion til at formatere telefonnummer til visning
  String _formatPhoneForDisplay(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.length != 8) return phone;

    return '${cleanPhone.substring(0, 2)} ${cleanPhone.substring(2, 4)} ${cleanPhone.substring(4, 6)} ${cleanPhone.substring(6, 8)}';
  }

  // Helper funktion til at fjerne formatering før gem
  String _cleanPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userData = await UserService.getUserData();
      final initials = await UserService.getUserInitials();

      setState(() {
        _userData = userData;
        _userInitials = initials;

        // Populate form controllers
        _firstNameController.text = userData['firstName'] ?? '';
        _lastNameController.text = userData['lastName'] ?? '';
        _emailController.text = userData['email'] ?? '';
        // Formater telefonnumre når de indlæses
        _phoneController.text = _formatPhoneForDisplay(userData['phone'] ?? '');
        _roomNumberController.text = userData['roomNumber'] ?? '';
        _contactNameController.text = userData['contactName'] ?? '';
        _contactPhoneController.text = _formatPhoneForDisplay(
          userData['contactPhone'] ?? '',
        );

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        SuccessNotification.show(
          context,
          title: 'Fejl',
          message: 'Kunne ikke indlæse brugerdata: $e',
          icon: Icons.error_outline,
          color: Colors.red,
        );
      }
    }
  }

  // Validering for værelsenummer
  String? _validateRoomNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Værelsenummer er påkrævet';
    }

    final trimmedValue = value.trim();
    if (!RegExp(r'^\d{3}$').hasMatch(trimmedValue)) {
      return 'Værelsenummer skal være præcis 3 cifre (f.eks. 204)';
    }

    return null;
  }

  // Validering for telefonnummer
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Telefonnummer er ikke påkrævet
    }

    final cleanPhone = _cleanPhoneNumber(value);
    if (cleanPhone.length != 8) {
      return 'Telefonnummer skal være præcis 8 cifre';
    }

    return null;
  }

  Future<void> _updateProfile() async {
    // Valider værelsenummer før opdatering
    final roomValidation = _validateRoomNumber(_roomNumberController.text);
    if (roomValidation != null) {
      SuccessNotification.show(
        context,
        title: 'Fejl',
        message: roomValidation,
        icon: Icons.error_outline,
        color: Colors.red,
      );
      return;
    }

    // Valider telefonnumre
    final phoneValidation = _validatePhoneNumber(_phoneController.text);
    if (phoneValidation != null) {
      SuccessNotification.show(
        context,
        title: 'Fejl',
        message: phoneValidation,
        icon: Icons.error_outline,
        color: Colors.red,
      );
      return;
    }

    final contactPhoneValidation = _validatePhoneNumber(
      _contactPhoneController.text,
    );
    if (contactPhoneValidation != null) {
      SuccessNotification.show(
        context,
        title: 'Fejl',
        message: 'Kontaktperson $contactPhoneValidation',
        icon: Icons.error_outline,
        color: Colors.red,
      );
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      final userId = await UserService.getUserId();

      final requestBody = {
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _cleanPhoneNumber(_phoneController.text), // Fjern formatering
        'room_number': _roomNumberController.text.trim(),
        'contact_name': _contactNameController.text.trim(),
        'contact_phone': _cleanPhoneNumber(
          _contactPhoneController.text,
        ), // Fjern formatering
      };

      print('Update request body: $requestBody'); // Debug output

      final response = await http.put(
        Uri.parse(
          'https://kollegie.socdata.dk/api/residents/update_resident.php',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$userId:resident',
        },
        body: json.encode(requestBody),
      );

      print('Update response: ${response.body}'); // Debug output

      final jsonResponse = json.decode(response.body);

      if (jsonResponse['success'] == true) {
        // Update local user data
        await UserService.updateUserDataAdvanced({
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _cleanPhoneNumber(_phoneController.text),
          'roomNumber': _roomNumberController.text.trim(),
          'contactName': _contactNameController.text.trim(),
          'contactPhone': _cleanPhoneNumber(_contactPhoneController.text),
        });

        // Reload user data and exit edit modes
        await _loadUserData();
        setState(() {
          _isEditingPersonal = false;
          _isEditingRoom = false;
          _isEditingContact = false;
        });

        if (mounted) {
          SuccessNotification.show(
            context,
            title: 'Succes!',
            message: 'Profil opdateret',
            icon: Icons.check_circle,
            color: Colors.green,
          );
        }
      } else {
        throw Exception(jsonResponse['message'] ?? 'Opdatering fejlede');
      }
    } catch (e) {
      print('Update error: $e'); // Debug output
      if (mounted) {
        SuccessNotification.show(
          context,
          title: 'Fejl',
          message: 'Kunne ikke opdatere profil: $e',
          icon: Icons.error_outline,
          color: Colors.red,
        );
      }
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  void _cancelEditing(String section) {
    setState(() {
      // Reset controllers to original values
      _firstNameController.text = _userData['firstName'] ?? '';
      _lastNameController.text = _userData['lastName'] ?? '';
      _emailController.text = _userData['email'] ?? '';
      _phoneController.text = _formatPhoneForDisplay(_userData['phone'] ?? '');
      _roomNumberController.text = _userData['roomNumber'] ?? '';
      _contactNameController.text = _userData['contactName'] ?? '';
      _contactPhoneController.text = _formatPhoneForDisplay(
        _userData['contactPhone'] ?? '',
      );

      // Exit edit mode
      if (section == 'personal') _isEditingPersonal = false;
      if (section == 'room') _isEditingRoom = false;
      if (section == 'contact') _isEditingContact = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text(
            'Min Profil',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            ),
          ],
        ),
        endDrawer: const NavigationMenu(currentRoute: profileRoute),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'Min Profil',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      endDrawer: const NavigationMenu(currentRoute: profileRoute),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile header
              _buildProfileHeader(context),

              // Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Personal information
                    _buildInfoCard(
                      context,
                      title: 'Personlige Oplysninger',
                      icon: Icons.person,
                      isEditing: _isEditingPersonal,
                      content: _isEditingPersonal
                          ? [
                              _buildEditableField(
                                'Fornavn',
                                _firstNameController,
                              ),
                              _buildEditableField(
                                'Efternavn',
                                _lastNameController,
                              ),
                              _buildEditableField(
                                'Email',
                                _emailController,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              _buildEditableField(
                                'Telefon',
                                _phoneController,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [_PhoneNumberFormatter()],
                              ),
                            ]
                          : [
                              _buildDetailRow(
                                context,
                                'Navn',
                                '${_userData['firstName'] ?? ''} ${_userData['lastName'] ?? ''}'
                                    .trim(),
                              ),
                              _buildDetailRow(
                                context,
                                'Email',
                                _userData['email'] ?? '',
                              ),
                              _buildDetailRow(
                                context,
                                'Telefon',
                                _formatPhoneForDisplay(
                                  _userData['phone'] ?? '',
                                ),
                              ),
                            ],
                      onEdit: () {
                        setState(() {
                          _isEditingPersonal = true;
                        });
                      },
                      onSave: _updateProfile,
                      onCancel: () => _cancelEditing('personal'),
                    ),

                    const SizedBox(height: 20),

                    // Room information
                    _buildInfoCard(
                      context,
                      title: 'Værelse Information',
                      icon: Icons.home,
                      isEditing: _isEditingRoom,
                      content: _isEditingRoom
                          ? [
                              _buildEditableField(
                                'Værelsesnummer',
                                _roomNumberController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [_RoomNumberFormatter()],
                              ),
                            ]
                          : [
                              _buildDetailRow(
                                context,
                                'Værelsesnummer',
                                _userData['roomNumber'] ?? '',
                              ),
                            ],
                      onEdit: () {
                        setState(() {
                          _isEditingRoom = true;
                        });
                      },
                      onSave: _updateProfile,
                      onCancel: () => _cancelEditing('room'),
                    ),

                    const SizedBox(height: 20),

                    // Emergency contact
                    _buildInfoCard(
                      context,
                      title: 'Kontaktperson',
                      icon: Icons.contacts,
                      isEditing: _isEditingContact,
                      content: _isEditingContact
                          ? [
                              _buildEditableField(
                                'Navn',
                                _contactNameController,
                              ),
                              _buildEditableField(
                                'Telefon',
                                _contactPhoneController,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [_PhoneNumberFormatter()],
                              ),
                            ]
                          : [
                              _buildDetailRow(
                                context,
                                'Navn',
                                _userData['contactName'] ?? 'Ikke angivet',
                              ),
                              _buildDetailRow(
                                context,
                                'Telefon',
                                _userData['contactPhone'] != null &&
                                        _userData['contactPhone']!.isNotEmpty
                                    ? _formatPhoneForDisplay(
                                        _userData['contactPhone']!,
                                      )
                                    : 'Ikke angivet',
                              ),
                            ],
                      onEdit: () {
                        setState(() {
                          _isEditingContact = true;
                        });
                      },
                      onSave: _updateProfile,
                      onCancel: () => _cancelEditing('contact'),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final theme = Theme.of(context);
    final fullName =
        '${_userData['firstName'] ?? ''} ${_userData['lastName'] ?? ''}'.trim();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: theme.colorScheme.primary),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Simpel CircleAvatar med kun initialer
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Text(
                _userInitials,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              fullName.isNotEmpty ? fullName : 'Navn ikke angivet',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Studerende • Mercantec',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> content,
    required bool isEditing,
    VoidCallback? onEdit,
    VoidCallback? onSave,
    VoidCallback? onCancel,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isEditing) ...[
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onCancel,
                    color: Colors.grey,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: _isUpdating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    onPressed: _isUpdating ? null : onSave,
                    color: Theme.of(context).colorScheme.primary,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ] else if (onEdit != null) ...[
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: onEdit,
                    color: Theme.of(context).colorScheme.primary,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ],
            ),
            const Divider(height: 24),
            ...content,
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? helperText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              helperText: helperText,
              helperStyle: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          Flexible(
            child: Text(
              value.isNotEmpty ? value : 'Ikke angivet',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
