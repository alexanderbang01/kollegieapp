import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../widgets/navigation_menu.dart';
import '../widgets/success_notification.dart';
import '../services/user_service.dart';

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
  bool _isUploadingImage = false;

  // User data
  Map<String, String?> _userData = {};
  String _userInitials = '';
  File? _selectedImage;
  bool _hasSelectedNewImage =
      false; // Ny variabel til at tracke om billede er valgt

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
        _phoneController.text = userData['phone'] ?? '';
        _roomNumberController.text = userData['roomNumber'] ?? '';
        _contactNameController.text = userData['contactName'] ?? '';
        _contactPhoneController.text = userData['contactPhone'] ?? '';

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

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _hasSelectedNewImage = true; // Marker at nyt billede er valgt
        });
      }
    } catch (e) {
      if (mounted) {
        SuccessNotification.show(
          context,
          title: 'Fejl',
          message: 'Kunne ikke vælge billede: $e',
          icon: Icons.error_outline,
          color: Colors.red,
        );
      }
    }
  }

  Future<void> _saveImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final userId = await UserService.getUserId();

      // Læs billedet som bytes og konverter til base64
      final Uint8List imageBytes = await _selectedImage!.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      // Få fil extension
      final String extension = _selectedImage!.path
          .split('.')
          .last
          .toLowerCase();

      final response = await http.post(
        Uri.parse(
          'http://localhost/kollegieapp-webadmin/api/residents/upload_profile_image.php',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$userId:resident',
        },
        body: json.encode({
          'image_data': base64Image,
          'file_extension': extension,
        }),
      );

      print('Upload response: ${response.body}'); // Debug output

      final jsonResponse = json.decode(response.body);

      if (jsonResponse['success'] == true) {
        // Update local user data
        await UserService.updateUserDataAdvanced({
          'profileImage': jsonResponse['image_url'] ?? '',
        });

        // Reset image selection state
        setState(() {
          _selectedImage = null;
          _hasSelectedNewImage = false;
        });

        // Reload user data
        await _loadUserData();

        if (mounted) {
          SuccessNotification.show(
            context,
            title: 'Succes!',
            message: 'Profilbillede opdateret',
            icon: Icons.check_circle,
            color: Colors.green,
          );
        }
      } else {
        throw Exception(jsonResponse['message'] ?? 'Upload fejlede');
      }
    } catch (e) {
      print('Upload error: $e'); // Debug output
      if (mounted) {
        SuccessNotification.show(
          context,
          title: 'Fejl',
          message: 'Kunne ikke uploade billede: $e',
          icon: Icons.error_outline,
          color: Colors.red,
        );
      }
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  void _cancelImageSelection() {
    setState(() {
      _selectedImage = null;
      _hasSelectedNewImage = false;
    });
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final userId = await UserService.getUserId();

      final requestBody = {
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'room_number': _roomNumberController.text.trim(),
        'contact_name': _contactNameController.text.trim(),
        'contact_phone': _contactPhoneController.text.trim(),
      };

      print('Update request body: $requestBody'); // Debug output

      final response = await http.put(
        Uri.parse(
          'http://localhost/kollegieapp-webadmin/api/residents/update_resident.php',
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
          'phone': _phoneController.text.trim(),
          'roomNumber': _roomNumberController.text.trim(),
          'contactName': _contactNameController.text.trim(),
          'contactPhone': _contactPhoneController.text.trim(),
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
      _phoneController.text = _userData['phone'] ?? '';
      _roomNumberController.text = _userData['roomNumber'] ?? '';
      _contactNameController.text = _userData['contactName'] ?? '';
      _contactPhoneController.text = _userData['contactPhone'] ?? '';

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
                    Text(
                      'Profil Information',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

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
                                _userData['phone'] ?? '',
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
                                'Værelse',
                                _roomNumberController,
                              ),
                            ]
                          : [
                              _buildDetailRow(
                                context,
                                'Værelse',
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
                                _userData['contactPhone'] ?? 'Ikke angivet',
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
            FutureBuilder<String?>(
              future: UserService.getProfileImageUrl(),
              builder: (context, snapshot) {
                return CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : (snapshot.data != null
                                ? NetworkImage(snapshot.data!)
                                : null)
                            as ImageProvider?,
                  child: (_selectedImage == null && snapshot.data == null)
                      ? Text(
                          _userInitials,
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        )
                      : null,
                );
              },
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
            const SizedBox(height: 16),

            // Vis forskellige knapper baseret på tilstand
            if (_hasSelectedNewImage) ...[
              // Vis Gem og Fortryd knapper når billede er valgt
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isUploadingImage ? null : _cancelImageSelection,
                    icon: const Icon(Icons.close),
                    label: const Text('Fortryd'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _isUploadingImage ? null : _saveImage,
                    icon: _isUploadingImage
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      _isUploadingImage ? 'Gemmer...' : 'Gem Billede',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: theme.colorScheme.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Vis Skift Billede knap når intet billede er valgt
              ElevatedButton.icon(
                onPressed: _isUploadingImage ? null : _pickImage,
                icon: const Icon(Icons.photo_camera),
                label: const Text('Skift Billede'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: theme.colorScheme.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ],
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
