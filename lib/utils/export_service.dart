// lib/utils/export_service.dart

import 'dart:convert';
import 'package:csv/csv.dart';
import 'dart:html' as html;
import 'package:flutter/material.dart';

class ExportService {
  void exportToCsv(BuildContext context, List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No data to export.')));
      return;
    }

    final List<String> headers = [
      'team_name',
      'idea_title',
      'idea_abstract',
      'participation_format',
      'team_lead_name',
      'team_lead_email',
      'team_lead_number',
      'team_lead_semester',
      'team_lead_branch',
      'team_lead_college',
      'member_1_name',
      'member_1_email',
      'member_1_number',
      'member_1_semester',
      'member_1_branch',
      'member_1_college',
      'member_2_name',
      'member_2_email',
      'member_2_number',
      'member_2_semester',
      'member_2_branch',
      'member_2_college',
      'member_3_name',
      'member_3_email',
      'member_3_number',
      'member_3_semester',
      'member_3_branch',
      'member_3_college',
    ];

    List<List<dynamic>> rows = [];
    rows.add(headers);

    for (var reg in data) {
      List<dynamic> row = [];
      for (var header in headers) {
        row.add(reg[header] ?? '');
      }
      rows.add(row);
    }

    String csv = const ListToCsvConverter().convert(rows);

    final bytes = utf8.encode(csv);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "ideathon_registrations_export.csv")
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
