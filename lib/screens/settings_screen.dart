import 'package:flutter/material.dart';
import 'package:kollegie_app/widgets/theme_switch.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../services/user_service.dart';
import '../widgets/navigation_menu.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, String?> _userData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await UserService.getUserData();
      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fejl ved indlæsning af brugerdata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'Indstillinger',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: theme.brightness == Brightness.light
            ? Colors.white
            : const Color(0xFF1C1C1E),
        foregroundColor: theme.brightness == Brightness.light
            ? AppTheme.primaryColor
            : Colors.white,
        elevation: 0,
        // Flytter tilbage-knappen til venstre, men bruger iOS-stil
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        // Flytter navigationsmenuen til højre side
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      // Bruger den genbrugelige NavigationMenu-widget
      endDrawer: const NavigationMenu(currentRoute: settingsRoute),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: SingleChildScrollView(
            // Sikrer at indholdet kan scrolles hvis det ikke passer
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Appindstillinger',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),

                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ThemeSwitchWidget(
                        isDarkMode: themeService.isDarkMode,
                        onChanged: (value) {
                          themeService.setTheme(value);
                        },
                      ),
                      SwitchListTile(
                        title: Row(
                          children: [
                            Icon(
                              AppIcons.notifications,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              AppText.notificationsSwitch,
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        value:
                            true, // Dette ville normalt være en gemt indstilling
                        onChanged: (value) {
                          // Implementer notifikationslogik her
                        },
                        activeColor: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.large),

                Text(
                  'Kontoinformation',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),

                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: AppSpacing.cardPadding,
                    child: _isLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : Column(
                            children: [
                              _buildInfoRow(
                                context,
                                'Navn',
                                '${_userData['firstName'] ?? ''} ${_userData['lastName'] ?? ''}'
                                    .trim(),
                              ),
                              const Divider(),
                              _buildInfoRow(
                                context,
                                'Email',
                                _userData['email'] ?? 'Ikke angivet',
                              ),
                              const Divider(),
                              _buildInfoRow(
                                context,
                                'Telefon',
                                _userData['phone'] ?? 'Ikke angivet',
                              ),
                              const Divider(),
                              _buildInfoRow(
                                context,
                                'Værelse',
                                _userData['roomNumber'] ?? 'Ikke angivet',
                              ),
                              const Divider(),
                              _buildInfoRow(
                                context,
                                'Nødkontakt',
                                _userData['contactName'] ?? 'Ikke angivet',
                              ),
                              const Divider(),
                              _buildInfoRow(
                                context,
                                'Nødkontakt telefon',
                                _userData['contactPhone'] ?? 'Ikke angivet',
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: AppSpacing.large),

                Text(
                  'App information',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),

                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: AppSpacing.cardPadding,
                    child: Column(
                      children: [
                        _buildInfoRow(context, 'App version', appVersion),
                        const Divider(),
                        _buildInfoRow(
                          context,
                          'Udviklet af',
                          'Mercantec Studerende',
                        ),
                        const Divider(),
                        _buildInfoRow(
                          context,
                          'Kontakt',
                          'support@mercantec.dk',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
          ),
          Flexible(
            // Flexible sikrer at værdien ikke overskrider skærmens bredde
            child: Text(
              value.isEmpty ? 'Ikke angivet' : value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              overflow:
                  TextOverflow.ellipsis, // Viser "..." hvis teksten er for lang
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log ud'),
          content: const Text('Er du sikker på, at du vil logge ud?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuller'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await UserService.logoutUser();
                  if (mounted) {
                    Navigator.of(context).pop(); // Luk dialog
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/', // Naviger til registreringsskærm
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.of(context).pop(); // Luk dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Fejl ved logout: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Log ud', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
