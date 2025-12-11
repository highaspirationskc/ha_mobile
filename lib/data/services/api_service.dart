// lib/data/services/api_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../business/community_service/entities/community_service.dart';
import '../../business/user/entities/role_mentee.dart';
import '../../business/user/entities/user.dart';
import '../../business/user/entities/user_role.dart';
import '../../business/user/entities/family_member.dart';
import '../../business/user/entities/user_refs.dart';
import '../../business/mentee_spotlight/entities/mentee_spotlight.dart';
import '../../business/pulse/entities/pulse.dart';
import '../../business/leaderboard/entities/leaderboard.dart';
import '../../business/olympic_season/entities/olympic_season.dart';
import '../../business/events/entities/event.dart';
import '../mock/mock_leaderboard.dart';
import '../graphql/graphql_client.dart';
import '../graphql/documents/queries/queries.dart';
import '../graphql/documents/mutations/update_user_mutation.dart';
import '../graphql/documents/mutations/event_mutations.dart';
import '../graphql/documents/mutations/create_community_service_mutation.dart';
import 'olympic_season_service.dart';

/// Response class for getCurrentUser that includes user, optional mentor, guardians, and children
class CurrentUserData {
  final User user;
  final UserRef? mentor;
  final List<UserRef> guardians;
  final List<UserRef> children; // For guardian users

