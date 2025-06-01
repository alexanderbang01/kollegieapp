import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/navigation_menu.dart';
import '../services/message_service.dart';
import '../services/user_service.dart';
import '../services/employees_service.dart';
import '../services/residents_service.dart';
import '../models/message_model.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Brugerdata
  String _currentUserId = '';
  String _currentUserType = '';
  String _currentUserName = '';

  // Data
  List<Map<String, dynamic>> _allContacts = [];
  List<Conversation> _conversations = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeUser() async {
    try {
      final userId = await UserService.getUserId();
      final userType = await UserService.getUserType();
      final userName = await UserService.getFullName();

      setState(() {
        _currentUserId = userId;
        _currentUserType = userType;
        _currentUserName = userName;
      });

      await _loadContacts();
    } catch (e) {
      setState(() {
        _errorMessage = 'Fejl ved indlæsning af brugerdata: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadContacts() async {
    if (_currentUserId.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Hent kun ansatte - beboere skal kun kunne kontakte personalet
      final employeesResponse = await EmployeesService.getEmployees();

      List<Map<String, dynamic>> contacts = [];

      // Tilføj ansatte
      if (employeesResponse['success'] == true) {
        final employees = employeesResponse['data'] as List<dynamic>? ?? [];
        for (var employee in employees) {
          contacts.add({
            'id': employee['id'],
            'name':
                employee['name'] ??
                '${employee['first_name']} ${employee['last_name']}',
            'type': 'staff',
            'role': employee['profesion'] ?? employee['role'] ?? 'Personale',
            'avatar': _generateInitials(
              employee['name'] ??
                  '${employee['first_name']} ${employee['last_name']}',
            ),
            'lastMessage': '',
            'lastMessageTime': null,
            'unreadCount': 0,
            'isOnline': false,
            'profileImage': employee['profile_image'],
          });
        }
      }

      // Filtrer den nuværende bruger ud
      contacts = contacts.where((contact) {
        if (_currentUserType == contact['type'] &&
            contact['id'].toString() == _currentUserId) {
          return false;
        }
        return true;
      }).toList();

      setState(() {
        _allContacts = contacts;
        _conversations = contacts
            .map((contact) => Conversation.fromJson(contact))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Fejl ved indlæsning af kontakter: $e';
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _getResidents() async {
    try {
      return await ResidentsService.getResidents();
    } catch (e) {
      return {'success': false, 'message': 'Fejl ved hentning af beboere: $e'};
    }
  }

  String _generateInitials(String name) {
    if (name.isEmpty) return 'U';

    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    } else {
      return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
    }
  }

  // Filtrerede kontakter baseret på søgning
  List<Conversation> get _filteredConversations {
    if (_searchQuery.isEmpty) {
      return _conversations;
    }
    return _conversations.where((conversation) {
      final name = conversation.name.toLowerCase();
      final role = conversation.role.toLowerCase();
      final searchLower = _searchQuery.toLowerCase();

      return name.contains(searchLower) || role.contains(searchLower);
    }).toList();
  }

  // Gruppér samtaler efter type
  List<Conversation> get _staffConversations {
    return _filteredConversations
        .where((conv) => conv.type == 'staff')
        .toList();
  }

  List<Conversation> get _residentConversations {
    return _filteredConversations
        .where((conv) => conv.type == 'resident')
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'Beskeder',
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
      endDrawer: const NavigationMenu(currentRoute: messagesRoute),
      body: SafeArea(
        child: Column(
          children: [
            // Søgefelt
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Søg efter personale...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: theme.brightness == Brightness.light
                      ? Colors.grey.shade100
                      : Colors.grey.shade800,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),

            // Info besked
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tryk på en person for at starte en samtale',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Kontakter liste
            Expanded(child: _buildBody()),
          ],
        ),
      ),
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
            Text('Indlæser kontakter...'),
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
              onPressed: _loadContacts,
              child: const Text('Prøv igen'),
            ),
          ],
        ),
      );
    }

    if (_filteredConversations.isEmpty) {
      return _buildEmptyState();
    }

    return _buildContactsList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.message_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'Ingen personale fundet'
                : 'Ingen personale tilgængeligt',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Prøv at søge efter noget andet'
                : 'Personalet vil vises her når de er tilgængelige',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsList() {
    return RefreshIndicator(
      onRefresh: _loadContacts,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          // Kun personale sektion - beboere kan kun kontakte personalet
          if (_staffConversations.isNotEmpty) ...[
            _buildSectionHeader('Personale'),
            ..._staffConversations.map(
              (conversation) => _buildContactCard(conversation),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildContactCard(Conversation conversation) {
    final theme = Theme.of(context);
    final bool isStaff = conversation.type == 'staff';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openConversation(conversation),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: isStaff
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : theme.colorScheme.secondary.withOpacity(0.1),
                backgroundImage: conversation.profileImage != null
                    ? NetworkImage(conversation.profileImage!)
                    : null,
                child: conversation.profileImage == null
                    ? Text(
                        conversation.avatar,
                        style: TextStyle(
                          color: isStaff
                              ? theme.colorScheme.primary
                              : theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // Contact info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isStaff
                            ? theme.colorScheme.primary.withOpacity(0.1)
                            : theme.colorScheme.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        conversation.role,
                        style: TextStyle(
                          fontSize: 10,
                          color: isStaff
                              ? theme.colorScheme.primary
                              : theme.colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tryk for at starte samtale med personalet',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Chevron icon
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  void _openConversation(Conversation conversation) async {
    // Naviger til chat-skærmen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          conversation: conversation.toJson(),
          currentUserId: _currentUserId,
          currentUserType: _currentUserType,
        ),
      ),
    );

    // Hvis der blev sendt en besked, genindlæs kontakter
    if (result == true) {
      _loadContacts();
    }
  }
}
