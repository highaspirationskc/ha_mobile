import '../../business/teams/entities/team.dart';
import '../../business/user/entities/user_refs.dart';
import '../../business/user/entities/user_base.dart';
import 'mock_users.dart';

// Helper function to create UserRef from User
UserRef _userToRef(User user) {
  return UserRef(
    id: user.id,
    firstName: user.firstName,
    lastName: user.lastName,
    image: user.image,
    colorIndex: user.colorIndex,
  );
}

// Mock Teams - one for each color
final List<Team> mockTeams = [
  // Red Team - Fire Dragons
  // Team(
  //   id: 'team_red',
  //   name: 'Fire Dragons',
  //   color: TeamColor.red,
  //   mentors: [
  //     _userToRef(mockMentors[1]), // Alex Johnson
  //     _userToRef(mockMentors[5]), // Mike Davis
  //   ],
  //   rank: 1,
  //   points: 285,
  //   mentorCount: 2,
  //   menteeCount: 8,
  // ),

  // // Green Team - Forest Hawks
  // Team(
  //   id: 'team_green',
  //   name: 'Forest Hawks',
  //   color: TeamColor.green,
  //   mentors: [
  //     _userToRef(mockMentors[2]), // Maria Garcia
  //   ],
  //   rank: 3,
  //   points: 210,
  //   mentorCount: 1,
  //   menteeCount: 6,
  // ),

  // // Blue Team - Ocean Wolves
  // Team(
  //   id: 'team_blue',
  //   name: 'Ocean Wolves',
  //   color: TeamColor.blue,
  //   mentors: [
  //     _userToRef(mockMentors[3]), // David Chen
  //     _userToRef(mockMentors[0]), // Sam Rivera (original mentor)
  //   ],
  //   rank: 2,
  //   points: 245,
  //   mentorCount: 2,
  //   menteeCount: 7,
  // ),

  // // Yellow Team - Lightning Eagles
  // Team(
  //   id: 'team_yellow',
  //   name: 'Lightning Eagles',
  //   color: TeamColor.yellow,
  //   mentors: [
  //     _userToRef(mockMentors[4]), // Sarah Wright
  //   ],
  //   rank: 4,
  //   points: 175,
  //   mentorCount: 1,
  //   menteeCount: 5,
  // ),
];

// Quick lookup by team id
final Map<String, Team> mockTeamsById = {
  for (final team in mockTeams) team.id: team,
};

// Quick lookup by team color
final Map<TeamColor, Team> mockTeamsByColor = {
  for (final team in mockTeams) team.color: team,
};

// Team assignments for mentees (mapping mentee id to team)
final Map<String, Team> mockMenteeTeamAssignments = {
  // Red Team mentees
  'u_mentee_2': mockTeamsById['team_red']!, // Emma Brown
  'u_mentee_3': mockTeamsById['team_red']!, // Carlos Lopez
  'u_mentee_9': mockTeamsById['team_red']!, // Liam Anderson
  'u_mentee_10': mockTeamsById['team_red']!, // Sofia Rodriguez
  // Green Team mentees
  'u_mentee_4': mockTeamsById['team_green']!, // Aisha Patel
  'u_mentee_11': mockTeamsById['team_green']!, // Noah Jackson
  'u_mentee_12': mockTeamsById['team_green']!, // Isabella White
  // Blue Team mentees
  'u_mentee_1': mockTeamsById['team_blue']!, // Jordan Lee (original mentee)
  'u_mentee_5': mockTeamsById['team_blue']!, // Tyler Kim
  'u_mentee_6': mockTeamsById['team_blue']!, // Zoe Martinez
  // Yellow Team mentees
  'u_mentee_7': mockTeamsById['team_yellow']!, // Justin Wilson
  'u_mentee_8': mockTeamsById['team_yellow']!, // Maya Thompson
};

// Helper function to get team by mentee id
Team? getTeamByMenteeId(String menteeId) {
  return mockMenteeTeamAssignments[menteeId];
}

// Helper function to get team by mentor id
Team? getTeamByMentorId(String mentorId) {
  for (final team in mockTeams) {
    if (team.mentors.any((mentor) => mentor.id == mentorId)) {
      return team;
    }
  }
  return null;
}
