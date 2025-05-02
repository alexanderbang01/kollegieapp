import 'package:flutter/material.dart';
import '../utils/constants.dart';

class NavigationMenu extends StatelessWidget {
  final String currentRoute;

  const NavigationMenu({Key? key, required this.currentRoute})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          Container(
            height: 200, // Øget højde
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(24),
                bottomLeft: Radius.circular(24),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      // Rundt logo
                      ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: Container(
                          width: 80,
                          height: 80,
                          color: Colors.white,
                          padding: const EdgeInsets.all(8),
                          child: Image.asset(
                            'assets/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kollegie App',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Alexander Jensen',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'alexander@example.com',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Tlf: +45 12 34 56 78',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              children: [
                // Hovednavigation
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    'NAVIGATION',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                _buildNavItem(
                  context: context,
                  icon: AppIcons.home,
                  title: AppText.homeTitle,
                  route: homeRoute,
                  isActive: currentRoute == homeRoute,
                ),
                _buildNavItem(
                  context: context,
                  icon: AppIcons.food,
                  title: AppText.foodTitle,
                  route: foodRoute,
                  isActive: currentRoute == foodRoute,
                ),
                _buildNavItem(
                  context: context,
                  icon: AppIcons.events,
                  title: AppText.eventsTitle,
                  route: eventsRoute,
                  isActive: currentRoute == eventsRoute,
                ),

                // Divider for at separere navigation og personlige indstillinger
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Divider(),
                ),

                // Personlige indstillinger sektion
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    'PERSONLIGT',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                _buildNavItem(
                  context: context,
                  icon: AppIcons.profile,
                  title: AppText.profileTitle,
                  route: profileRoute,
                  isActive: currentRoute == profileRoute,
                ),
                _buildNavItem(
                  context: context,
                  icon: AppIcons.settings,
                  title: AppText.settingsTitle,
                  route: settingsRoute,
                  isActive: currentRoute == settingsRoute,
                ),
              ],
            ),
          ),
          // Version number at the bottom
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Version $appVersion',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String route,
    required bool isActive,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Material(
        color: isActive
            ? theme.colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.pop(context);
            if (!isActive) {
              if (route == homeRoute) {
                Navigator.pushReplacementNamed(context, route);
              } else {
                Navigator.pushNamed(context, route);
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.8),
                  size: 28, // Større ikon
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 16, // Større tekst
                    color: isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                if (isActive) ...[
                  const Spacer(),
                  Container(
                    width: 8,
                    height: 32,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
