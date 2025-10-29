import 'package:ha_mobile/business/user/entities/user.dart';
import 'package:ha_mobile/business/user/entities/user_role.dart';

final User mockMentee = User(
  id: 'u_mentee_1',
  email: 'mentee@example.com',
  firstName: 'Jordan',
  lastName: 'Lee',
  colorIndex: 8, // indigo-ish
  roles: const {UserRole.mentee},
);

final User mockMentor = User(
  id: 'u_mentor_1',
  email: 'mentor@example.com',
  firstName: 'Sam',
  lastName: 'Rivera',
  image: 'https://images.unsplash.com/photo-1502685104226-ee32379fefbe?w=400',
  colorIndex: 9, // purple-ish
  roles: const {UserRole.mentor},
);

final User mockStaff = User(
  id: 'u_staff_1',
  email: 'staff@example.com',
  firstName: 'James',
  lastName: 'Smith',
  // image: 'https://images.unsplash.com/photo-1502685104226-ee32379fefbe?w=400',
  colorIndex: 7,
  roles: const {UserRole.staff},
);

// Additional mentors for team diversity
final List<User> mockMentors = [
  mockMentor, // u_mentor_1
  User(
    id: 'u_mentor_2',
    email: 'alex.johnson@example.com',
    firstName: 'Alex',
    lastName: 'Johnson',
    image:
        'https://images.unsplash.com/photo-1527980965255-d3b416303d12?q=80&w=400&auto=format&fit=crop',
    colorIndex: 0, // red theme
    roles: const {UserRole.mentor},
  ),
  User(
    id: 'u_mentor_3',
    email: 'maria.garcia@example.com',
    firstName: 'Maria',
    lastName: 'Garcia',
    image:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=400&auto=format&fit=crop',
    colorIndex: 3, // green theme
    roles: const {UserRole.mentor},
  ),
  User(
    id: 'u_mentor_4',
    email: 'david.chen@example.com',
    firstName: 'David',
    lastName: 'Chen',
    image:
        'https://images.unsplash.com/photo-1520813792240-56fc4a3765a7?q=80&w=400&auto=format&fit=crop',
    colorIndex: 6, // blue theme
    roles: const {UserRole.mentor},
  ),
  User(
    id: 'u_mentor_5',
    email: 'sarah.wright@example.com',
    firstName: 'Sarah',
    lastName: 'Wright',
    image:
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=400&auto=format&fit=crop',
    colorIndex: 1, // yellow theme
    roles: const {UserRole.mentor},
  ),
  User(
    id: 'u_mentor_6',
    email: 'mike.davis@example.com',
    firstName: 'Mike',
    lastName: 'Davis',
    image:
        'https://images.unsplash.com/photo-1547425260-76bcadfb4f2c?q=80&w=400&auto=format&fit=crop',
    colorIndex: 2,
    roles: const {UserRole.mentor},
  ),
];

// Additional mentees for team diversity
final List<User> mockMentees = [
  mockMentee, // u_mentee_1
  User(
    id: 'u_mentee_2',
    email: 'emma.brown@example.com',
    firstName: 'Emma',
    lastName: 'Brown',
    colorIndex: 4,
    roles: const {UserRole.mentee},
  ),
  User(
    id: 'u_mentee_3',
    email: 'carlos.lopez@example.com',
    firstName: 'Carlos',
    lastName: 'Lopez',
    colorIndex: 5,
    roles: const {UserRole.mentee},
  ),
  User(
    id: 'u_mentee_4',
    email: 'aisha.patel@example.com',
    firstName: 'Aisha',
    lastName: 'Patel',
    image:
        'https://images.unsplash.com/photo-1544005314-04d1a1f5f1a0?q=80&w=400&auto=format&fit=crop',
    colorIndex: 7,
    roles: const {UserRole.mentee},
  ),
  User(
    id: 'u_mentee_5',
    email: 'tyler.kim@example.com',
    firstName: 'Tyler',
    lastName: 'Kim',
    colorIndex: 8,
    roles: const {UserRole.mentee},
  ),
  User(
    id: 'u_mentee_6',
    email: 'zoe.martinez@example.com',
    firstName: 'Zoe',
    lastName: 'Martinez',
    colorIndex: 9,
    roles: const {UserRole.mentee},
  ),
  User(
    id: 'u_mentee_7',
    email: 'justin.wilson@example.com',
    firstName: 'Justin',
    lastName: 'Wilson',
    colorIndex: 10,
    roles: const {UserRole.mentee},
  ),
  User(
    id: 'u_mentee_8',
    email: 'maya.thompson@example.com',
    firstName: 'Maya',
    lastName: 'Thompson',
    colorIndex: 11,
    roles: const {UserRole.mentee},
  ),
  User(
    id: 'u_mentee_9',
    email: 'liam.anderson@example.com',
    firstName: 'Liam',
    lastName: 'Anderson',
    colorIndex: 0,
    roles: const {UserRole.mentee},
  ),
  User(
    id: 'u_mentee_10',
    email: 'sofia.rodriguez@example.com',
    firstName: 'Sofia',
    lastName: 'Rodriguez',
    colorIndex: 1,
    roles: const {UserRole.mentee},
  ),
  User(
    id: 'u_mentee_11',
    email: 'noah.jackson@example.com',
    firstName: 'Noah',
    lastName: 'Jackson',
    colorIndex: 2,
    roles: const {UserRole.mentee},
  ),
  User(
    id: 'u_mentee_12',
    email: 'isabella.white@example.com',
    firstName: 'Isabella',
    lastName: 'White',
    colorIndex: 3,
    roles: const {UserRole.mentee},
  ),
];

// All mentors and mentees combined for easy access
final List<User> allMockMentors = mockMentors;
final List<User> allMockMentees = mockMentees;
