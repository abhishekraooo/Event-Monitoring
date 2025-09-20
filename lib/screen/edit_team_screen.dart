// lib/screens/edit_team_screen.dart

import 'package:flutter/material.dart';
import 'package:ideathon_monitor/services/database_service.dart';

class EditTeamScreen extends StatefulWidget {
  final Map<String, dynamic> registration;
  const EditTeamScreen({super.key, required this.registration});

  @override
  State<EditTeamScreen> createState() => _EditTeamScreenState();
}

class _EditTeamScreenState extends State<EditTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dbService = DatabaseService();
  bool _isLoading = false;

  // Controllers for every field
  late final TextEditingController _teamNameController;
  late final TextEditingController _ideaTitleController;
  late final TextEditingController _ideaAbstractController;
  late final TextEditingController _formatController;

  late final TextEditingController _leadNameController;
  late final TextEditingController _leadEmailController;
  late final TextEditingController _leadNumberController;
  late final TextEditingController _leadSemesterController;
  late final TextEditingController _leadBranchController;
  late final TextEditingController _leadCollegeController;

  // Controllers for members (can be null)
  late final TextEditingController? _member1NameController;
  late final TextEditingController? _member1EmailController;
  late final TextEditingController? _member1NumberController;
  late final TextEditingController? _member1SemesterController;
  late final TextEditingController? _member1BranchController;
  late final TextEditingController? _member1CollegeController;

  // ... Add controllers for member 2 and 3 similarly
  late final TextEditingController? _member2NameController;
  late final TextEditingController? _member2EmailController;
  late final TextEditingController? _member2NumberController;
  late final TextEditingController? _member2SemesterController;
  late final TextEditingController? _member2BranchController;
  late final TextEditingController? _member2CollegeController;

  // ... Add controllers for member 2 and 3 similarly
  late final TextEditingController? _member3NameController;
  late final TextEditingController? _member3EmailController;
  late final TextEditingController? _member3NumberController;
  late final TextEditingController? _member3SemesterController;
  late final TextEditingController? _member3BranchController;
  late final TextEditingController? _member3CollegeController;

  @override
  void initState() {
    super.initState();
    final reg = widget.registration;

    // Initialize all controllers with existing data
    _teamNameController = TextEditingController(text: reg['team_name']);
    _ideaTitleController = TextEditingController(text: reg['idea_title']);
    _ideaAbstractController = TextEditingController(text: reg['idea_abstract']);
    _formatController = TextEditingController(
      text: reg['participation_format'],
    );

    _leadNameController = TextEditingController(text: reg['team_lead_name']);
    _leadEmailController = TextEditingController(text: reg['team_lead_email']);
    _leadNumberController = TextEditingController(
      text: reg['team_lead_number'],
    );
    _leadSemesterController = TextEditingController(
      text: reg['team_lead_semester'],
    );
    _leadBranchController = TextEditingController(
      text: reg['team_lead_branch'],
    );
    _leadCollegeController = TextEditingController(
      text: reg['team_lead_college'],
    );

    _member1NameController = TextEditingController(text: reg['member_1_name']);
    _member1EmailController = TextEditingController(
      text: reg['member_1_email'],
    );
    _member1NumberController = TextEditingController(
      text: reg['member_1_number'],
    );
    _member1SemesterController = TextEditingController(
      text: reg['member_1_semester'],
    );
    _member1BranchController = TextEditingController(
      text: reg['member_1_branch'],
    );
    _member1CollegeController = TextEditingController(
      text: reg['member_1_college'],
    );

    _member2NameController = TextEditingController(text: reg['member_2_name']);
    _member2EmailController = TextEditingController(
      text: reg['member_2_email'],
    );
    _member2NumberController = TextEditingController(
      text: reg['member_2_number'],
    );
    _member2SemesterController = TextEditingController(
      text: reg['member_2_semester'],
    );
    _member2BranchController = TextEditingController(
      text: reg['member_2_branch'],
    );
    _member2CollegeController = TextEditingController(
      text: reg['member_2_college'],
    );

    _member3NameController = TextEditingController(text: reg['member_3_name']);
    _member3EmailController = TextEditingController(
      text: reg['member_3_email'],
    );
    _member3NumberController = TextEditingController(
      text: reg['member_3_number'],
    );
    _member3SemesterController = TextEditingController(
      text: reg['member_3_semester'],
    );
    _member3BranchController = TextEditingController(
      text: reg['member_3_branch'],
    );
    _member3CollegeController = TextEditingController(
      text: reg['member_3_college'],
    );
  }

  @override
  void dispose() {
    // Dispose all controllers to free up resources
    _teamNameController.dispose();
    _ideaTitleController.dispose();
    // ... dispose all other controllers
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Create a map of all the data to update
      final dataToUpdate = {
        'team_name': _teamNameController.text,
        'idea_title': _ideaTitleController.text,
        'idea_abstract': _ideaAbstractController.text,
        'participation_format': _formatController.text,
        'team_lead_name': _leadNameController.text,
        'team_lead_email': _leadEmailController.text,
        'team_lead_number': _leadNumberController.text,
        'team_lead_semester': _leadSemesterController.text,
        'team_lead_branch': _leadBranchController.text,
        'team_lead_college': _leadCollegeController.text,
        'member_1_name': _member1NameController?.text,
        'member_1_email': _member1EmailController?.text,
        'member_1_number': _member1NumberController?.text,
        'member_1_semester': _member1SemesterController?.text,
        'member_1_branch': _member1BranchController?.text,
        'member_1_college': _member1CollegeController?.text,
        // ... add all other member 2 & 3 fields
      };

      try {
        await _dbService.updateRegistration(
          widget.registration['id'],
          dataToUpdate,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Changes saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Pop and signal a refresh
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit ${widget.registration['team_name']}')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSectionHeader('Team Details'),
            _buildTextField(_teamNameController, 'Team Name'),
            _buildTextField(_formatController, 'Participation Format'),
            _buildTextField(_ideaTitleController, 'Idea Title'),
            _buildTextField(
              _ideaAbstractController,
              'Idea Abstract',
              maxLines: 5,
            ),

            _buildSectionHeader('Team Lead Details'),
            _buildTextField(_leadNameController, "Lead's Name"),
            _buildTextField(_leadEmailController, "Lead's Email"),
            _buildTextField(_leadNumberController, "Lead's Number"),
            _buildTextField(_leadSemesterController, "Lead's Semester"),
            _buildTextField(_leadBranchController, "Lead's Branch"),
            _buildTextField(_leadCollegeController, "Lead's College"),

            // --- Member 1 Section ---
            // You can repeat this block for members 2 and 3
            if (_member1NameController?.text.isNotEmpty ?? false) ...[
              _buildSectionHeader('Member 1 Details'),
              _buildTextField(_member1NameController!, "Member 1's Name"),
              _buildTextField(_member1EmailController!, "Member 1's Email"),
              _buildTextField(_member1NumberController!, "Member 1's Number"),
              _buildTextField(
                _member1SemesterController!,
                "Member 1's Semester",
              ),
              _buildTextField(_member1BranchController!, "Member 1's Branch"),
              _buildTextField(_member1CollegeController!, "Member 1's College"),
            ],

            if (_member2NameController?.text.isNotEmpty ?? false) ...[
              _buildSectionHeader('Member 2 Details'),
              _buildTextField(_member2NameController!, "Member 2's Name"),
              _buildTextField(_member2EmailController!, "Member 2's Email"),
              _buildTextField(_member2NumberController!, "Member 2's Number"),
              _buildTextField(
                _member2SemesterController!,
                "Member 2's Semester",
              ),
              _buildTextField(_member2BranchController!, "Member 2's Branch"),
              _buildTextField(_member2CollegeController!, "Member 2's College"),
            ],

            if (_member3NameController?.text.isNotEmpty ?? false) ...[
              _buildSectionHeader('Member 3 Details'),
              _buildTextField(_member3NameController!, "Member 3's Name"),
              _buildTextField(_member3EmailController!, "Member 3's Email"),
              _buildTextField(_member3NumberController!, "Member 3's Number"),
              _buildTextField(
                _member3SemesterController!,
                "Member 3's Semester",
              ),
              _buildTextField(_member3BranchController!, "Member 3's Branch"),
              _buildTextField(_member3CollegeController!, "Member 3's College"),
            ],

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to create section headers
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
    );
  }

  // Helper widget to reduce boilerplate for TextFormFields
  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          alignLabelWithHint: maxLines > 1,
        ),
        maxLines: maxLines,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label cannot be empty';
          }
          return null;
        },
      ),
    );
  }
}