  const CurrentUserData({
    required this.user,
    this.mentor,
    this.guardians = const [],
    this.children = const [],
  });
}

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

  /// Clear all user-specific caches (call on logout)
  void clearUserCaches() {
    if (kDebugMode) {
      print('🧹 API: Clearing user caches');
    }
    _registrations.clear();
    _checkins.clear();
    _communityServices.clear();
    _pulses.clear();
    _cachedEvents = null;
    _eventsLastFetched = null;
    changes.value++; // notify listeners
  }

  /// Register for an event using GraphQL mutation
  Future<void> registerForEvent({
    required String eventId,
    required String userId,
  }) async {
    if (kDebugMode) {
      print('📝 API: Registering for event: $eventId');
    }

    try {
      final result = await _graphQLClient.client.mutate(
        MutationOptions(
          document: gql(registerForEventMutation),
          variables: {
            'input': {'eventId': eventId},
          },
        ),
      );

      if (result.hasException) {
        if (kDebugMode) {
          print('❌ API: GraphQL error registering: ${result.exception}');
        }
        throw Exception('Failed to register: ${result.exception}');
      }

      final registerData = result.data?['register'] as Map<String, dynamic>?;
      final errors = registerData?['errors'] as List<dynamic>?;

      if (errors != null && errors.isNotEmpty) {
        throw Exception(errors.join(', '));
      }

      final eventLog = registerData?['eventLog'] as Map<String, dynamic>?;
      if (kDebugMode) {
        print('✅ API: Registered successfully');
        if (eventLog != null) {
          print('   Event log ID: ${eventLog['id']}');
          print('   Points awarded: ${eventLog['pointsAwarded']}');
        }
      }

      // Update local cache
      final set = _registrations.putIfAbsent(userId, () => <String>{});
      set.add(eventId);

      // Refetch events to update registeredUsers lists
      await _refetchEvents();

      changes.value++; // notify listeners
    } catch (e) {
      if (kDebugMode) {
        print('❌ API: Exception registering for event: $e');
      }
      rethrow;
    }
  }

  Future<bool> isRegistered({
    required String eventId,
    required String userId,
  }) async {
    // Check local cache (updated after successful register/unregister)
    final set = _registrations[userId];
    return set != null && set.contains(eventId);
  }

  Future<void> unregister({
    required String eventId,
    required String userId,
  }) async {
    // TODO: Add GraphQL mutation for unregister when available
    await Future.delayed(const Duration(milliseconds: 400));
    _registrations[userId]?.remove(eventId);
    _checkins[userId]?.remove(eventId);
    changes.value++; // notify listeners
  }

  /// Check in to an event using GraphQL mutation
  Future<void> checkInForEvent({
    required String eventId,
    required String userId,
  }) async {
    if (kDebugMode) {
      print('✅ API: Checking in to event: $eventId');
    }

    try {
      final result = await _graphQLClient.client.mutate(
        MutationOptions(
          document: gql(checkInToEventMutation),
          variables: {
            'input': {'eventId': eventId},
          },
        ),
      );

      if (result.hasException) {
        if (kDebugMode) {
          print('❌ API: GraphQL error checking in: ${result.exception}');
        }
        throw Exception('Failed to check in: ${result.exception}');
      }

      final checkInData = result.data?['checkIn'] as Map<String, dynamic>?;
      final errors = checkInData?['errors'] as List<dynamic>?;

      if (errors != null && errors.isNotEmpty) {
        throw Exception(errors.join(', '));
      }

      final eventLog = checkInData?['eventLog'] as Map<String, dynamic>?;
      if (kDebugMode) {
        print('✅ API: Checked in successfully');
        if (eventLog != null) {
          print('   Event log ID: ${eventLog['id']}');
          print('   Log type: ${eventLog['logType']}');
          print('   Points awarded: ${eventLog['pointsAwarded']}');
        }
      }

      // Update local cache
      final set = _checkins.putIfAbsent(userId, () => <String>{});
      set.add(eventId);

      // Refetch events to update arrivedUsers lists
      await _refetchEvents();

      changes.value++; // notify listeners
    } catch (e) {
      if (kDebugMode) {
        print('❌ API: Exception checking in: $e');
      }
      rethrow;
    }
  }

  Future<bool> isCheckedIn({
    required String eventId,
    required String userId,
  }) async {
    // Check local cache (updated after successful check-in)
    final set = _checkins[userId];
    return set != null && set.contains(eventId);
  }

  /// Refetch events from server to get updated registeredUsers/arrivedUsers
  Future<void> _refetchEvents() async {
    if (kDebugMode) {
      print('🔄 API: Refetching events after registration/check-in...');
    }
    try {
      // Force refresh the Olympic Season to get updated user lists
      await OlympicSeasonService.instance.refresh();
      if (kDebugMode) {
        print('✅ API: Events refetched successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ API: Failed to refetch events: $e');
      }
      // Don't rethrow - the registration/check-in was successful
    }
  }

  /// Cached events list (populated by getOlympicSeason)
  List<Event>? _cachedEvents;
  DateTime? _eventsLastFetched;

  /// Get cached events (call getOlympicSeason first to populate)
  List<Event> get cachedEvents => _cachedEvents ?? [];

  /// Check if events cache is valid
  bool get hasValidEventsCache =>
      _cachedEvents != null &&
      _eventsLastFetched != null &&
      DateTime.now().difference(_eventsLastFetched!).inMinutes < 5;

  /// Creates a new community service record via GraphQL
  Future<CommunityService> createCommunityService({
    required String userId,
    required String name,
    required String description,
    required double hours,
    required DateTime eventDate,
  }) async {
    if (kDebugMode) {
      print('📝 API: Creating community service record: $name');
    }

    try {
      final result = await _graphQLClient.client.mutate(
        MutationOptions(
          document: gql(createCommunityServiceRecordMutation),
          variables: {
            'event': name,
            'description': description.isNotEmpty ? description : null,
            'eventDate': eventDate.toIso8601String().split('T')[0],
            'hours': hours,
          },
        ),
      );

      if (result.hasException) {
        if (kDebugMode) {
          print('❌ API: GraphQL error creating CS record: ${result.exception}');
        }
        throw Exception(
          'Failed to create community service: ${result.exception}',
        );
      }

      final payload =
          result.data?['createCommunityServiceRecord'] as Map<String, dynamic>?;
      final errors = payload?['errors'] as List<dynamic>?;

      if (errors != null && errors.isNotEmpty) {
        throw Exception(errors.join(', '));
      }

      final recordData =
          payload?['communityServiceRecord'] as Map<String, dynamic>?;
      if (recordData == null) {
        throw Exception('No community service record in response');
      }

      final communityService = CommunityService.fromJson(recordData);

      if (kDebugMode) {
        print(
          '✅ API: Created community service record: ${communityService.id}',
        );
      }

      // Invalidate cache so next fetch gets fresh data
      _communityServices.remove(userId);
      changes.value++; // notify listeners

      return communityService;
    } catch (e) {
      if (kDebugMode) {
        print('❌ API: Exception creating community service: $e');
      }
      rethrow;
    }
  }

  /// Gets all community service records for a user from API
  Future<List<CommunityService>> getCommunityServices({
    required String userId,
  }) async {
    if (kDebugMode) {
      print('🔍 API: Fetching community service records for user: $userId');
    }

    try {
      final result = await _graphQLClient.client.query(
        QueryOptions(
          document: gql(getMenteeCommunityServiceQuery),
          variables: {'userId': userId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        if (kDebugMode) {
          print(
            '❌ API: GraphQL error fetching CS records: ${result.exception}',
          );
        }
        return _communityServices[userId] ?? [];
      }

      final userData = result.data?['user'] as Map<String, dynamic>?;
      final menteeData = userData?['mentee'] as Map<String, dynamic>?;

      if (menteeData == null) {
        if (kDebugMode) {
          print('⚠️ API: No mentee data found for user');
        }
        return [];
      }

      final recordsData =
          menteeData['communityServiceRecords'] as List<dynamic>? ?? [];
      final services = recordsData
          .map(
            (json) => CommunityService.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      // Sort by event date descending (most recent first)
      services.sort((a, b) => b.eventDate.compareTo(a.eventDate));

      // Cache the results
      _communityServices[userId] = services;

      if (kDebugMode) {
        print('✅ API: Fetched ${services.length} community service records');
      }

      return services;
    } catch (e) {
      if (kDebugMode) {
        print('❌ API: Exception fetching community services: $e');
      }
      return _communityServices[userId] ?? [];
    }
  }

  /// Gets the total community service hours for a user from API
  Future<double> getTotalCommunityServiceHours({required String userId}) async {
    if (kDebugMode) {
      print('🔍 API: Fetching total CS hours for user: $userId');
    }

    try {
      final result = await _graphQLClient.client.query(
        QueryOptions(
          document: gql(getMenteeCommunityServiceQuery),
          variables: {'userId': userId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        if (kDebugMode) {
          print('❌ API: GraphQL error fetching CS hours: ${result.exception}');
        }
        // Fallback to cached data
        final cached = _communityServices[userId] ?? [];
        return cached.fold<double>(0, (total, s) => total + s.hours);
      }

      final userData = result.data?['user'] as Map<String, dynamic>?;
      final menteeData = userData?['mentee'] as Map<String, dynamic>?;

      if (menteeData == null) {
        return 0;
      }

      final totalHours =
          (menteeData['totalCommunityServiceHours'] as num?)?.toDouble() ?? 0;

      if (kDebugMode) {
        print('✅ API: Total CS hours: $totalHours');
      }

      return totalHours;
    } catch (e) {
      if (kDebugMode) {
        print('❌ API: Exception fetching CS hours: $e');
      }
      // Fallback to cached data
      final cached = _communityServices[userId] ?? [];
      return cached.fold<double>(0, (total, s) => total + s.hours);
    }
  }

  /// Gets mentee data for a user including guardians and mentor
  Future<MenteeData?> getMenteeData({required String userId}) async {
    if (kDebugMode) {
      print('🔍 API: Fetching mentee data for user: $userId');
    }

    try {
      final result = await _graphQLClient.client.query(
        QueryOptions(
          document: gql(getUserMenteeDataQuery),
          variables: {'id': userId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        if (kDebugMode) {
          print(
            '❌ API: GraphQL error fetching mentee data: ${result.exception}',
          );
        }
        return null;
      }

      final userData = result.data?['user'] as Map<String, dynamic>?;
      if (userData == null) {
        if (kDebugMode) {
          print('⚠️ API: No user data found for ID: $userId');
        }
        return null;
      }

      final menteeData = userData['mentee'] as Map<String, dynamic>?;
      if (menteeData == null) {
        if (kDebugMode) {
          print('⚠️ API: User is not a mentee');
        }
        return null;
      }

      // Parse guardians (parents)
      List<UserRef> parents = [];
      final guardiansData = menteeData['guardians'] as List<dynamic>?;
      if (guardiansData != null) {
        parents = guardiansData.map((guardian) {
          final guardianUserData = guardian['user'] as Map<String, dynamic>;
          return UserRef(
            id: guardianUserData['id'].toString(),
            firstName: guardianUserData['firstName'] as String?,
            lastName: guardianUserData['lastName'] as String?,
            email: guardianUserData['email'] as String?,
            image: guardianUserData['avatarUrl'] as String?,
          );
        }).toList();
      }

      // Parse mentor
      UserRef? mentor;
      final mentorData = menteeData['mentor'] as Map<String, dynamic>?;
      if (mentorData != null) {
        final mentorUserData = mentorData['user'] as Map<String, dynamic>?;
        if (mentorUserData != null) {
          mentor = UserRef(
            id: mentorUserData['id'].toString(),
            firstName: mentorUserData['firstName'] as String?,
            lastName: mentorUserData['lastName'] as String?,
            email: mentorUserData['email'] as String?,
            image: mentorUserData['avatarUrl'] as String?,
          );
        }
      }

      if (kDebugMode) {
        print(
          '✅ API: Found ${parents.length} guardians and ${mentor != null ? 1 : 0} mentor',
        );
      }

      return MenteeData(
        userId: userId,
        parents: parents.isNotEmpty ? parents : null,
        mentor: mentor,
        totalAttendance: 0,
        currentStreak: 0,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ API: Exception fetching mentee data: $e');
      }
      return null;
    }
  }

  /// Gets the current authenticated user with mentor data if available
  Future<CurrentUserData> getCurrentUser() async {
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

      // Parse mentor and guardians from mentee data if available
      UserRef? mentor;
      List<UserRef> guardians = [];

      final menteeData = userData['mentee'] as Map<String, dynamic>?;
      if (menteeData != null) {
        // Parse mentor
        final mentorData = menteeData['mentor'] as Map<String, dynamic>?;
        if (mentorData != null) {
          final mentorUserData = mentorData['user'] as Map<String, dynamic>?;
          if (mentorUserData != null) {
            mentor = UserRef(
              id: mentorUserData['id'].toString(),
              firstName: mentorUserData['firstName'] as String?,
              lastName: mentorUserData['lastName'] as String?,
              email: mentorUserData['email'] as String?,
              image: mentorUserData['avatarUrl'] as String?,
            );
            if (kDebugMode) {
              print('✅ API: Found mentor: ${mentor.displayName}');
            }
          }
        }

        // Parse guardians
        final guardiansData = menteeData['guardians'] as List<dynamic>?;
        if (guardiansData != null) {
          guardians = guardiansData.map((guardian) {
            final guardianUserData = guardian['user'] as Map<String, dynamic>;
            return UserRef(
              id: guardianUserData['id'].toString(),
              firstName: guardianUserData['firstName'] as String?,
              lastName: guardianUserData['lastName'] as String?,
              email: guardianUserData['email'] as String?,
              image: guardianUserData['avatarUrl'] as String?,
            );
          }).toList();
          if (kDebugMode) {
            print('✅ API: Found ${guardians.length} guardians');
          }
        }
      }

      // Parse children from guardian data if available (for guardian/parent users)
      List<UserRef> children = [];
      final guardianData = userData['guardian'] as Map<String, dynamic>?;
      if (guardianData != null) {
        final childrenData = guardianData['children'] as List<dynamic>?;
        if (childrenData != null) {
          children = childrenData.map((child) {
            final childUserData = child['user'] as Map<String, dynamic>;
            return UserRef(
              id: childUserData['id'].toString(),
              firstName: childUserData['firstName'] as String?,
              lastName: childUserData['lastName'] as String?,
              email: childUserData['email'] as String?,
              image: childUserData['avatarUrl'] as String?,
            );
          }).toList();
          if (kDebugMode) {
            print('✅ API: Found ${children.length} children for guardian');
          }
        }
      }

      if (kDebugMode) {
        print(
          '✅ API: Fetched current user: ${user.displayName} (${user.email})',
        );
      }

      return CurrentUserData(
        user: user,
        mentor: mentor,
        guardians: guardians,
        children: children,
      );
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
      print('🔍 API: Fetching mentees for mentor: $mentorId');
    }

    try {
      final result = await _graphQLClient.client.query(
        QueryOptions(
          document: gql(getMenteesByMentorQuery),
          variables: {'mentorId': mentorId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        if (kDebugMode) {
          print('❌ API: GraphQL error fetching mentees: ${result.exception}');
        }
        return [];
      }

      final userData = result.data?['user'];
      if (userData == null) {
        if (kDebugMode) {
          print('❌ API: No user data found for mentor $mentorId');
        }
        return [];
      }

      final mentorData = userData['mentor'];
      if (mentorData == null) {
        if (kDebugMode) {
          print('❌ API: User $mentorId is not a mentor');
        }
        return [];
      }

      final menteesData = mentorData['mentees'] as List<dynamic>? ?? [];
      final mentees = menteesData
          .map(
            (mentee) => User.fromJson(mentee['user'] as Map<String, dynamic>),
          )
          .toList();

      if (kDebugMode) {
        print('✅ API: Found ${mentees.length} mentees for mentor $mentorId');
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
      return [];
    }
  }

  /// Gets all children assigned to the current authenticated parent
  /// Uses the guardian.children data from getCurrentUser
  Future<List<User>> getChildrenByParent({required String parentId}) async {
    if (kDebugMode) {
      print('🔍 API: Fetching children for parent: $parentId');
    }

    try {
      // Fetch current user which includes guardian.children
      final currentUserData = await getCurrentUser();

      // Convert UserRef children to User objects
      final children = currentUserData.children.map((childRef) {
        return User(
          id: childRef.id,
          firstName: childRef.firstName,
          lastName: childRef.lastName,
          email: childRef.email,
          image: childRef.image,
        );
      }).toList();

      if (kDebugMode) {
        print('✅ API: Found ${children.length} children for parent $parentId');
        for (final child in children) {
          print('   - ${child.firstName} ${child.lastName} (ID: ${child.id})');
        }
      }

      return children;
    } catch (e) {
      if (kDebugMode) {
        print('❌ API: Exception fetching children: $e');
      }
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

  /// Gets the mentee spotlight
  Future<MenteeSpotlight?> getMenteeSpotlight() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final leaderboard = getMockLeaderboard();
    if (leaderboard.topMentees.isEmpty) return null;

    // For now, create a spotlight from the top mentee
    final topMentee = leaderboard.topMentees.first;

    return MenteeSpotlight(
      id: 'spotlight_${topMentee.mentee.id}',
      mentee: User(
        id: topMentee.mentee.id,
        email: '', // UserRef doesn't have email
        firstName: topMentee.mentee.firstName,
        lastName: topMentee.mentee.lastName,
        image: topMentee.mentee.image,
        colorIndex: topMentee.mentee.colorIndex,
      ),
      description:
          "${topMentee.mentee.firstName} has been an outstanding member of our program, "
          "consistently demonstrating leadership and dedication. Their positive attitude "
          "and commitment to excellence make them a true role model for their peers.",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Gets all family member relationships
  Future<List<FamilyMember>> getFamilyMembers() async {
    if (kDebugMode) {
      print('🔍 API: Fetching all family members');
    }

    try {
      final result = await _graphQLClient.client.query(
        QueryOptions(
          document: gql(getFamilyMembersQuery),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (kDebugMode) {
        print('📦 API: Family members query response:');
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
        if (kDebugMode) {
          print('⚠️ API: Error fetching family members');
        }
        return [];
      }

      final familyMembersList = result.data?['familyMembers'] as List<dynamic>?;
      if (familyMembersList == null || familyMembersList.isEmpty) {
        if (kDebugMode) {
          print('✅ API: No family members found');
        }
        return [];
      }

      // Parse the family members from GraphQL response
      final familyMembers = familyMembersList.map((json) {
        return FamilyMember.fromJson(json as Map<String, dynamic>);
      }).toList();

      if (kDebugMode) {
        print('✅ API: Fetched ${familyMembers.length} family members');
      }

      return familyMembers;
    } catch (e) {
      if (kDebugMode) {
        print('❌ API: Exception fetching family members: $e');
      }
      return [];
    }
  }

  /// Gets a specific family member by ID
  Future<FamilyMember?> getFamilyMember({required String id}) async {
    if (kDebugMode) {
      print('🔍 API: Fetching family member with ID: $id');
    }

    try {
      final result = await _graphQLClient.client.query(
        QueryOptions(
          document: gql(getFamilyMemberQuery),
          variables: {'id': id},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (kDebugMode) {
        print('📦 API: Family member query response:');
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
        if (kDebugMode) {
          print('⚠️ API: Error fetching family member');
        }
        return null;
      }

      final familyMemberData =
          result.data?['familyMember'] as Map<String, dynamic>?;
      if (familyMemberData == null) {
        if (kDebugMode) {
          print('✅ API: Family member not found');
        }
        return null;
      }

      final familyMember = FamilyMember.fromJson(familyMemberData);

      if (kDebugMode) {
        print('✅ API: Fetched family member: ${familyMember.id}');
      }

      return familyMember;
    } catch (e) {
      if (kDebugMode) {
        print('❌ API: Exception fetching family member: $e');
      }
      return null;
    }
  }

  /// Gets family members for a specific user (as either user or relatedUser)
  Future<List<FamilyMember>> getFamilyMembersForUser({
    required String userId,
  }) async {
    if (kDebugMode) {
      print('🔍 API: Fetching family members for user: $userId');
    }

    try {
      // First, get all family members
      final allFamilyMembers = await getFamilyMembers();

      // Filter to only those where the user is involved
      final userFamilyMembers = allFamilyMembers.where((fm) {
        return fm.user.id == userId || fm.relatedUser.id == userId;
      }).toList();

      if (kDebugMode) {
        print(
          '✅ API: Found ${userFamilyMembers.length} family members for user $userId',
        );
      }

      return userFamilyMembers;
    } catch (e) {
      if (kDebugMode) {
        print('❌ API: Exception fetching family members for user: $e');
      }
      return [];
    }
  }

  /// Gets all family members related to the current authenticated parent's children
  /// This returns OTHER family members (siblings, other parents, etc.) related to the children
  Future<List<FamilyMember>> getFamilyMembersForChildren({
    required String parentId,
  }) async {
    if (kDebugMode) {
      print(
        '🔍 API: Fetching family members for parent\'s children: $parentId',
      );
    }

    try {
      // First, get the parent's children
      final children = await getChildrenByParent(parentId: parentId);

      if (children.isEmpty) {
        if (kDebugMode) {
          print('✅ API: Parent has no children, so no family members to fetch');
        }
        return [];
      }

      // Get all family members
      final allFamilyMembers = await getFamilyMembers();

      // Filter to get family members related to the children
      // but exclude the parent-child relationships we already have
      final childrenIds = children.map((c) => c.id).toSet();
      final familyMembersForChildren = allFamilyMembers.where((fm) {
        // Include if either user or relatedUser is one of the children
        // but exclude if it's the direct parent-child relationship
        final hasChild =
            childrenIds.contains(fm.user.id) ||
            childrenIds.contains(fm.relatedUser.id);
        final isParentChildRelation =
            (fm.user.id == parentId || fm.relatedUser.id == parentId) &&
            (childrenIds.contains(fm.user.id) ||
                childrenIds.contains(fm.relatedUser.id));

        return hasChild && !isParentChildRelation;
      }).toList();

      if (kDebugMode) {
        print(
          '✅ API: Found ${familyMembersForChildren.length} family members for parent\'s children',
        );
        for (final fm in familyMembersForChildren) {
          print(
            '   - ${fm.user.displayName} [${fm.relationshipType}] -> ${fm.relatedUser.displayName}',
          );
        }
      }

      return familyMembersForChildren;
    } catch (e) {
      if (kDebugMode) {
        print('❌ API: Exception fetching family members for children: $e');
      }
      return [];
    }
  }

  /// Gets the current Olympic Season with all events
  /// Defaults to current year if no year is provided
  Future<OlympicSeason> getOlympicSeason({String? name, int? year}) async {
    // Default to current year
    final queryYear = year ?? DateTime.now().year;

    if (kDebugMode) {
      print('🏅 Fetching Olympic Season for year $queryYear...');
    }

    try {
      final result = await _graphQLClient.client.query(
        QueryOptions(
          document: gql(getOlympicSeasonQuery),
          variables: {
            'input': {if (name != null) 'name': name, 'year': queryYear},
          },
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
        throw Exception('GraphQL error: ${result.exception}');
      }

      final seasonData = result.data?['olympicSeason'] as Map<String, dynamic>?;
      if (seasonData == null) {
        throw Exception('No Olympic Season data in response');
      }

      // Parse events from the season
      final eventsData = seasonData['events'] as List<dynamic>? ?? [];
      final events = eventsData.map((json) {
        return Event.fromJson(json as Map<String, dynamic>);
      }).toList();

      // Sort events by date
      events.sort((a, b) => a.eventDate.compareTo(b.eventDate));

      // Cache the events
      _cachedEvents = events;
      _eventsLastFetched = DateTime.now();

      final season = OlympicSeason(
        id: seasonData['id'].toString(),
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
      }
      rethrow;
    }
  }

  /// Upload media (image) to the server
  /// Returns the media ID and URL on success
  /// Uses bytes instead of file path for web compatibility
  Future<({int id, String url})> uploadMedia({
    required List<int> bytes,
    required String fileName,
    required String category,
  }) async {
    if (kDebugMode) {
      print('📤 API: Uploading media file: $fileName (category: $category)');
    }

    final token = _graphQLClient.authToken;
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Uri.parse('https://api.highaspirationskc.org/media');
    final request = http.MultipartRequest('POST', uri);

    // Add headers
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    // Add file from bytes (works on both web and native)
    final mimeType = _getMimeType(fileName);
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
        contentType: mimeType,
      ),
    );

    // Add category field
    request.fields['category'] = category;

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('📦 API: Upload response status: ${response.statusCode}');
        print('   Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final id = data['id'] as int;
        final url = data['url'] as String;

        if (kDebugMode) {
          print('✅ API: Media uploaded successfully - ID: $id, URL: $url');
        }

        return (id: id, url: url);
      } else {
        throw Exception(
          'Failed to upload media: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ API: Exception uploading media: $e');
      }
      rethrow;
    }
  }

  MediaType _getMimeType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      default:
        return MediaType('image', 'jpeg');
    }
  }

  /// Update user avatar by uploading image and updating user profile
  /// Returns the new avatar URL on success
  /// Uses bytes for web compatibility
  Future<String> updateUserAvatar({
    required String userId,
    required List<int> imageBytes,
    required String fileName,
  }) async {
    if (kDebugMode) {
      print('🖼️ API: Updating avatar for user: $userId');
    }

    try {
      // Step 1: Upload the image
      final uploadResult = await uploadMedia(
        bytes: imageBytes,
        fileName: fileName,
        category: 'avatar',
      );

      // Step 2: Update user with the new avatar ID
      final result = await _graphQLClient.client.mutate(
        MutationOptions(
          document: gql(updateUserMutation),
          variables: {
            'input': {'id': userId, 'avatarId': uploadResult.id.toString()},
          },
        ),
      );

      if (result.hasException) {
        if (kDebugMode) {
          print(
            '❌ API: GraphQL error updating user avatar: ${result.exception}',
          );
        }
        throw Exception('Failed to update user avatar: ${result.exception}');
      }

      final updateData = result.data?['updateUser'] as Map<String, dynamic>?;
      final errors = updateData?['errors'] as List<dynamic>?;

      if (errors != null && errors.isNotEmpty) {
        throw Exception('Failed to update avatar: ${errors.join(', ')}');
      }

      final userData = updateData?['user'] as Map<String, dynamic>?;
      final newAvatarUrl =
          userData?['avatarUrl'] as String? ?? uploadResult.url;

      if (kDebugMode) {
        print('✅ API: Avatar updated successfully - URL: $newAvatarUrl');
      }

      // Notify listeners that user data has changed
      changes.value++;

      return newAvatarUrl;
    } catch (e) {
      if (kDebugMode) {
        print('❌ API: Exception updating user avatar: $e');
      }
      rethrow;
    }
  }
}
