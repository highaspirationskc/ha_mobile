// lib/data/services/api_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../business/community_service/entities/community_service.dart';
import '../../business/user/entities/role_mentee.dart';
import '../../business/pulse/entities/pulse.dart';
import '../../business/leaderboard/entities/leaderboard.dart';
import '../../data/mock/mock_data.dart';
import '../mock/mock_leaderboard.dart';

class ApiService {
  ApiService._() {
    _initializeMockData();
  }
  static final instance = ApiService._();

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
