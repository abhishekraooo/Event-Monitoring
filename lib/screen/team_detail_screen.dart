// lib/screens/team_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:ideathon_monitor/screen/edit_team_screen.dart';
import 'package:ideathon_monitor/services/database_service.dart';

class TeamDetailScreen extends StatefulWidget {
  final Map<String, dynamic> registration;
  final String userRole;

  const TeamDetailScreen({
    super.key,
    required this.registration,
    required this.userRole,
  });

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen> {
  late Map<String, dynamic> _currentRegistration;
  final _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _currentRegistration = widget.registration;
  }

  Future<void> _refreshData() async {
    final freshData = await _dbService.getRegistrationById(
      _currentRegistration['id'],
    );
    if (mounted) {
      setState(() {
        _currentRegistration = freshData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentRegistration['team_name'] ?? 'Details'),
      ),
      floatingActionButton: widget.userRole == 'editor'
          ? FloatingActionButton(
              onPressed: () async {
                final didSaveChanges = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditTeamScreen(registration: _currentRegistration),
                  ),
                );

                if (didSaveChanges == true && mounted) {
                  _refreshData();
                }
              },
              child: const Icon(Icons.edit),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentRegistration['idea_title'] ?? 'No Title Provided',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Divider(height: 24),
                  Text(
                    _currentRegistration['idea_abstract'] ??
                        'No abstract provided.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Team Members',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),

          _ParticipantCard(
            registration: _currentRegistration,
            prefix: 'team_lead',
            isLead: true,
          ),
          if (_currentRegistration['member_1_name'] != null &&
              _currentRegistration['member_1_name'].isNotEmpty)
            _ParticipantCard(
              registration: _currentRegistration,
              prefix: 'member_1',
            ),
          if (_currentRegistration['member_2_name'] != null &&
              _currentRegistration['member_2_name'].isNotEmpty)
            _ParticipantCard(
              registration: _currentRegistration,
              prefix: 'member_2',
            ),
          if (_currentRegistration['member_3_name'] != null &&
              _currentRegistration['member_3_name'].isNotEmpty)
            _ParticipantCard(
              registration: _currentRegistration,
              prefix: 'member_3',
            ),

          const SizedBox(height: 60),
        ],
      ),
    );
  }
}

// Helper widget for displaying a participant's details
class _ParticipantCard extends StatelessWidget {
  final Map<String, dynamic> registration;
  final String prefix;
  final bool isLead;

  const _ParticipantCard({
    required this.registration,
    required this.prefix,
    this.isLead = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      color: isLead ? Colors.deepPurple.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  isLead ? Icons.star : Icons.person,
                  color: Colors.deepPurple,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    registration['${prefix}_name'] ?? 'N/A',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (isLead) const Chip(label: Text('Leader')),
              ],
            ),
            const Divider(),
            _BuildDetailRow(
              title: 'Email:',
              value: registration['${prefix}_email'],
            ),
            _BuildDetailRow(
              title: 'Contact:',
              value: registration['${prefix}_number'],
            ),
            _BuildDetailRow(
              title: 'College:',
              value: registration['${prefix}_college'],
            ),
            _BuildDetailRow(
              title: 'Branch:',
              value: registration['${prefix}_branch'],
            ),
            _BuildDetailRow(
              title: 'Semester:',
              value: registration['${prefix}_semester'],
            ),
          ],
        ),
      ),
    );
  }
}

// Helper widget for displaying a single row of detail (e.g., "Title: Value")
class _BuildDetailRow extends StatelessWidget {
  final String title;
  final String? value;

  const _BuildDetailRow({required this.title, this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value ?? 'N/A')),
        ],
      ),
    );
  }
}
