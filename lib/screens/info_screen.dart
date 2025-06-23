import 'package:flutter/material.dart';
import '../widgets/navigation_menu.dart';
import '../utils/constants.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({Key? key}) : super(key: key);

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Map<String, dynamic>> _activities = [
    {
      'title': 'PlayStation',
      'icon': Icons.videogame_asset,
      'description': 'PlayStation i pejsestuen',
      'color': Colors.blue,
    },
    {
      'title': 'Poker',
      'icon': Icons.casino,
      'description': 'Kortspil og poker',
      'color': Colors.red,
    },
    {
      'title': 'Dart',
      'icon': Icons.center_focus_strong,
      'description': 'Dartbord i fællesrummet',
      'color': Colors.green,
    },
    {
      'title': 'Padel Tennis',
      'icon': Icons.sports_tennis,
      'description': 'Padel tennis bane',
      'color': Colors.orange,
    },
    {
      'title': 'E-sport',
      'icon': Icons.computer,
      'description': 'Gaming og esport',
      'color': Colors.purple,
    },
    {
      'title': 'Magnet Fiskeri',
      'icon': Icons.anchor,
      'description': 'Magnet fiskeri aktivitet',
      'color': Colors.cyan,
    },
    {
      'title': 'Tennis',
      'icon': Icons.sports_tennis,
      'description': 'Tennis faciliteter',
      'color': Colors.lime,
    },
    {
      'title': 'Multibane',
      'icon': Icons.sports_basketball,
      'description': 'Basketball multibane',
      'color': Colors.deepOrange,
    },
    {
      'title': 'Beach Volley',
      'icon': Icons.sports_volleyball,
      'description': 'Beach volleyball bane',
      'color': Colors.amber,
    },
    {
      'title': 'Fodbold',
      'icon': Icons.sports_soccer,
      'description': 'Fodboldstadion',
      'color': Colors.green,
    },
    {
      'title': 'Biograf',
      'icon': Icons.movie,
      'description': 'Stor fælles TV med streaming',
      'color': Colors.indigo,
    },
    {
      'title': 'Mountain Bike',
      'icon': Icons.pedal_bike,
      'description': 'Mountain bike faciliteter',
      'color': Colors.brown,
    },
    {
      'title': 'Bordtennis',
      'icon': Icons.sports_tennis,
      'description': 'Bordtennisbord',
      'color': Colors.pink,
    },
    {
      'title': 'Motionsrum',
      'icon': Icons.fitness_center,
      'description': 'Fitness og træning',
      'color': Colors.red,
    },
    {
      'title': 'Billard',
      'icon': Icons.sports_cricket,
      'description': 'Billard bord',
      'color': Colors.teal,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'Info',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWeekendInfoSection(theme),
            const SizedBox(height: 30),
            _buildActivitiesSection(theme),
            const SizedBox(height: 30),
            _buildDocumentSection(theme),
            const SizedBox(height: 30),
          ],
        ),
      ),
      endDrawer: const NavigationMenu(currentRoute: infoRoute),
    );
  }

  Widget _buildWeekendInfoSection(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.weekend,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekend Tilmelding',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Information om weekendophold',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Hvis du planlægger at blive på kollegiet over en weekend, skal du tilmelde dig senest onsdag kl. 22:00.',
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurface,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '• Du skal have en gyldig grund til at blive på kollegiet\n'
            '• Du får adgang til fællesområderne hele weekenden\n'
            '• Husk at afmelde dig hvis planerne ændrer sig',
            style: TextStyle(
              fontSize: 15,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tilmelding sker via kollegiets reception',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesSection(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.sports_esports,
                  color: Colors.green,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aktiviteter på Kollegiet',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Alle tilgængelige faciliteter og aktiviteter',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
              childAspectRatio: 1.0,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _activities.length,
            itemBuilder: (context, index) {
              final activity = _activities[index];
              return _buildActivityCard(activity, theme);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: activity['color'].withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: activity['color'].withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: activity['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(activity['icon'], color: activity['color'], size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            activity['title'],
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            activity['description'],
            style: TextStyle(
              fontSize: 10,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentSection(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.picture_as_pdf,
                  color: Colors.red,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dokumenter',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Vigtige dokumenter og aftaler',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.2),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _showDocumentViewer(context),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.description,
                        color: Colors.red,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Indflytningsaftale',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'PDF - Tryk for at læse',
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDocumentViewer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.red,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Indflytningsaftale.pdf',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'RAMMEAFTALE',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Du har modtaget dit værelse rengjort. Ved mangler skal du straks henvende dig til receptionen, der vil sørge for, at det udbedres hurtigst muligt.',
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Det er ikke tilladt at have el-kedler, kaffemaskiner, køleskab eller lignende på værelserne. Du må gerne medbringe en mindre skærm og pc.',
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Du har selv ansvar for den daglige rengøring af værelset, og du skal ved afrejse afleveret værelset ryddet for affald og rengjort. Vi forventer, at du rengør værelset en gang ugentligt, herunder også badeværelset.',
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Du er indforstået med, at kollegiets personale har adgang til og fører tilsyn med dit værelse.',
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Du skal selv medbringe dyne, pude og lagen. Låner/køber du dyne/pude, skal du også leje en linnedpakke. Er der ikke lagt ekstra lagen på din seng, vil du blive afkrævet et beløb til vask.',
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Du modtager en værelsesnøgle, nøgle til klædeskab, nøglering og skilt. Er dine nøgler bortkommet, skal du betale en erstatning på 600 kr. Har du glemt din nøgle, kan du låne en nøgle mod at betale et depositum 600 kr. Prisen for bortkomne nøgler på Campus og på Midtbyens Kollegium er 2.500 kr.',
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Det er ikke tilladt at ryge på Mercantec i tidsrummet 7:30 – 16:00. Efter kl. 16:00 er det KUN tilladt at ryge i rygeskuret, der støder op til terrassen foran Bistro 7.',
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Du er indforstået med følgende forhold, hvilket også er en forudsætning for at bo på kollegiet:',
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildBulletPoint(
                          'At rygning IKKE er tilladt på Kollegiet, hverken på værelser eller i fællesarealerne. Overtrædelse medfører advarsel samt et gebyr, og gentagelser vil medføre bortvisning. Dette gælder også E-cigaretter og lignende f.eks. snustobak',
                        ),
                        _buildBulletPoint(
                          'At der er ro på Kollegiet efter kl. 22:00 af hensyn til øvrige beboere',
                        ),
                        _buildBulletPoint(
                          'At der altid er ryddeligt på værelset og på badeværelset',
                        ),
                        _buildBulletPoint(
                          'At der IKKE forefindes eller indtages øl, vin spiritus eller euforiserende stoffer på Mercantecs område, hverken ude eller inde',
                        ),
                        _buildBulletPoint(
                          'I tilfælde af mistanke om besiddelse og/eller brug af euforiserende stoffer, vil der blive foretaget ransagning, evt. med anvendelse af narkohund. Besiddelse og/eller brug af euforiserende stoffer på skolens adresser anmeldes normalt til politiet, og det vil medføre øjeblikkelig bortvisning',
                        ),
                        _buildBulletPoint(
                          'Uhensigtsmæssig adfærd, beruselse samt hærværk, vold, trusler om vold beboer imellem og i forhold til personalet accepteres ikke og vil medføre bortvisning',
                        ),
                        _buildBulletPoint(
                          'Der må ikke forefindes knive og øvrige farlige effekter på værelset',
                        ),
                        _buildBulletPoint(
                          'Mobning accepteres ikke, hverken mod ansatte eller husets øvrige beboere, og det vil medføre bortvisning',
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.yellow[50],
                            border: Border.all(color: Colors.orange[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'HUSK: På hjemrejsedagen afleveres nøgler og adgangskort altid senest kl. 8:00. Du har mulighed for at få dine ting opbevaret på kontoret, indtil din undervisning er færdig. (Fredag senest kl. 13)',
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
