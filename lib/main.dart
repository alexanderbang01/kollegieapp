import 'package:flutter/material.dart';
import 'package:kollegieapp/screens/contacts_screen.dart';
import 'package:kollegieapp/screens/chat_screen.dart';
import 'package:kollegieapp/screens/registration_screen.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/food_screen.dart';
import 'screens/news_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/events_screen.dart';
import 'screens/messages_screen.dart';
import 'services/theme_service.dart';
import 'services/user_service.dart';
import 'utils/constants.dart';
import 'utils/theme.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting('da_DK', null);
  runApp(
    ChangeNotifierProvider(create: (_) => ThemeService(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        return MaterialApp(
          title: appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          // Fjernet home og bruger initialRoute i stedet
          initialRoute: '/splash',
          routes: {
            '/splash': (context) => const AppInitializer(),
            homeRoute: (context) => const HomeScreen(),
            settingsRoute: (context) => const SettingsScreen(),
            foodRoute: (context) => const FoodScreen(),
            profileRoute: (context) => const ProfileScreen(),
            eventsRoute: (context) => const EventsScreen(),
            newsRoute: (context) => const NewsScreen(),
            contactsRoute: (context) => const ContactsScreen(),
            messagesRoute: (context) => const MessagesScreen(),
            '/registration': (context) => const RegistrationScreen(),
          },
        );
      },
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({Key? key}) : super(key: key);

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _checkUserRegistration();
  }

  Future<void> _checkUserRegistration() async {
    // Lille delay for splash effect
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      final isRegistered = await UserService.isUserRegistered();

      if (isRegistered) {
        // Bruger er registreret, gå til hovedskærm
        Navigator.of(context).pushReplacementNamed(homeRoute);
      } else {
        // Bruger er ikke registreret, gå til registrering
        Navigator.of(context).pushReplacementNamed('/registration');
      }
    } catch (e) {
      // Hvis der sker en fejl, gå til registrering for at være sikker
      Navigator.of(context).pushReplacementNamed('/registration');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.home,
                color: theme.colorScheme.primary,
                size: 60,
              ),
            ),
            const SizedBox(height: 32),

            // App navn
            Text(
              appName,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version $appVersion',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 48),

            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              'Indlæser...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
