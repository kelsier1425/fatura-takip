import 'package:flutter/material.dart';
import 'dart:math';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class CategoryHeatmap extends StatelessWidget {
  const CategoryHeatmap({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Son 30 Günlük Harcama Yoğunluğu',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildWeekDayLabels(),
            const SizedBox(height: 8),
            _buildHeatmapGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekDayLabels() {
    final weekDays = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    
    return Row(
      children: [
        const SizedBox(width: 40), // Space for week numbers
        ...weekDays.map((day) => Expanded(
          child: Center(
            child: Text(
              day,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildHeatmapGrid() {
    return Column(
      children: List.generate(5, (weekIndex) => _buildWeekRow(weekIndex)),
    );
  }

  Widget _buildWeekRow(int weekIndex) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '${weekIndex + 1}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ...List.generate(7, (dayIndex) => _buildDayCell(weekIndex, dayIndex)),
        ],
      ),
    );
  }

  Widget _buildDayCell(int weekIndex, int dayIndex) {
    final random = Random(weekIndex * 7 + dayIndex);
    final intensity = random.nextDouble();
    final hasExpense = random.nextBool() && random.nextBool();
    
    Color cellColor;
    if (!hasExpense) {
      cellColor = Colors.grey.shade100;
    } else if (intensity < 0.25) {
      cellColor = Colors.green.shade100;
    } else if (intensity < 0.5) {
      cellColor = Colors.orange.shade200;
    } else if (intensity < 0.75) {
      cellColor = Colors.red.shade300;
    } else {
      cellColor = Colors.red.shade600;
    }

    final expenseAmount = hasExpense ? (intensity * 1000).toInt() : 0;

    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: Tooltip(
          message: hasExpense 
              ? 'Gün ${weekIndex * 7 + dayIndex + 1}\n₺$expenseAmount'
              : 'Gün ${weekIndex * 7 + dayIndex + 1}\nHarcama yok',
          child: Container(
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: cellColor,
              borderRadius: BorderRadius.circular(2),
            ),
            child: hasExpense && intensity > 0.7
                ? Center(
                    child: Text(
                      '${(intensity * 10).toInt()}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 8,
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}