// lib/data/services/api_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../business/community_service/entities/community_service.dart';
import '../../business/user/entities/role_mentee.dart';
import '../../business/user/entities/user.dart';
import '../../business/pulse/entities/pulse.dart';
import '../../business/leaderboard/entities/leaderboard.dart';
import '../../data/mock/mock_data.dart';
import '../mock/mock_leaderboard.dart';
import '../mock/mock_users.dart';
import '../graphql/graphql_client.dart';
import '../graphql/documents/queries/queries.dart';

class ApiService {
  ApiService._() {
    _initializeMockData();
    _graphQLClient = GraphQLClientService.instance;
    _graphQLClient.initialize();
  }
  static final instance = ApiService._();

  late final GraphQLClientService _graphQLClient;

  /// Broadcast-only: increments whenever registrations/check-ins change.
  final ValueNotifier<int> changes = ValueNotifier<int>(0);

  final Map<String, Set<String>> _registrations = {};
  final Map<String, Set<String>> _checkins = {};
  final Map<String, List<CommunityService>> _communityServices = {};
  final Map<String, List<Pulse>> _pulses = {};

  /// Initialize with some mock check-in data for testing
  void _initializeMockData() {
    // Add some mock check-ins for the mock mentee
    const mockMenteeId = 'u_mentee_1'; // matches mockMentee.id
    _checkins[mockMenteeId] = {
      'evt_1', // Mentor Meetup
      'evt_2', // Career Workshop
      'evt_3', // Community Service Day
      'evt_4', // STEM Lab Tour
      'evt_5', // College Q&A
      'evt_6', // Leadership Panel
      'evt_7', // Hack Night
    };
  }

  Future<void> registerForEvent({
    required String eventId,
    required String userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));
    final set = _registrations.putIfAbsent(userId, () => <String>{});
    set.add(eventId);
    changes.value++; // notify listeners
  }

  Future<bool> isRegistered({
    required String eventId,
    required String userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final set = _registrations[userId];
    return set != null && set.contains(eventId);
  }

  Future<void> unregister({
    required String eventId,
    required String userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _registrations[userId]?.remove(eventId);
    _checkins[userId]?.remove(eventId);
    changes.value++; // notify listeners
  }

  Future<void> checkInForEvent({
    required String eventId,
    required String userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final isReg = _registrations[userId]?.contains(eventId) ?? false;
    if (!isReg) throw Exception('You must register before checking in.');
    final set = _checkins.putIfAbsent(userId, () => <String>{});
    set.add(eventId);
    if (kDebugMode) {
      print('checkInForEvent: $userId checked into $eventId');
      print('Total check-ins for $userId: ${set.length}');
    }
    changes.value++; // notify listeners
  }

  Future<bool> isCheckedIn({
    required String eventId,
    required String userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final set = _checkins[userId];
    return set != null && set.contains(eventId);
  }

  /// Creates a new community service entry for a user
  Future<CommunityService> createCommunityService({
    required String userId,
    required String name,
    required String description,
    required int hours,
    String? location,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final communityService = CommunityService(
      id: 'cs_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      hours: hours,
      location: location,
      createdAt: DateTime.now(),
    );

    final userServices = _communityServices.putIfAbsent(
      userId,
      () => <CommunityService>[],
    );
    userServices.add(communityService);
    changes.value++; // notify listeners

    return communityService;
  }

  /// Gets all community service entries for a user
  Future<List<CommunityService>> getCommunityServices({
    required String userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_communityServices[userId] ?? []);
  }

  /// Gets the total community service hours for a user
  Future<int> getTotalCommunityServiceHours({required String userId}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final services = _communityServices[userId] ?? [];
    return services.fold<int>(0, (total, service) => total + service.hours);
  }

  /// Gets mentee data for a user
  Future<MenteeData?> getMenteeData({required String userId}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return mockMenteesByUserId[userId];
  }

  /// Gets all mentees assigned to a specific mentor
  Future<List<User>> getMenteesByMentor({required String mentorId}) async {
    if (kDebugMode) {
      print('🔍 Fetching mentees for mentor: $mentorId');
    }

    try {
      final result = await _graphQLClient.client.query(
        QueryOptions(
          document: gql(getMenteesByMentorQuery),
          variables: {'mentorId': mentorId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (kDebugMode) {
        print('📦 Mentees query response:');
        print('   Has exception: ${result.hasException}');
        print('   Has data: ${result.data != null}');
        if (result.hasException) {
          print('   Exception: ${result.exception}');
        }
        if (result.data != null) {
          print('   Data: ${result.data}');
        }
      }

      if (result.hasException) {
        // If there's a network/GraphQL error, fall back to mock data
        if (kDebugMode) {
          print('⚠️ Error fetching mentees, using mock data');
        }
        // Return a subset of mock mentees (simulate mentor having 3-5 mentees)
        return allMockMentees.take(5).toList();
      }

      final menteesList = result.data?['menteesByMentor'] as List<dynamic>?;
      if (menteesList == null) {
        if (kDebugMode) {
          print('⚠️ No mentees data in response, using mock data');
        }
        return allMockMentees.take(5).toList();
      }

      // Parse the mentees from GraphQL response
      final mentees = menteesList.map((json) {
        return User(
          id: json['id'] as String,
          email: json['email'] as String,
          firstName: json['firstName'] as String?,
          lastName: json['lastName'] as String?,
          phone: json['phone'] as String?,
          image: json['image'] as String?,
          colorIndex: json['colorIndex'] as int?,
        );
      }).toList();

      if (kDebugMode) {
        print('✅ Fetched ${mentees.length} mentees');
      }

      return mentees;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception fetching mentees: $e');
        print('   Using mock data as fallback');
      }
      // On any error, return mock data
      return allMockMentees.take(5).toList();
    }
  }

  /// Gets the total attendance count (check-ins) for a user
  Future<int> getTotalAttendance({required String userId}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final checkins = _checkins[userId];
    final count = checkins?.length ?? 0;
    if (kDebugMode) {
      print('getTotalAttendance for $userId: $count check-ins');
      print('Check-ins: ${checkins?.toList()}');
    }
    return count;
  }

  /// Creates a new pulse entry for a user
  Future<Pulse> createPulse({
    required String userId,
    required int rating,
    required String highlight,
    required String challenge,
    required String thoughts,
    required List<SupportTopic> supportTopics,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final pulse = Pulse(
      id: 'pulse_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      createdAt: DateTime.now(),
      rating: rating,
      highlight: highlight,
      challenge: challenge,
      thoughts: thoughts,
      supportTopics: supportTopics,
    );

    final userPulses = _pulses.putIfAbsent(userId, () => <Pulse>[]);
    userPulses.add(pulse);
    changes.value++; // notify listeners

    return pulse;
  }

  /// Gets all pulse entries for a user
  Future<List<Pulse>> getPulses({required String userId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_pulses[userId] ?? []);
  }

  /// Gets the latest pulse for a user
  Future<Pulse?> getLatestPulse({required String userId}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final pulses = _pulses[userId] ?? [];
    if (pulses.isEmpty) return null;
    pulses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return pulses.first;
  }

  /// Gets the leaderboard with all teams info and top 10 mentees by points
  Future<Leaderboard> getLeaderboard() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return getMockLeaderboard();
  }

  /// Gets the mentee spotlight (mentee with the most points)
  Future<MenteeRanking?> getMenteeSpotlight() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final leaderboard = getMockLeaderboard();
    if (leaderboard.topMentees.isEmpty) return null;

    // Return the mentee with the highest points (should be first in the list)
    return leaderboard.topMentees.first;
  }
}
