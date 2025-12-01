import '../../events/entities/event.dart';

class OlympicSeason {
  final String id;
  final String name;
  final int startMonth;
  final int startDay;
  final int endMonth;
  final int endDay;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Event> events;

  const OlympicSeason({
    required this.id,
    required this.name,
    required this.startMonth,
    required this.startDay,
    required this.endMonth,
    required this.endDay,
    required this.createdAt,
    required this.updatedAt,
    this.events = const [],
  });

  factory OlympicSeason.fromJson(Map<String, dynamic> json) {
    return OlympicSeason(
      id: json['id'] as String,
      name: json['name'] as String,
      startMonth: json['startMonth'] as int,
      startDay: json['startDay'] as int,
      endMonth: json['endMonth'] as int,
      endDay: json['endDay'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      events:
          (json['events'] as List<dynamic>?)
              ?.map((e) => Event.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startMonth': startMonth,
      'startDay': startDay,
      'endMonth': endMonth,
      'endDay': endDay,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'events': events.map((e) => e.toJson()).toList(),
    };
  }

  /// Get the start date for a given year
  DateTime getStartDate(int year) {
    return DateTime(year, startMonth, startDay);
  }

  /// Get the end date for a given year
  DateTime getEndDate(int year) {
    return DateTime(year, endMonth, endDay);
  }

  /// Check if a date falls within this season for a given year
  bool isDateInSeason(DateTime date, int year) {
    final start = getStartDate(year);
    final end = getEndDate(year);
    return date.isAfter(start.subtract(const Duration(days: 1))) &&
        date.isBefore(end.add(const Duration(days: 1)));
  }

  /// Get the season name with year (e.g., "Fall 2024")
  String getSeasonName(int year) {
    return '$name $year';
  }

  int get eventCount => events.length;
}
