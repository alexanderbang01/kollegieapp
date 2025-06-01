import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../widgets/navigation_menu.dart';
import '../widgets/success_notification.dart';
import '../services/events_service.dart';
import '../services/user_service.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  // User data
  String _currentUserId = '';
  String _currentUserType = '';

  // UI state
  bool _showPastEvents = false;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;

  // Events data
  List<Map<String, dynamic>> _events = [];
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _initializeUser();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreEvents();
    }
  }

  Future<void> _initializeUser() async {
    try {
      final userId = await UserService.getUserId();
      final userType = await UserService.getUserType();

      setState(() {
        _currentUserId = userId;
        _currentUserType = userType;
      });

      await _loadEvents();
    } catch (e) {
      setState(() {
        _errorMessage = 'Fejl ved indlæsning af brugerdata: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadEvents({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _hasMore = true;
        _events.clear();
      });
    }

    setState(() {
      _isLoading = refresh || _currentPage == 1;
      _errorMessage = null;
    });

    try {
      final response = await EventsService.getEvents(
        userId: _currentUserId,
        userType: _currentUserType,
        showPast: _showPastEvents,
        page: _currentPage,
        limit: 20,
      );

      if (response['success'] == true) {
        final List<dynamic> eventsData = response['data'] ?? [];
        final pagination = response['pagination'];

        setState(() {
          if (refresh || _currentPage == 1) {
            _events = List<Map<String, dynamic>>.from(eventsData);
          } else {
            _events.addAll(List<Map<String, dynamic>>.from(eventsData));
          }
          _hasMore = pagination['has_next'] ?? false;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              response['message'] ?? 'Fejl ved indlæsning af begivenheder';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Netværksfejl: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreEvents() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    try {
      final response = await EventsService.getEvents(
        userId: _currentUserId,
        userType: _currentUserType,
        showPast: _showPastEvents,
        page: _currentPage,
        limit: 20,
      );

      if (response['success'] == true) {
        final List<dynamic> eventsData = response['data'] ?? [];
        final pagination = response['pagination'];

        setState(() {
          _events.addAll(List<Map<String, dynamic>>.from(eventsData));
          _hasMore = pagination['has_next'] ?? false;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _currentPage--; // Revert page increment
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _currentPage--; // Revert page increment
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _toggleEventRegistration(Map<String, dynamic> event) async {
    final eventId = event['id'] as int;
    final isRegistered = event['isUserRegistered'] as bool;

    try {
      final response = await EventsService.toggleEventRegistration(
        userId: _currentUserId,
        userType: _currentUserType,
        eventId: eventId,
        isCurrentlyRegistered: isRegistered,
      );

      if (response['success'] == true) {
        setState(() {
          final eventIndex = _events.indexWhere((e) => e['id'] == eventId);
          if (eventIndex != -1) {
            _events[eventIndex]['isUserRegistered'] = !isRegistered;

            final currentParticipants =
                _events[eventIndex]['currentParticipants'] as int;

            if (!isRegistered) {
              _events[eventIndex]['currentParticipants'] =
                  currentParticipants + 1;
            } else {
              _events[eventIndex]['currentParticipants'] =
                  currentParticipants - 1;
            }
          }
        });

        if (mounted) {
          SuccessNotification.show(
            context,
            title: !isRegistered ? 'Tilmeldt!' : 'Afmeldt!',
            message:
                response['message'] ??
                (!isRegistered
                    ? 'Du er nu tilmeldt begivenheden'
                    : 'Du er nu afmeldt begivenheden'),
            icon: !isRegistered
                ? Icons.check_circle
                : Icons.remove_circle_outline,
            color: !isRegistered ? Colors.green : Colors.orange,
          );
        }
      } else {
        if (mounted) {
          SuccessNotification.show(
            context,
            title: 'Fejl',
            message: response['message'] ?? 'Fejl ved tilmelding',
            icon: Icons.error_outline,
            color: Colors.red,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SuccessNotification.show(
          context,
          title: 'Netværksfejl',
          message: 'Der opstod en fejl. Prøv igen senere.',
          icon: Icons.wifi_off,
          color: Colors.red,
        );
      }
    }
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
              _loadEvents(refresh: true);
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      endDrawer: const NavigationMenu(currentRoute: eventsRoute),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Indlæser begivenheder...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Der opstod en fejl',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadEvents(refresh: true),
              child: const Text('Prøv igen'),
            ),
          ],
        ),
      );
    }

    if (_events.isEmpty) {
      return _buildEmptyState();
    }

    return _buildEventsList();
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: () => _loadEvents(refresh: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 200,
          child: Center(
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
                        : 'Hold øje med nye begivenheder',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    return RefreshIndicator(
      onRefresh: () => _loadEvents(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _events.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _events.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final event = _events[index];
          return _buildEventCard(context, event);
        },
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Map<String, dynamic> event) {
    final theme = Theme.of(context);
    final DateTime eventDateTime = DateTime.parse(
      '${event['date']} ${event['time']}',
    );
    final bool isToday = _isToday(eventDateTime);
    final bool isUserRegistered = event['isUserRegistered'] ?? false;
    final bool isPast = _showPastEvents;
    final bool isDarkMode = theme.brightness == Brightness.dark;

    // Bedre farver for past events
    Color cardColor;
    Color textColor;
    Color secondaryTextColor;
    Color progressBarColor;
    Color progressBackgroundColor;

    if (isPast) {
      if (isDarkMode) {
        // Dark mode - past events
        cardColor = Colors.grey.shade800.withOpacity(0.6);
        textColor = Colors.grey.shade400;
        secondaryTextColor = Colors.grey.shade500;
        progressBarColor = Colors.grey.shade600;
        progressBackgroundColor = Colors.grey.shade700;
      } else {
        // Light mode - past events
        cardColor = Colors.grey.shade200.withOpacity(0.8);
        textColor = Colors.grey.shade700;
        secondaryTextColor = Colors.grey.shade600;
        progressBarColor = Colors.grey.shade500;
        progressBackgroundColor = Colors.grey.shade300;
      }
    } else {
      // Kommende events - normale farver
      cardColor = theme.colorScheme.primary.withOpacity(0.1);
      textColor = theme.colorScheme.onSurface;
      secondaryTextColor = Colors.grey.shade700;
      progressBarColor = theme.colorScheme.primary;
      progressBackgroundColor = Colors.grey.shade200;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
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
                  Expanded(
                    child: Text(
                      event['title'],
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  if (isToday)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
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
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: secondaryTextColor),
                  const SizedBox(width: 4),
                  Text(
                    event['location'],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: secondaryTextColor),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatDate(eventDateTime)} ${_formatTime(event['time'])} • ${event['organizer']}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildParticipantIndicator(
                    context,
                    event,
                    isPast,
                    progressBarColor,
                    progressBackgroundColor,
                    textColor,
                  ),
                  const Spacer(),
                  if (!isPast)
                    ElevatedButton.icon(
                      onPressed: () => _toggleEventRegistration(event),
                      icon: Icon(
                        isUserRegistered
                            ? Icons.check_circle
                            : Icons.add_circle_outline,
                        size: 18,
                      ),
                      label: Text(
                        isUserRegistered ? 'Afmeld' : 'Tilmeld',
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isUserRegistered
                            ? Colors.red
                            : theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
    BuildContext context,
    Map<String, dynamic> event,
    bool isPast,
    Color progressBarColor,
    Color progressBackgroundColor,
    Color textColor,
  ) {
    final theme = Theme.of(context);
    final int currentParticipants = event['currentParticipants'] ?? 0;
    final int? maxParticipants = event['maxParticipants'];

    if (maxParticipants == null) {
      return Text(
        '$currentParticipants deltagere',
        style: theme.textTheme.bodySmall?.copyWith(color: textColor),
      );
    }

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
                color: progressBackgroundColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              width: 100 * percentage,
              height: 8,
              decoration: BoxDecoration(
                color: isPast
                    ? progressBarColor
                    : (percentage > 0.8 ? Colors.orange : progressBarColor),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        Text(
          '$currentParticipants/$maxParticipants',
          style: theme.textTheme.bodySmall?.copyWith(color: textColor),
        ),
      ],
    );
  }

  void _showEventDetails(BuildContext context, Map<String, dynamic> event) {
    final theme = Theme.of(context);
    final bool isUserRegistered = event['isUserRegistered'] ?? false;
    final bool isPast = _showPastEvents;

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
                  Icon(Icons.location_on, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(event['location'], style: theme.textTheme.bodyLarge),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    '${_formatDate(DateTime.parse('${event['date']} ${event['time']}'))} ${_formatTime(event['time'])}',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Arrangør: ${event['organizer']}',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Beskrivelse
              if (event['description'] != null &&
                  event['description'].isNotEmpty) ...[
                Text(
                  'Om begivenheden',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(event['description'], style: theme.textTheme.bodyMedium),
                const SizedBox(height: 20),
              ],

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
                    '(${event['currentParticipants']}${event['maxParticipants'] != null ? '/${event['maxParticipants']}' : ''})',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (event['participants'] != null &&
                  (event['participants'] as List).isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: (event['participants'] as List).length,
                    itemBuilder: (context, index) {
                      final participant =
                          (event['participants'] as List)[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(participant),
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
              const SizedBox(height: 16),

              // Tilmeldingsknap
              if (!isPast)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _toggleEventRegistration(event);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: isUserRegistered
                          ? Colors.red
                          : theme.colorScheme.primary,
                    ),
                    child: Text(
                      isUserRegistered
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

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.day == now.day &&
        date.month == now.month &&
        date.year == now.year;
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
      'december',
    ];

    return '${date.day}. ${months[date.month - 1]}';
  }

  String _formatTime(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        final hour = parts[0].padLeft(2, '0');
        final minute = parts[1].padLeft(2, '0');
        return '$hour:$minute';
      }
      return timeString;
    } catch (e) {
      return timeString;
    }
  }
}
