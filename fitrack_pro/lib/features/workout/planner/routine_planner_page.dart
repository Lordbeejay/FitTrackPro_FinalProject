import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitrack_pro/core/models/goal.dart';
import 'package:fitrack_pro/core/services/goal_service.dart';
import 'package:fitrack_pro/features/workout/goals/goal_card.dart';
import 'package:fitrack_pro/features/workout/goals/goals_page.dart';
import 'package:fitrack_pro/features/workout/planner/routine_model.dart';
import 'package:fitrack_pro/features/workout/planner/routine_service.dart';
import 'package:table_calendar/table_calendar.dart';

const TextStyle kHeaderStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 24,
  letterSpacing: 0.5,
  color: Colors.black,
);

class RoutinePlannerPage extends StatefulWidget {
  const RoutinePlannerPage({super.key});

  @override
  State<RoutinePlannerPage> createState() => _RoutinePlannerPageState();
}

class _RoutinePlannerPageState extends State<RoutinePlannerPage>
    with TickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  bool _showWeekView = false;
  double _scrollOffset = 0.0;
  static const double _transitionThreshold = 50.0;
  bool _isDraggingWeekView = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!mounted || _isDraggingWeekView) return;
    
    final offset = _scrollController.offset;
    final previousOffset = _scrollOffset;
    final scrollDelta = offset - previousOffset;
    
    setState(() {
      _scrollOffset = offset;
      
      // Show week view when scrolling up beyond threshold
      if (scrollDelta > 0 && offset > _transitionThreshold && !_showWeekView) {
        _showWeekView = true;
        _animationController.forward();
      }
      // Hide week view when scrolling down near top
      else if (scrollDelta < 0 && offset < _transitionThreshold && _showWeekView) {
        _showWeekView = false;
        _animationController.reverse();
      }
    });
  }

  void _handleWeekViewDragStart(DragStartDetails details) {
    _isDraggingWeekView = true;
  }

  void _handleWeekViewDragUpdate(DragUpdateDetails details) {
    // Calculate how much we've dragged down (negative delta)
    final dragDelta = details.primaryDelta ?? 0;
    
    if (dragDelta > 0) { // Only respond to downward drags
      // Calculate opacity based on drag distance
      final newOpacity = 1.0 - (dragDelta / 200).clamp(0.0, 1.0);
      _animationController.value = newOpacity;
    }
  }

  void _handleWeekViewDragEnd(DragEndDetails details) {
    _isDraggingWeekView = false;
    
    // If the view was dragged down enough, close it
    if (_animationController.value < 0.5) {
      _showWeekView = false;
      _animationController.reverse();
      // Scroll back to top
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    } else {
      // Otherwise, snap back to full view
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'advanced':
        return Colors.red;
      case 'intermediate':
        return Colors.orange;
      case 'beginner':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildMarker(DateTime day, List<Routine> routines) {
    final dayRoutines = routines.where((routine) => isSameDay(routine.scheduledDate, day)).toList();
    if (dayRoutines.isEmpty) {
      return Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: Color(0xFFB86AD9),
          shape: BoxShape.circle,
        ),
      );
    }
    
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: _getDifficultyColor(dayRoutines.first.difficulty),
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routineService = Provider.of<RoutineService>(context);
    final goalService = Provider.of<GoalService>(context);

    final routines = routineService.getRoutines();
    final goals = goalService.getGoals();

    // Filter routines for the selected day
    final selectedRoutines = routines.where((routine) =>
      isSameDay(routine.scheduledDate, _selectedDay ?? _focusedDay)
    ).toList();

    // Generate time slots (6AM to 8PM)
    final timeSlots = List.generate(15, (i) => TimeOfDay(hour: 6 + i, minute: 0));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App Bar
              SliverAppBar(
                backgroundColor: const Color(0xFFF8F8F8),
                elevation: 0,
                pinned: true,
                expandedHeight: 0,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                title: const Text(
                  'Workout Schedule',
                  style: kHeaderStyle,
                ),
                centerTitle: true,
              ),
              
              // Month Calendar Section
              SliverToBoxAdapter(
                child: AnimatedOpacity(
                  opacity: _showWeekView ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _showWeekView ? 0 : 400,
                    child: _showWeekView
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TableCalendar(
                              firstDay: DateTime.utc(2020, 1, 1),
                              lastDay: DateTime.utc(2030, 12, 31),
                              focusedDay: _focusedDay,
                              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                              onDaySelected: (selectedDay, focusedDay) {
                                setState(() {
                                  _selectedDay = selectedDay;
                                  _focusedDay = focusedDay;
                                });
                              },
                              eventLoader: (day) {
                                return routines.where((routine) => isSameDay(routine.scheduledDate, day)).toList();
                              },
                              calendarFormat: CalendarFormat.month,
                              availableCalendarFormats: const {
                                CalendarFormat.month: 'Month',
                              },
                              daysOfWeekStyle: const DaysOfWeekStyle(
                                weekendStyle: TextStyle(color: Colors.grey),
                                weekdayStyle: TextStyle(color: Colors.grey),
                              ),
                              calendarStyle: CalendarStyle(
                                todayDecoration: BoxDecoration(
                                  color: const Color(0xFFB2B6FF).withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                selectedDecoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF7F7CFF), Color(0xFFB86AD9)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                selectedTextStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                defaultTextStyle: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                                weekendTextStyle: const TextStyle(
                                  color: Colors.grey,
                                ),
                                outsideTextStyle: const TextStyle(color: Colors.grey),
                                cellMargin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                                markersMaxCount: 3,
                                markersAlignment: Alignment.bottomCenter,
                                markerDecoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                              ),
                              calendarBuilders: CalendarBuilders(
                                markerBuilder: (context, date, events) {
                                  if (events.isEmpty) return null;
                                  return _buildMarker(date, routines);
                                },
                              ),
                              headerStyle: const HeaderStyle(
                                formatButtonVisible: false,
                                titleCentered: true,
                                titleTextStyle: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
                                rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
                              ),
                            ),
                          ),
                  ),
                ),
              ),

              // Transition indicator
              SliverToBoxAdapter(
                child: AnimatedOpacity(
                  opacity: !_showWeekView ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Icon(
                          _showWeekView ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                          color: Colors.grey[400],
                          size: 24,
                        ),
                        Text(
                          _showWeekView ? 'Scroll down to return to calendar' : 'Scroll up for detailed schedule',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Spacer to allow scrolling
              SliverToBoxAdapter(
                child: SizedBox(height: 800), // This creates space to scroll into
              ),
            ],
          ),

          // Week View Overlay
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onVerticalDragStart: _handleWeekViewDragStart,
                  onVerticalDragUpdate: _handleWeekViewDragUpdate,
                  onVerticalDragEnd: _handleWeekViewDragEnd,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: _showWeekView
                          ? Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: Offset(0, -2),
                                  ),
                                ],
                              ),
                              margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 80),
                              child: Column(
                                children: [
                                  // Drag indicator - now more prominent
                                  GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      setState(() {
                                        _showWeekView = false;
                                        _animationController.reverse();
                                        _scrollController.animateTo(
                                          0,
                                          duration: const Duration(milliseconds: 200),
                                          curve: Curves.easeOut,
                                        );
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      child: Center(
                                        child: Container(
                                          width: 60,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[400],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Week Calendar
                                  TableCalendar(
                                    firstDay: DateTime.utc(2020, 1, 1),
                                    lastDay: DateTime.utc(2030, 12, 31),
                                    focusedDay: _focusedDay,
                                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                                    onDaySelected: (selectedDay, focusedDay) {
                                      setState(() {
                                        _selectedDay = selectedDay;
                                        _focusedDay = focusedDay;
                                      });
                                    },
                                    eventLoader: (day) {
                                      return routines.where((routine) => isSameDay(routine.scheduledDate, day)).toList();
                                    },
                                    calendarFormat: CalendarFormat.week,
                                    availableCalendarFormats: const {
                                      CalendarFormat.week: 'Week',
                                    },
                                    daysOfWeekStyle: const DaysOfWeekStyle(
                                      weekendStyle: TextStyle(color: Colors.grey),
                                      weekdayStyle: TextStyle(color: Colors.grey),
                                    ),
                                    calendarStyle: CalendarStyle(
                                      todayDecoration: BoxDecoration(
                                        color: const Color(0xFFB2B6FF).withOpacity(0.3),
                                        shape: BoxShape.circle,
                                      ),
                                      selectedDecoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Color(0xFF7F7CFF), Color(0xFFB86AD9)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      selectedTextStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      defaultTextStyle: const TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      weekendTextStyle: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                      outsideTextStyle: const TextStyle(color: Colors.grey),
                                      cellMargin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                                      markersMaxCount: 3,
                                      markersAlignment: Alignment.bottomCenter,
                                      markerDecoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    calendarBuilders: CalendarBuilders(
                                      markerBuilder: (context, date, events) {
                                        if (events.isEmpty) return null;
                                        return _buildMarker(date, routines);
                                      },
                                    ),
                                    headerStyle: const HeaderStyle(
                                      formatButtonVisible: false,
                                      titleCentered: true,
                                      titleTextStyle: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
                                      rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
                                    ),
                                  ),
                                  // Time-based Schedule
                                  Expanded(
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        // Timeline settings
                                        final double halfHourHeight = 32.0; // Height for 30 minutes
                                        final int startHour = 0;
                                        final int endHour = 23;
                                        final int totalHalfHours = (endHour - startHour + 1) * 2; // 48 half-hours
                                        final double timelineHeight = halfHourHeight * totalHalfHours;
                                        final now = DateTime.now();
                                        final isToday = isSameDay(_selectedDay ?? _focusedDay, now);

                                        // Helper to get vertical offset for a DateTime
                                        double getOffset(DateTime dt) {
                                          return ((dt.hour * 2 + (dt.minute / 30.0)) * halfHourHeight);
                                        }

                                        return SingleChildScrollView(
                                          child: SizedBox(
                                            height: timelineHeight,
                                            child: Stack(
                                              children: [
                                                // Time labels and lines (every 30 minutes)
                                                for (int i = 0; i < totalHalfHours; i++)
                                                  Positioned(
                                                    top: i * halfHourHeight,
                                                    left: 0,
                                                    right: 0,
                                                    child: Row(
                                                      children: [
                                                        SizedBox(
                                                          width: 60,
                                                          child: Text(
                                                            () {
                                                              final hour = startHour + (i ~/ 2);
                                                              final minute = (i % 2) * 30;
                                                              return TimeOfDay(hour: hour, minute: minute).format(context);
                                                            }(),
                                                            style: const TextStyle(
                                                              color: Colors.grey,
                                                              fontWeight: FontWeight.w500,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Expanded(
                                                          child: Divider(
                                                            height: 1,
                                                            color: Color(0xFFEAEAEA),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                // Current time indicator (always visible if today)
                                                if (isToday)
                                                  Positioned(
                                                    top: getOffset(now),
                                                    left: 0,
                                                    right: 0,
                                                    child: Row(
                                                      children: [
                                                        const SizedBox(width: 60 + 8),
                                                        Expanded(
                                                          child: Container(
                                                            height: 2,
                                                            color: const Color(0xFF7F7CFF),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Container(
                                                          width: 10,
                                                          height: 10,
                                                          decoration: BoxDecoration(
                                                            color: const Color(0xFF7F7CFF),
                                                            shape: BoxShape.circle,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                // Routine blocks
                                                for (final routine in selectedRoutines)
                                                  if (routine.scheduledDate.hour >= startHour && routine.scheduledDate.hour <= endHour)
                                                    Positioned(
                                                      top: getOffset(routine.scheduledDate),
                                                      left: 60 + 16.0, // time label + spacing
                                                      right: 16.0,
                                                      height: (routine.durationInMinutes / 60.0) * (halfHourHeight * 2),
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (context) => RoutineDetailsDialog(routine: routine),
                                                          );
                                                        },
                                                        child: Container(
                                                          alignment: Alignment.centerLeft,
                                                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                                                          decoration: BoxDecoration(
                                                            gradient: const LinearGradient(
                                                              colors: [Color(0xFF7F7CFF), Color(0xFFB86AD9)],
                                                              begin: Alignment.topLeft,
                                                              end: Alignment.bottomRight,
                                                            ),
                                                            borderRadius: BorderRadius.circular(24),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: const Color(0xFF7F7CFF).withOpacity(0.12),
                                                                blurRadius: 8,
                                                                offset: const Offset(0, 4),
                                                              ),
                                                            ],
                                                          ),
                                                          child: Text(
                                                            '${routine.name}, ${TimeOfDay.fromDateTime(routine.scheduledDate).format(context)}',
                                                            style: const TextStyle(
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF7F7CFF), Color(0xFF7F7CFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7F7CFF).withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          heroTag: 'addRoutine',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RoutineFormPage(
                  goals: goals,
                  scheduledDate: _selectedDay ?? _focusedDay,
                ),
              ),
            );
          },
          tooltip: 'Schedule Workout',
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, size: 32, color: Colors.white),
        ),
      ),
    );
  }
}

class RoutineCard extends StatelessWidget {
  final Routine routine;

  const RoutineCard({super.key, required this.routine});

  @override
  Widget build(BuildContext context) {
    final goal = routine.associatedGoal;

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(routine.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Days: ${routine.daysOfWeek.join(", ")}'),
            Text('Exercises: ${routine.exercises.join(", ")}'),
            const SizedBox(height: 12),
            GoalCard(goal: goal),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GoalsPage(),
                  ),
                );
              },
              child: const Text('Edit Goal'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                final routineService = Provider.of<RoutineService>(context, listen: false);
                routineService.deleteRoutine(routine.id);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Routine Deleted: ${routine.name}')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete Routine'),
            ),
          ],
        ),
      ),
    );
  }
}

class RoutineFormPage extends StatefulWidget {
  final List<Goal> goals;
  final DateTime scheduledDate;

  const RoutineFormPage({super.key, required this.goals, required this.scheduledDate});

  @override
  RoutineFormPageState createState() => RoutineFormPageState();
}

class RoutineFormPageState extends State<RoutineFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();
  Goal? _selectedGoal;
  String? _selectedDifficulty;
  int _repetitions = 10;
  final List<String> _selectedExercises = [];

  // Use the same exercise database as workout_create_sheet.dart
  final Map<String, List<String>> _exerciseDatabase = {
    'Back': ['Pull-ups', 'Lat Pulldown', 'Bent-over Rows'],
    'Chest': ['Bench Press', 'Push-ups', 'Incline Dumbbell Press'],
    'Legs': ['Squats', 'Lunges', 'Leg Press'],
    'Arms': ['Bicep Curls', 'Tricep Dips', 'Hammer Curls'],
    'Abs': ['Crunches', 'Plank', 'Leg Raises'],
  };

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );
      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year, date.month, date.day, time.hour, time.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Schedule', style: kHeaderStyle),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date and Time Picker
              Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '${_selectedDateTime.toLocal().toString().split(' ')[0]}  '
                    '${TimeOfDay.fromDateTime(_selectedDateTime).format(context)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _pickDateTime,
                    child: const Text('Change'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Routine Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Routine Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Enter a name' : null,
              ),
              const SizedBox(height: 24),
              // Planned Exercises
              const Text('Planned Exercises', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._exerciseDatabase.entries.map((entry) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Wrap(
                    spacing: 8,
                    children: entry.value.map((exercise) => FilterChip(
                      label: Text(exercise),
                      selected: _selectedExercises.contains(exercise),
                      onSelected: (selected) {
                        setState(() {
                          selected ? _selectedExercises.add(exercise) : _selectedExercises.remove(exercise);
                        });
                      },
                    )).toList(),
                  ),
                  const SizedBox(height: 8),
                ],
              )),
              const SizedBox(height: 24),
              // Goal Dropdown
              DropdownButtonFormField<Goal>(
                value: _selectedGoal,
                hint: const Text('Select Goal'),
                items: widget.goals.map((goal) {
                  return DropdownMenuItem<Goal>(
                    value: goal,
                    child: Text(goal.title),
                  );
                }).toList(),
                onChanged: (goal) {
                  setState(() {
                    _selectedGoal = goal;
                  });
                },
                validator: (value) => value == null ? 'Select a goal' : null,
              ),
              const SizedBox(height: 24),
              // Difficulty Dropdown
              DropdownButtonFormField<String>(
                value: _selectedDifficulty,
                hint: const Text('Select Difficulty'),
                items: [
                  DropdownMenuItem<String>(
                    value: 'Beginner',
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Beginner'),
                      ],
                    ),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Intermediate',
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Intermediate'),
                      ],
                    ),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Advanced',
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Advanced'),
                      ],
                    ),
                  ),
                ],
                onChanged: (level) {
                  setState(() {
                    _selectedDifficulty = level;
                  });
                },
                validator: (value) => value == null ? 'Select difficulty' : null,
              ),
              const SizedBox(height: 24),
              // Repetitions
              Row(
                children: [
                  const Text('Repetitions:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: _repetitions.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (val) {
                        setState(() {
                          _repetitions = int.tryParse(val) ?? 10;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    backgroundColor: const Color(0xFF7F7CFF),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate() && _selectedExercises.isNotEmpty) {
                      final routineService = Provider.of<RoutineService>(context, listen: false);
                      final goalService = Provider.of<GoalService>(context, listen: false);
                      final routine = routineService.createRoutine(
                        _nameController.text,
                        [_selectedDateTime.weekday.toString()],
                        _selectedExercises,
                        60,
                        _selectedGoal ?? goalService.createGoal('Fitness Goal', 'A new fitness goal', 10.0),
                        _selectedDateTime,
                        _selectedDifficulty ?? 'Beginner',
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Routine Created: ${routine.name}')),
                      );
                      Navigator.pop(context);
                    } else if (_selectedExercises.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select at least one exercise.')),
                      );
                    }
                  },
                  child: const Text('Save', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF8F8F8),
    );
  }
}

class RoutineDetailsDialog extends StatelessWidget {
  final Routine routine;

  const RoutineDetailsDialog({super.key, required this.routine});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Close Button
              Row(
                children: [
                  Expanded(
                    child: Text(
                      routine.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7F7CFF),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Date & Time
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '${routine.scheduledDate.toLocal().toString().split(' ')[0]}  '
                    '${TimeOfDay.fromDateTime(routine.scheduledDate).format(context)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Days of Week
              Row(
                children: [
                  const Icon(Icons.repeat, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text('Days: ${routine.daysOfWeek.join(", ")}', style: const TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 8),
              // Exercises
              const Text('Exercises:', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: routine.exercises.map((e) => Chip(label: Text(e))).toList(),
              ),
              const SizedBox(height: 8),
              // Duration
              Text('Duration: ${routine.durationInMinutes} mins', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              // Goal
              if (routine.associatedGoal != null) ...[
                const Text('Goal:', style: TextStyle(fontWeight: FontWeight.bold)),
                GoalCard(goal: routine.associatedGoal),
              ],
              const SizedBox(height: 24),
              // Mark as Done Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    backgroundColor: const Color(0xFF7F7CFF),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Marked "${routine.name}" as done!')),
                    );
                  },
                  child: const Text('Mark as Done', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}