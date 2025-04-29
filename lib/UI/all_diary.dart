import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/diary_service.dart';
import '../logic/model/diary_entry.dart';
import 'diary_details.dart';

class AllDiary extends StatefulWidget {
  const AllDiary({super.key});

  @override
  State<AllDiary> createState() => _AllDiaryState();
}

class _AllDiaryState extends State<AllDiary> {
  List<DiaryEntry> allDiaries = [];
  bool isLoading = true;

  final DiaryService _diaryService = DiaryService();

  @override
  void initState() {
    super.initState();
    loadAllDiaries();
  }

  // Load diaries from the service
  Future<void> loadAllDiaries() async {
    try {
      final diaries = await _diaryService.fetchAllDiary(userId: '14');
      setState(() {
        allDiaries = diaries;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading diaries: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF7EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF7EF),
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/backButton.png', width: 32),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 30.0), // Add right padding to the left image
              child: Image.asset(
                'assets/faceRightRabbit.png',
                width: 50,
                height: 50,
              ),
            ),
            const Text(
              'All Diaries',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.purple),
            ),
            Padding(
              padding: EdgeInsets.only(left: 30.0), // Add left padding to the right image
              child: Image.asset(
                'assets/faceLeftRabbit.png',
                width: 50,
                height: 50,
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : allDiaries.isEmpty
          ? const Center(child: Text('No diaries found.'))
          : ListView.builder(
        itemCount: allDiaries.length,
        itemBuilder: (context, index) {
          final diary = allDiaries[index];

          final dateFormatted = DateFormat('dd / MM / yyyy (EEE)').format(diary.createdAt);
          final timeFormatted = DateFormat('h:mm a').format(diary.createdAt);

          return GestureDetector(
            onLongPress: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Diary'),
                  content: const Text('Are you sure you want to delete this diary?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              // Inside your AllDiary widget
              if (confirm == true) {
                try {
                  // Call the diary_service to delete
                  if (diary.id != null) {
                    await _diaryService.deleteDiaryEntry(diary.id!);
                  } else {
                    // Handle the case where diary.id is null
                    print('Diary ID is null');
                  }

                  // Remove the diary entry from the list
                  setState(() {
                    allDiaries.removeWhere((d) => d.id == diary.id);
                  });

                  // Show a success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Diary deleted successfully')),
                  );
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting diary: $error')),
                  );
                }
              }
            },
            onTap: () {
              // Navigate to diary detail page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DiaryDetailPage(diary: diary),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Date Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          diary.title ?? 'Untitled',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          dateFormatted,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Content preview
                    Text(
                      diary.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),

                    // Time bottom right
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        timeFormatted.toLowerCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 50),
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF975EE0), // Solid purple
          borderRadius: BorderRadius.circular(40), // Smooth rounded "pill" shape
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/home');
              },
              child: Image.asset(
                'assets/homeIcon.png',
                width: 30,
                height: 30,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/gift');
              },
              child: Image.asset(
                'assets/RewardsIcon.png',
                width: 30,
                height: 30,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/target');
              },
              child: Image.asset(
                'assets/GoalsIcon.png',
                width: 30,
                height: 30,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
              child: Image.asset(
                'assets/ProfileIcon.png',
                width: 30,
                height: 30,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
