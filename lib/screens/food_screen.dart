import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../widgets/navigation_menu.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({Key? key}) : super(key: key);

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Dage i ugen
    final List<String> ugedage = [
      'Mandag',
      'Tirsdag',
      'Onsdag',
      'Torsdag',
      'Fredag',
      'Lordag',
      'Sondag',
    ];

    // Madplanen for ugen
    final List<Map<String, dynamic>> madplan = [
      {
        'ret': 'Pasta Carbonara',
        'beskrivelse': 'Klassisk italiensk ret med bacon, aeg og parmesan',
        'tid': '18:00',
        'sted': 'Faelleskokken',
        'ansvarlig': 'Marie T.',
        'vegetar': false,
        'billede': 'https://via.placeholder.com/150',
      },
      {
        'ret': 'Taco Tuesday',
        'beskrivelse':
            'Byg-selv tacos med oksekod, grontsager og diverse tilbehor',
        'tid': '18:30',
        'sted': 'Faelleskokken',
        'ansvarlig': 'Jakob L.',
        'vegetar': false,
        'billede': 'https://via.placeholder.com/150',
      },
      {
        'ret': 'Vegetarisk Buddha Bowl',
        'beskrivelse':
            'Sund skal med quinoa, avocado, grontsager og tahin-dressing',
        'tid': '18:00',
        'sted': 'Faelleskokken',
        'ansvarlig': 'Sofie M.',
        'vegetar': true,
        'billede': 'https://via.placeholder.com/150',
      },
      {
        'ret': 'Kylling i karry',
        'beskrivelse': 'Cremet karryret med ris og naanbrod',
        'tid': '18:15',
        'sted': 'Faelleskokken',
        'ansvarlig': 'Mads H.',
        'vegetar': false,
        'billede': 'https://via.placeholder.com/150',
      },
      {
        'ret': 'Pizza aften',
        'beskrivelse': 'Hjemmelavet pizza med forskellige toppings',
        'tid': '19:00',
        'sted': 'Faelleskokken',
        'ansvarlig': 'Emma K.',
        'vegetar': false,
        'billede': 'https://via.placeholder.com/150',
      },
      {
        'ret': 'Burger buffet',
        'beskrivelse': 'Byg-selv burgere med diverse tilbehor',
        'tid': '18:30',
        'sted': 'Faelleskokken',
        'ansvarlig': 'Mikkel R.',
        'vegetar': false,
        'billede': 'https://via.placeholder.com/150',
      },
      {
        'ret': 'Rester fra ugen',
        'beskrivelse': 'Vi samler alle rester fra ugen og laver en buffet',
        'tid': '18:00',
        'sted': 'Faelleskokken',
        'ansvarlig': 'Alle',
        'vegetar': false,
        'billede': 'https://via.placeholder.com/150',
      },
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'Madplan',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: theme.colorScheme.primary,
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
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          tabs: ugedage.map((dag) => Tab(text: dag)).toList(),
        ),
      ),
      // Bruger den genbrugelige NavigationMenu-widget
      endDrawer: const NavigationMenu(),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(7, (index) {
          return _buildDagensRet(context, madplan[index]);
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Vis dialog med tilmelding til madplan
          _visAnmeldDialog(context);
        },
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildDagensRet(BuildContext context, Map<String, dynamic> madRet) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ret og info
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Madret titel og beskrivelse
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              madRet['ret'],
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              madRet['beskrivelse'],
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      // Vegetar badge hvis relevant
                      if (madRet['vegetar'])
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
                              Icon(
                                Icons.eco,
                                size: 14,
                                color: Colors.green.shade800,
                              ),
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
                  const SizedBox(height: 16),
                  // Praktisk info
                  Row(
                    children: [
                      _buildInfoItem(context, Icons.access_time, madRet['tid']),
                      const SizedBox(width: 16),
                      _buildInfoItem(
                        context,
                        Icons.location_on,
                        madRet['sted'],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoItem(
                    context,
                    Icons.person,
                    'Ansvarlig: ${madRet['ansvarlig']}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Tilmeldte personer
          Text(
            'Tilmeldte (12)',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTilmeldtPerson(
                    context,
                    'Marie Thomsen',
                    'Vaerelse A-101',
                  ),
                  const Divider(),
                  _buildTilmeldtPerson(
                    context,
                    'Anders Nielsen',
                    'Vaerelse B-204',
                  ),
                  const Divider(),
                  _buildTilmeldtPerson(
                    context,
                    'Louise Pedersen',
                    'Vaerelse A-304',
                  ),
                  const Divider(),
                  _buildTilmeldtPerson(
                    context,
                    'Mads Hansen',
                    'Vaerelse C-102',
                  ),
                  const Divider(),
                  _buildTilmeldtPerson(
                    context,
                    'Emma Kristensen',
                    'Vaerelse B-301',
                  ),

                  // Vis flere knap
                  TextButton(
                    onPressed: () {
                      // Håndter vis flere
                    },
                    child: Text(
                      'Vis alle tilmeldte',
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Allergi information
          Text(
            'Allergiinformation',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Denne ret kan indeholde:',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildAllergiChip(context, 'Gluten'),
                      _buildAllergiChip(context, 'Laktose'),
                      _buildAllergiChip(context, 'Aeg'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Har du andre allergier, kontakt venligst kokkenansvarlig.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: Colors.grey.shade700)),
      ],
    );
  }

  Widget _buildTilmeldtPerson(
    BuildContext context,
    String navn,
    String roomInfo,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.2),
            child: Text(
              navn.substring(0, 1),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(navn, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(
                roomInfo,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllergiChip(BuildContext context, String allergi) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        allergi,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
      ),
    );
  }

  void _visAnmeldDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Tilmeld dig til madplan'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Kommentar (valgfri)',
                    hintText: 'Evt. allergier eller andet kokkenet skal vide',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(value: false, onChanged: (value) {}),
                    const Text('Jeg har allergier'),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuller'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tilmeld'),
              ),
            ],
          ),
    );
  }
}
