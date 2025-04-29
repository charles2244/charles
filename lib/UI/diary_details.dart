import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../logic/model/diary_entry.dart'; // <-- Import your Diary model

class DiaryDetailPage extends StatelessWidget {
  final DiaryEntry diary; // <-- Corrected type here

  const DiaryDetailPage({Key? key, required this.diary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format the date
    String formattedDate = DateFormat('dd / MM / yyyy (EEE)').format(diary.createdAt);
    String formattedTime = DateFormat('h:mm a').format(diary.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: Text(diary.title ?? 'Diary Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Date Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    diary.title ?? 'Untitled',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Diary Content
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  diary.content,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
            ),

            // Time at bottom right
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                formattedTime.toLowerCase(),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
