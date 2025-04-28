import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/diary_service.dart';
import 'all_diary.dart';
import 'calendar_widget.dart';
import '../logic/controller/diary_controller.dart' hide DiaryEntry;
import 'diary_details.dart';
import 'write_diary_screen.dart';
import '../logic/model/diary_entry.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final DiaryController controller = DiaryController();
  final DiaryService _diaryService = DiaryService();
  List<DiaryEntry> filteredEntries = [];
  bool isLoading = true;

  bool isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  void initState() {
    super.initState();
    loadFilteredDDiary();
  }

  Future<void> loadFilteredDDiary() async {
    try {
      final drawings = await _diaryService.fetchDiaryByDate(userId: '14', selectedDate: DateTime.now());
      setState(() {
        filteredEntries = drawings;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading drawings: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _fetchDiaries(String userId, DateTime selectedDate) async {
    final diaries = await _diaryService.fetchDiaryByDate(userId: userId, selectedDate: selectedDate);
    setState(() {
      filteredEntries = diaries;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedMonth = controller.selectedDate != null
        ? DateFormat('MMMM').format(controller.selectedDate!).toUpperCase()
        : 'All Entries';

    // Assuming you have a user ID stored
    final userId = '14'; // Replace this with the actual user ID, which can be retrieved from your authentication service

    return Scaffold(
      backgroundColor: const Color(0xFFEDE6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEDE6FB),
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/backButton.png', width: 32),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () async { // <<== make it async
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const WriteDiaryScreen(),
                ),
              );
              // After coming back, check if user saved a drawing
              if (result == true) {
                loadFilteredDDiary();
              }
            },
          )
        ],
        centerTitle: true,
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/faceRightRabbit.png', width: 50),
                const Text(
                  'Diary',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.purple),
                ),
                Image.asset('assets/faceLeftRabbit.png', width: 50),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          CalendarWidget(
            selectedDate: controller.selectedDate ?? DateTime.now(),
            onDateSelected: (date) {
              setState(() {
                controller.selectDate(date); // Filter by day
              });
              // Fetch filtered diaries when a date is selected
              _fetchDiaries(userId, date); // Pass userId and date to filter
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedMonth,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AllDiary()),
                    );
                  },
                  child: const Text('View all', style: TextStyle(color: Colors.purple)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filteredEntries.length,
              itemBuilder: (context, index) {
                final entry = filteredEntries[index];
                return GestureDetector( // Wrap the Container with a GestureDetector
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
                          if (entry.id != null) {
                            await _diaryService.deleteDiaryEntry(entry.id!);
                          } else {
                            // Handle the case where diary.id is null
                            print('Diary ID is null');
                          }

                          // Remove the diary entry from the list
                          setState(() {
                            filteredEntries.removeWhere((d) => d.id == entry.id);
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiaryDetailPage(diary: entry), // Navigate to detail page
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (entry.title != null) ...[
                            Text(
                              entry.title!, // Display title
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 8), // Add some space
                          ],
                          Text(
                            DateFormat('dd / MM / yyyy (EEE)').format(entry.createdAt), // Date format
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),

                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        entry.content,
                        style: const TextStyle(fontSize: 14, color: Colors.black),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              DateFormat('h:mm a').format(entry.createdAt), // Time
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ]
                      )
                    ],
                  ),
                ));
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.purple,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: "Gift"),
          BottomNavigationBarItem(icon: Icon(Icons.bolt), label: "Goals"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
