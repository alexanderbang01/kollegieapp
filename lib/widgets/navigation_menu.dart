import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/user_service.dart';

class NavigationMenu extends StatefulWidget {
  final String currentRoute;

  const NavigationMenu({Key? key, required this.currentRoute})
    : super(key: key);

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  String _userName = '';
  String _userEmail = '';
  String _userInitials = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await UserService.getUserData();
      final initials = await UserService.getUserInitials();

      if (mounted) {
        setState(() {
          _userName =
              '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'
                  .trim();
          _userEmail = userData['email'] ?? '';
          _userInitials = initials;

          // Fallback hvis data mangler
          if (_userName.isEmpty) _userName = 'Bruger';
          if (_userEmail.isEmpty) _userEmail = 'Ingen email';
        });
      }
    } catch (e) {
      print('Fejl ved indlæsning af brugerdata i navigation: $e');
      if (mounted) {
        setState(() {
          _userName = 'Bruger';
          _userEmail = 'Ingen email';
          _userInitials = 'U';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          Container(
            height: 200,
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
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Text(
                          _userInitials,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _userEmail,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                  isActive: widget.currentRoute == homeRoute,
                ),
                _buildNavItem(
                  context: context,
                  icon: AppIcons.food,
                  title: AppText.foodTitle,
                  route: foodRoute,
                  isActive: widget.currentRoute == foodRoute,
                ),
                _buildNavItem(
                  context: context,
                  icon: AppIcons.events,
                  title: AppText.eventsTitle,
                  route: eventsRoute,
                  isActive: widget.currentRoute == eventsRoute,
                ),
                _buildNavItem(
                  context: context,
                  icon: AppIcons.news,
                  title: AppText.newsTitle,
                  route: newsRoute,
                  isActive: widget.currentRoute == newsRoute,
                ),
                _buildNavItem(
                  context: context,
                  icon: AppIcons.contacts,
                  title: AppText.contactsTitle,
                  route: contactsRoute,
                  isActive: widget.currentRoute == contactsRoute,
                ),
                // Tilføjer Info navigation item
                _buildNavItem(
                  context: context,
                  icon: AppIcons.info,
                  title: AppText.infoTitle,
                  route: infoRoute,
                  isActive: widget.currentRoute == infoRoute,
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
                  isActive: widget.currentRoute == profileRoute,
                ),
                _buildNavItem(
                  context: context,
                  icon: AppIcons.settings,
                  title: AppText.settingsTitle,
                  route: settingsRoute,
                  isActive: widget.currentRoute == settingsRoute,
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
