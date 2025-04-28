class DiaryEntry {
  final String? id;
  final String? title;
  final String content;
  final String? moodTag;
  final DateTime createdAt;
  final String? userId;

  DiaryEntry({
    this.id,
    this.title,
    required this.content,
    this.moodTag,
    required this.createdAt,
    this.userId,
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
