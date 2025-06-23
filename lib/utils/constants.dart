import 'package:flutter/material.dart';
import '../utils/theme.dart';

// App information
const String appName = 'Mercantec Kollegium';
const String appVersion = '1.0.0';

// Route names
const String homeRoute = '/';
const String eventsRoute = '/events';
const String foodRoute = '/food';
const String notificationsRoute = '/notifications';
const String maintenanceRoute = '/maintenance';
const String communityRoute = '/community';
const String profileRoute = '/profile';
const String settingsRoute = '/settings';
const String aboutRoute = '/about';
const String newsRoute = '/news';
const String contactsRoute = '/contacts';
const String messagesRoute = '/messages';
const String chatRoute = '/chat';
const String infoRoute = '/info'; // Ny route tilføjet

// Tekststrenge
class AppText {
  static const String welcome = 'Hej Alexander';
  static const String homeTitle = 'Forside';
  static const String eventsTitle = 'Begivenheder';
  static const String foodTitle = 'Madplan';
  static const String notificationsTitle = 'Meddelelser';
  static const String maintenanceTitle = 'Fejlrapportering';
  static const String communityTitle = 'Fællesskab';
  static const String profileTitle = 'Profil';
  static const String settingsTitle = 'Indstillinger';
  static const String aboutTitle = 'Om Appen';
  static const String newsTitle = 'Nyheder';
  static const String contactsTitle = 'Kontaktpersoner';
  static const String messagesTitle = 'Beskeder';
  static const String infoTitle = 'Info'; // Ny titel tilføjet

  static const String darkModeSwitch = 'Mørk tilstand';
  static const String notificationsSwitch = 'Notifikationer';
  static const String languagePreference = 'Sprog';
}

// Ikoner der bruges gennem appen
class AppIcons {
  static const IconData home = Icons.home;
  static const IconData events = Icons.event;
  static const IconData food = Icons.restaurant_menu;
  static const IconData notifications = Icons.notifications;
  static const IconData maintenance = Icons.build;
  static const IconData community = Icons.groups;
  static const IconData profile = Icons.person;
  static const IconData settings = Icons.settings;
  static const IconData about = Icons.info;
  static const IconData news = Icons.newspaper;
  static const IconData contacts = Icons.contact_phone;
  static const IconData messages = Icons.message;
  static const IconData info = Icons.info_outline; // Nyt ikon tilføjet

  static const IconData darkMode = Icons.dark_mode;
  static const IconData lightMode = Icons.light_mode;
}

// Padding og spacing
class AppSpacing {
  static const double xs = 4.0;
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const EdgeInsets screenPadding = EdgeInsets.all(medium);
  static const EdgeInsets cardPadding = EdgeInsets.all(medium);
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    vertical: small,
    horizontal: medium,
  );
}

// Border radius
class AppRadius {
  static const double small = 4.0;
  static const double medium = 8.0;
  static const double large = 12.0;
  static const double xl = 16.0;
  static const double xxl = 24.0;

  static final BorderRadius smallBorderRadius = BorderRadius.circular(small);
  static final BorderRadius mediumBorderRadius = BorderRadius.circular(medium);
  static final BorderRadius largeBorderRadius = BorderRadius.circular(large);
  static final BorderRadius xlBorderRadius = BorderRadius.circular(xl);
  static final BorderRadius xxlBorderRadius = BorderRadius.circular(xxl);
}
