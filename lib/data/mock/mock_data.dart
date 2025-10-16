// lib/data/mock/mock_data.dart
import 'dart:math';
import '../../business/events/entities/event.dart';
import '../../business/user/entities/user.dart';

/// -------- Mock Users (50) --------
final _rng = Random(42);

const _firstNames = [
  'Avery',
  'Jordan',
  'Taylor',
  'Morgan',
  'Riley',
  'Cameron',
  'Casey',
  'Drew',
  'Harper',
  'Quinn',
  'Parker',
  'Reese',
  'Rowan',
  'Skyler',
  'Sage',
  'Emerson',
  'Finley',
  'Hayden',
  'Jules',
  'Kai',
  'Logan',
  'Micah',
  'Noel',
  'Peyton',
  'River',
  'Sidney',
  'Tatum',
  'Alex',
  'Bailey',
  'Charlie',
  'Dakota',
  'Elliot',
  'Frankie',
  'Gray',
  'Indy',
  'Jamie',
  'Kendall',
  'London',
  'Milan',
  'Nico',
  'Oakley',
  'Phoenix',
  'Reagan',
  'Sasha',
  'Teagan',
  'Val',
  'Winter',
  'Zion',
  'Remy',
  'Blair',
];
const _lastNames = [
  'Taylor',
  'Nguyen',
  'Patel',
  'Garcia',
  'Brown',
  'Johnson',
  'Williams',
  'Jones',
  'Davis',
  'Miller',
  'Wilson',
  'Moore',
  'Anderson',
  'Thomas',
  'Jackson',
  'White',
  'Harris',
  'Martin',
  'Thompson',
  'Martinez',
  'Robinson',
  'Clark',
  'Rodriguez',
  'Lewis',
  'Lee',
  'Walker',
  'Hall',
  'Allen',
  'Young',
  'Hernandez',
  'King',
  'Wright',
  'Lopez',
  'Hill',
  'Scott',
  'Green',
  'Adams',
  'Baker',
  'Gonzalez',
  'Nelson',
  'Carter',
  'Mitchell',
  'Perez',
  'Roberts',
  'Turner',
  'Phillips',
  'Campbell',
  'Parker',
  'Evans',
  'Edwards',
];

// A few Unsplash headshots to sample from
const _headshots = [
  'https://images.unsplash.com/photo-1527980965255-d3b416303d12?q=80&w=512&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=512&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=512&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1520813792240-56fc4a3765a7?q=80&w=512&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1547425260-76bcadfb4f2c?q=80&w=512&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1544005314-04d1a1f5f1a0?q=80&w=512&auto=format&fit=crop',
];

List<User> _buildUsers(int count) {
  return List.generate(count, (i) {
    final f = _firstNames[i % _firstNames.length];
    final l = _lastNames[i % _lastNames.length];
    // ~60% with images, 40% without
    final hasImg = _rng.nextDouble() < 0.6;
    final img = hasImg ? _headshots[_rng.nextInt(_headshots.length)] : '';
    return User(
      firstName: f,
      lastName: l,
      email: '${f.toLowerCase()}.${l.toLowerCase()}@example.com',
      image: img,
    );
  });
}

final List<User> mockUsers = _buildUsers(50);

/// A single featured mock user you’ve been using
const User mockUser = User(
  firstName: 'Avery',
  lastName: 'Taylor',
  email: 'avery.taylor@highaspirations.org',
  image:
      'https://images.unsplash.com/photo-1527980965255-d3b416303d12?q=80&w=512&auto=format&fit=crop',
);

/// -------- Mock Events (8) --------
final DateTime _now = DateTime.now();

DateTime _onDay(int daysFromNow, {int hour = 18, int minute = 0}) {
  final d = _now.add(Duration(days: daysFromNow));
  return DateTime(d.year, d.month, d.day, hour, minute);
}

final List<String> _eventImgs = [
  'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?q=80&w=1200&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1515165562835-c3b8c2e3f3b9?q=80&w=1200&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1431540015161-0bf868a2d407?q=80&w=1200&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?q=80&w=1200&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1485217988980-11786ced9454?q=80&w=1200&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1515168833906-d2a3b82b3029?q=80&w=1200&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1519681393784-d120267933ba?q=80&w=1200&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1461749280684-dccba630e2f6?q=80&w=1200&auto=format&fit=crop',
];

String _img(int i) => _eventImgs[i % _eventImgs.length];

List<User> _pickAttendees() {
  final count = _rng.nextInt(51); // 0..50
  if (count == 0) return const [];
  // shuffle copy
  final pool = List<User>.from(mockUsers)..shuffle(_rng);
  return pool.take(count).toList();
}

final List<Event> mockEvents = List<Event>.generate(8, (i) {
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
    dateTime: _onDay((i + 1) * 2, hour: 17 + (i % 3)), // 5–7 PM ranges
    location: locations[i],
    image: _img(i),
    attendees: _pickAttendees(),
  );
});
