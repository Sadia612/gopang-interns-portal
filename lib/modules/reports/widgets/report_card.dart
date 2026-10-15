
import 'package:flutter/material.dart';

import '../models/work_report.dart';

class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
    required this.report,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final WorkReport report;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static const Color navy = Color(0xFF1A5490);
  static const Color muted = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE5ECF4);

  @override
  Widget build(BuildContext context) {
    final status = report.status.trim().isEmpty
        ? 'Status unavailable'
        : report.status.replaceAll('_', ' ');

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  report.taskTitle.trim().isEmpty
                      ? 'Work report'
                      : report.taskTitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: navy,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 11,
                      color: navy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.folder_outlined,
                size: 17,
                color: muted,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  report.projectName.trim().isEmpty
                      ? 'Project not provided'
                      : report.projectName,
                  style: const TextStyle(
                    fontSize: 13,
                    color: muted,
                  ),
                ),
              ),
            ],
          ),
          if ((report.reportDate ?? '').isNotEmpty) ...[
            const SizedBox(height: 7),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: muted,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    report.reportDate!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: muted,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (report.workDone.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'Work completed',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: navy,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              report.workDone,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                height: 1.45,
                color: muted,
              ),
            ),
          ],
          if (report.description.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              report.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
                color: muted,
              ),
            ),
          ],
          const SizedBox(height: 14),
          const Divider(height: 1, color: borderColor),
          const SizedBox(height: 12),

          // View, Edit and Delete buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onView,
                  icon: const Icon(
                    Icons.visibility_outlined,
                    size: 17,
                  ),
                  label: const Text('View'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: navy,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    side: const BorderSide(
                      color: Color(0xFFB8CCE0),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 17,
                  ),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF178FB4),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    side: const BorderSide(
                      color: Color(0xFFB9E2EC),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 17,
                  ),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFC0392B),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    side: const BorderSide(
                      color: Color(0xFFECC5C1),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
