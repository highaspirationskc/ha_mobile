import 'dart:math';
import '../../business/user/entities/user.dart';
import '../../business/events/entities/event.dart';

/// --- Mock User ---
const User mockUser = User(
  firstName: 'Avery',
  lastName: 'Taylor',
  email: 'avery.taylor@highaspirations.org',
  image:
      'https://images.unsplash.com/photo-1527980965255-d3b416303d12?q=80&w=512&auto=format&fit=crop',
);

/// --- Utilities for dates/images ---
final DateTime _now = DateTime.now();
DateTime _onDay(int daysFromNow, {int hour = 18, int minute = 0}) {
  final d = _now.add(Duration(days: daysFromNow));
  return DateTime(d.year, d.month, d.day, hour, minute);
}

// Some nice sample images (royalty-free). Replace any time.
final List<String> _eventImgs = [
  'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?q=80&w=1200&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1515165562835-c3b8c2e3f3b9?q=80&w=1200&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1431540015161-0bf868a2d407?q=80&w=1200&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?q=80&w=1200&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?q=80&w=1200&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1485217988980-11786ced9454?q=80&w=1200&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1515168833906-d2a3b82b3029?q=80&w=1200&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?q=80&w=1200&auto=format&fit=crop',
];

String _pickImg(int i) => _eventImgs[i % _eventImgs.length];

/// --- 8 Mock Events ---
final List<Event> mockEvents = List<Event>.generate(8, (i) {
  final day = (i + 1) * 2; // every 2 days
  final titles = [
    'Mentor Meetup',
    'Career Workshop',
    'Community Service Day',
    'STEM Lab Tour',
    'College Q&A',
    'Leadership Panel',
    'Hack Night',
    'Alumni Mixer',
  ];
  final locations = [
    'Downtown Center',
    'HA Campus – Room 204',
    'Riverside Park',
    'Innovation Hub',
    'Virtual (Zoom)',
    'Auditorium A',
    'Makerspace',
    'Cafe Aurora',
  ];

  return Event(
    id: 'evt_${i + 1}',
    name: titles[i],
    description:
        'Join us for ${titles[i].toLowerCase()} focused on growth, networking, and hands-on learning.',
    dateTime: _onDay(day, hour: 17 + (i % 3) * 1), // 5–7pm-ish
    location: locations[i],
    image: _pickImg(i),
  );
});
