// lib/data/services/api_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../business/community_service/entities/community_service.dart';
import '../../business/user/entities/role_mentee.dart';
import '../../business/user/entities/user.dart';
import '../../business/user/entities/user_role.dart';
import '../../business/user/entities/family_member.dart';
import '../../business/mentee_spotlight/entities/mentee_spotlight.dart';
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
  Future<List<User>> getChildrenByParent({required String parentId}) async {
    if (kDebugMode) {
      print('🔍 API: Fetching children for parent: $parentId');
    }

    try {
      // Get all family members
      final allFamilyMembers = await getFamilyMembers();

      if (kDebugMode) {
        print(
          '📦 API: Retrieved ${allFamilyMembers.length} total family members',
        );
        for (final fm in allFamilyMembers) {
          print(
            '   - ${fm.user.displayName} (ID: ${fm.user.id}) [${fm.relationshipType}] -> ${fm.relatedUser.displayName} (ID: ${fm.relatedUser.id})',
          );
        }
      }

      // Filter to find relationships where:
      // - user is the parent (parentId)
      // - relationshipType is "parent" or "child" related
      // - relatedUser is the child
      final childFamilyMembers = allFamilyMembers.where((fm) {
        final isParentRelationship =
            fm.user.id == parentId &&
            (fm.relationshipType.toLowerCase().contains('parent') ||
                fm.relationshipType.toLowerCase().contains('child'));

        // Also check the reverse: if the relatedUser is the parent and user is the child
        final isReverseRelationship =
            fm.relatedUser.id == parentId &&
            (fm.relationshipType.toLowerCase().contains('parent') ||
                fm.relationshipType.toLowerCase().contains('child'));

        return isParentRelationship || isReverseRelationship;
      }).toList();

      // Extract the children
      // If user is parent, child is relatedUser
      // If relatedUser is parent, child is user
      final children = childFamilyMembers.map((fm) {
        return fm.user.id == parentId ? fm.relatedUser : fm.user;
      }).toList();

      // Remove duplicates
      final uniqueChildren = <String, User>{};
      for (final child in children) {
        uniqueChildren[child.id] = child;
      }

      final childrenList = uniqueChildren.values.toList();

      if (kDebugMode) {
        print(
          '✅ API: Found ${childrenList.length} children for parent $parentId',
        );
        for (final child in childrenList) {
          print('   - ${child.firstName} ${child.lastName} (ID: ${child.id})');
        }
      }

      return childrenList;
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
