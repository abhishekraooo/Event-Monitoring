// lib/services/database_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final supabase = Supabase.instance.client;

  /// Fetches the total number of team registrations for the dashboard.
  Future<Map<String, int>> getDashboardStats() async {
    try {
      final count = await supabase.from('registrations').count();
      return {'totalRegistrations': count};
    } catch (e) {
      print('Error fetching stats: $e');
      return {'totalRegistrations': 0};
    }
  }

  /// Fetches all registration records, sorted alphabetically by team name.
  Future<List<Map<String, dynamic>>> getAllRegistrations() async {
    try {
      final response = await supabase
          .from('registrations')
          .select()
          .order('team_name', ascending: true);
      return response;
    } catch (e) {
      print('Error fetching registrations: $e');
      return [];
    }
  }

  /// Fetches the role of the currently logged-in coordinator.
  Future<String> getCurrentUserRole() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final response = await supabase
          .from('coordinators')
          .select('role')
          .eq('id', userId)
          .single();
      return response['role'] ?? 'viewer';
    } catch (e) {
      print('Error fetching user role: $e');
      return 'viewer'; // Default to 'viewer' on error
    }
  }

  /// Updates a registration record with a map of new data.
  Future<void> updateRegistration(
    int id,
    Map<String, dynamic> dataToUpdate,
  ) async {
    await supabase.from('registrations').update(dataToUpdate).eq('id', id);
  }

  /// Fetches the most up-to-date data for a single registration by its ID.
  Future<Map<String, dynamic>> getRegistrationById(int id) async {
    final response = await supabase
        .from('registrations')
        .select()
        .eq('id', id)
        .single();
    return response;
  }
  // --- ADD THESE NEW FUNCTIONS ---

  /// Fetches the list of all coordinators (admin only).
  Future<List<Map<String, dynamic>>> getAllCoordinators() async {
    try {
      final response = await supabase.from('coordinators').select();
      return response;
    } catch (e) {
      print('Error fetching coordinators: $e');
      return [];
    }
  }

  /// Updates the role of a specific coordinator (admin only).
  Future<void> updateCoordinatorRole(String userId, String newRole) async {
    await supabase
        .from('coordinators')
        .update({'role': newRole})
        .eq('id', userId);
  }
}
