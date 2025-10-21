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
