import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../widgets/navigation_menu.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showPastEvents = false;

  // Dummydata for begivenheder
  final List<Map<String, dynamic>> _events = [
    {
      'id': '1',
      'title': 'Fællesspisning',
      'description': 'Vi mødes i fælleskøkkenet og laver mad sammen. Medbring ingredienser efter aftale.',
      'date': DateTime.now().add(const Duration(days: 2)),
      'location': 'Fælleskøkkenet, 2. sal',
      'organizer': 'Julie Hansen',
      'maxParticipants': 15,
      'currentParticipants': 3,
      'participants': ['Alexander Jensen', 'Mia Nielsen', 'Søren Larsen'],
      'imageUrl': 'assets/images/dinner.jpg',
      'category': 'Mad',
    },
    {
      'id': '2',
      'title': 'Filmaften',
      'description': 'Vi ser en film sammen i fællesrummet. Afstemning om filmen foregår på Facebook-gruppen.',
      'date': DateTime.now().add(const Duration(days: 5)),
      'location': 'Fællesrummet, stueetagen',
      'organizer': 'Mikkel Andersen',
      'maxParticipants': 25,
      'currentParticipants': 3,
      'participants': ['Alexander Jensen', 'Julie Hansen', 'Peter Olsen'],
      'imageUrl': 'assets/images/movie.jpg',
      'category': 'Underholdning',
    },
    {
      'id': '3',
      'title': 'Brætspilsaften',
      'description': 'Tag dit yndlingsbrætspil med! Der vil også være snacks og sodavand.',
      'date': DateTime.now().add(const Duration(days: 7)),
      'location': 'Fællesrummet, stueetagen',
      'organizer': 'Sofie Pedersen',
      'maxParticipants': 20,
      'currentParticipants': 2,
      'participants': ['Mia Nielsen', 'Thomas Jensen'],
      'imageUrl': 'assets/images/boardgame.jpg',
      'category': 'Underholdning',
    },
    {
      'id': '4',
      'title': 'Generalforsamling',
      'description': 'Årlig generalforsamling for kollegiet. Vigtigt at deltage!',
      'date': DateTime.now().add(const Duration(days: 14)),
      'location': 'Fællesrummet, stueetagen',
      'organizer': 'Kollegiebestyrelsen',
      'maxParticipants': 100,
      'currentParticipants': 4,
      'participants': ['Alexander Jensen', 'Julie Hansen', 'Mia Nielsen', 'Thomas Jensen'],
      'imageUrl': 'assets/images/meeting.jpg',
      'category': 'Møde',
    },
    {
      'id': '5',
      'title': 'Loppemarked',
      'description': 'Kom og sælg dine brugte ting eller gør et godt køb!',
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'location': 'Gården',
      'organizer': 'Anna Poulsen',
      'maxParticipants': 50,
      'currentParticipants': 0,
      'participants': [],
      'imageUrl': 'assets/images/market.jpg',
      'category': 'Andet',
      'isPast': true,
    },
    {
      'id': '6',
      'title': 'Rengøringsdag',
      'description': 'Vi hjælpes ad med at gøre fællesområderne rene. Kollegiet giver pizza bagefter!',
      'date': DateTime.now().subtract(const Duration(days: 14)),
      'location': 'Hele kollegiet',
      'organizer': 'Kollegiebestyrelsen',
      'maxParticipants': 100,
      'currentParticipants': 0,
      'participants': [],
      'imageUrl': 'assets/images/cleaning.jpg',
      'category': 'Praktisk',
      'isPast': true,
    },
  ];

  // Filtrering af begivenheder
  List<Map<String, dynamic>> get _filteredEvents {
    final now = DateTime.now();
    return _events.where((event) {
      final isPast = event['date'].isBefore(now);
      return _showPastEvents ? isPast : !isPast;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'Begivenheder',
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
            icon: Icon(_showPastEvents ? Icons.calendar_today : Icons.history),
            onPressed: () {
              setState(() {
                _showPastEvents = !_showPastEvents;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      endDrawer: const NavigationMenu(currentRoute: eventsRoute),
      body: _filteredEvents.isEmpty
          ? _buildEmptyState()
          : _buildEventsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _showPastEvents ? Icons.history : Icons.event_busy,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _showPastEvents
                ? 'Ingen tidligere begivenheder'
                : 'Ingen kommende begivenheder',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _showPastEvents
                  ? 'Der er ikke registreret tidligere begivenheder'
                  : 'Opret en ny begivenhed ved at trykke på knappen nederst',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredEvents.length,
      itemBuilder: (context, index) {
        final event = _filteredEvents[index];
        return _buildEventCard(context, event);
      },
    );
  }

  Widget _buildEventCard(BuildContext context, Map<String, dynamic> event) {
    final theme = Theme.of(context);
    final DateTime eventDate = event['date'];
    final bool isToday = DateTime.now().day == eventDate.day &&
        DateTime.now().month == eventDate.month &&
        DateTime.now().year == eventDate.year;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: _getCategoryColor(event['category']).withOpacity(0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showEventDetails(context, event),
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
                      color: _getCategoryColor(event['category']),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      event['category'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(eventDate),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
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
              const SizedBox(height: 12),
              Text(
                event['title'],
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    event['location'],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatTime(eventDate)} • ${event['organizer']}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildParticipantIndicator(context, event),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      // Logik for tilmelding/afmelding
                      _toggleParticipation(context, event);
                    },
                    icon: Icon(
                      event['participants'].contains('Alexander Jensen')
                          ? Icons.check_circle
                          : Icons.add_circle_outline,
                      color: theme.colorScheme.primary,
                    ),
                    label: Text(
                      event['participants'].contains('Alexander Jensen')
                          ? 'Tilmeldt'
                          : 'Tilmeld',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParticipantIndicator(
      BuildContext context, Map<String, dynamic> event) {
    final theme = Theme.of(context);
    final int currentParticipants = event['participants'].length;
    final int maxParticipants = event['maxParticipants'];
    final double percentage = currentParticipants / maxParticipants;

    return Row(
      children: [
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              width: 100,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              width: 100 * percentage,
              height: 8,
              decoration: BoxDecoration(
                color: percentage > 0.8
                    ? Colors.orange
                    : theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        Text(
          '$currentParticipants/$maxParticipants',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  void _showEventDetails(BuildContext context, Map<String, dynamic> event) {
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
                      color: _getCategoryColor(event['category']),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      event['category'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(event['date']),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Titel
              Text(
                event['title'],
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Detaljer
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    event['location'],
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatTime(event['date']),
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Arrangør: ${event['organizer']}',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Beskrivelse
              Text(
                'Om begivenheden',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                event['description'],
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),

              // Deltagere
              Row(
                children: [
                  Text(
                    'Deltagere',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${event['participants'].length}/${event['maxParticipants']})',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (event['participants'].isNotEmpty)
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: event['participants'].length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(event['participants'][index]),
                      );
                    },
                  ),
                )
              else
                Text(
                  'Ingen tilmeldte endnu',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              const Spacer(),

              // Tilmeldingsknap
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Logik for tilmelding/afmelding
                    _toggleParticipation(context, event);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: event['participants']
                            .contains('Alexander Jensen')
                        ? Colors.red
                        : theme.colorScheme.primary,
                  ),
                  child: Text(
                    event['participants'].contains('Alexander Jensen')
                        ? 'Afmeld begivenhed'
                        : 'Tilmeld begivenhed',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleParticipation(
      BuildContext context, Map<String, dynamic> event) {
    setState(() {
      if (event['participants'].contains('Alexander Jensen')) {
        event['participants'].remove('Alexander Jensen');
      } else {
        // Tjek om der er plads
        if (event['participants'].length < event['maxParticipants']) {
          event['participants'].add('Alexander Jensen');
        } else {
          // Vis en besked om at begivenheden er fuld
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Begivenheden er allerede fuld'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    });
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Mad':
        return Colors.green;
      case 'Underholdning':
        return Colors.purple;
      case 'Møde':
        return Colors.blue;
      case 'Praktisk':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return 'I dag';
    }

    final tomorrow = now.add(const Duration(days: 1));
    if (date.day == tomorrow.day &&
        date.month == tomorrow.month &&
        date.year == tomorrow.year) {
      return 'I morgen';
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

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}