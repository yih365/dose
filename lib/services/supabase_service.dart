import 'package:supabase_flutter/supabase_flutter.dart';
import '../models.dart';

// All DB access goes through this class. Every method requires the user to be
// signed in — Supabase RLS enforces row-level ownership server-side, so
// there's no additional filtering needed in the queries.
class SupabaseService {
  static SupabaseClient get _db => Supabase.instance.client;

  // ── Caffeine entries ──────────────────────────────────────────────────────

  static Future<List<CaffeineEntry>> fetchEntriesForDay(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end   = start.add(const Duration(days: 1));
    final rows  = await _db
        .from('caffeine_entries')
        .select()
        .gte('logged_at', start.toIso8601String())
        .lt('logged_at', end.toIso8601String())
        .order('logged_at');
    return rows.map(_rowToEntry).toList();
  }

  static Future<List<CaffeineEntry>> fetchEntriesForRange(
    DateTime start,
    DateTime end,
  ) async {
    final rows = await _db
        .from('caffeine_entries')
        .select()
        .gte('logged_at', start.toIso8601String())
        .lt('logged_at', end.toIso8601String())
        .order('logged_at');
    return rows.map(_rowToEntry).toList();
  }

  static Future<String> insertEntry(CaffeineEntry entry) async {
    final userId = _db.auth.currentUser!.id;
    final row = await _db.from('caffeine_entries').insert({
      'user_id':    userId,
      'drink_type': entry.type.name,
      'mg':         entry.mg,
      'logged_at':  entry.time.toIso8601String(),
      'source':     entry.source.toLowerCase(),
    }).select().single();
    return row['id'] as String;
  }

  static Future<void> deleteEntry(String id) async {
    await _db.from('caffeine_entries').delete().eq('id', id);
  }

  // ── User profile ──────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> fetchProfile() async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) return null;
    final rows = await _db
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return rows;
  }

  static Future<void> upsertProfile({
    int? dailyLimitMg,
    int? sleepCutoffHour,
  }) async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) return;
    await _db.from('profiles').upsert({
      'id':          userId,
      'daily_limit_mg':    dailyLimitMg,
      'sleep_cutoff_hour': sleepCutoffHour,
      'updated_at':  DateTime.now().toIso8601String(),
    });
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static CaffeineEntry _rowToEntry(Map<String, dynamic> row) {
    final type = DrinkType.values.firstWhere(
      (t) => t.name == row['drink_type'],
      orElse: () => DrinkType.custom,
    );
    return CaffeineEntry(
      id:     row['id'] as String,
      type:   type,
      mg:     row['mg'] as int,
      time:   DateTime.parse(row['logged_at'] as String).toLocal(),
      source: row['source'] as String,
    );
  }
}
