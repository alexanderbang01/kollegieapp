import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../widgets/navigation_menu.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showAllNews = true; // Viser alle nyheder som standard

  // Demo nyheder
  final List<Map<String, dynamic>> _news = [
    {
      'id': '1',
      'title': 'Ny trådløs printer installeret',
      'content': 'Du kan nu printe fra din enhed i fællesrummet via Wi-Fi. Printeren er placeret i studierummet på 1. sal. For at bruge printeren, forbind til kollegiets Wi-Fi og vælg "Kollegieprinter" fra din enhed. Kontakt administrationen hvis du har problemer med at forbinde.',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'author': 'Administrator',
      'category': 'Faciliteter',
      'isImportant': true,
      'imageUrl': 'assets/images/printer.jpg',
    },
    {
      'id': '2',
      'title': 'Sommerfest planlægges',
      'content': 'Sæt kryds i kalenderen: Vi planlægger årets sommerfest den 15. juni. Der vil være grill, musik og forskellige aktiviteter. Vi søger frivillige til at hjælpe med planlægning og opsætning. Hvis du er interesseret, kontakt Julie eller Mikkel fra festudvalget.',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'author': 'Festudvalget',
      'category': 'Arrangementer',
      'isImportant': false,
      'imageUrl': 'assets/images/party.jpg',
    },
    {
      'id': '3',
      'title': 'Vedligeholdelse af vaskeri næste uge',
      'content': 'Vaskeriet vil være lukket mandag den 10. maj fra kl. 8-14 på grund af planlagt vedligeholdelse og reparation af maskiner. Vi beklager ulejligheden og foreslår, at du planlægger din vask før eller efter denne periode.',
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'author': 'Vicevært',
      'category': 'Vedligeholdelse',
      'isImportant': true,
      'imageUrl': 'assets/images/laundry.jpg',
    },
    {
      'id': '4',
      'title': 'Ny kollegiebestyrelse valgt',
      'content': 'På sidste generalforsamling blev den nye kollegiebestyrelse valgt. Tillykke til Søren (formand), Maria (næstformand), Anders (kasserer), Julie og Thomas (medlemmer). De vil arbejde på at forbedre vores fællesfaciliteter og sociale arrangementer i det kommende år.',
      'date': DateTime.now().subtract(const Duration(days: 14)),
      'author': 'Administrator',
      'category': 'Administration',
      'isImportant': false,
      'imageUrl': 'assets/images/committee.jpg',
    },
    {
      'id': '5',
      'title': 'Påmindelse om støjregler',
      'content': 'Vi vil gerne minde alle beboere om at respektere støjreglerne, især i eksamensperioden. Høj musik og støj skal minimeres efter kl. 22:00 på hverdage og 24:00 i weekender. Planlægger du en fest, informer venligst dine naboer i forvejen.',
      'date': DateTime.now().subtract(const Duration(days: 20)),
      'author': 'Kollegiebestyrelsen',
      'category': 'Husorden',
      'isImportant': true,
      'imageUrl': 'assets/images/noise.jpg',
    },
  ];

  // Filtrerede nyheder baseret på valg
  List<Map<String, dynamic>> get _filteredNews {
    if (_showAllNews) {
      return _news;
    } else {
      // Vis kun vigtige nyheder
      return _news.where((news) => news['isImportant'] == true).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'Nyheder',
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
          // Filter-knap til at skifte mellem alle nyheder og vigtige nyheder
          IconButton(
            icon: Icon(_showAllNews ? Icons.filter_list : Icons.warning_amber),
            onPressed: () {
              setState(() {
                _showAllNews = !_showAllNews;
              });
            },
            tooltip: _showAllNews ? 'Vis kun vigtige' : 'Vis alle',
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      endDrawer: const NavigationMenu(currentRoute: newsRoute),
      body: _filteredNews.isEmpty
          ? _buildEmptyState()
          : _buildNewsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.newspaper,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Ingen nyheder at vise',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Der er ingen nyheder at vise i øjeblikket. Kom tilbage senere for opdateringer.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredNews.length,
      itemBuilder: (context, index) {
        final news = _filteredNews[index];
        return _buildNewsCard(context, news);
      },
    );
  }

  Widget _buildNewsCard(BuildContext context, Map<String, dynamic> news) {
    final theme = Theme.of(context);
    final DateTime newsDate = news['date'];
    final bool isRecent = DateTime.now().difference(newsDate).inDays <= 3;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: _getCategoryColor(news['category']).withOpacity(0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showNewsDetails(context, news),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(news['category']),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      news['category'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (news['isImportant'])
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Vigtig',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (isRecent)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'NY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Text(
                    _formatDate(newsDate),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                news['title'],
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Viser de første 3 linjer af indholdet
              Text(
                news['content'],
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    news['author'],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _showNewsDetails(context, news),
                    child: const Text('Læs mere'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNewsDetails(BuildContext context, Map<String, dynamic> news) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle til at lukke modal
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Kategori og dato
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(news['category']),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      news['category'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (news['isImportant'])
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Vigtig',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const Spacer(),
                  Text(
                    _formatDate(news['date']),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Titel
              Text(
                news['title'],
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Skrevet af ${news['author']}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Indhold
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    news['content'],
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              // Del-knap i bunden
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Her kan man implementere deling af nyheden
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Deling ikke implementeret endnu'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Del med andre'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Faciliteter':
        return Colors.blue;
      case 'Arrangementer':
        return Colors.purple;
      case 'Vedligeholdelse':
        return Colors.orange;
      case 'Administration':
        return Colors.green;
      case 'Husorden':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'I dag';
    } else if (difference == 1) {
      return 'I går';
    } else if (difference < 7) {
      return '$difference dage siden';
    }

    // Danske månedsnavne
    final months = [
      'januar',
      'februar',
      'marts',
      'april',
      'maj',
      'juni',
      'juli',
      'august',
      'september',
      'oktober',
      'november',
      'december'
    ];

    return '${date.day}. ${months[date.month - 1]}';
  }
}