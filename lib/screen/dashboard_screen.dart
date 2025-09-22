// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:ideathon_monitor/screen/admin_screen.dart';
import 'package:ideathon_monitor/screen/teams_screen.dart';
import 'package:ideathon_monitor/services/database_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final Future<Map<String, dynamic>> _dashboardDataFuture;
  final DatabaseService _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _dashboardDataFuture = _loadDashboardData();
  }

  Future<Map<String, dynamic>> _loadDashboardData() async {
    final registrations = await _dbService.getAllRegistrations();
    final role = await _dbService.getCurrentUserRole();
    return {'registrations': registrations, 'role': role};
  }

  // Helper function to count participants in a single registration
  int _countParticipants(Map<String, dynamic> reg) {
    int count = 0;
    if (reg['team_lead_name'] != null && reg['team_lead_name'].isNotEmpty)
      count++;
    if (reg['member_1_name'] != null && reg['member_1_name'].isNotEmpty)
      count++;
    if (reg['member_2_name'] != null && reg['member_2_name'].isNotEmpty)
      count++;
    if (reg['member_3_name'] != null && reg['member_3_name'].isNotEmpty)
      count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Supabase.instance.client.auth.signOut(),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dashboardDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // --- NEW: Perform calculations here ---
          final registrations =
              snapshot.data?['registrations'] as List<dynamic>? ?? [];
          final userRole = snapshot.data?['role'] as String? ?? 'viewer';

          final totalRegistrations = registrations.length;
          final totalParticipants = registrations.fold<int>(
            0,
            (sum, reg) => sum + _countParticipants(reg),
          );
          final abstractsSubmitted = registrations
              .where(
                (reg) =>
                    (reg['idea_abstract'] != null &&
                    reg['idea_abstract'].isNotEmpty),
              )
              .length;
          final soloTeams = registrations
              .where((reg) => reg['participation_format'] == 'Solo')
              .length;
          final teamTeams = registrations
              .where((reg) => reg['participation_format'] == 'Team')
              .length;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // --- UPDATED: Stat Cards Section ---
                Wrap(
                  spacing: 16.0,
                  runSpacing: 16.0,
                  alignment: WrapAlignment.center,
                  children: [
                    StatCard(
                      title: 'Total Teams',
                      value: totalRegistrations.toString(),
                      icon: Icons.group,
                      color: Colors.deepPurple,
                    ),
                    StatCard(
                      title: 'Total Participants',
                      value: totalParticipants.toString(),
                      icon: Icons.person,
                      color: Colors.green,
                    ),
                    StatCard(
                      title: 'Abstracts Submitted',
                      value: '$abstractsSubmitted / $totalRegistrations',
                      icon: Icons.lightbulb,
                      color: Colors.orange,
                    ),
                    StatCard(
                      title: 'Team Registrations',
                      value: teamTeams.toString(),
                      icon: Icons.groups,
                      color: Colors.blue,
                    ),
                    StatCard(
                      title: 'Solo Registrations',
                      value: soloTeams.toString(),
                      icon: Icons.person_outline,
                      color: Colors.teal,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.list_alt),
                  title: const Text('View All Registrations'),
                  subtitle: const Text(
                    'See detailed information for every team',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeamsScreen(userRole: userRole),
                      ),
                    );
                  },
                ),
                // --- NEW: Conditionally show the Admin Panel link ---
                if (userRole == 'admin')
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings),
                    title: const Text('Admin: Manage Coordinators'),
                    subtitle: const Text('Add/remove users and manage roles'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminScreen(),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// The StatCard widget remains unchanged
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Card(
        elevation: 2.0,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(title, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
