import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';
import '../widgets/navigation_menu.dart';
import '../widgets/success_notification.dart';
import '../services/employees_service.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  // State variabler
  String _searchQuery = '';
  bool _isLoading = true;
  bool _isSearching = false;
  String? _errorMessage;

  // Data
  List<Map<String, dynamic>> _allContacts = [];
  List<Map<String, dynamic>> _filteredContacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await EmployeesService.getEmployees();

      if (response['success'] == true) {
        final List<dynamic> contactsData = response['data'] ?? [];
        setState(() {
          _allContacts = List<Map<String, dynamic>>.from(contactsData);
          _filteredContacts = _allContacts;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              response['message'] ?? 'Fejl ved indlæsning af kontakter';
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

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _filteredContacts = _allContacts;
        _searchQuery = '';
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchQuery = query;
    });

    try {
      final response = await EmployeesService.searchEmployees(query: query);

      if (response['success'] == true) {
        final List<dynamic> searchResults = response['data'] ?? [];
        setState(() {
          _filteredContacts = List<Map<String, dynamic>>.from(searchResults);
          _isSearching = false;
        });
      } else {
        setState(() {
          _filteredContacts = [];
          _isSearching = false;
        });
      }
    } catch (e) {
      setState(() {
        _filteredContacts = [];
        _isSearching = false;
      });
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _filteredContacts = _allContacts;
      _isSearching = false;
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      SuccessNotification.show(
        context,
        title: 'Intet telefonnummer',
        message: 'Denne kontakt har ikke et telefonnummer',
        icon: Icons.phone_disabled,
        color: Colors.orange,
      );
      return;
    }

    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        SuccessNotification.show(
          context,
          title: 'Kunne ikke ringe',
          message: 'Telefonfunktion ikke tilgængelig på denne enhed',
          icon: Icons.phone_disabled,
          color: Colors.red,
        );
      }
    } catch (e) {
      SuccessNotification.show(
        context,
        title: 'Opkaldsfejl',
        message: 'Der opstod en fejl ved opkald',
        icon: Icons.error_outline,
        color: Colors.red,
      );
    }
  }

  Future<void> _sendEmail(String email) async {
    if (email.isEmpty) {
      SuccessNotification.show(
        context,
        title: 'Ingen email',
        message: 'Denne kontakt har ikke en email-adresse',
        icon: Icons.email_outlined,
        color: Colors.orange,
      );
      return;
    }

    final Uri launchUri = Uri(scheme: 'mailto', path: email);

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        SuccessNotification.show(
          context,
          title: 'Kunne ikke sende email',
          message: 'Email-app ikke tilgængelig på denne enhed',
          icon: Icons.email_outlined,
          color: Colors.red,
        );
      }
    } catch (e) {
      SuccessNotification.show(
        context,
        title: 'Email-fejl',
        message: 'Der opstod en fejl ved afsendelse af email',
        icon: Icons.error_outline,
        color: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'Kontaktpersoner',
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
      endDrawer: const NavigationMenu(currentRoute: contactsRoute),
      body: SafeArea(
        child: Column(
          children: [
            // Søgefelt
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Søg efter kontaktperson...',
                  prefixIcon: _isSearching
                      ? const Padding(
                          padding: EdgeInsets.all(14.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: _clearSearch,
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
                onChanged: (value) => _performSearch(value),
              ),
            ),

            // Content
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
            Text('Indlæser kontaktpersoner...'),
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

    if (_filteredContacts.isEmpty) {
      return _buildEmptyState();
    }

    return _buildContactsList();
  }

  Widget _buildEmptyState() {
    final isSearch = _searchQuery.isNotEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearch ? Icons.search_off : Icons.contacts,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            isSearch ? 'Ingen kontaktpersoner fundet' : 'Ingen kontaktpersoner',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            isSearch
                ? 'Prøv at søge efter noget andet'
                : 'Der er ikke registreret nogle kontaktpersoner endnu',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactsList() {
    return RefreshIndicator(
      onRefresh: _loadContacts,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: _filteredContacts.length,
        itemBuilder: (context, index) {
          final contact = _filteredContacts[index];
          return _buildContactCard(contact);
        },
      ),
    );
  }

  Widget _buildContactCard(Map<String, dynamic> contact) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Kontakt avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  backgroundImage:
                      contact['profile_image'] != null &&
                          contact['profile_image'].isNotEmpty
                      ? NetworkImage(contact['profile_image'])
                      : null,
                  child:
                      contact['profile_image'] == null ||
                          contact['profile_image'].isEmpty
                      ? Text(
                          contact['initials'] ??
                              contact['name']?.substring(0, 1) ??
                              'U',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact['name'] ?? 'Ukendt navn',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          contact['role'] ?? 'Ukendt rolle',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // Telefonnummer (kan trykkes på)
            InkWell(
              onTap: () => _makePhoneCall(contact['phone'] ?? ''),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.phone,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      contact['phone'] ?? 'Intet telefonnummer',
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Email (kan trykkes på)
            InkWell(
              onTap: () => _sendEmail(contact['email'] ?? ''),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.email,
                      size: 20,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        contact['email'] ?? 'Ingen email',
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
