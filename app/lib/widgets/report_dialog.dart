import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../services/social_service.dart';

const reportReasons = [
  'Harassment',
  'Hate',
  'Violence',
  'Sexual',
  'ChildSafety',
  'Scam',
  'Privacy',
  'Other',
];

Future<void> showReportDialog(
  BuildContext context, {
  required String targetType,
  required int targetId,
}) async {
  String reason = reportReasons.first;
  final details = TextEditingController();
  bool busy = false;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text('Report ${targetType.toLowerCase()}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: reason,
              items: reportReasons
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: busy ? null : (value) => reason = value ?? reason,
              decoration: const InputDecoration(labelText: 'Reason'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: details,
              maxLength: 1000,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Details (optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: busy ? null : () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: busy
                ? null
                : () async {
                    setState(() => busy = true);
                    try {
                      final message = await SocialService().report(
                        targetType: targetType,
                        targetId: targetId,
                        reason: reason,
                        details: details.text,
                      );
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(message)));
                      }
                    } catch (error) {
                      if (dialogContext.mounted) {
                        setState(() => busy = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(apiErrorMessage(error))),
                        );
                      }
                    }
                  },
            child: busy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Submit'),
          ),
        ],
      ),
    ),
  );
  details.dispose();
}
