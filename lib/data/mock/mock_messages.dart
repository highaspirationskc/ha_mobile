import 'package:ha_mobile/business/messages/entities/message.dart';
import 'mock_users.dart';

final List<Message> mockMessages = [
  // TODAY'S MESSAGES (5 messages)
  // Message(
  //   id: 'msg_1',
  //   subject: 'Quick Check-in',
  //   message:
  //       'Just wanted to check in and see how your day is going. Any questions about the project we discussed yesterday?',
  //   author: mockMentor,
  //   createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  //   read: true,
  // ),

  // Message(
  //   id: 'msg_2',
  //   subject: 'Program Update',
  //   message:
  //       'We\'re excited to announce some new features in our mentoring platform! You can now track your progress and set reminders.',
  //   author: mockStaff,
  //   createdAt: DateTime.now().subtract(const Duration(hours: 4)),
  //   read: false,
  // ),

  // Message(
  //   id: 'msg_3',
  //   subject: 'Meeting Confirmation',
  //   message:
  //       'Confirming our meeting tomorrow at 2 PM. I\'ve prepared some materials that I think will be really helpful for your goals.',
  //   author: mockMentor,
  //   createdAt: DateTime.now().subtract(const Duration(hours: 6)),
  //   read: true,
  // ),

  // Message(
  //   id: 'msg_4',
  //   subject: 'Workshop Reminder',
  //   message:
  //       'Don\'t forget about the time management workshop this evening at 6 PM. It\'s going to be really valuable for your productivity.',
  //   author: mockStaff,
  //   createdAt: DateTime.now().subtract(const Duration(hours: 8)),
  //   read: false,
  // ),

  // Message(
  //   id: 'msg_5',
  //   subject: 'Great Work Today!',
  //   message:
  //       'I saw your latest assignment submission and I\'m really impressed with the improvement. Your attention to detail has really grown.',
  //   author: mockMentor,
  //   createdAt: DateTime.now().subtract(const Duration(hours: 10)),
  //   read: true,
  // ),

  // // YESTERDAY'S MESSAGES (8 messages)
  // Message(
  //   id: 'msg_6',
  //   subject: 'Resource Recommendation',
  //   message:
  //       'I found this great online course that I think would be perfect for your learning goals. Check out the link I sent.',
  //   author: mockMentor,
  //   createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
  //   read: true,
  // ),

  // Message(
  //   id: 'msg_7',
  //   subject: 'Community Service Project',
  //   message:
  //       'Join us for our monthly community service project this Saturday. We\'ll be working with local organizations to make a positive impact.',
  //   author: mockStaff,
  //   createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
  //   read: false,
  // ),

  // Message(
  //   id: 'msg_8',
  //   subject: 'Study Tips',
  //   message:
  //       'Here are some effective study techniques I\'ve seen work well: 1) Pomodoro technique for focus, 2) Active recall for retention.',
  //   author: mockMentor,
  //   createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
  //   read: true,
  // ),

  // Message(
  //   id: 'msg_9',
  //   subject: 'Scholarship Opportunities',
  //   message:
  //       'Several new scholarship opportunities have been added to our database. These are specifically for students in our program.',
  //   author: mockStaff,
  //   createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
  //   read: false,
  // ),

  // Message(
  //   id: 'msg_10',
  //   subject: 'Career Guidance',
  //   message:
  //       'Based on our conversations about your interests, I think you\'d excel in STEM fields. Let\'s explore some career paths.',
  //   author: mockMentor,
  //   createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 10)),
  //   read: true,
  // ),

  // Message(
  //   id: 'msg_11',
  //   subject: 'Academic Support Resources',
  //   message:
  //       'Struggling with a particular subject? We\'ve expanded our academic support resources including tutoring and study groups.',
  //   author: mockStaff,
  //   createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 12)),
  //   read: false,
  // ),

  // Message(
  //   id: 'msg_12',
  //   subject: 'Networking Opportunity',
  //   message:
  //       'There\'s a networking event next week that I think would be perfect for you. It\'s focused on young professionals in tech.',
  //   author: mockMentor,
  //   createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 14)),
  //   read: true,
  // ),

  // Message(
  //   id: 'msg_13',
  //   subject: 'Technology Support',
  //   message:
  //       'Having trouble with the app or online platform? Our tech support team is available Monday-Friday, 9 AM - 5 PM.',
  //   author: mockStaff,
  //   createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 16)),
  //   read: false,
  // ),

  // // LAST WEEK'S MESSAGES (12 messages)
  // Message(
  //   id: 'msg_14',
  //   subject: 'Welcome to the Program!',
  //   message:
  //       'Welcome to our mentoring program! I\'m excited to work with you and help you achieve your goals.',
  //   author: mockMentor,
  //   createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
  //   read: true,
  // ),

  // Message(
  //   id: 'msg_15',
  //   subject: 'Important Policy Changes',
  //   message:
  //       'Please review the updated program policies that will take effect next month. Key changes include new meeting requirements.',
  //   author: mockStaff,
  //   createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
  //   read: false,
  // ),

  // Message(
  //   id: 'msg_16',
  //   subject: 'Great Progress This Week',
  //   message:
  //       'I wanted to congratulate you on the excellent work you\'ve done this week. Your dedication is really paying off!',
  //   author: mockMentor,
  //   createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
  //   read: true,
  // ),

  // Message(
  //   id: 'msg_17',
  //   subject: 'Survey Request',
  //   message:
  //       'Your feedback is important to us! Please take 5 minutes to complete our quarterly survey about your mentoring experience.',
  //   author: mockStaff,
  //   createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 4)),
  //   read: false,
  // ),

  // Message(
  //   id: 'msg_18',
  //   subject: 'Goal Setting Session',
  //   message:
  //       'Let\'s set some specific, measurable goals for the next quarter. I\'d like to hear your thoughts on what you want to achieve.',
  //   author: mockMentor,
  //   createdAt: DateTime.now().subtract(const Duration(days: 4, hours: 1)),
  //   read: true,
  // ),

  // Message(
  //   id: 'msg_19',
  //   subject: 'Workshop Schedule',
  //   message:
  //       'Check out our updated workshop schedule for February! We\'ve added new sessions on financial literacy and career exploration.',
  //   author: mockStaff,
  //   createdAt: DateTime.now().subtract(const Duration(days: 4, hours: 3)),
  //   read: false,
  // ),

  // Message(
  //   id: 'msg_20',
  //   subject: 'Feedback on Project',
  //   message:
  //       'I reviewed your latest project submission and I\'m impressed with the creativity and attention to detail.',
  //   author: mockMentor,
  //   createdAt: DateTime.now().subtract(const Duration(days: 5, hours: 2)),
  //   read: true,
  // ),

  // Message(
  //   id: 'msg_21',
  //   subject: 'Mental Health Resources',
  //   message:
  //       'Your mental health and wellbeing are our priority. We\'ve partnered with local counselors to provide free, confidential support.',
  //   author: mockStaff,
  //   createdAt: DateTime.now().subtract(const Duration(days: 5, hours: 4)),
  //   read: false,
  // ),

  // Message(
  //   id: 'msg_22',
  //   subject: 'Leadership Development',
  //   message:
  //       'I\'ve noticed your natural leadership abilities. Let\'s explore ways to develop these skills further through volunteer opportunities.',
  //   author: mockMentor,
  //   createdAt: DateTime.now().subtract(const Duration(days: 6, hours: 1)),
  //   read: true,
  // ),

  // Message(
  //   id: 'msg_23',
  //   subject: 'Parent Communication',
  //   message:
  //       'We\'re implementing a new parent communication system to keep families better informed about their student\'s progress.',
  //   author: mockStaff,
  //   createdAt: DateTime.now().subtract(const Duration(days: 6, hours: 3)),
  //   read: false,
  // ),

  // Message(
  //   id: 'msg_24',
  //   subject: 'Summer Internship Opportunities',
  //   message:
  //       'I\'ve compiled a list of summer internship opportunities that match your interests and skill level.',
  //   author: mockMentor,
  //   createdAt: DateTime.now().subtract(const Duration(days: 7, hours: 2)),
  //   read: true,
  // ),

  // Message(
  //   id: 'msg_25',
  //   subject: 'Program Statistics',
  //   message:
  //       'Great news! Our program participants have shown a 25% improvement in academic performance this semester.',
  //   author: mockStaff,
  //   createdAt: DateTime.now().subtract(const Duration(days: 7, hours: 4)),
  //   read: false,
  // ),
];
