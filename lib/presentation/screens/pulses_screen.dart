// lib/presentation/screens/pulses_screen.dart
import 'package:flutter/material.dart';
import '../../business/pulse/entities/pulse.dart';
import '../../core/session.dart';
import '../../data/services/api_service.dart';
import '../widgets/list_tile_pulse.dart';

class PulsesScreen extends StatefulWidget {
  const PulsesScreen({super.key});

  @override
  State<PulsesScreen> createState() => _PulsesScreenState();
}

class _PulsesScreenState extends State<PulsesScreen> {
  List<Pulse> _pulses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPulses();
    // Listen to API service changes to update pulses when new ones are added
    ApiService.instance.changes.addListener(_onApiChanges);
  }

  @override
  void dispose() {
    ApiService.instance.changes.removeListener(_onApiChanges);
    super.dispose();
  }

  void _onApiChanges() {
    _loadPulses();
  }

  Future<void> _loadPulses() async {
    try {
      final pulses = await ApiService.instance.getPulses(userId: currentUserId);
      if (mounted) {
        setState(() {
          _pulses = pulses;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: cs.primary))
          : _pulses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_outline,
                    size: 64,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No pulses yet',
                    style: t.headlineSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Share your first pulse to get started',
                    style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Summary Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: cs.shadow.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(
                          Icons.favorite,
                          color: cs.onPrimaryContainer,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_pulses.length}',
                              style: t.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                            ),
                            Text(
                              'Total Pulses',
                              style: t.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_pulses.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${_pulses.map((p) => p.rating).reduce((a, b) => a + b) / _pulses.length}',
                              style: t.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.primary,
                              ),
                            ),
                            Text(
                              'Avg Rating',
                              style: t.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                // Pulses List
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _pulses.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final pulse = _pulses[index];
                      return ListTilePulse(pulse: pulse);
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
