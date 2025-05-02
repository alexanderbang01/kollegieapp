import 'package:flutter/material.dart';
import '../utils/constants.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          Container(
            height: 170,
            decoration: BoxDecoration(color: theme.colorScheme.primary),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/logo.png', width: 60, height: 60),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kollegie App',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Tlf: +45 12 34 56 78',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
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
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: Icon(
                    AppIcons.home,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text(
                    AppText.homeTitle,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, homeRoute);
                  },
                ),
                ListTile(
                  leading: Icon(
                    AppIcons.food,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text(
                    AppText.foodTitle,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, foodRoute);
                  },
                ),
                ListTile(
                  leading: Icon(
                    AppIcons.events,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text(
                    AppText.eventsTitle,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, eventsRoute);
                  },
                ),
                ListTile(
                  leading: Icon(
                    AppIcons.settings,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text(
                    AppText.settingsTitle,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, settingsRoute);
                  },
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
}
