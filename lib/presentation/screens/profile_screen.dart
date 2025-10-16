// lib/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../../data/mock/mock_data.dart';
import '../widgets/avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _imagePath; // local file path or URL (from picker)
  int? _colorIndex; // chosen profile color

  @override
  Widget build(BuildContext context) {
    final u = mockUser;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Avatar(
              firstName: u.firstName,
              lastName: u.lastName,
              image: _imagePath ?? u.image, // use picked image or mock default
              colorIndex: _colorIndex,
              editable: true,
              onImageChanged: (path) => setState(() => _imagePath = path),
              onColorChanged: (i) => setState(() => _colorIndex = i),
              size: 96,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    u.fullName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    u.email,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text('Other profile settings coming soon…'),
      ],
    );
  }
}
