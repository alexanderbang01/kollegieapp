import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../widgets/theme_switch.dart';
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
        backgroundColor:
            theme.brightness == Brightness.light
                ? Colors.white
                : const Color(0xFF1C1C1E),
        foregroundColor:
            theme.brightness == Brightness.light
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
      endDrawer: const NavigationMenu(),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
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
                  child: Column(
                    children: [
                      _buildInfoRow(context, 'Navn', 'Alexander Jensen'),
                      const Divider(),
                      _buildInfoRow(context, 'Email', 'alexander@example.com'),
                      const Divider(),
                      _buildInfoRow(context, 'Værelse', 'A-204'),
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
                      _buildInfoRow(context, 'Kontakt', 'support@mercantec.dk'),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Implementer log ud logik her
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Log ud funktion vil blive implementeret senere',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(
                      double.infinity,
                      50,
                    ), // Gør knappen bredere
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Log ud',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ),
            ],
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
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
