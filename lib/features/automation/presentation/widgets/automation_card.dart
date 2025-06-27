import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/automation_entity.dart';
import '../../../../core/constants/app_colors.dart';

class AutomationCard extends StatelessWidget {
  final AutomationEntity automation;
  final Function(bool) onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  
  const AutomationCard({
    Key? key,
    required this.automation,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Type Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getTypeColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getTypeIcon(),
                    color: _getTypeColor(),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Title and Type
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTypeName(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getTypeDescription(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Active Switch
                Switch(
                  value: automation.isActive,
                  onChanged: onToggle,
                  activeColor: AppColors.success,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  if (automation.nextExecutionDate != null)
                    _buildDetailRow(
                      icon: Icons.schedule,
                      label: 'Sonraki Çalışma',
                      value: DateFormat('dd MMM yyyy', 'tr').format(automation.nextExecutionDate!),
                    ),
                  if (automation.executionCount > 0) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      icon: Icons.done_all,
                      label: 'Çalışma Sayısı',
                      value: '${automation.executionCount} kez',
                    ),
                  ],
                  if (automation.lastExecutionDate != null) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      icon: Icons.history,
                      label: 'Son Çalışma',
                      value: DateFormat('dd MMM yyyy', 'tr').format(automation.lastExecutionDate!),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Düzenle'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                  label: const Text('Sil', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
      },
    );
  }
  
  IconData _getTypeIcon() {
    switch (automation.type) {
      case AutomationType.recurring:
        return Icons.autorenew;
      case AutomationType.reminder:
        return Icons.notifications_outlined;
      case AutomationType.smartSuggestion:
        return Icons.lightbulb_outline;
    }
  }
  
  Color _getTypeColor() {
    switch (automation.type) {
      case AutomationType.recurring:
        return AppColors.primary;
      case AutomationType.reminder:
        return AppColors.warning;
      case AutomationType.smartSuggestion:
        return AppColors.accent;
    }
  }
  
  String _getTypeName() {
    switch (automation.type) {
      case AutomationType.recurring:
        return 'Tekrarlayan Harcama';
      case AutomationType.reminder:
        return 'Hatırlatıcı';
      case AutomationType.smartSuggestion:
        return 'Akıllı Öneri';
    }
  }
  
  String _getTypeDescription() {
    switch (automation.type) {
      case AutomationType.recurring:
        return 'Belirli aralıklarla otomatik harcama oluşturur';
      case AutomationType.reminder:
        return 'Ödeme tarihlerinde bildirim gönderir';
      case AutomationType.smartSuggestion:
        return 'Harcama desenlerine göre öneriler sunar';
    }
  }
}