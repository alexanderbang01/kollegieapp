import 'package:flutter/material.dart';
import '../utils/constants.dart';

// Omdøber klassen for at undgå navnekonflikter
class ThemeSwitchWidget extends StatelessWidget {
  final bool isDarkMode;
  final Function(bool) onChanged;

  const ThemeSwitchWidget({
    Key? key,
    required this.isDarkMode,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SwitchListTile(
      title: Row(
        children: [
          Icon(
            isDarkMode ? AppIcons.darkMode : AppIcons.lightMode,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 16),
          const Text(
            AppText.darkModeSwitch,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
      value: isDarkMode,
      onChanged: onChanged,
      activeColor: theme.colorScheme.primary,
    );
  }
}
