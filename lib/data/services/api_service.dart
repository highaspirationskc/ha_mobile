// lib/data/services/api_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../business/community_service/entities/community_service.dart';
import '../../business/user/entities/role_mentee.dart';
import '../../business/user/entities/user.dart';
import '../../business/user/entities/user_role.dart';
import '../../business/pulse/entities/pulse.dart';
import '../../business/leaderboard/entities/leaderboard.dart';
import '../../business/olympic_season/entities/olympic_season.dart';
import '../../business/events/entities/event.dart';
import '../../business/events/entities/event_type.dart';
import '../../data/mock/mock_data.dart';
import '../mock/mock_leaderboard.dart';
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

  /// Gets the current authenticated user
  Future<User> getCurrentUser() async {
    if (kDebugMode) {
      print('🔍 API: Fetching current user data');
    }

    try {
      final result = await _graphQLClient.client.query(
        QueryOptions(
          document: gql(getCurrentUserQuery),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (kDebugMode) {
        print('📦 API: Current user query response:');
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
        throw Exception('Failed to fetch current user');
      }

      final userData = result.data?['currentUser'] as Map<String, dynamic>?;
      if (userData == null) {
        throw Exception('No current user data in response');
      }

      final user = User(
        id: userData['id'].toString(),
        email: userData['email'] as String,
        firstName: userData['firstName'] as String?,
        lastName: userData['lastName'] as String?,
        image: userData['avatarUrl'] as String?,
        roles: userData['role'] != null
            ? {UserRole.fromString(userData['role'] as String)}
            : {},
      );

      if (kDebugMode) {
        print(
          '✅ API: Fetched current user: ${user.displayName} (${user.email})',
        );
      }

      return user;
    } catch (e) {
      if (kDebugMode) {
        print('❌ API: Exception fetching current user: $e');
      }
      rethrow;
    }
  }

  /// Gets all mentees assigned to the current authenticated mentor
  Future<List<User>> getMenteesByMentor({required String mentorId}) async {
    if (kDebugMode) {
      print('🔍 API: Fetching mentees for current user (mentor)');
    }

    try {
      final result = await _graphQLClient.client.query(
        QueryOptions(
          document: gql(getCurrentUserQuery),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (kDebugMode) {
        print('📦 API: Current user query response:');
        print('   Has exception: ${result.hasException}');
        print('   Has data: ${result.data != null}');
        if (result.hasException) {
          print('   Exception: ${result.exception}');
          print('   GraphQL errors: ${result.exception?.graphqlErrors}');
          print('   Link exception: ${result.exception?.linkException}');
        }
        if (result.data != null) {
          print('   Data: ${result.data}');
        }
      }

      if (result.hasException) {
        // If there's a network/GraphQL error, return empty list
        if (kDebugMode) {
          print('⚠️ API: Error fetching current user');
        }
        return [];
      }

      final userData = result.data?['currentUser'] as Map<String, dynamic>?;
      if (userData == null) {
        if (kDebugMode) {
          print('⚠️ API: No current user data in response');
        }
        return [];
      }

      final menteesList = userData['mentees'] as List<dynamic>?;
      if (menteesList == null || menteesList.isEmpty) {
        if (kDebugMode) {
          print('✅ API: Current user has no mentees assigned');
        }
        return [];
      }

      // Parse the mentees from GraphQL response
      final mentees = menteesList.map((json) {
        return User(
          id: json['id'].toString(),
          email: json['email'] as String,
          firstName: json['firstName'] as String?,
          lastName: json['lastName'] as String?,
          image: json['avatarUrl'] as String?,
          roles: json['role'] != null
              ? {UserRole.fromString(json['role'] as String)}
              : {},
        );
      }).toList();

      if (kDebugMode) {
        print('✅ API: Current user has ${mentees.length} mentees');
        for (final mentee in mentees) {
          print(
            '   - ${mentee.firstName} ${mentee.lastName} (ID: ${mentee.id})',
          );
        }
      }

      return mentees;
    } catch (e) {
      if (kDebugMode) {
        print('❌ API: Exception fetching mentees: $e');
      }
      // On any error, return empty list
      return [];
    }
  }

  /// Gets all children assigned to the current authenticated parent
  Future<List<User>> getChildrenByParent({required String parentId}) async {
    if (kDebugMode) {
      print('🔍 API: Fetching children for current user (parent)');
    }

    try {
      final result = await _graphQLClient.client.query(
        QueryOptions(
          document: gql(getCurrentUserQuery),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (kDebugMode) {
        print('📦 API: Current user query response:');
        print('   Has exception: ${result.hasException}');
        print('   Has data: ${result.data != null}');
        if (result.hasException) {
          print('   Exception: ${result.exception}');
          print('   GraphQL errors: ${result.exception?.graphqlErrors}');
          print('   Link exception: ${result.exception?.linkException}');
        }
        if (result.data != null) {
          print('   Data: ${result.data}');
        }
      }

      if (result.hasException) {
        // If there's a network/GraphQL error, return empty list
        if (kDebugMode) {
          print('⚠️ API: Error fetching current user');
        }
        return [];
      }

      final userData = result.data?['currentUser'] as Map<String, dynamic>?;
      if (userData == null) {
        if (kDebugMode) {
          print('⚠️ API: No current user data in response');
        }
        return [];
      }

      final childrenList = userData['children'] as List<dynamic>?;
      if (childrenList == null || childrenList.isEmpty) {
        if (kDebugMode) {
          print('✅ API: Current user has no children assigned');
        }
        return [];
      }

      // Parse the children from GraphQL response
      final children = childrenList.map((json) {
        return User(
          id: json['id'].toString(),
          email: json['email'] as String,
          firstName: json['firstName'] as String?,
          lastName: json['lastName'] as String?,
          image: json['avatarUrl'] as String?,
          roles: json['role'] != null
              ? {UserRole.fromString(json['role'] as String)}
              : {},
        );
      }).toList();

      if (kDebugMode) {
        print('✅ API: Current user has ${children.length} children');
        for (final child in children) {
          print('   - ${child.firstName} ${child.lastName} (ID: ${child.id})');
        }
      }

      return children;
    } catch (e) {
      if (kDebugMode) {
        print('❌ API: Exception fetching children: $e');
      }
      // On any error, return empty list
      return [];
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

  /// Gets the current Olympic Season with all events
  /// Pass input to get a specific season, or leave null for current
  Future<OlympicSeason> getOlympicSeason({String? name, int? year}) async {
    if (kDebugMode) {
      print('🏅 Fetching Olympic Season...');
    }

    try {
      final Map<String, dynamic>? variables = (name != null || year != null)
          ? {
              'input': {
                if (name != null) 'name': name,
                if (year != null) 'year': year,
              },
            }
          : null;

      final result = await _graphQLClient.client.query(
        QueryOptions(
          document: gql(getOlympicSeasonQuery),
          variables: variables ?? {},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (kDebugMode) {
        print('📦 Olympic Season query response:');
        print('   Has exception: ${result.hasException}');
        print('   Has data: ${result.data != null}');
        if (result.hasException) {
          print('   Exception: ${result.exception}');
        }
        if (result.data != null) {
          print('   Data keys: ${result.data?.keys}');
        }
      }

      if (result.hasException) {
        if (kDebugMode) {
          print('⚠️ Error fetching Olympic Season, using mock data');
        }
        // Fall back to current season mock data
        return getCurrentSeason();
      }

      final seasonData = result.data?['olympicSeason'] as Map<String, dynamic>?;
      if (seasonData == null) {
        if (kDebugMode) {
          print('⚠️ No Olympic Season data in response, using mock data');
        }
        return getCurrentSeason();
      }

      // Parse events
      final eventsData = seasonData['events'] as List<dynamic>? ?? [];
      final events = eventsData.map((json) {
        final eventTypeData = json['eventType'] as Map<String, dynamic>;
        final eventType = EventType.fromJson(eventTypeData);

        final registeredUsersData =
            json['registeredUsers'] as List<dynamic>? ?? [];
        final registeredUsers = registeredUsersData.map((u) {
          final userData = u as Map<String, dynamic>;
          // Map API fields to our User model fields
          return User(
            id: userData['id'].toString(),
            email: userData['email'] as String,
            firstName: userData['firstName'] as String?,
            lastName: userData['lastName'] as String?,
            image: userData['avatarUrl'] as String?,
            roles: userData['role'] != null
                ? {UserRole.fromString(userData['role'] as String)}
                : {},
          );
        }).toList();

        final arrivedUsersData = json['arrivedUsers'] as List<dynamic>? ?? [];
        final arrivedUsers = arrivedUsersData.map((u) {
          final userData = u as Map<String, dynamic>;
          // Map API fields to our User model fields
          return User(
            id: userData['id'].toString(),
            email: userData['email'] as String,
            firstName: userData['firstName'] as String?,
            lastName: userData['lastName'] as String?,
            image: userData['avatarUrl'] as String?,
            roles: userData['role'] != null
                ? {UserRole.fromString(userData['role'] as String)}
                : {},
          );
        }).toList();

        return Event(
          id: json['id'] as String,
          name: json['name'] as String,
          description: json['description'] as String?,
          eventDate: DateTime.parse(json['eventDate'] as String),
          location: json['location'] as String?,
          imageUrl: json['imageUrl'] as String?,
          eventType: eventType,
          olympicSeasonId: seasonData['id'] as String,
          registeredUsers: registeredUsers,
          arrivedUsers: arrivedUsers,
          createdAt: DateTime.parse(json['createdAt'] as String),
          updatedAt: DateTime.parse(json['updatedAt'] as String),
        );
      }).toList();

      final season = OlympicSeason(
        id: seasonData['id'] as String,
        name: seasonData['name'] as String,
        startMonth: seasonData['startMonth'] as int,
        startDay: seasonData['startDay'] as int,
        endMonth: seasonData['endMonth'] as int,
        endDay: seasonData['endDay'] as int,
        createdAt: DateTime.parse(seasonData['createdAt'] as String),
        updatedAt: DateTime.parse(seasonData['updatedAt'] as String),
        events: events,
      );

      if (kDebugMode) {
        print('✅ Fetched ${season.name} season with ${events.length} events');
      }

      return season;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception fetching Olympic Season: $e');
        print('   Using mock data as fallback');
      }
      // On any error, return mock data
      return getCurrentSeason();
    }
  }
}
