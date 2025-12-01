import 'package:flutter/foundation.dart';
import '../../business/olympic_season/entities/olympic_season.dart';
import '../../business/events/entities/event.dart';
import 'api_service.dart';

/// Service to manage Olympic Season data with caching
class OlympicSeasonService extends ChangeNotifier {
  static final OlympicSeasonService instance = OlympicSeasonService._();
  OlympicSeasonService._();

  OlympicSeason? _currentSeason;
  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetch;

  // Cache duration (5 minutes)
  static const _cacheDuration = Duration(minutes: 5);

  OlympicSeason? get currentSeason => _currentSeason;
  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _currentSeason != null;

  /// Check if cache is still valid
  bool get _isCacheValid {
    if (_lastFetch == null) return false;
    return DateTime.now().difference(_lastFetch!) < _cacheDuration;
  }

  /// Fetch current Olympic Season data (with caching)
  Future<void> fetchCurrentSeason({bool forceRefresh = false}) async {
    // Return cached data if valid and not forcing refresh
    if (!forceRefresh && _isCacheValid && _currentSeason != null) {
      if (kDebugMode) {
        print('📦 Using cached Olympic Season data');
      }
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (kDebugMode) {
        print('🔄 Fetching current Olympic Season from API...');
      }

      // Fetch current season (no input means current season)
      final season = await ApiService.instance.getOlympicSeason();

      _currentSeason = season;
      _events = season.events;
      _lastFetch = DateTime.now();
      _error = null;

      if (kDebugMode) {
        print(
          '✅ Fetched ${season.name} season with ${season.events.length} events',
        );
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('❌ Error fetching Olympic Season: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh data (forces a new fetch)
  Future<void> refresh() async {
    return fetchCurrentSeason(forceRefresh: true);
  }

  /// Clear cached data
  void clearCache() {
    _currentSeason = null;
    _events = [];
    _lastFetch = null;
    _error = null;
    notifyListeners();
  }

  /// Get the next Saturday event
  Event? getNextSaturdayEvent() {
    final now = DateTime.now();
    final saturdayEvents = _events.where((e) {
      return e.eventDate.isAfter(now) &&
          e.eventDate.weekday == DateTime.saturday;
    }).toList();

    if (saturdayEvents.isEmpty) return null;

    // Sort by date and return the nearest one
    saturdayEvents.sort((a, b) => a.eventDate.compareTo(b.eventDate));
    return saturdayEvents.first;
  }

  /// Get upcoming events (sorted by date)
  List<Event> getUpcomingEvents() {
    final now = DateTime.now();
    final upcoming = _events.where((e) => e.eventDate.isAfter(now)).toList();
    upcoming.sort((a, b) => a.eventDate.compareTo(b.eventDate));
    return upcoming;
  }
}
