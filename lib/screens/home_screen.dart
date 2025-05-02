import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/navigation_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'Forside',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        // Flytter navigationsikonet til højre side
        automaticallyImplyLeading: false,
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Madplan sektion
                _buildSectionHeader(context, 'Madplan'),
                const SizedBox(height: 16),
                _buildMealPlanCard(
                  context,
                  'I dag',
                  'Pasta Carbonara',
                  'Serveres kl. 18:00 i fælleskøkkenet',
                  onTap: () => Navigator.pushNamed(context, foodRoute),
                ),
                const SizedBox(height: 12),
                _buildMealPlanCard(
                  context,
                  'I morgen',
                  'Taco Tirsdag',
                  'Serveres kl. 18:00 i fælleskøkkenet',
                  onTap: () => Navigator.pushNamed(context, foodRoute),
                ),

                const SizedBox(height: 24),

                // Kommende begivenheder
                _buildSectionHeader(context, 'Kommende Begivenheder'),
                const SizedBox(height: 16),
                _buildEventCard(
                  context,
                  'Filmaften',
                  'Fællesrummet',
                  'Fredag, 20:00',
                  theme.colorScheme.primary.withOpacity(0.1),
                ),
                const SizedBox(height: 12),
                _buildEventCard(
                  context,
                  'Brætspilsaften',
                  'Fællesrummet, 3. etage',
                  'Lørdag, 19:00',
                  theme.colorScheme.primary.withOpacity(0.1),
                ),

                const SizedBox(height: 24),

                // Nyheder
                _buildSectionHeader(context, 'Nyheder'),
                const SizedBox(height: 16),
                _buildNewsCard(
                  context,
                  'Ny trådløs printer installeret',
                  'Du kan nu printe fra din enhed i fællesrummet via Wi-Fi.',
                  '12. maj',
                ),
                const SizedBox(height: 12),
                _buildNewsCard(
                  context,
                  'Sommerfest planlægges',
                  'Sæt kryds i kalenderen: Vi planlægger årets sommerfest den 15. juni.',
                  '10. maj',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildMealPlanCard(
    BuildContext context,
    String day,
    String meal,
    String details, {
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.restaurant,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      day,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      meal,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      details,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(
    BuildContext context,
    String title,
    String location,
    String time,
    Color backgroundColor,
  ) {
    return Card(
      elevation: 0,
      color: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.event, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(location, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCard(
    BuildContext context,
    String title,
    String content,
    String date,
  ) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.newspaper, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(content, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Text(
                    date,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
