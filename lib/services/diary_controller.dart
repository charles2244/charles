import '../../database/diary_service.dart';
import 'content.dart';

class DiaryEntry implements Content {
  @override
  final String id;
  @override
  final String title;
  final String content;
  final String? moodTag;
  @override
  final DateTime createdAt;
  final int userId;

  DiaryEntry({
    required this.id,
    required this.title,
    required this.content,
    this.moodTag,
    required this.createdAt,
    required this.userId,
  });

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      moodTag: json['mood_tag'],
      createdAt: DateTime.parse(json['created_at']),
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'mood_tag': moodTag,
      // 'created_at': createdAt.toIso8601String(), // Supabase auto handles created_at
    };
  }
}

class DiaryController {
  DateTime? selectedDate = DateTime.now();

  final DiaryService _service = DiaryService();
  List<DiaryEntry> entries = [];

  // Future<void> loadEntries() async {
  //   entries = (await _service.fetchDiaryEntries()).cast<DiaryEntry>();
  // }

  void selectDate(DateTime date) {
    selectedDate = date;
  }

  List<DiaryEntry> get filteredEntries {
    if (selectedDate == null) return entries;
    return entries.where((entry) =>
    entry.createdAt.year == selectedDate!.year &&
        entry.createdAt.month == selectedDate!.month &&
        entry.createdAt.day == selectedDate!.day
    ).toList();
  }
}