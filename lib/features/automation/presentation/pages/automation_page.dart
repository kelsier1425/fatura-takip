import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/automation_entity.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../widgets/automation_card.dart';
import '../widgets/upcoming_reminders_widget.dart';
import '../widgets/calendar_event_marker.dart';
import '../../../../core/constants/app_colors.dart';

class AutomationPage extends ConsumerStatefulWidget {
  const AutomationPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AutomationPage> createState() => _AutomationPageState();
}

class _AutomationPageState extends ConsumerState<AutomationPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  
  // Demo data - TODO: Replace with actual data
  final List<AutomationEntity> _automations = [];
  final Map<DateTime, List<ExpenseEntity>> _upcomingExpenses = {};
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _generateDemoData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  void _generateDemoData() {
    // Generate some demo upcoming expenses for the calendar
    final now = DateTime.now();
    for (int i = 1; i <= 30; i++) {
      final date = now.add(Duration(days: i));
      if (i % 7 == 0 || i % 15 == 0) {
        _upcomingExpenses[DateTime(date.year, date.month, date.day)] = [
          ExpenseEntity(
            id: 'demo_$i',
            userId: 'guest',
            categoryId: 'home',
            title: i % 7 == 0 ? 'Elektrik Faturası' : 'Netflix Abonelik',
            amount: i % 7 == 0 ? 150.0 : 29.99,
            date: date,
            type: i % 7 == 0 ? ExpenseType.bill : ExpenseType.subscription,
            isRecurring: true,
            recurrenceType: RecurrenceType.monthly,
            createdAt: now,
          ),
        ];
      }
    }
  }
  
  List<ExpenseEntity> _getEventsForDay(DateTime day) {
    return _upcomingExpenses[DateTime(day.year, day.month, day.day)] ?? [];
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Otomasyon & Takvim'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Takvim', icon: Icon(Icons.calendar_month)),
            Tab(text: 'Otomatik', icon: Icon(Icons.autorenew)),
            Tab(text: 'Hatırlatıcılar', icon: Icon(Icons.notifications)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCalendarTab(),
          _buildAutomationTab(),
          _buildRemindersTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAutomationOptions(),
        icon: const Icon(Icons.add),
        label: const Text('Otomasyon Ekle'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
  
  Widget _buildCalendarTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Calendar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TableCalendar<ExpenseEntity>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat,
              eventLoader: _getEventsForDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                markerDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                weekendTextStyle: TextStyle(color: AppColors.error),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonDecoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                formatButtonTextStyle: TextStyle(color: Colors.white),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    return CalendarEventMarker(
                      events: events.cast<ExpenseEntity>(),
                    );
                  }
                  return null;
                },
              ),
            ),
          ),
          
          // Selected Day Events
          if (_getEventsForDay(_selectedDay).isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('dd MMMM yyyy', 'tr').format(_selectedDay),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._getEventsForDay(_selectedDay).map((expense) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Icon(
                            expense.type == ExpenseType.bill 
                                ? Icons.receipt_outlined 
                                : Icons.subscriptions_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        title: Text(expense.title),
                        subtitle: Text('₺${expense.amount.toStringAsFixed(2)}'),
                        trailing: expense.isRecurring
                            ? const Icon(Icons.repeat, color: AppColors.primary)
                            : null,
                        onTap: () {
                          // TODO: Navigate to expense detail
                        },
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 100), // Space for FAB
        ],
      ),
    );
  }
  
  Widget _buildAutomationTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Quick Stats
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Aktif Otomasyon',
                value: '${_automations.where((a) => a.isActive).length}',
                icon: Icons.autorenew,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Bu Ay Çalıştı',
                value: '12',
                icon: Icons.done_all,
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Automation List
        if (_automations.isEmpty)
          _buildEmptyAutomationState()
        else
          ..._automations.map((automation) {
            return AutomationCard(
              automation: automation,
              onToggle: (isActive) => _toggleAutomation(automation, isActive),
              onEdit: () => _editAutomation(automation),
              onDelete: () => _deleteAutomation(automation),
            );
          }).toList(),
      ],
    );
  }
  
  Widget _buildRemindersTab() {
    return const UpcomingRemindersWidget();
  }
  
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyAutomationState() {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.autorenew,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz otomasyon yok',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tekrarlayan harcamalarınız için otomasyon oluşturun',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAutomationOptions,
            icon: const Icon(Icons.add),
            label: const Text('İlk Otomasyonu Oluştur'),
          ),
        ],
      ),
    );
  }
  
  void _showAutomationOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Otomasyon Türü Seç',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.repeat, color: AppColors.primary),
              title: const Text('Tekrarlayan Harcama'),
              subtitle: const Text('Belirli aralıklarla otomatik harcama oluştur'),
              onTap: () {
                Navigator.pop(context);
                context.push('/automation/recurring');
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications, color: AppColors.warning),
              title: const Text('Hatırlatıcı'),
              subtitle: const Text('Ödeme tarihlerinde bildirim al'),
              onTap: () {
                Navigator.pop(context);
                context.push('/automation/reminder');
              },
            ),
            ListTile(
              leading: const Icon(Icons.lightbulb, color: AppColors.accent),
              title: const Text('Akıllı Öneri'),
              subtitle: const Text('Harcama desenlerine göre öneriler'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Akıllı öneriler yakında gelecek!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _toggleAutomation(AutomationEntity automation, bool isActive) {
    // TODO: Update automation status
    setState(() {
      // Update in local list for demo
    });
  }
  
  void _editAutomation(AutomationEntity automation) {
    // TODO: Navigate to edit automation
  }
  
  void _deleteAutomation(AutomationEntity automation) {
    // TODO: Delete automation
  }
}