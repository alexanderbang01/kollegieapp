import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../widgets/navigation_menu.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'Min Profil',
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
      ),
      endDrawer: const NavigationMenu(currentRoute: profileRoute),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profiloversigtskort
              _buildProfileHeader(context),

              // Indhold
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profil Information',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Personlige oplysninger
                    _buildInfoCard(
                      context,
                      title: 'Personlige Oplysninger',
                      icon: Icons.person,
                      content: [
                        _buildDetailRow(context, 'Navn', 'Alexander Jensen'),
                        _buildDetailRow(
                          context,
                          'Email',
                          'alexander@example.com',
                        ),
                        _buildDetailRow(context, 'Telefon', '+45 12 34 56 78'),
                        _buildDetailRow(
                          context,
                          'Fodselsdato',
                          '15. juni 1998',
                        ),
                      ],
                      onEdit: () {
                        _showEditDialog(context, 'Personlige Oplysninger');
                      },
                    ),

                    const SizedBox(height: 20),

                    // Adresse information
                    _buildInfoCard(
                      context,
                      title: 'Adresse',
                      icon: Icons.home,
                      content: [
                        _buildDetailRow(context, 'Vaerelse', 'A-204'),
                        _buildDetailRow(context, 'Etage', '2. sal'),
                        _buildDetailRow(context, 'Adresse', 'Kollegievej 123'),
                        _buildDetailRow(context, 'Postnr & By', '8800 Viborg'),
                      ],
                      onEdit: () {
                        _showEditDialog(context, 'Adresse');
                      },
                    ),

                    const SizedBox(height: 20),

                    // Kontaktperson
                    _buildInfoCard(
                      context,
                      title: 'Kontaktperson i nodsituation',
                      icon: Icons.contacts,
                      content: [
                        _buildDetailRow(context, 'Navn', 'Marie Jensen'),
                        _buildDetailRow(context, 'Relation', 'Mor'),
                        _buildDetailRow(context, 'Telefon', '+45 87 65 43 21'),
                      ],
                      onEdit: () {
                        _showEditDialog(context, 'Kontaktperson');
                      },
                    ),

                    const SizedBox(height: 20),

                    // Præferencer
                    _buildInfoCard(
                      context,
                      title: 'Praeferencers',
                      icon: Icons.favorite,
                      content: [
                        _buildSwitchRow(
                          context,
                          'Vis mig i beboerlisten',
                          true,
                        ),
                        _buildSwitchRow(
                          context,
                          'Modtag push-notifikationer',
                          true,
                        ),
                        _buildSwitchRow(context, 'Email-notifikationer', false),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Betalingshistorik
                    _buildPaymentHistoryCard(context),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: theme.colorScheme.primary),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Text(
                'AJ',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Alexander Jensen',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Studerende • Mercantec',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Rediger profilbillede
              },
              icon: const Icon(Icons.photo_camera),
              label: const Text('Skift Billede'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: theme.colorScheme.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> content,
    VoidCallback? onEdit,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: onEdit,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
            const Divider(height: 24),
            ...content,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(BuildContext context, String label, bool value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          Switch(
            value: value,
            onChanged: (newValue) {
              // Håndter ændring af switch
            },
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistoryCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Betalingshistorik',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const Divider(height: 24),

            // Transaktioner
            _buildTransactionItem(
              context,
              date: '01. maj 2025',
              description: 'Husleje - Maj',
              amount: '4.200 kr',
              isCompleted: true,
            ),
            const Divider(height: 8),
            _buildTransactionItem(
              context,
              date: '01. apr 2025',
              description: 'Husleje - April',
              amount: '4.200 kr',
              isCompleted: true,
            ),
            const Divider(height: 8),
            _buildTransactionItem(
              context,
              date: '01. mar 2025',
              description: 'Husleje - Marts',
              amount: '4.200 kr',
              isCompleted: true,
            ),

            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  // Se alle transaktioner
                },
                child: Text(
                  'Se alle transaktioner',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context, {
    required String date,
    required String description,
    required String amount,
    required bool isCompleted,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.green.shade100
                  : Colors.orange.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isCompleted ? Icons.check : Icons.access_time,
              color: isCompleted
                  ? Colors.green.shade700
                  : Colors.orange.shade700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  date,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isCompleted
                  ? Colors.green.shade700
                  : Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, String section) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rediger $section'),
        content: const Text('Denne funktion kommer snart!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
