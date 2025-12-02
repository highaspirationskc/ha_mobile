// lib/features/mentees/mentees_list_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../business/user/entities/user.dart';
import '../../core/session.dart';
import '../../data/services/api_service.dart';
import 'widgets/mentee_call_tile.dart';
import 'mentee_screen.dart';

class MenteesListScreen extends StatefulWidget {
  const MenteesListScreen({super.key});

  @override
  State<MenteesListScreen> createState() => _MenteesListScreenState();
}

class _MenteesListScreenState extends State<MenteesListScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<User> _mentees = [];
  List<FamilyMember> _familyMembers = [];

  @override
  void initState() {
    super.initState();
    _loadMentees();
  }

  Future<void> _loadMentees() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userKind = currentUserKind.value;
      final isParent = userKind == CurrentUserKind.parent;

      if (kDebugMode) {
        print(
          '👥 Loading ${isParent ? "children" : "mentees"} for current authenticated ${userKind.name}',
        );
        print('   Authenticated: ${isAuthenticated ? "Yes" : "No"}');
      }

      // Fetch mentees or children based on user role
      final List<User> mentees;
      final List<FamilyMember> familyMembers;

      if (isParent) {
        mentees = await ApiService.instance.getChildrenByParent(
          parentId: currentUserId,
        );
        // Also fetch family members for the parent's children
        familyMembers = await ApiService.instance.getFamilyMembersForChildren(
          parentId: currentUserId,
        );
      } else {
        mentees = await ApiService.instance.getMenteesByMentor(
          mentorId: currentUserId,
        );
        familyMembers = [];
      }

      if (kDebugMode) {
        print(
          '✅ Loaded ${mentees.length} ${isParent ? "children" : "mentees"}',
        );
        for (final mentee in mentees) {
          print(
            '   - ${mentee.firstName} ${mentee.lastName} (${mentee.email})',
          );
        }
        if (isParent && familyMembers.isNotEmpty) {
          print('✅ Loaded ${familyMembers.length} family members');
          for (final fm in familyMembers) {
            print(
              '   - ${fm.user.displayName} (${fm.relationshipType}) -> ${fm.relatedUser.displayName}',
            );
          }
        }
      }

      setState(() {
        _mentees = mentees;
        _familyMembers = familyMembers;
        _isLoading = false;
      });

      // Auto-navigate if there's only one mentee/child
      if (mentees.length == 1 && mounted) {
        if (kDebugMode) {
          print(
            'ℹ️ Only one ${isParent ? "child" : "mentee"}, auto-navigating to detail screen',
          );
        }
        // Use addPostFrameCallback to ensure navigation happens after build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => MenteeScreen(mentee: mentees[0]),
              ),
            );
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading mentees: $e');
      }
      setState(() {
        _errorMessage = 'Failed to load: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: cs.error),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: t.bodyLarge?.copyWith(color: cs.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadMentees,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_mentees.isEmpty && _familyMembers.isEmpty) {
      final isParent = currentUserKind.value == CurrentUserKind.parent;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: cs.outline),
            const SizedBox(height: 16),
            Text(
              isParent ? 'No children found' : 'No mentees assigned yet',
              style: t.titleLarge?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              isParent
                  ? 'Your children will appear here once they are added to the system'
                  : 'Mentees will appear here once they are assigned to you',
              style: t.bodyMedium?.copyWith(color: cs.outline),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final isParent = currentUserKind.value == CurrentUserKind.parent;

    return RefreshIndicator(
      onRefresh: _loadMentees,
      child: ListView.builder(
        padding: const EdgeInsets.only(
          top: 8,
          bottom: 100, // Space for floating nav bar
        ),
        itemCount: _mentees.length + (isParent ? 1 : 0),
        itemBuilder: (context, index) {
          // Show mentees/children first
          if (index < _mentees.length) {
            final mentee = _mentees[index];
            return Column(
              children: [
                MenteeCallTile(
                  mentee: mentee,
                  onTap: () {
                    // Navigate to mentee detail screen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MenteeScreen(mentee: mentee),
                      ),
                    );
                  },
                ),
                if (index < _mentees.length - 1 || _familyMembers.isNotEmpty)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 72,
                    color: cs.outlineVariant.withOpacity(0.3),
                  ),
              ],
            );
          }

          // Show family members section for parents
          if (isParent && _familyMembers.isNotEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    'Family Members',
                    style: t.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: cs.outlineVariant.withOpacity(0.5),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _familyMembers.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    thickness: 1,
                    indent: 72,
                    color: cs.outlineVariant.withOpacity(0.3),
                  ),
                  itemBuilder: (_, i) {
                    final familyMember = _familyMembers[i];
                    return _FamilyMemberTile(
                      familyMember: familyMember,
                      onTap: () {
                        // Navigate to family member's user detail screen
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                MenteeScreen(mentee: familyMember.user),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

/// Widget to display a family member in the list
class _FamilyMemberTile extends StatelessWidget {
  final FamilyMember familyMember;
  final VoidCallback? onTap;

  const _FamilyMemberTile({required this.familyMember, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    // Display the family member (user who has the relationship)
    final displayUser = familyMember.user;
    final relatedUser = familyMember.relatedUser;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: cs.primaryContainer,
              backgroundImage: displayUser.image != null
                  ? NetworkImage(displayUser.image!)
                  : null,
              child: displayUser.image == null
                  ? Text(
                      displayUser.displayName.isNotEmpty
                          ? displayUser.displayName[0].toUpperCase()
                          : '?',
                      style: t.titleLarge?.copyWith(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),

            // Name and relationship info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayUser.displayName,
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.family_restroom, size: 16, color: cs.outline),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${familyMember.relationshipType} of ${relatedUser.displayName}',
                          style: t.bodySmall?.copyWith(color: cs.outline),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Navigation arrow
            Icon(Icons.chevron_right, color: cs.outline),
          ],
        ),
      ),
    );
  }
}
