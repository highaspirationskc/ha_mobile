// lib/data/mock/mock_data.dart
import 'dart:math';

import 'package:ha_mobile/data/mock/mock_users.dart';

import '../../business/events/entities/event.dart';
import '../../business/scoops/entities/scoop.dart';

// NEW role-based user models
import '../../business/user/entities/user_base.dart';
import '../../business/user/entities/user_role.dart';
import '../../business/user/entities/user_refs.dart';
import '../../business/user/entities/role_mentee.dart';
import '../../business/user/entities/role_mentor.dart';

/// =================================================================================
/// USERS
/// =================================================================================

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

User _genUser(int idx) {
  final f = _firstNames[idx % _firstNames.length];
  final l = _lastNames[idx % _lastNames.length];
  final hasImg = _rng.nextDouble() < 0.6; // ~60% with images
  final img = hasImg ? _headshots[_rng.nextInt(_headshots.length)] : null;
  return User(
    id: 'u_${idx + 1}',
    email: '${f.toLowerCase()}.${l.toLowerCase()}@example.com',
    firstName: f,
    lastName: l,
    image: img,
    // random profile color index 0..11
    colorIndex: _rng.nextInt(12),
    roles: const {}, // generic users have no role by default
  );
}

/// Build 48 generic users, then add our 2 special users => ~50 total
final List<User> mockUsers = [
  for (int i = 0; i < 48; i++) _genUser(i),
  mockMentee,
  mockMentor,
];

/// Quick lookups
final Map<String, User> mockUsersById = {for (final u in mockUsers) u.id: u};

/// Role data
final MenteeData mockMenteeData = MenteeData(
  userId: mockMentee.id,
  mentor: UserRef(
    id: mockMentor.id,
    firstName: mockMentor.firstName,
    lastName: mockMentor.lastName,
    image: mockMentor.image,
    colorIndex: mockMentor.colorIndex,
  ),
  totalAttendance: 7,
  currentStreak: 2,
);

final MentorData mockMentorData = MentorData(
  userId: mockMentor.id,
  mentees: [
    UserRef(
      id: mockMentee.id,
      firstName: mockMentee.firstName,
      lastName: mockMentee.lastName,
      image: mockMentee.image,
      colorIndex: mockMentee.colorIndex,
    ),
  ],
);

final Map<String, MenteeData> mockMenteesByUserId = {
  mockMenteeData.userId: mockMenteeData,
};

final Map<String, MentorData> mockMentorsByUserId = {
  mockMentorData.userId: mockMentorData,
};

/// (Optional) A single featured mock user you’d been using previously
final User mockUser = User(
  id: 'u_featured',
  email: 'avery.taylor@highaspirations.org',
  firstName: 'Avery',
  lastName: 'Taylor',
  image:
      'https://images.unsplash.com/photo-1527980965255-d3b416303d12?q=80&w=512&auto=format&fit=crop',
  colorIndex: 3,
  roles: const {},
);

/// =================================================================================
/// EVENTS
/// =================================================================================

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

/// =================================================================================
/// SCOOPS
/// =================================================================================

