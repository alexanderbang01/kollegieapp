import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/navigation_menu.dart';
import '../services/user_service.dart';
import '../services/foodplan_service.dart';
import '../services/events_service.dart';
import '../services/news_service.dart';
import '../services/notifications_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey _notificationKey = GlobalKey();

  // Animation controllers
  late AnimationController _notificationAnimationController;
  late Animation<double> _notificationSlideAnimation;
  late Animation<double> _notificationFadeAnimation;
  bool _showNotificationDropdown = false;
  OverlayEntry? _notificationOverlay;

  // User data
  String _userName = '';
  String _userInitials = '';
  String _currentUserId = '';
  String _currentUserType = '';
  String? _profileImageUrl;

  // Madplan data - følger samme mønster som food_screen.dart
  List<Map<String, dynamic>> _currentMealPlan = [];
  bool _loadingMeals = true;
  String? _mealError;

  // Events data
  List<Map<String, dynamic>> _upcomingEvents = [];
  bool _loadingEvents = true;

  // News data
  List<Map<String, dynamic>> _latestNews = [];
  bool _loadingNews = true;

  // Notifications data
  List<Map<String, dynamic>> _notifications = [];
  bool _loadingNotifications = true;
  int _unreadNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    _notificationAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _notificationSlideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _notificationAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _notificationFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _notificationAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _initializeData();
  }

  @override
  void dispose() {
    _notificationAnimationController.dispose();
    _hideNotificationDropdown();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _loadUserData();
    await _loadWeekMeals();
    await _loadUpcomingEvents();
    await _loadLatestNews();
    await _loadNotifications();
  }

  Future<void> _refreshData() async {
    await Future.wait([
      _loadUserData(),
      _loadWeekMeals(),
      _loadUpcomingEvents(),
      _loadLatestNews(),
      _loadNotifications(),
    ]);
  }

  Future<void> _loadUserData() async {
    try {
      final fullName = await UserService.getFullName();
      final initials = await UserService.getUserInitials();
      final userId = await UserService.getUserId();
      final userType = await UserService.getUserType();
      final profileImageUrl = await UserService.getProfileImageUrl();

      if (mounted) {
        setState(() {
          _userName = fullName.isNotEmpty ? fullName : 'Bruger';
          _userInitials = initials;
          _currentUserId = userId;
          _currentUserType = userType;
          _profileImageUrl = profileImageUrl;
        });
      }
    } catch (e) {
      print('Fejl ved indlæsning af brugerdata: $e');
      if (mounted) {
        setState(() {
          _userName = 'Bruger';
          _userInitials = 'U';
          _profileImageUrl = null;
        });
      }
    }
  }

  Future<void> _loadWeekMeals() async {
    setState(() {
      _loadingMeals = true;
      _mealError = null;
    });

    try {
      // Følger samme mønster som food_screen.dart
      final now = DateTime.now();
      final currentWeek = FoodplanService.getSimpleWeekNumber(now);
      final currentYear = now.year;

      final response = await FoodplanService.getFoodplan(
        week: currentWeek,
        year: currentYear,
      );

      print('Madplan response: $response');

      if (response['success'] == true) {
        final data = response['data'];
        if (data != null) {
          setState(() {
            _currentMealPlan = List<Map<String, dynamic>>.from(
              data['meals'] ?? [],
            );
            _loadingMeals = false;
          });
          print('Loaded ${_currentMealPlan.length} meals: $_currentMealPlan');
        } else {
          setState(() {
            _currentMealPlan = [];
            _loadingMeals = false;
          });
        }
      } else {
        setState(() {
          _mealError = response['message'] ?? 'Fejl ved indlæsning af madplan';
          _loadingMeals = false;
        });
      }
    } catch (e) {
      setState(() {
        _mealError = 'Netværksfejl: $e';
        _loadingMeals = false;
      });
    }
  }

  Future<void> _loadUpcomingEvents() async {
    setState(() {
      _loadingEvents = true;
    });

    if (_currentUserId.isEmpty || _currentUserType.isEmpty) {
      setState(() {
        _upcomingEvents = [];
        _loadingEvents = false;
      });
      return;
    }

    try {
      final response = await EventsService.getUpcomingEvents(
        userId: _currentUserId,
        userType: _currentUserType,
        limit: 2,
      );

      if (response['success'] == true && response['data'] != null) {
        final events = response['data'] as List<dynamic>? ?? [];
        setState(() {
          _upcomingEvents = List<Map<String, dynamic>>.from(events);
          _loadingEvents = false;
        });
      } else {
        setState(() {
          _upcomingEvents = [];
          _loadingEvents = false;
        });
      }
    } catch (e) {
      print('Fejl ved indlæsning af begivenheder: $e');
      setState(() {
        _upcomingEvents = [];
        _loadingEvents = false;
      });
    }
  }

  Future<void> _loadLatestNews() async {
    setState(() {
      _loadingNews = true;
    });

    if (_currentUserId.isEmpty) {
      setState(() {
        _latestNews = [];
        _loadingNews = false;
      });
      return;
    }

    try {
      final response = await NewsService.getLatestNews(
        userId: _currentUserId,
        limit: 2,
      );

      if (response['success'] == true && response['data'] != null) {
        final news = response['data'] as List<dynamic>? ?? [];
        setState(() {
          _latestNews = List<Map<String, dynamic>>.from(news);
          _loadingNews = false;
        });
      } else {
        setState(() {
          _latestNews = [];
          _loadingNews = false;
        });
      }
    } catch (e) {
      print('Fejl ved indlæsning af nyheder: $e');
      setState(() {
        _latestNews = [];
        _loadingNews = false;
      });
    }
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _loadingNotifications = true;
    });

    if (_currentUserId.isEmpty) {
      setState(() {
        _notifications = [];
        _unreadNotificationCount = 0;
        _loadingNotifications = false;
      });
      return;
    }

    try {
      // Hent notifikationer
      final response = await NotificationsService.getNotifications(
        userId: _currentUserId,
        limit: 10, // Flere notifikationer til dropdown
      );

      // Hent antal ulæste
      final unreadResponse = await NotificationsService.getUnreadCount(
        userId: _currentUserId,
      );

      if (response['success'] == true && response['data'] != null) {
        final notifications = response['data'] as List<dynamic>? ?? [];
        setState(() {
          _notifications = List<Map<String, dynamic>>.from(notifications);
          _unreadNotificationCount =
              unreadResponse['data']?['unread_count'] ?? 0;
          _loadingNotifications = false;
        });
      } else {
        setState(() {
          _notifications = [];
          _unreadNotificationCount = 0;
          _loadingNotifications = false;
        });
      }
    } catch (e) {
      print('Fejl ved indlæsning af notifikationer: $e');
      setState(() {
        _notifications = [];
        _unreadNotificationCount = 0;
        _loadingNotifications = false;
      });
    }
  }

  Future<void> _markNotificationAsRead(int notificationId) async {
    try {
      await NotificationsService.markAsRead(
        userId: _currentUserId,
        notificationId: notificationId,
      );

      // Opdater lokalt
      setState(() {
        final index = _notifications.indexWhere(
          (n) => n['id'] == notificationId,
        );
        if (index != -1) {
          _notifications[index]['is_read'] = true;
          if (_unreadNotificationCount > 0) {
            _unreadNotificationCount--;
          }
        }
      });
    } catch (e) {
      print('Fejl ved markering som læst: $e');
    }
  }

  Future<void> _markAllNotificationsAsRead() async {
    try {
      await NotificationsService.markAllAsRead(userId: _currentUserId);

      setState(() {
        for (int i = 0; i < _notifications.length; i++) {
          _notifications[i]['is_read'] = true;
        }
        _unreadNotificationCount = 0;
      });
    } catch (e) {
      print('Fejl ved markering af alle som læst: $e');
    }
  }

  void _toggleNotificationDropdown() {
    if (_showNotificationDropdown) {
      _hideNotificationDropdown();
    } else {
      _showNotificationDropdownMethod();
    }
  }

  void _showNotificationDropdownMethod() {
    if (_showNotificationDropdown) return;

    // Sikr at animation controller er initialiseret
    if (!_notificationAnimationController.isCompleted &&
        !_notificationAnimationController.isAnimating) {
      _notificationAnimationController.reset();
    }

    setState(() {
      _showNotificationDropdown = true;
    });

    // Tjek om context og key stadig eksisterer
    if (!mounted || _notificationKey.currentContext == null) return;

    final RenderBox? renderBox =
        _notificationKey.currentContext!.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenWidth = MediaQuery.of(context).size.width;

    _notificationOverlay = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _hideNotificationDropdown,
        child: Container(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned(
                top: position.dy + size.height + 8,
                right: 8, // Justeret fra 16 til 8 for bedre margin
                width:
                    screenWidth -
                    16, // Begrænset bredde til skærmbredde minus margen
                child: AnimatedBuilder(
                  animation: _notificationAnimationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _notificationSlideAnimation.value * 50),
                      child: Opacity(
                        opacity: _notificationFadeAnimation.value,
                        child: _buildNotificationDropdown(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_notificationOverlay!);
    _notificationAnimationController.forward();
  }

  void _hideNotificationDropdown() {
    if (!_showNotificationDropdown) return;

    _notificationAnimationController.reverse().then((_) {
      _notificationOverlay?.remove();
      _notificationOverlay = null;
      if (mounted) {
        setState(() {
          _showNotificationDropdown = false;
        });
      }
    });
  }

  Widget _buildNotificationDropdown() {
    final theme = Theme.of(context);

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 350, // Øget bredde
        constraints: const BoxConstraints(maxHeight: 450, minHeight: 200),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Notifikationer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_unreadNotificationCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$_unreadNotificationCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (_unreadNotificationCount > 0)
                    TextButton(
                      onPressed: _markAllNotificationsAsRead,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Marker alle',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Notifications list
            if (_loadingNotifications)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              )
            else if (_notifications.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ingen notifikationer',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _notifications.length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: Colors.grey.shade200),
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return _buildDropdownNotificationItem(notification);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownNotificationItem(Map<String, dynamic> notification) {
    final theme = Theme.of(context);
    final isRead = notification['is_read'] == true;
    final type = notification['type'] as String;

    IconData icon;
    Color iconColor;

    switch (type) {
      case 'event':
        icon = Icons.event;
        iconColor = Colors.blue;
        break;
      case 'news':
        icon = Icons.newspaper;
        iconColor = Colors.green;
        break;
      case 'message':
        icon = Icons.message;
        iconColor = Colors.orange;
        break;
      default:
        icon = Icons.notifications;
        iconColor = theme.colorScheme.primary;
    }

    return InkWell(
      onTap: () => _onNotificationTap(notification),
      child: Container(
        padding: const EdgeInsets.all(16),
        color: isRead ? null : theme.colorScheme.primary.withOpacity(0.03),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification['title'] ?? '',
                          style: TextStyle(
                            fontWeight: isRead
                                ? FontWeight.w500
                                : FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 2, // Tilføjet maxLines
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!isRead) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification['content'] ?? '',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    maxLines: 3, // Øget fra 2 til 3
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatNotificationDate(notification['created_at']),
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
          final eventIndex = _upcomingEvents.indexWhere(
            (e) => e['id'] == eventId,
          );
          if (eventIndex != -1) {
            _upcomingEvents[eventIndex]['isUserRegistered'] = !isRegistered;

            final currentParticipants =
                _upcomingEvents[eventIndex]['currentParticipants'] as int;

            if (!isRegistered) {
              _upcomingEvents[eventIndex]['currentParticipants'] =
                  currentParticipants + 1;
            } else {
              _upcomingEvents[eventIndex]['currentParticipants'] =
                  currentParticipants - 1;
            }
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message']),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Fejl ved tilmelding'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Netværksfejl: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _onNewsCardTap(Map<String, dynamic> news) async {
    // Marker som læst før navigation
    try {
      await NewsService.markNewsAsRead(
        userId: _currentUserId,
        newsId: news['id'] as int,
      );
    } catch (e) {
      print('Fejl ved markering som læst: $e');
    }

    // Naviger til news screen
    Navigator.pushNamed(context, newsRoute);
  }

  void _onNotificationTap(Map<String, dynamic> notification) async {
    final notificationId = notification['id'] as int;
    final type = notification['type'] as String;
    final relatedId = notification['related_id'];

    // Skjul dropdown først
    _hideNotificationDropdown();

    // Marker som læst hvis ikke allerede læst
    if (notification['is_read'] != true) {
      await _markNotificationAsRead(notificationId);
    }

    // Naviger baseret på type
    switch (type) {
      case 'event':
        Navigator.pushNamed(context, eventsRoute);
        break;
      case 'news':
        Navigator.pushNamed(context, newsRoute);
        break;
      case 'message':
        Navigator.pushNamed(context, messagesRoute);
        break;
    }
  }

  String _getTodayMeal() {
    if (_currentMealPlan.isEmpty) return 'Ingen ret i dag';

    final today = DateTime.now().weekday;
    const dayNames = [
      'Mandag',
      'Tirsdag',
      'Onsdag',
      'Torsdag',
      'Fredag',
      'Lørdag',
      'Søndag',
    ];

    if (today <= dayNames.length) {
      final todayName = dayNames[today - 1];

      for (final meal in _currentMealPlan) {
        if (meal['dag'] == todayName) {
          return meal['ret'] ?? 'Ingen ret';
        }
      }
    }

    return 'Ingen ret i dag';
  }

  List<Map<String, dynamic>> _getUpcomingMeals() {
    if (_currentMealPlan.isEmpty) return [];

    final today = DateTime.now().weekday;
    const dayNames = [
      'Mandag',
      'Tirsdag',
      'Onsdag',
      'Torsdag',
      'Fredag',
      'Lørdag',
      'Søndag',
    ];

    List<Map<String, dynamic>> upcomingMeals = [];

    // Start med i dag og de næste 2 dage
    for (int i = 0; i < 3; i++) {
      final dayIndex = (today - 1 + i) % 7;
      if (dayIndex < dayNames.length) {
        final dayName = dayNames[dayIndex];

        for (final meal in _currentMealPlan) {
          if (meal['dag'] == dayName) {
            String displayDay;
            if (i == 0) {
              displayDay = 'I dag';
            } else if (i == 1) {
              displayDay = 'I morgen';
            } else {
              displayDay = dayName;
            }

            upcomingMeals.add({...meal, 'displayDay': displayDay});
            break;
          }
        }
      }
    }

    // Hvis vi ikke har nok måltider, tilføj resten
    if (upcomingMeals.length < 2 && _currentMealPlan.isNotEmpty) {
      for (final meal in _currentMealPlan) {
        if (upcomingMeals.length >= 3) break;

        bool alreadyAdded = upcomingMeals.any(
          (existing) => existing['dag'] == meal['dag'],
        );
        if (!alreadyAdded) {
          upcomingMeals.add({...meal, 'displayDay': meal['dag']});
        }
      }
    }

    return upcomingMeals;
  }

  String _formatNewsDate(String? dateString) {
    if (dateString == null) return '';

    try {
      final date = DateTime.parse(dateString);

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
    } catch (e) {
      return dateString;
    }
  }

  String _formatNotificationDate(String? dateString) {
    if (dateString == null) return '';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'Nu';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m siden';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}t siden';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d siden';
      } else {
        // DD-MM-YYYY format
        return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }

  // Hjælpefunktioner til datoformatering uden brug af intl
  String _getDayName(int weekday) {
    const days = [
      'Mandag',
      'Tirsdag',
      'Onsdag',
      'Torsdag',
      'Fredag',
      'Lørdag',
      'Søndag',
    ];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final now = DateTime.now();
    final formattedDate =
        '${_getDayName(now.weekday)} ${now.day}. ${_getMonthName(now.month)}';

    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // App Bar med brugerdata fra UserService
              SliverAppBar(
                floating: true,
                pinned: false,
                automaticallyImplyLeading: false,
                backgroundColor: theme.scaffoldBackgroundColor,
                elevation: 0,
                title: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: theme.colorScheme.primary,
                      backgroundImage: _profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!)
                          : null,
                      child: _profileImageUrl == null
                          ? Text(
                              _userInitials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hej ${_userName.split(' ').first}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.brightness == Brightness.light
                                ? Colors.black87
                                : Colors.white,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.brightness == Brightness.light
                                ? Colors.grey
                                : Colors.grey[300],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
                actions: [
                  // Notification icon with badge
                  Container(
                    key: _notificationKey,
                    child: IconButton(
                      icon: Stack(
                        children: [
                          Icon(
                            Icons.notifications_outlined,
                            color: theme.colorScheme.primary,
                            size: 28,
                          ),
                          if (_unreadNotificationCount > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  _unreadNotificationCount > 99
                                      ? '99+'
                                      : _unreadNotificationCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                      onPressed: _toggleNotificationDropdown,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                    onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                  ),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dagens oversigt
                      _buildDaySummaryCard(context, size),
                      const SizedBox(height: 24),

                      // Madplan sektion med horisontal scroll
                      _buildSectionWithSeeAll(
                        context,
                        'Madplan',
                        onPressed: () =>
                            Navigator.pushNamed(context, foodRoute),
                      ),
                      const SizedBox(height: 12),
                      _buildMealPlanSection(),

                      const SizedBox(height: 24),

                      // Kommende begivenheder
                      _buildSectionWithSeeAll(
                        context,
                        'Kommende Begivenheder',
                        onPressed: () =>
                            Navigator.pushNamed(context, eventsRoute),
                      ),
                      const SizedBox(height: 12),
                      _buildEventsSection(),

                      const SizedBox(height: 24),

                      // Nyheder
                      _buildSectionWithSeeAll(
                        context,
                        'Nyheder',
                        onPressed: () =>
                            Navigator.pushNamed(context, newsRoute),
                      ),
                      const SizedBox(height: 12),
                      _buildNewsSection(),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      endDrawer: const NavigationMenu(currentRoute: homeRoute),
    );
  }

  Widget _buildEventsSection() {
    if (_loadingEvents) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 8),
              Text(
                'Indlæser begivenheder...',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    if (_upcomingEvents.isEmpty) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy, color: Colors.grey.shade400),
              const SizedBox(height: 8),
              Text(
                'Ingen kommende begivenheder',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, eventsRoute),
                child: const Text('Se alle begivenheder'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _upcomingEvents.asMap().entries.map((entry) {
        final index = entry.key;
        final event = entry.value;
        final isFirst = index == 0;

        return Padding(
          padding: EdgeInsets.only(
            bottom: index < _upcomingEvents.length - 1 ? 12 : 0,
          ),
          child: _buildModernEventCard(
            context,
            event: event,
            isHighlighted: isFirst,
            onTap: () => Navigator.pushNamed(context, eventsRoute),
            onToggleRegistration: () => _toggleEventRegistration(event),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMealPlanSection() {
    if (_loadingMeals) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 8),
              Text(
                'Indlæser madplan...',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    if (_mealError != null) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade400, size: 40),
              const SizedBox(height: 8),
              Text(
                'Fejl ved indlæsning',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _mealError!,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _loadWeekMeals,
                child: const Text('Prøv igen'),
              ),
            ],
          ),
        ),
      );
    }

    if (_currentMealPlan.isEmpty) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restaurant_menu,
                color: Colors.grey.shade400,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                'Ingen madplan denne uge',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Der er endnu ikke oprettet en madplan',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, foodRoute),
                child: const Text('Se madplan'),
              ),
            ],
          ),
        ),
      );
    }

    final upcomingMeals = _getUpcomingMeals();
    final theme = Theme.of(context);

    print('Current meal plan: $_currentMealPlan');
    print('Upcoming meals: $upcomingMeals');

    if (upcomingMeals.isEmpty) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restaurant_menu,
                color: Colors.grey.shade400,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                'Ingen kommende måltider',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                'Debug: ${_currentMealPlan.length} måltider i alt',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, foodRoute),
                child: const Text('Se madplan'),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: upcomingMeals.length,
        itemBuilder: (context, index) {
          final meal = upcomingMeals[index];
          return _buildHorizontalMealCard(
            context,
            meal['displayDay'] ?? meal['dag'] ?? 'Ukendt dag',
            meal['ret'] ?? 'Ingen ret',
            meal['beskrivelse'] ?? 'Ingen beskrivelse tilgængelig',
            Icons.restaurant,
            theme.colorScheme.primary,
            onTap: () => Navigator.pushNamed(context, foodRoute),
          );
        },
      ),
    );
  }

  Widget _buildNewsSection() {
    if (_loadingNews) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 8),
              Text(
                'Indlæser nyheder...',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    if (_latestNews.isEmpty) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.newspaper, color: Colors.grey.shade400),
              const SizedBox(height: 8),
              Text(
                'Ingen nyheder',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _latestNews.asMap().entries.map((entry) {
        final index = entry.key;
        final news = entry.value;

        return Padding(
          padding: EdgeInsets.only(
            bottom: index < _latestNews.length - 1 ? 12 : 0,
          ),
          child: _buildNewsCardModern(
            context,
            title: news['title'] ?? '',
            content: news['content'] ?? '',
            date: _formatNewsDate(news['published_at']),
            isNew: news['is_recent'] ?? false,
            onTap: () => _onNewsCardTap(news),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDaySummaryCard(BuildContext context, Size size) {
    final theme = Theme.of(context);
    final todayMeal = _getTodayMeal();

    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.home_rounded,
              size: 120,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
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
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.event_available,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_upcomingEvents.length} begivenheder i dag',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // FJERNET: det røde badge - kun notifikations-ikonet i app bar nu
                  ],
                ),
                const Spacer(),
                const Text(
                  'Dagens ret',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  todayMeal,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionWithSeeAll(
    BuildContext context,
    String title, {
    required VoidCallback onPressed,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: onPressed,
          child: Row(
            children: [
              Text(
                'Se alle',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalMealCard(
    BuildContext context,
    String day,
    String meal,
    String details,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 16),
                  ),
                  const Spacer(),
                  Text(
                    day,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                meal,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                details,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernEventCard(
    BuildContext context, {
    required Map<String, dynamic> event,
    required bool isHighlighted,
    required VoidCallback onTap,
    VoidCallback? onToggleRegistration,
  }) {
    final theme = Theme.of(context);
    final currentParticipants = event['currentParticipants'] ?? 0;
    final maxParticipants = event['maxParticipants'];
    final attendeePercent = maxParticipants != null
        ? currentParticipants / maxParticipants
        : 0.0;
    final isUserRegistered = event['isUserRegistered'] ?? false;

    final eventDate = DateTime.parse(event['date']);
    final isToday = _isToday(eventDate);

    return Card(
      elevation: isHighlighted ? 4 : 1,
      shadowColor: isHighlighted
          ? theme.colorScheme.primary.withOpacity(0.4)
          : Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isHighlighted
            ? BorderSide(
                color: theme.colorScheme.primary.withOpacity(0.5),
                width: 1,
              )
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.event,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event['title'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatEventDateTime(event),
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                          ),
                        ),
                      ],
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
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                event['description'] ?? '',
                style: TextStyle(color: Colors.grey[800], fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      event['location'] ?? '',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  // Attendee progress
                  if (maxParticipants != null) ...[
                    Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        Container(
                          width: 100.0 * attendeePercent,
                          height: 6,
                          decoration: BoxDecoration(
                            color: attendeePercent > 0.8
                                ? Colors.orange
                                : theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$currentParticipants/$maxParticipants',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ] else ...[
                    Text(
                      '$currentParticipants deltagere',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const Spacer(),
                  ElevatedButton(
                    onPressed: onToggleRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isUserRegistered
                          ? Colors.red
                          : theme.colorScheme.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isUserRegistered ? 'Afmeld' : 'Tilmeld',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
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

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.day == now.day &&
        date.month == now.month &&
        date.year == now.year;
  }

  String _formatEventDateTime(Map<String, dynamic> event) {
    try {
      final date = DateTime.parse(event['date']);
      final time = event['time'] ?? '';

      final now = DateTime.now();
      String dateStr;

      if (date.day == now.day &&
          date.month == now.month &&
          date.year == now.year) {
        dateStr = 'I dag';
      } else {
        final tomorrow = now.add(const Duration(days: 1));
        if (date.day == tomorrow.day &&
            date.month == tomorrow.month &&
            date.year == tomorrow.year) {
          dateStr = 'I morgen';
        } else {
          final dayNames = [
            'Mandag',
            'Tirsdag',
            'Onsdag',
            'Torsdag',
            'Fredag',
            'Lørdag',
            'Søndag',
          ];
          dateStr = dayNames[date.weekday - 1];
        }
      }

      // Format time
      String timeStr = '';
      if (time.isNotEmpty) {
        final parts = time.split(':');
        if (parts.length >= 2) {
          timeStr = '${parts[0]}:${parts[1]}';
        } else {
          timeStr = time;
        }
      }

      return timeStr.isNotEmpty ? '$dateStr, $timeStr' : dateStr;
    } catch (e) {
      return event['date'] ?? '';
    }
  }

  Widget _buildNewsCardModern(
    BuildContext context, {
    required String title,
    required String content,
    required String date,
    required bool isNew,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.newspaper,
                      color: theme.colorScheme.secondary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (isNew)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'NY',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          content,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 46.0, top: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: onTap,
                      child: Row(
                        children: [
                          Text(
                            'Læs mere',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            size: 12,
                            color: theme.colorScheme.secondary,
                          ),
                        ],
                      ),
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
}
