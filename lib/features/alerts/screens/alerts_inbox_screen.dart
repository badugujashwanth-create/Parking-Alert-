import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/routing/app_routes.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/alert_controller.dart';
import '../models/alert_item.dart';

class AlertsInboxScreen extends StatelessWidget {
  const AlertsInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthController>().currentUser?.uid;
    if (uid == null) {
      return const Center(child: Text('Please log in to see alerts.'));
    }
    final controller = context.watch<AlertController>();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _FilterBar(uid: uid),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<List<AlertItem>>(
              stream: controller.watchAlerts(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final alerts = snapshot.data ?? [];
                if (alerts.isEmpty) {
                  return const Center(child: Text(AppStrings.alertsEmptyHint));
                }
                return ListView.separated(
                  itemCount: alerts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final alert = alerts[index];
                    return _AlertSwipeable(
                      alert: alert,
                      uid: uid,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AlertController>();
    final currentFilter = controller.filter;
    const filters = [
      {'label': 'All', 'value': 'all'},
      {'label': 'New', 'value': 'new'},
      {'label': 'Resolved', 'value': 'resolved'},
    ];
    return Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: 8,
            children: filters.map((filter) {
              final isSelected = filter['value'] == currentFilter;
              return ChoiceChip(
                label: Text(filter['label']!),
                selected: isSelected,
                onSelected: (_) => controller.filter = filter['value']!,
              );
            }).toList(),
          ),
        ),
        StreamBuilder<int>(
          stream: controller.watchNewCount(uid),
          builder: (context, snapshot) {
            final count = snapshot.data ?? 0;
            if (count == 0) {
              return const SizedBox.shrink();
            }
            return Chip(
              label: Text('${AppStrings.alertNewLabel} $count'),
              backgroundColor: Colors.redAccent.shade100,
            );
          },
        ),
      ],
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert});

  final AlertItem alert;

  @override
  Widget build(BuildContext context) {
    final statusColor = alert.status == 'new' ? Colors.redAccent : Colors.grey;
    final subtitle = alert.note?.isNotEmpty == true ? alert.note! : 'No additional notes';
    final created = alert.createdAt;
    final timeLabel = created != null ? TimeOfDay.fromDateTime(created).format(context) : '-';
    return Card(
      child: ListTile(
        onTap: () => Navigator.of(context).pushNamed(
          AppRoutes.alertDetails,
          arguments: alert.alertId,
        ),
        title: Text(alert.reason),
        subtitle: Text('$subtitle • $timeLabel'),
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: Text(
            alert.status == 'new' ? 'N' : 'R',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        trailing: Text(alert.status.toUpperCase()),
      ),
    );
  }
}

class _AlertSwipeable extends StatelessWidget {
  const _AlertSwipeable({
    required this.alert,
    required this.uid,
  });

  final AlertItem alert;
  final String uid;

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.alertDelete),
        content: const Text(AppStrings.alertDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.alertDelete),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Widget _buildBackground(BuildContext context, String text, Color color, Alignment alignment) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check, color: Colors.white),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<AlertController>();
    return Dismissible(
      key: ValueKey(alert.alertId),
      direction: DismissDirection.horizontal,
      background: _buildBackground(context, AppStrings.alertResolveSwipe, Colors.green, Alignment.centerLeft),
      secondaryBackground: _buildBackground(context, AppStrings.alertDeleteSwipe, Colors.redAccent, Alignment.centerRight),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await controller.resolveAlert(uid: uid, alertId: alert.alertId);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(AppStrings.alertResolvedSnackbar)),
            );
          }
          return false;
        } else {
          final confirmed = await _confirmDelete(context);
          if (confirmed) {
            await controller.deleteAlert(uid: uid, alertId: alert.alertId);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(AppStrings.alertDeletedSnackbar)),
              );
            }
          }
          return false;
        }
      },
      child: _AlertTile(alert: alert),
    );
  }
}
