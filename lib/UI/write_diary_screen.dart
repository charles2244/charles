// lib/UI/write_diary_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/diary_controller.dart'; // Import your DiaryEntry model
import '../database/diary_service.dart'; // Import your DiaryService
import '../services/ai_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    String title = _titleController.text.trim();
    final String content = _contentController.text.trim();
    const int maxTitleLength = 35;

    if (title.length > maxTitleLength) {
      showDialog(
          context: context,
          barrierDismissible: true, // Allow tap outside to dismiss
          builder: (context) {
            // Delay navigation back twice after 3 seconds
            Future.delayed(const Duration(seconds: 3), () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop(); // Close dialog
              }
            });

            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              backgroundColor: const Color(0xFFFBF7EF),
              // Light cream background
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Bunny image centered
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: SizedBox(
                        height: 120,
                        width: 120,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              'assets/bunnyBackground.png',
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                            ),
                            Image.asset(
                              'assets/wrongBunny.png',
                              height: 200,
                              width: 200,
                              fit: BoxFit.cover,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Success message centered
                    const Text(
                      'Title cannot exceed 35 characters including space.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4B3F3F),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          });
      return;
    }

    if (title.isEmpty) {
      title = 'Untitled';
    }
    if (content.isNotEmpty) {
      // Call your DiaryService to save the data
      try {
        final prefs = await SharedPreferences.getInstance();
        final int? userId = prefs.getInt('user_id'); // Read the saved int user_id

        if (userId == null) {
          // Handle missing user ID gracefully
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User not logged in. Please log in again.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        await _diaryService.saveDiaryEntry(title: title, content: content, userId: userId,);

        // Send content to GROQ API for emotional analysis
        final AIController aiController = AIController(
          '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',
          "meta-llama/llama-4-scout-17b-16e-instruct",
        );
        final analysisResult = await aiController.sendMessage(
          "Analyze the emotion of this text: $content" + "then give me only negative or positive word to represent overall analysis",
        );

        print('GROQ analysis raw result: $analysisResult');

        String message;
        if (analysisResult.contains('negative')) {
          message = await aiController.sendMessage(
              "Suggest relaxing activities for someone feeling negative emotions."
          );
        } else {
          message = await aiController.sendMessage(
              "Give a compliment or uplifting message for someone feeling positive emotions."
          );
        }

        // Show the message in a dialog
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Emotion Analysis Result'),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );

        Navigator.of(context).pop(true); // Go back to the diary screen

        showDialog(
            context: context,
            barrierDismissible: true, // Allow tap outside to dismiss
            builder: (context) {
              // Delay navigation back twice after 3 seconds
              Future.delayed(const Duration(seconds: 3), () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop(); // Close dialog
                }
              });

              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                backgroundColor: const Color(0xFFFBF7EF),
                // Light cream background
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Bunny image centered
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: SizedBox(
                          height: 120,
                          width: 120,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'assets/bunnyBackground.png',
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                              ),
                              Image.asset(
                                'assets/happyBunny.gif',
                                height: 200,
                                width: 200,
                                fit: BoxFit.cover,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Success message centered
                      const Text(
                        'Diary successfully saved!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4B3F3F),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            });
      } catch (error) {
        // Handle any errors during saving
        print('Error saving diary entry: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save diary entry.')),
        );
      }
    } else {
      // Show an error if the content is empty
      showDialog(
          context: context,
          barrierDismissible: true, // Allow tap outside to dismiss
          builder: (context) {
            // Delay navigation back twice after 3 seconds
            Future.delayed(const Duration(seconds: 3), () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop(); // Close dialog
              }
            });

            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              backgroundColor: const Color(0xFFFBF7EF),
              // Light cream background
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Bunny image centered
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: SizedBox(
                        height: 120,
                        width: 120,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              'assets/bunnyBackground.png',
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                            ),
                            Image.asset(
                              'assets/wrongBunny.png',
                              height: 200,
                              width: 200,
                              fit: BoxFit.cover,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Success message centered
                    const Text(
                      'Diary content cannot be empty.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4B3F3F),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF7EF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/backButton.png', width: 32),
          onPressed: () => _handleBackPressed(context),
        ),
        title: const Text('New Diary', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.w600)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.check, color: Color(0xFF706A6A), size: 30),
              onPressed: () => _saveDiaryEntry(context),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Date: ${DateFormat('dd MMM yyyy – hh:mm a').format(DateTime.now())}',
                style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 20),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                child: TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Title (Optional)',
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF4B3F3F)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded( // Wrap TextField with Expanded inside SingleChildScrollView
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _contentController,
                    maxLines: null,
                    expands: true,
                    decoration: const InputDecoration(
                      hintText: 'Write your thoughts here...',
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                    textAlignVertical: TextAlignVertical.top, // Align text to the top
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleBackPressed(BuildContext context) async {
    if (_titleController.text.trim().isNotEmpty || _contentController.text.trim().isNotEmpty) {
      final confirm = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFFFBF7EF),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bunny and message row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bunny image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: SizedBox(
                        height: 100,
                        width: 100,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              'assets/bunnyBackground.png',
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                            Image.asset(
                              'assets/bunnyQuestionMark.gif',
                              height: 75,
                              width: 75,
                              fit: BoxFit.cover,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Message
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Discard changes?',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4B3F3F),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'You have unsaved changes. Are you sure you want to discard them?',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF4B3F3F),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF975EE0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF975EE0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('Discard'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      if (confirm == true) {
        Navigator.of(context).pop(); // Go back if confirmed
      }
    } else {
      Navigator.of(context).pop(); // Go back directly
    }
  }
}