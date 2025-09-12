import 'package:flutter/material.dart';

/*
A header widget that toggles between expanded and collapsed state when tapped.
*/

class ExpandableHeader extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final String title;

  const ExpandableHeader({
    super.key,
    required this.isExpanded,
    required this.onToggle,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Icon(
            isExpanded ? Icons.keyboard_arrow_down : Icons.chevron_right,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}