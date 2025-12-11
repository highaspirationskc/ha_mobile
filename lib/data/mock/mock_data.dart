// lib/data/mock/mock_data.dart
import 'dart:math';

import 'package:ha_mobile/data/mock/mock_users.dart';

import '../../business/events/entities/event.dart';
import '../../business/events/entities/event_type.dart';
import '../../business/olympic_season/entities/olympic_season.dart';
import '../../business/scoops/entities/scoop.dart';

// NEW role-based user models
import '../../business/user/entities/user_base.dart';
import '../../business/user/entities/user_refs.dart';
import '../../business/user/entities/role_mentee.dart';
import '../../business/user/entities/role_mentor.dart';
import '../../business/teams/entities/team.dart';

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

/// Mock parent for Jordan Lee
final User mockParent = User(
  id: 'u_parent_1',
  email: 'patricia.lee@example.com',
  firstName: 'Patricia',
  lastName: 'Lee',
  phone: '+1 (555) 123-4567',
  image:
      'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=400&auto=format&fit=crop',
  colorIndex: 5,
  roles: const {},
);

/// Role data
final MenteeData mockMenteeData = MenteeData(
  userId: mockMentee.id,
  parents: [
    UserRef(
      id: mockParent.id,
      firstName: mockParent.firstName,
      lastName: mockParent.lastName,
      image: mockParent.image,
      colorIndex: mockParent.colorIndex,
      phone: mockParent.phone,
      email: mockParent.email,
    ),
  ],
  mentor: UserRef(
    id: mockMentor.id,
    firstName: mockMentor.firstName,
    lastName: mockMentor.lastName,
    image: mockMentor.image,
    colorIndex: mockMentor.colorIndex,
  ),
  teamId: 'team_blue',
  teamSummary: const TeamSummary(
    id: 'team_blue',
    name: 'Ocean Wolves',
    color: TeamColor.blue,
    points: 245,
    rank: 2,
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
/// EVENT TYPES
/// =================================================================================

final EventType mockEventTypeMentorship = EventType(
  id: 'et_mentorship',
  name: 'Mentorship',
  category: 'Social',
  pointValue: 10,
  createdAt: DateTime.now().subtract(const Duration(days: 365)),
  updatedAt: DateTime.now().subtract(const Duration(days: 365)),
);

final EventType mockEventTypeCareer = EventType(
  id: 'et_career',
  name: 'Career Development',
  category: 'Professional',
  pointValue: 15,
  createdAt: DateTime.now().subtract(const Duration(days: 365)),
  updatedAt: DateTime.now().subtract(const Duration(days: 365)),
);

final EventType mockEventTypeCommunity = EventType(
  id: 'et_community',
  name: 'Community Service',
  category: 'Service',
  pointValue: 20,
  createdAt: DateTime.now().subtract(const Duration(days: 365)),
  updatedAt: DateTime.now().subtract(const Duration(days: 365)),
);

final EventType mockEventTypeSTEM = EventType(
  id: 'et_stem',
  name: 'STEM Activity',
  category: 'Education',
  pointValue: 15,
  createdAt: DateTime.now().subtract(const Duration(days: 365)),
  updatedAt: DateTime.now().subtract(const Duration(days: 365)),
);

final EventType mockEventTypeLeadership = EventType(
  id: 'et_leadership',
  name: 'Leadership',
  category: 'Professional',
  pointValue: 15,
  createdAt: DateTime.now().subtract(const Duration(days: 365)),
  updatedAt: DateTime.now().subtract(const Duration(days: 365)),
);

final EventType mockEventTypeRecreation = EventType(
  id: 'et_recreation',
  name: 'Recreation',
  category: 'Social',
  pointValue: 5,
  createdAt: DateTime.now().subtract(const Duration(days: 365)),
  updatedAt: DateTime.now().subtract(const Duration(days: 365)),
);

final List<EventType> mockEventTypes = [
  mockEventTypeMentorship,
  mockEventTypeCareer,
  mockEventTypeCommunity,
  mockEventTypeSTEM,
  mockEventTypeLeadership,
  mockEventTypeRecreation,
];

/// Quick lookups
final Map<String, EventType> mockEventTypesById = {
  for (final et in mockEventTypes) et.id: et,
};

/// =================================================================================
/// OLYMPIC SEASONS
/// =================================================================================

final OlympicSeason mockOlympicSeasonFall = OlympicSeason(
  id: 'os_fall',
  name: 'Fall',
  startMonth: 9,
  startDay: 1,
  endMonth: 11,
  endDay: 30,
  createdAt: DateTime.now().subtract(const Duration(days: 365)),
  updatedAt: DateTime.now().subtract(const Duration(days: 30)),
);

final OlympicSeason mockOlympicSeasonWinter = OlympicSeason(
  id: 'os_winter',
  name: 'Winter',
  startMonth: 12,
  startDay: 1,
  endMonth: 2,
  endDay: 28,
  createdAt: DateTime.now().subtract(const Duration(days: 365)),
  updatedAt: DateTime.now().subtract(const Duration(days: 30)),
);

final OlympicSeason mockOlympicSeasonSpring = OlympicSeason(
  id: 'os_spring',
  name: 'Spring',
  startMonth: 3,
  startDay: 1,
  endMonth: 5,
  endDay: 31,
  createdAt: DateTime.now().subtract(const Duration(days: 365)),
  updatedAt: DateTime.now().subtract(const Duration(days: 30)),
);

final OlympicSeason mockOlympicSeasonSummer = OlympicSeason(
  id: 'os_summer',
  name: 'Summer',
  startMonth: 6,
  startDay: 1,
  endMonth: 8,
  endDay: 31,
  createdAt: DateTime.now().subtract(const Duration(days: 365)),
  updatedAt: DateTime.now().subtract(const Duration(days: 30)),
);

final List<OlympicSeason> mockOlympicSeasons = [
  mockOlympicSeasonFall,
  mockOlympicSeasonWinter,
  mockOlympicSeasonSpring,
  mockOlympicSeasonSummer,
];

/// Quick lookups
final Map<String, OlympicSeason> mockOlympicSeasonsById = {
  for (final os in mockOlympicSeasons) os.id: os,
};

/// Helper to get current season based on today's date
OlympicSeason getCurrentSeason() {
  final now = DateTime.now();
  final month = now.month;

  if (month >= 9 && month <= 11) return mockOlympicSeasonFall;
  if (month == 12 || month <= 2) return mockOlympicSeasonWinter;
  if (month >= 3 && month <= 5) return mockOlympicSeasonSpring;
  return mockOlympicSeasonSummer;
}

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

List<User> _pickUsers(int maxCount) {
  final count = _rng.nextInt(maxCount + 1);
  if (count == 0) return const [];
  final pool = List<User>.from(mockUsers)..shuffle(_rng);
  return pool.take(count).toList();
}

/// Helper to find the next Saturday from now
DateTime _nextSaturday() {
  final now = DateTime.now();
  final daysUntilSaturday = (DateTime.saturday - now.weekday) % 7;
  final daysToAdd = daysUntilSaturday == 0 ? 7 : daysUntilSaturday;
  final saturday = now.add(Duration(days: daysToAdd));
  return DateTime(saturday.year, saturday.month, saturday.day, 14, 0); // 2 PM
}

final List<Event> mockEvents = [
  Event(
    id: 'evt_saturday',
    name: 'Chess Tournament',
    description:
        'Join us for a friendly chess tournament! All skill levels welcome. Compete for prizes and connect with fellow chess enthusiasts.',
    eventDate: _nextSaturday(),
    location: 'HA Headquarters',
    imageUrl:
        'https://images.unsplash.com/photo-1529699211952-734e80c4d42b?q=80&w=1200&auto=format&fit=crop',
    eventType: mockEventTypeRecreation,
    olympicSeasonId: getCurrentSeason().id,
    registeredUsers: _pickUsers(50),
    arrivedUsers: _pickUsers(35),
    createdAt: _now.subtract(const Duration(days: 14)),
    updatedAt: _now.subtract(const Duration(days: 2)),
    createdBy: mockMentor,
  ),
  // Other events
  ...List<Event>.generate(7, (i) {
    final titles = [
      'Mentor Meetup',
      'Career Workshop',
      'Community Service Day',
      'STEM Lab Tour',
      'College Q&A',
      'Leadership Panel',
      'Hack Night',
    ];
    final locations = [
      'Downtown Center',
      'HA Campus – Room 204',
      'Riverside Park',
      'Innovation Hub',
      'Virtual (Zoom)',
      'Auditorium A',
      'Makerspace',
    ];
    final eventTypes = [
      mockEventTypeMentorship,
      mockEventTypeCareer,
      mockEventTypeCommunity,
      mockEventTypeSTEM,
      mockEventTypeCareer,
      mockEventTypeLeadership,
      mockEventTypeSTEM,
    ];

    final eventDate = _onDay((i + 1) * 2 + 1, hour: 17 + (i % 3));
    return Event(
      id: 'evt_${i + 1}',
      name: titles[i],
      description:
          'Join us for ${titles[i].toLowerCase()} focused on growth, networking, and hands-on learning.',
      eventDate: eventDate,
      location: locations[i],
      imageUrl: _img(i),
      eventType: eventTypes[i],
      olympicSeasonId: getCurrentSeason().id,
      registeredUsers: _pickUsers(40),
      arrivedUsers: _pickUsers(30),
      createdAt: eventDate.subtract(const Duration(days: 21)),
      updatedAt: eventDate.subtract(const Duration(days: 7)),
      createdBy: mockMentor,
    );
  }),
];

/// Quick lookups
final Map<String, Event> mockEventsById = {for (final e in mockEvents) e.id: e};

/// =================================================================================
/// SCOOPS (Mock data - now using API, but kept for fallback/testing)
/// =================================================================================

final List<Scoop> mockScoops = <Scoop>[
  Scoop(
    id: 's1',
    title: 'How to Set Big Goals (and actually hit them)',
    author: 'A. Rivera',
    videoUrl: 'https://www.youtube.com/watch?v=aad35J4De2c',
    description:
        'A practical framework for setting high-leverage goals and tracking progress.',
    published: true,
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  Scoop(
    id: 's2',
    title: 'Morning Routines of Top Performers',
    author: 'K. Lee',
    videoUrl: 'https://www.youtube.com/watch?v=aad35J4De2c',
    description:
        'What elite performers do before 9am — and how to make it stick.',
    published: true,
    createdAt: DateTime.now().subtract(const Duration(days: 7)),
  ),
  Scoop(
    id: 's3',
    title: 'The 3-Hour Deep Work Sprint',
    author: 'M. Chen',
    videoUrl: 'https://www.youtube.com/watch?v=aad35J4De2c',
    description: 'Block, protect, and execute a weekly deep work session.',
    published: true,
    createdAt: DateTime.now().subtract(const Duration(days: 14)),
  ),
  Scoop(
    id: 's4',
    title: 'Beat Procrastination with 10-Minute Starts',
    author: 'S. Patel',
    videoUrl: 'https://www.youtube.com/watch?v=aad35J4De2c',
    description: 'Micro-commitments that break the activation barrier.',
    published: true,
    createdAt: DateTime.now().subtract(const Duration(days: 21)),
  ),
  Scoop(
    id: 's5',
    title: 'Design Your Week: Calendar as a Strategy',
    author: 'N. Gomez',
    videoUrl: 'https://www.youtube.com/watch?v=aad35J4De2c',
    description: 'Turn your week into a playbook for momentum.',
    published: true,
    createdAt: DateTime.now().subtract(const Duration(days: 28)),
  ),
  Scoop(
    id: 's6',
    title: 'Sleep as a Performance Advantage',
    author: 'R. Brown',
    videoUrl: 'https://www.youtube.com/watch?v=aad35J4De2c',
    description: 'Quick wins to improve sleep quality this week.',
    published: true,
    createdAt: DateTime.now().subtract(const Duration(days: 35)),
  ),
  Scoop(
    id: 's7',
    title: 'The One-Page Personal Strategy',
    author: 'T. Nakamura',
    videoUrl: 'https://www.youtube.com/watch?v=aad35J4De2c',
    description: 'Tie goals to habits with a single, visible sheet.',
    published: true,
    createdAt: DateTime.now().subtract(const Duration(days: 42)),
  ),
  Scoop(
    id: 's8',
    title: 'Practice: The 1% Daily Upgrade',
    author: 'L. Santos',
    videoUrl: 'https://www.youtube.com/watch?v=aad35J4De2c',
    description: 'Compound skills with tiny, consistent reps.',
    published: true,
    createdAt: DateTime.now().subtract(const Duration(days: 49)),
  ),
  Scoop(
    id: 's9',
    title: 'Simple Nutrition for Busy Weeks',
    author: 'C. Morgan',
    videoUrl: 'https://www.youtube.com/watch?v=aad35J4De2c',
    description: 'Meal patterns that reduce decision fatigue.',
    published: true,
    createdAt: DateTime.now().subtract(const Duration(days: 56)),
  ),
  Scoop(
    id: 's10',
    title: 'Mindset Reset: Reframing Setbacks',
    author: 'D. Ibrahim',
    videoUrl: 'https://www.youtube.com/watch?v=aad35J4De2c',
    description: 'Turn stumbles into data, not drama.',
    published: true,
    createdAt: DateTime.now().subtract(const Duration(days: 63)),
  ),
  Scoop(
    id: 's11',
    title: 'Focus without Notifications',
    author: 'E. Park',
    videoUrl: 'https://www.youtube.com/watch?v=aad35J4De2c',
    description: 'Silent modes and batching that actually stick.',
    published: true,
    createdAt: DateTime.now().subtract(const Duration(days: 70)),
  ),
  Scoop(
    id: 's12',
    title: 'Confidence via Reps, Not Results',
    author: 'J. Carter',
    videoUrl: 'https://www.youtube.com/watch?v=aad35J4De2c',
    description: 'Build identity by counting inputs you control.',
    published: true,
    createdAt: DateTime.now().subtract(const Duration(days: 77)),
  ),
  Scoop(
    id: 's13',
    title: "Habit Tracking that Doesn't Suck",
    author: 'M. Singh',
    videoUrl: 'https://www.youtube.com/watch?v=aad35J4De2c',
    description: "Minimalist tracking you'll actually maintain.",
    published: true,
    createdAt: DateTime.now().subtract(const Duration(days: 84)),
  ),
  Scoop(
    id: 's14',
    title: 'Small Talk to Strong Networks',
    author: 'P. Nguyen',
    videoUrl: 'https://www.youtube.com/watch?v=aad35J4De2c',
    description: 'Conversation openers and follow-ups that work.',
    published: true,
    createdAt: DateTime.now().subtract(const Duration(days: 91)),
  ),
  Scoop(
    id: 's15',
    title: 'Systems Beat Motivation',
    author: 'R. Alvarez',
    videoUrl: 'https://www.youtube.com/watch?v=aad35J4De2c',
    description: 'Set it up once, benefit weekly.',
    published: true,
    createdAt: DateTime.now().subtract(const Duration(days: 98)),
  ),
];
