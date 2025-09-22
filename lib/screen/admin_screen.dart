// lib/screens/admin_screen.dart

import 'package:flutter/material.dart';
import 'package:ideathon_monitor/services/database_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _dbService = DatabaseService();
  late Future<List<Map<String, dynamic>>> _coordinatorsFuture;

  @override
  void initState() {
    super.initState();
    _coordinatorsFuture = _dbService.getAllCoordinators();
  }

  void _updateRole(String userId, String newRole) async {
    try {
      await _dbService.updateCoordinatorRole(userId, newRole);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Role updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      // Refresh the list after updating
      setState(() {
        _coordinatorsFuture = _dbService.getAllCoordinators();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating role: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Coordinators')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _coordinatorsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final coordinators = snapshot.data ?? [];

          return Column(
            children: [
              // Info box to remind how to add users
              Container(
                color: Colors.blue.shade50,
                padding: const EdgeInsets.all(12.0),
                margin: const EdgeInsets.all(8.0),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'To add a new user, go to the Supabase dashboard > Authentication and click "Add user". They will appear here automatically.',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: coordinators.length,
                  itemBuilder: (context, index) {
                    final coordinator = coordinators[index];
                    final String userId = coordinator['id'];
                    final String currentRole = coordinator['role'];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: ListTile(
                        title: Text(coordinator['full_name'] ?? 'No Name'),
                        subtitle: Text(coordinator['email'] ?? 'No Email'),
                        trailing: DropdownButton<String>(
                          value: currentRole,
                          items: const [
                            DropdownMenuItem(
                              value: 'viewer',
                              child: Text('Viewer'),
                            ),
                            DropdownMenuItem(
                              value: 'editor',
                              child: Text('Editor'),
                            ),
                            DropdownMenuItem(
                              value: 'admin',
                              child: Text('Admin'),
                            ),
                          ],
                          onChanged: (newRole) {
                            if (newRole != null && newRole != currentRole) {
                              _updateRole(userId, newRole);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