final List<Scoop> mockScoops = <Scoop>[
  Scoop(
    id: 's1',
    title: 'How to Set Big Goals (and actually hit them)',
    author: 'A. Rivera',
    videoUrl: 'https://www.youtube.com/watch?v=aad35J4De2c',
    description:
        'A practical framework for setting high-leverage goals and tracking progress.',
    runtime: const Duration(minutes: 8, seconds: 12),
    datePosted: DateTime.now().subtract(const Duration(days: 3)),
  ),
  Scoop(
    id: 's2',
    title: 'Morning Routines of Top Performers',
    author: 'K. Lee',
    videoUrl: 'https://www.youtube.com/watch?v=aad35J4De2c',
    description:
        'What elite performers do before 9am — and how to make it stick.',
    runtime: const Duration(minutes: 6, seconds: 47),
    datePosted: DateTime.now().subtract(const Duration(days: 7)),
  ),
  Scoop(
    id: 's3',
    title: 'The 3-Hour Deep Work Sprint',
    author: 'M. Chen',
    videoUrl: 'https://www.youtube.com/watch?v=aad35J4De2c',
    description: 'Block, protect, and execute a weekly deep work session.',
    runtime: const Duration(minutes: 9, seconds: 5),
    datePosted: DateTime.now().subtract(const Duration(days: 14)),
  ),
  Scoop(
    id: 's4',
    title: 'Beat Procrastination with 10-Minute Starts',
    author: 'S. Patel',
    videoUrl: 'https://www.youtube.com/watch?v=aad35J4De2c',
    description: 'Micro-commitments that break the activation barrier.',
    runtime: const Duration(minutes: 5, seconds: 58),
    datePosted: DateTime.now().subtract(const Duration(days: 21)),
  ),
  Scoop(
    id: 's5',
    title: 'Design Your Week: Calendar as a Strategy',
    author: 'N. Gomez',
    videoUrl: 'https://www.youtube.com/watch?v=aad35J4De2c',
    description: 'Turn your week into a playbook for momentum.',
    runtime: const Duration(minutes: 7, seconds: 21),
    datePosted: DateTime.now().subtract(const Duration(days: 28)),
  ),
  Scoop(
    id: 's6',
    title: 'Sleep as a Performance Advantage',
    author: 'R. Brown',
    videoUrl: 'https://www.youtube.com/watch?v=aad35J4De2c',
    description: 'Quick wins to improve sleep quality this week.',
    runtime: const Duration(minutes: 6, seconds: 2),
    datePosted: DateTime.now().subtract(const Duration(days: 35)),
  ),
  Scoop(
    id: 's7',
    title: 'The One-Page Personal Strategy',
    author: 'T. Nakamura',
    videoUrl: 'https://www.youtube.com/watch?v=aad35J4De2c',
    description: 'Tie goals to habits with a single, visible sheet.',
    runtime: const Duration(minutes: 8, seconds: 44),
    datePosted: DateTime.now().subtract(const Duration(days: 42)),
  ),
  Scoop(
    id: 's8',
    title: 'Practice: The 1% Daily Upgrade',
    author: 'L. Santos',
    videoUrl: 'https://www.youtube.com/watch?v=aad35J4De2c',
    description: 'Compound skills with tiny, consistent reps.',
    runtime: const Duration(minutes: 4, seconds: 56),
    datePosted: DateTime.now().subtract(const Duration(days: 49)),
  ),
  Scoop(
    id: 's9',
    title: 'Simple Nutrition for Busy Weeks',
    author: 'C. Morgan',
    videoUrl: 'https://www.youtube.com/watch?v=aad35J4De2c',
    description: 'Meal patterns that reduce decision fatigue.',
    runtime: const Duration(minutes: 5, seconds: 34),
    datePosted: DateTime.now().subtract(const Duration(days: 56)),
  ),
  Scoop(
    id: 's10',
    title: 'Mindset Reset: Reframing Setbacks',
    author: 'D. Ibrahim',
    videoUrl: 'https://www.youtube.com/watch?v=aad35J4De2c',
    description: 'Turn stumbles into data, not drama.',
    runtime: const Duration(minutes: 7, seconds: 8),
    datePosted: DateTime.now().subtract(const Duration(days: 63)),
  ),
  Scoop(
    id: 's11',
    title: 'Focus without Notifications',
    author: 'E. Park',
    videoUrl: 'https://www.youtube.com/watch?v=aad35J4De2c',
    description: 'Silent modes and batching that actually stick.',
    runtime: const Duration(minutes: 6, seconds: 19),
    datePosted: DateTime.now().subtract(const Duration(days: 70)),
  ),
  Scoop(
    id: 's12',
    title: 'Confidence via Reps, Not Results',
    author: 'J. Carter',
    videoUrl: 'https://www.youtube.com/watch?v=aad35J4De2c',
    description: 'Build identity by counting inputs you control.',
    runtime: const Duration(minutes: 9, seconds: 40),
    datePosted: DateTime.now().subtract(const Duration(days: 77)),
  ),
  Scoop(
    id: 's13',
    title: 'Habit Tracking that Doesn’t Suck',
    author: 'M. Singh',
    videoUrl: 'https://www.youtube.com/watch?v=aad35J4De2c',
    description: 'Minimalist tracking you’ll actually maintain.',
    runtime: const Duration(minutes: 5, seconds: 11),
    datePosted: DateTime.now().subtract(const Duration(days: 84)),
  ),
  Scoop(
    id: 's14',
    title: 'Small Talk to Strong Networks',
    author: 'P. Nguyen',
    videoUrl: 'https://www.youtube.com/watch?v=aad35J4De2c',
    description: 'Conversation openers and follow-ups that work.',
    runtime: const Duration(minutes: 6, seconds: 27),
    datePosted: DateTime.now().subtract(const Duration(days: 91)),
  ),
  Scoop(
    id: 's15',
    title: 'Systems Beat Motivation',
    author: 'R. Alvarez',
    videoUrl: 'https://www.youtube.com/watch?v=aad35J4De2c',
    description: 'Set it up once, benefit weekly.',
    runtime: const Duration(minutes: 7, seconds: 55),
    datePosted: DateTime.now().subtract(const Duration(days: 98)),
  ),
];
