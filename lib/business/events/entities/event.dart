import '../../user/entities/user.dart';

class Event {
  final String id;
  final String name;
  final String description;
  final DateTime dateTime;
  final String location;

  final String image;

  final List<User> attendees;

  const Event({
    required this.id,
    required this.name,
    required this.description,
    required this.dateTime,
    required this.location,
    required this.image,
    this.attendees = const [],
  });

  int get attendeeCount => attendees.length;
}
