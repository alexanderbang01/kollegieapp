import 'package:flutter/material.dart';
import '../utils/constants.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: theme.colorScheme.primary),
            accountName: const Text(
              'Velkommen til Mercantec Kollegium',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: const Text('Din digitale kollegieassistent'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: theme.colorScheme.secondary,
              child: const Icon(Icons.school, size: 40, color: Colors.white),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.home,
                  title: 'Forside',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.event,
                  title: 'Begivenheder',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/events');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.local_laundry_service,
                  title: 'Vaskeri',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/laundry');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.notifications,
                  title: 'Meddelelser',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/notifications');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.build,
                  title: 'Fejlrapportering',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/maintenance');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.food_bank,
                  title: 'Madklub',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/food');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.groups,
                  title: 'Fællesskab',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/community');
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  context,
                  icon: Icons.person,
                  title: 'Profil',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings,
                  title: 'Indstillinger',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  context,
                  icon: Icons.info,
                  title: 'Om Appen',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/about');
                  },
                ),
              ],
            ),
          ),
          // Version number at the bottom
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text('Version 1.0.0', style: theme.textTheme.bodySmall),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      onTap: onTap,
      dense: true,
    );
  }
}
