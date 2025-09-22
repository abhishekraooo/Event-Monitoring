// lib/widgets/filter_chip_group.dart

import 'package:flutter/material.dart';

class FilterChipGroup extends StatelessWidget {
  final String label;
  final List<String> options;
  final String selectedOption;
  final ValueChanged<String> onSelected;

  const FilterChipGroup({
    super.key,
    required this.label,
    required this.options,
    required this.selectedOption,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
