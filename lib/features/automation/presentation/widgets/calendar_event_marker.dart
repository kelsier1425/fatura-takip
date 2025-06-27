import 'package:flutter/material.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../../core/constants/app_colors.dart';

class CalendarEventMarker extends StatelessWidget {
  final List<ExpenseEntity> events;
  
  const CalendarEventMarker({
    Key? key,
    required this.events,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();
    
    final eventCount = events.length;
    final hasUrgentEvents = events.any((e) => 
        e.date.difference(DateTime.now()).inDays <= 3 && !e.isPaid);
    
    return Positioned(
      bottom: 2,
      right: 2,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: hasUrgentEvents ? AppColors.error : AppColors.primary,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            eventCount > 9 ? '9+' : eventCount.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}