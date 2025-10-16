import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../business/events/entities/event.dart';
import '../widgets/list_tile_calendar.dart';
import '../../core/routes.dart';
import '../../business/events/entities/event.dart'; // you already have this
import '../../data/mock/mock_data.dart';

enum CalendarView { list, month }

/// Top-level helper so it can be used in initializers / anywhere.
DateTime _truncate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarView _view = CalendarView.list;

  late Map<DateTime, List<Event>> _eventsByDay;
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = _truncate(DateTime.now());
    _selectedDay = _truncate(DateTime.now());
    _eventsByDay = _groupByDay(mockEvents);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SegmentedButton<CalendarView>(
          segments: const [
            ButtonSegment(
              value: CalendarView.list,
              label: Text('List'),
              icon: Icon(Icons.view_list),
            ),
            ButtonSegment(
              value: CalendarView.month,
              label: Text('Calendar'),
              icon: Icon(Icons.calendar_month),
            ),
          ],
          selected: {_view},
          onSelectionChanged: (s) => setState(() => _view = s.first),
        ),
        const SizedBox(height: 12),
        if (_view == CalendarView.list)
          _buildListView(context)
        else
          _buildMonthView(context, cs),
      ],
    );
  }

  // ----- LIST VIEW -----
  Widget _buildListView(BuildContext context) {
    final items = List<Event>.from(mockEvents)
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final e = items[i];
        return ListTileCalendar(
          event: e,
          onTap: () {
            Navigator.of(context).pushNamed(
              AppRoutes.eventDetail,
              arguments: e, // pass the whole Event
            );
          },

          compact: false,
        );
      },
    );
  }

  // ----- MONTH VIEW -----
  Widget _buildMonthView(BuildContext context, ColorScheme cs) {
    final dayEvents = _eventsByDay[_selectedDay] ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TableCalendar<Event>(
          firstDay: _truncate(
            DateTime.now().subtract(const Duration(days: 365)),
          ),
          lastDay: _truncate(DateTime.now().add(const Duration(days: 365))),
          focusedDay: _focusedDay,
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.sunday,
          selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
          eventLoader: (day) => _eventsByDay[_truncate(day)] ?? const [],
          onDaySelected: (selected, focused) {
            setState(() {
              _selectedDay = _truncate(selected);
              _focusedDay = _truncate(focused);
            });
          },
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          calendarStyle: CalendarStyle(
            markerDecoration: BoxDecoration(
              color: cs.primary,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: cs.primaryContainer,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: cs.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (dayEvents.isEmpty)
          Text(
            'No events on ${_fmtDate(_selectedDay)}',
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
                compact: true, // smaller variant under the calendar grid
                showChevron: false, // optional
                onTap: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.eventDetail,
                    arguments: e, // pass the whole Event
                  );
                },
              );
            },
          ),
      ],
    );
  }

  // ----- Helpers -----
  Map<DateTime, List<Event>> _groupByDay(List<Event> list) {
    final map = <DateTime, List<Event>>{};
    for (final e in list) {
      final d = _truncate(e.dateTime);
      map.putIfAbsent(d, () => []).add(e);
    }
    return map;
  }

  String _fmtDate(DateTime dt) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${m[dt.month - 1]} ${dt.day}';
    // For full i18n later, use package:intl
  }

  String _fmtTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final min = dt.minute.toString().padLeft(2, '0');
    final ap = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$min $ap';
  }
}
