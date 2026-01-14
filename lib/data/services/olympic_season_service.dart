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
  bool get hasData => _currentSeason != null || _events.isNotEmpty;

  /// Check if cache is still valid
  bool get _isCacheValid {
    if (_lastFetch == null) return false;
    return DateTime.now().difference(_lastFetch!) < _cacheDuration;
  }

  /// Fetch current Olympic Season data with events (with caching)
  /// Uses olympicSeason query with current year filter
  Future<void> fetchCurrentSeason({bool forceRefresh = false}) async {
    // Return cached data if valid and not forcing refresh
    if (!forceRefresh && _isCacheValid && _events.isNotEmpty) {
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
        print('🔄 Fetching Olympic Season with events from API...');
      }

      // Fetch season with events (defaults to current year)
      final season = await ApiService.instance.getOlympicSeason();
      _currentSeason = season;
      _events = season.events;

      _lastFetch = DateTime.now();
      _error = null;

      if (kDebugMode) {
        print('✅ Fetched ${season.name} season with ${_events.length} events');
      }
    } catch (e) {
      _error = e.toString();
      _events = [];
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

  /// Get the next Saturday event (this Saturday or next)
  Event? getNextSaturdayEvent() {
    final now = DateTime.now();

    // Find the next Saturday (including today if it's Saturday)
    final daysUntilSaturday = (DateTime.saturday - now.weekday) % 7;
    final thisSaturday = DateTime(
      now.year,
      now.month,
      now.day + daysUntilSaturday,
    );
    final thisSaturdayYear = thisSaturday.year;
    final thisSaturdayMonth = thisSaturday.month;
    final thisSaturdayDay = thisSaturday.day;

    // Find events on this Saturday
    // Compare year, month, day directly since dates are now in local timezone
    final saturdayEvents = _events.where((e) {
      return e.eventDate.year == thisSaturdayYear &&
          e.eventDate.month == thisSaturdayMonth &&
          e.eventDate.day == thisSaturdayDay;
    }).toList();

    if (saturdayEvents.isEmpty) return null;

    // Sort by time and return the first one
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

  /// Get an event by ID (refreshed data with registration info)
  Event? getEventById(String eventId) {
    try {
      return _events.firstWhere((e) => e.id == eventId);
    } catch (_) {
      return null;
    }
  }
}
