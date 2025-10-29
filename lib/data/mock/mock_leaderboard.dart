import 'dart:math';
import '../../business/leaderboard/entities/leaderboard.dart';
import '../../business/user/entities/user_refs.dart';
import '../../business/user/entities/user_base.dart';
import '../../business/user/entities/role_mentee.dart';
import 'mock_teams.dart';
import 'mock_users.dart';

// Helper to create UserRef from User
UserRef _userToRef(User user) {
  return UserRef(
    id: user.id,
    firstName: user.firstName,
    lastName: user.lastName,
    image: user.image,
    colorIndex: user.colorIndex,
  );
}

// Helper to get team summary for a mentee
TeamSummary? _getTeamSummary(String menteeId) {
  final team = mockMenteeTeamAssignments[menteeId];
  if (team == null) return null;

  return TeamSummary(
    id: team.id,
    name: team.name,
    color: team.color,
    points: team.points,
    rank: team.rank,
  );
}

// Mock mentee rankings with realistic point distributions
final List<MenteeRanking> mockMenteeRankings = [
  // High performers
  MenteeRanking(
    mentee: _userToRef(mockMentees[0]), // Jordan Lee (current user)
    team: _getTeamSummary('u_mentee_1'),
    points: 15, // 7 attendance + 8 community service events
    rank: 1,
    attendance: 7,
    communityServiceEvents: 8,
  ),
  MenteeRanking(
    mentee: _userToRef(mockMentees[3]), // Aisha Patel
    team: _getTeamSummary('u_mentee_4'),
    points: 13, // 6 attendance + 7 community service events
    rank: 2,
    attendance: 6,
    communityServiceEvents: 7,
  ),
  MenteeRanking(
    mentee: _userToRef(mockMentees[4]), // Tyler Kim
    team: _getTeamSummary('u_mentee_5'),
    points: 12, // 5 attendance + 7 community service events
    rank: 3,
    attendance: 5,
    communityServiceEvents: 7,
  ),
  MenteeRanking(
    mentee: _userToRef(mockMentees[1]), // Emma Brown
    team: _getTeamSummary('u_mentee_2'),
    points: 11, // 5 attendance + 6 community service events
    rank: 4,
    attendance: 5,
    communityServiceEvents: 6,
  ),
  MenteeRanking(
    mentee: _userToRef(mockMentees[5]), // Zoe Martinez
    team: _getTeamSummary('u_mentee_6'),
    points: 10, // 4 attendance + 6 community service events
    rank: 5,
    attendance: 4,
    communityServiceEvents: 6,
  ),

  // Mid-tier performers
  MenteeRanking(
    mentee: _userToRef(mockMentees[10]), // Noah Jackson
    team: _getTeamSummary('u_mentee_11'),
    points: 9, // 4 attendance + 5 community service events
    rank: 6,
    attendance: 4,
    communityServiceEvents: 5,
  ),
  MenteeRanking(
    mentee: _userToRef(mockMentees[2]), // Carlos Lopez
    team: _getTeamSummary('u_mentee_3'),
    points: 8, // 3 attendance + 5 community service events
    rank: 7,
    attendance: 3,
    communityServiceEvents: 5,
  ),
  MenteeRanking(
    mentee: _userToRef(mockMentees[7]), // Maya Thompson
    team: _getTeamSummary('u_mentee_8'),
    points: 7, // 3 attendance + 4 community service events
    rank: 8,
    attendance: 3,
    communityServiceEvents: 4,
  ),
  MenteeRanking(
    mentee: _userToRef(mockMentees[11]), // Isabella White
    team: _getTeamSummary('u_mentee_12'),
    points: 6, // 2 attendance + 4 community service events
    rank: 9,
    attendance: 2,
    communityServiceEvents: 4,
  ),
  MenteeRanking(
    mentee: _userToRef(mockMentees[6]), // Justin Wilson
    team: _getTeamSummary('u_mentee_7'),
    points: 5, // 2 attendance + 3 community service events
    rank: 10,
    attendance: 2,
    communityServiceEvents: 3,
  ),
];

// Mock leaderboard combining teams and mentee rankings
final Leaderboard mockLeaderboard = Leaderboard(
  teams: mockTeams, // All 4 teams
  topMentees: mockMenteeRankings, // Top 10 mentees by points
  lastUpdated: DateTime.now().subtract(const Duration(minutes: 15)),
);

// Helper function to get full leaderboard
Leaderboard getMockLeaderboard() {
  return mockLeaderboard.copyWith(
    lastUpdated: DateTime.now().subtract(
      Duration(
        minutes: Random().nextInt(30) + 5, // Random 5-35 minutes ago
      ),
    ),
  );
}
