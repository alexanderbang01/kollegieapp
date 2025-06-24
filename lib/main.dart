import 'package:flutter/material.dart';
import 'package:kollegie_app/screens/contacts_screen.dart';
import 'package:kollegie_app/screens/chat_screen.dart';
import 'package:kollegie_app/screens/registration_screen.dart';
import 'package:kollegie_app/screens/info_screen.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/food_screen.dart';
import 'screens/news_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/events_screen.dart';
// import 'screens/messages_screen.dart'; // Kommenteret ud - funktionalitet ikke ønsket lige nu
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
            // messagesRoute: (context) => const MessagesScreen(), // Kommenteret ud - funktionalitet ikke ønsket lige nu
            infoRoute: (context) => const InfoScreen(), // Ny route
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
    _checkRegistrationStatus();
  }

  Future<void> _checkRegistrationStatus() async {
    // Lille forsinkelse for splash screen effekt
    await Future.delayed(const Duration(seconds: 1));

    try {
      final isRegistered = await UserService.isUserRegistered();

      if (mounted) {
        if (isRegistered) {
          // Bruger er registreret, gå til home screen
          Navigator.pushReplacementNamed(context, homeRoute);
        } else {
          // Bruger er ikke registreret, gå til registrering
          Navigator.pushReplacementNamed(context, '/registration');
        }
      }
    } catch (e) {
      // Ved fejl, gå til registrering som fallback
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/registration');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo placeholder - erstat med dit faktiske logo
            Icon(Icons.home, size: 100, color: Colors.white),
            SizedBox(height: 24),
            Text(
              appName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
