import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../widgets/navigation_menu.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({Key? key}) : super(key: key);

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedWeek = 18; // Nuværende uge (uge 18)

  // Alle madplaner
  final Map<int, List<Map<String, dynamic>>> _allMealPlans = {
    // Uge 18 madplan
    18: [
      {
        'dag': 'Mandag',
        'ret': 'Pasta Carbonara',
        'beskrivelse': 'Klassisk italiensk ret med bacon, aeg og parmesan',
        'tid': '18:00',
        'allergener': ['Gluten', 'Laktose', 'Aeg'],
      },
      {
        'dag': 'Tirsdag',
        'ret': 'Taco Tuesday',
        'beskrivelse':
            'Byg-selv tacos med oksekod, grontsager og diverse tilbehor',
        'tid': '18:30',
        'allergener': ['Gluten', 'Laktose'],
      },
      {
        'dag': 'Onsdag',
        'ret': 'Vegetarisk Buddha Bowl',
        'beskrivelse':
            'Sund skal med quinoa, avocado, grontsager og tahin-dressing',
        'tid': '18:00',
        'allergener': ['Nødder', 'Sesam'],
        'vegetar': true,
      },
      {
        'dag': 'Torsdag',
        'ret': 'Kylling i karry',
        'beskrivelse': 'Cremet karryret med ris og naanbrod',
        'tid': '18:15',
        'allergener': ['Laktose'],
      },
    ],
    // Uge 19 madplan
    19: [
      {
        'dag': 'Mandag',
        'ret': 'Lasagne',
        'beskrivelse': 'Hjemmelavet lasagne med oksekød og bechamelsauce',
        'tid': '18:00',
        'allergener': ['Gluten', 'Laktose'],
      },
      {
        'dag': 'Tirsdag',
        'ret': 'Fiskefrikadeller',
        'beskrivelse': 'Fiskefrikadeller med kartofler og remoulade',
        'tid': '18:00',
        'allergener': ['Fisk', 'Aeg'],
      },
      {
        'dag': 'Onsdag',
        'ret': 'Pizza aften',
        'beskrivelse': 'Vi laver pizzaer sammen med forskellige toppings',
        'tid': '18:30',
        'allergener': ['Gluten', 'Laktose'],
      },
      {
        'dag': 'Torsdag',
        'ret': 'Falafler med couscous',
        'beskrivelse': 'Vegetariske falafler med couscous og tzatziki',
        'tid': '18:15',
        'allergener': ['Gluten', 'Laktose'],
        'vegetar': true,
      },
    ],
  };

  // Hent den valgte madplan
  List<Map<String, dynamic>> get _currentMealPlan => 
      _allMealPlans[_selectedWeek] ?? [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'Madplan',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: theme.brightness == Brightness.light
            ? theme.colorScheme.primary
            : const Color(0xFF1C1C1E),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      endDrawer: const NavigationMenu(currentRoute: foodRoute),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Uge selector og titel
              Row(
                children: [
                  Text(
                    'Madplan for uge $_selectedWeek',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // Tilføjer knapper til at skifte uge
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      setState(() {
                        _selectedWeek = _selectedWeek > 1 ? _selectedWeek - 1 : 52;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      setState(() {
                        _selectedWeek = _selectedWeek < 52 ? _selectedWeek + 1 : 1;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Viser "ingen madplan" besked hvis der ikke er data for den valgte uge
              if (_currentMealPlan.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ingen madplan for uge $_selectedWeek',
                          style: theme.textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Prøv en anden uge eller kontakt administrationen',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

              // Madplankort for hver dag
              ..._currentMealPlan
                  .map(
                    (mad) => _buildMealCard(
                      context,
                      mad,
                      isToday: mad['dag'] == 'Tirsdag', // Markerer tirsdag som "I DAG" for eksemplets skyld
                    ),
                  )
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealCard(
    BuildContext context,
    Map<String, dynamic> mad, {
    bool isToday = false,
  }) {
    final theme = Theme.of(context);
    final bool erVegetar = mad['vegetar'] == true;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide.none,
      ),
      color: theme.colorScheme.primary.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dag og tid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      mad['dag'],
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    if (isToday)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'I DAG',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                Text(
                  'Kl. ${mad['tid']}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Ret navn
            Row(
              children: [
                Expanded(
                  child: Text(
                    mad['ret'],
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (erVegetar)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.eco, size: 14, color: Colors.green.shade800),
                        const SizedBox(width: 4),
                        Text(
                          'Vegetar',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Beskrivelse
            Text(mad['beskrivelse'], style: theme.textTheme.bodyMedium),

            const SizedBox(height: 16),

            // Allergener
            if (mad['allergener'] != null &&
                (mad['allergener'] as List).isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Allergener:',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (mad['allergener'] as List)
                        .map(
                          (allergen) =>
                              _buildAllergenChip(context, allergen.toString()),
                        )
                        .toList(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllergenChip(BuildContext context, String allergen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        allergen,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
      ),
    );
  }
}