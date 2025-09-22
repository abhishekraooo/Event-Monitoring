// lib/screens/teams_screen.dart

import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:ideathon_monitor/screen/team_detail_screen.dart';
import 'package:ideathon_monitor/services/database_service.dart';
import 'package:ideathon_monitor/utils/export_service.dart';

// Import for web-specific download functionality
import 'dart:html' as html;

import 'package:ideathon_monitor/widgets/filter_chip_group.dart';

class TeamsScreen extends StatefulWidget {
  final String userRole;
  const TeamsScreen({super.key, required this.userRole});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  final _searchController = TextEditingController();
  final _dbService = DatabaseService();
  final _exportService = ExportService(); // <-- ADD THIS LINE

  bool _isLoading = true;
  List<Map<String, dynamic>> _allRegistrations = [];
  List<Map<String, dynamic>> _displayedRegistrations = [];

  String _selectedFormat = 'All';
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    _fetchRegistrations();
    _searchController.addListener(_runFilter);
  }

  @override
  void dispose() {
    _searchController.removeListener(_runFilter);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchRegistrations() async {
    final data = await _dbService.getAllRegistrations();
    if (mounted) {
      setState(() {
        _allRegistrations = data;
        _displayedRegistrations = data;
        _isLoading = false;
      });
    }
  }

  void _runFilter() {
    final query = _searchController.text.toLowerCase();
    List<Map<String, dynamic>> results = _allRegistrations;

    if (_selectedFormat != 'All') {
      results = results.where((reg) {
        return reg['participation_format'] == _selectedFormat;
      }).toList();
    }

    if (_selectedStatus != 'All') {
      results = results.where((reg) {
        final title = reg['idea_title'] as String?;
        final abstract = reg['idea_abstract'] as String?;
        final hasDetails =
            (title != null && title.isNotEmpty) &&
            (abstract != null && abstract.isNotEmpty);

        if (_selectedStatus == 'Complete') return hasDetails;
        if (_selectedStatus == 'Incomplete') return !hasDetails;
        return true;
      }).toList();
    }

    if (query.isNotEmpty) {
      results = results.where((reg) {
        final teamName = (reg['team_name'] ?? '').toLowerCase();
        final leadName = (reg['team_lead_name'] ?? '').toLowerCase();
        final member1Name = (reg['member_1_name'] ?? '').toLowerCase();
        final member2Name = (reg['member_2_name'] ?? '').toLowerCase();
        final member3Name = (reg['member_3_name'] ?? '').toLowerCase();
        final college = (reg['team_lead_college'] ?? '').toLowerCase();

        return teamName.contains(query) ||
            leadName.contains(query) ||
            member1Name.contains(query) ||
            member2Name.contains(query) ||
            member3Name.contains(query) ||
            college.contains(query);
      }).toList();
    }

    setState(() {
      _displayedRegistrations = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Registrations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.description),
            tooltip: 'Export to CSV',
            // Call the method from our new export service
            onPressed: () =>
                _exportService.exportToCsv(context, _displayedRegistrations),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search by Team, Member, or College',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Use our new reusable FilterChipGroup widget
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FilterChipGroup(
                        label: 'Format:',
                        options: const ['All', 'Team', 'Solo'],
                        selectedOption: _selectedFormat,
                        onSelected: (value) {
                          setState(() => _selectedFormat = value);
                          _runFilter();
                        },
                      ),
                      FilterChipGroup(
                        label: 'Details:',
                        options: const ['All', 'Complete', 'Incomplete'],
                        selectedOption: _selectedStatus,
                        onSelected: (value) {
                          setState(() => _selectedStatus = value);
                          _runFilter();
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  Expanded(
                    child: _displayedRegistrations.isEmpty
                        ? const Center(
                            child: Text('No matching registrations found.'),
                          )
                        : ListView.builder(
                            itemCount: _displayedRegistrations.length,
                            itemBuilder: (context, index) {
                              final registration =
                                  _displayedRegistrations[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 6.0,
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Text((index + 1).toString()),
                                  ),
                                  title: Text(
                                    registration['team_name'] ?? 'No Team Name',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Lead: ${registration['team_lead_name'] ?? 'N/A'}',
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TeamDetailScreen(
                                          registration: registration,
                                          userRole: widget.userRole,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFilterChipGroup({
    required String label,
    required List<String> options,
    required String selectedOption,
    required ValueChanged<String> onSelected,
  }) {
    return Row(
      children: [
        Text('$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
        ...options.map((option) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(option),
              selected: selectedOption == option,
              onSelected: (isSelected) {
                if (isSelected) {
                  onSelected(option);
                }
              },
            ),
          );
        }).toList(),
      ],
    );
  }
}
