import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../logic/model/diary_entry.dart';
import '../../UI/Drawing_screen2.dart';

class DiaryService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final GoTrueClient _authClient = Supabase.instance.client.auth;
  final SupabaseStorageClient _storageClient = Supabase.instance.client.storage;

  Future<List<Map<String, dynamic>>> getDiaryEntries() async {
    final List<dynamic> data = await _supabaseClient
        .from('diary') // Replace with your actual table name
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> saveDiaryEntry({String? title, required String content}) async {
    try {
      final user = '14';
      if (user == null) {
        throw Exception("User not authenticated");
      }

      final response = await _supabaseClient
          .from('content')
          .insert({
        'title': title,
        'user_id': user, // Include user_id here
      })
          .select('id')
          .single();

      final contentId = response['id'];

      await _supabaseClient
          .from('diary')
          .insert({
        'id': contentId,
        'content': content,
      });
    } catch (error) {
      print('Error saving diary entry to Supabase: $error');
      throw error;
    }
  }

  final _client = Supabase.instance.client;

  Future<List<DiaryEntry>> fetchAllDiary({required String userId}) async {
    try {
      final response = await _supabaseClient
          .from('content')
          .select('id, title, created_at, diary(content, mood_tag)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (response == null || response is! List) {
        throw Exception('Failed to fetch diaries');
      }

      return (response as List<dynamic>).where((data) {
        return data['diary'] != null; // only take diary type
      }).map((data) {
        final diaryData = data['diary'];

        final content = diaryData?['content'] ?? '';
        final mood = diaryData?['mood_tag'] ?? '';

        return DiaryEntry(
          id: data['id'].toString(),
          title: data['title'] ?? 'Untitled',
          createdAt: DateTime.parse(data['created_at']),
          content: content,
          moodTag: mood,
        );
      }).toList();
    } catch (error, stackTrace) {
      print('Error fetching diaries: $error\n$stackTrace');
      return [];
    }
  }

  Future<List<DiaryEntry>> fetchDiaryByDate({
    required String userId,
    required DateTime selectedDate,
  }) async {
    try {
      // Format the selectedDate to get the start of the day and end of the day
      final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabaseClient
          .from('content')
          .select('id, title, created_at, diary(content, mood_tag)')
          .eq('user_id', userId)
          .gte('created_at', startOfDay.toIso8601String()) // Greater than or equal to start of the day
          .lt('created_at', endOfDay.toIso8601String())  // Less than the end of the day
          .order('created_at', ascending: false);

      if (response == null || response is! List) {
        throw Exception('Failed to fetch diaries');
      }

      return (response as List<dynamic>).where((data) {
        return data['diary'] != null; // only take diary type
      }).map((data) {
        final diaryData = data['diary'];
        final content = diaryData?['content'] ?? '';
        final mood = diaryData?['mood_tag'] ?? '';

        return DiaryEntry(
          id: data['id'].toString(),
          title: data['title'] ?? 'Untitled',
          createdAt: DateTime.parse(data['created_at']),
          content: content,
          moodTag: mood,
        );
      }).toList();
    } catch (error, stackTrace) {
      print('Error fetching diaries: $error\n$stackTrace');
      return [];
    }
  }

  Future<void> deleteDiaryEntry(String diaryId) async {
    try {
      await _supabaseClient.from('diary').delete().eq('id', diaryId);
      await _supabaseClient.from('content').delete().eq('id', diaryId);
      print('Driary entry deleted from database. ID: $diaryId');
    } catch (error) {
      print('Error deleting diary entry from database: $error');
      throw error; // Re-throw to be handled in the UI
    }
  }
}
