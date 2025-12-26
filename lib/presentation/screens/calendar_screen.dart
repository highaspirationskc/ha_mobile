import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../business/events/entities/event.dart';
import '../widgets/list_tile_calendar.dart';
import '../widgets/tabs.dart';
import '../../core/routes.dart';
import '../../core/theme/brand_colors.dart';
import '../../data/services/olympic_season_service.dart';
import '../../core/utils/date_formatters.dart'; // <- shared utils

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Map<DateTime, List<Event>> _eventsByDay;
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _focusedDay = truncateToDay(DateTime.now());
    _selectedDay = truncateToDay(DateTime.now());
    _eventsByDay = _groupByDay(OlympicSeasonService.instance.events);

    // Listen to changes in Olympic Season data
    OlympicSeasonService.instance.addListener(_onSeasonDataChanged);
  }

  void _onSeasonDataChanged() {
    setState(() {
      _eventsByDay = _groupByDay(OlympicSeasonService.instance.events);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    OlympicSeasonService.instance.removeListener(_onSeasonDataChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.surface,
      child: Column(
        children: [
          const SizedBox(height: 16),
          HATabs(
            controller: _tabController,
            tabNames: const ['List', 'Calendar'],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildListView(context), _buildMonthView(context, cs)],
            ),
          ),
        ],
      ),
    );
  }

  // ----- LIST VIEW -----
  Widget _buildListView(BuildContext context) {
    final items = List<Event>.from(OlympicSeasonService.instance.events)
      ..sort((a, b) => a.eventDate.compareTo(b.eventDate));
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final e = items[i];
        return ListTileCalendar(
          event: e,
          onTap: () {
            Navigator.of(
              context,
            ).pushNamed(AppRoutes.eventDetail, arguments: e);
          },
          compact: false,
        );
      },
    );
  }

  // ----- MONTH VIEW -----
  Widget _buildMonthView(BuildContext context, ColorScheme cs) {
    final dayEvents = _eventsByDay[_selectedDay] ?? const [];
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TableCalendar<Event>(
            firstDay: truncateToDay(
              DateTime.now().subtract(const Duration(days: 365)),
            ),
            lastDay: truncateToDay(
              DateTime.now().add(const Duration(days: 365)),
            ),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.sunday,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            eventLoader: (day) => _eventsByDay[truncateToDay(day)] ?? const [],
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = truncateToDay(selected);
                _focusedDay = truncateToDay(focused);
              });
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarStyle: CalendarStyle(
              markerDecoration: const BoxDecoration(
                color: kTeamGreen,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: kHAPrimary.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: kHAPrimary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (dayEvents.isEmpty)
            Text(
              'No events on ${formatShortDate(_selectedDay)}',
              style: TextStyle(color: cs.onSurfaceVariant),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dayEvents.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final e = dayEvents[i];
                return ListTileCalendar(
                  event: e,
                  compact: true,
                  showChevron: false,
                  onTap: () {
                    Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.eventDetail, arguments: e);
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  // ----- Helpers -----
  Map<DateTime, List<Event>> _groupByDay(List<Event> list) {
    final map = <DateTime, List<Event>>{};
    for (final e in list) {
      final d = truncateToDay(e.eventDate);
      map.putIfAbsent(d, () => []).add(e);
    }
    return map;
  }
}
