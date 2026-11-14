import 'package:flutter/material.dart';
import 'package:app_pangan/core/theme/go_pay_theme.dart';

/// Chip musim tanam
Widget buildSeasonChip(BuildContext context, String label, String subtitle) {
  final color = context.goPayColors;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.neutral100.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.neutral100.withValues(alpha: 0.2), width: 0.5),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.crop, size: 12, color: color.neutral500),
        const SizedBox(width: 4),
        Text(
          '$label — $subtitle',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: color.neutral500,
          ),
        ),
      ],
    ),
  );
}