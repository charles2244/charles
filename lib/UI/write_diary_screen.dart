// lib/UI/write_diary_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../logic/model/diary_entry.dart'; // Import your DiaryEntry model
import '../database/diary_service.dart'; // Import your DiaryService

class WriteDiaryScreen extends StatefulWidget {
  const WriteDiaryScreen({super.key});

  @override
  State<WriteDiaryScreen> createState() => _WriteDiaryScreenState();
}

class _WriteDiaryScreenState extends State<WriteDiaryScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final DiaryService _diaryService = DiaryService();

  Future<void> _saveDiaryEntry(BuildContext context) async {
    final String title = _titleController.text.trim();
    final String content = _contentController.text.trim();

    if (content.isNotEmpty) {
      // Call your DiaryService to save the data
      try {
        await _diaryService.saveDiaryEntry(title: title, content: content);
        // Optionally, show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Diary entry saved!')),
        );
        Navigator.of(context).pop(true); // Go back to the diary screen
      } catch (error) {
        // Handle any errors during saving
        print('Error saving diary entry: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save diary entry.')),
        );
      }
    } else {
      // Show an error if the content is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Diary content cannot be empty.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE6FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/backButton.png', width: 32),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('New Diary', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.black),
            onPressed: () => _saveDiaryEntry(context), // Call the save function
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Date: ${DateFormat('dd MMM yyyy – hh:mm a').format(DateTime.now())}',
                style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 16),

            TextField(
              controller: _titleController, // Attach the title controller
              decoration: const InputDecoration(
                hintText: 'Title (Optional)',
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController, // Attach the content controller
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Write your thoughts here...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}