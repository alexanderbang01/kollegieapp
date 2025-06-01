import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../widgets/success_notification.dart';
import '../services/auth_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();

  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _roomNumberController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  int _currentPage = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _roomNumberController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AuthService.registerResident(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        roomNumber: _roomNumberController.text.trim().toUpperCase(),
        contactName: _contactNameController.text.trim(),
        contactPhone: _contactPhoneController.text.trim(),
      );

      if (response['success'] == true) {
        final userData = response['user_data'];
        final userId = response['user_id'].toString();

        // Gem brugerdata lokalt med det rigtige ID fra serveren
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', userId); // Vigtigt: brug ID fra server
        await prefs.setString('user_first_name', userData['first_name']);
        await prefs.setString('user_last_name', userData['last_name']);
        await prefs.setString('user_email', userData['email']);
        await prefs.setString('user_phone', userData['phone']);
        await prefs.setString('user_room_number', userData['room_number']);
        await prefs.setString(
          'user_contact_name',
          _contactNameController.text.trim(),
        );
        await prefs.setString(
          'user_contact_phone',
          _contactPhoneController.text.trim(),
        );
        await prefs.setString('user_type', 'resident');
        await prefs.setBool('is_registered', true);

        if (mounted) {
          SuccessNotification.show(
            context,
            title: 'Velkommen ${userData['first_name']}!',
            message:
                'Du er nu registreret på Mercantec Kollegium (ID: $userId)',
            icon: Icons.home,
            color: Colors.green,
            duration: const Duration(seconds: 4),
          );

          // Vent lidt så notifikationen kan vises, derefter naviger
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.of(context).pushReplacementNamed(homeRoute);
            }
          });
        }
      } else {
        if (mounted) {
          SuccessNotification.show(
            context,
            title: 'Registrering fejlede',
            message:
                response['message'] ?? 'Der opstod en fejl ved registrering',
            icon: Icons.error_outline,
            color: Colors.red,
            duration: const Duration(seconds: 5),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SuccessNotification.show(
          context,
          title: 'Netværksfejl',
          message: 'Tjek din internetforbindelse og prøv igen',
          icon: Icons.wifi_off,
          color: Colors.red,
          duration: const Duration(seconds: 5),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      if (_formKey.currentState!.validate()) {
        _registerUser();
      }
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Header med progress
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.home,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Velkommen til',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'Mercantec Kollegium',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Progress bar
                    Row(
                      children: List.generate(3, (index) {
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                            height: 4,
                            decoration: BoxDecoration(
                              color: index <= _currentPage
                                  ? theme.colorScheme.primary
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Trin ${_currentPage + 1} af 3',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Page content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: [
                    _buildPersonalInfoPage(),
                    _buildContactInfoPage(),
                    _buildEmergencyContactPage(),
                  ],
                ),
              ),

              // Navigation buttons
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    if (_currentPage > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _previousPage,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Tilbage'),
                        ),
                      ),
                    if (_currentPage > 0) const SizedBox(width: 16),
                    Expanded(
                      flex: _currentPage == 0 ? 1 : 1,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _nextPage,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: theme.colorScheme.primary,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(_currentPage == 2 ? 'Registrer' : 'Næste'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personlige oplysninger',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Indtast dine grundlæggende oplysninger',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),

          TextFormField(
            controller: _firstNameController,
            decoration: const InputDecoration(
              labelText: 'Fornavn',
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Indtast dit fornavn';
              }
              return null;
            },
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _lastNameController,
            decoration: const InputDecoration(
              labelText: 'Efternavn',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Indtast dit efternavn';
              }
              return null;
            },
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Indtast din email';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Indtast en gyldig email';
              }
              return null;
            },
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kontakt og værelse',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Så vi kan kontakte dig og finde dit værelse',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),

          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Telefonnummer',
              prefixIcon: Icon(Icons.phone),
              hintText: '+45 12 34 56 78',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Indtast dit telefonnummer';
              }
              return null;
            },
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _roomNumberController,
            decoration: const InputDecoration(
              labelText: 'Værelsenummer',
              prefixIcon: Icon(Icons.door_front_door),
              hintText: 'A-204',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Indtast dit værelsenummer';
              }
              return null;
            },
            textCapitalization: TextCapitalization.characters,
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nødkontakt',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Person der kan kontaktes i nødstilfælde',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),

          TextFormField(
            controller: _contactNameController,
            decoration: const InputDecoration(
              labelText: 'Kontaktpersonens navn',
              prefixIcon: Icon(Icons.contact_emergency),
              hintText: 'F.eks. forælder eller ven',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Indtast kontaktpersonens navn';
              }
              return null;
            },
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _contactPhoneController,
            decoration: const InputDecoration(
              labelText: 'Kontaktpersonens telefon',
              prefixIcon: Icon(Icons.phone),
              hintText: '+45 87 65 43 21',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Indtast kontaktpersonens telefonnummer';
              }
              return null;
            },
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.security, color: Colors.green.shade700),
                    const SizedBox(width: 12),
                    Text(
                      'Dine oplysninger er sikre',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Alle dine oplysninger gemmes sikkert i databasen og bruges kun til kollegieformål.',
                  style: TextStyle(color: Colors.green.shade700, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
