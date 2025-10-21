// lib/data/services/api_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../business/community_service/entities/community_service.dart';
import '../../business/user/entities/role_mentee.dart';
import '../../data/mock/mock_data.dart';

class ApiService {
  ApiService._();
  static final instance = ApiService._();

  /// Broadcast-only: increments whenever registrations/check-ins change.
  final ValueNotifier<int> changes = ValueNotifier<int>(0);

  final Map<String, Set<String>> _registrations = {};
  final Map<String, Set<String>> _checkins = {};
  final Map<String, List<CommunityService>> _communityServices = {};

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
}
