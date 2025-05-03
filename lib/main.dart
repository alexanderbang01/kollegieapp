import 'package:flutter/material.dart';
import 'package:kollegieapp/screens/contacts_screen.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/food_screen.dart';
import 'screens/news_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/events_screen.dart';
import 'services/theme_service.dart';
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
          initialRoute: homeRoute,
          // Ændrer standard page transitions til Cupertino-stil (iOS)
          routes: {
            homeRoute: (context) => const HomeScreen(),
            settingsRoute: (context) => const SettingsScreen(),
            foodRoute: (context) => const FoodScreen(),
            profileRoute: (context) => const ProfileScreen(),
            eventsRoute: (context) => const EventsScreen(),
            newsRoute: (context) => const NewsScreen(),
            contactsRoute: (context) => const ContactsScreen(),
            // notificationsRoute: (context) => const NotificationsScreen(),
            // maintenanceRoute: (context) => const MaintenanceScreen(),
            // communityRoute: (context) => const CommunityScreen(),
            // aboutRoute: (context) => const AboutScreen(),
          },
        );
      },
    );
  }
}
