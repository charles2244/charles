import 'dart:typed_data';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../database/drawing_service.dart';
import '../logic/model/drawing_entry.dart';
import 'drawing_board.dart';
import 'Drawing_screen2.dart';

// Change this to StatefulWidget
class DrawingScreen extends StatefulWidget {
  const DrawingScreen({super.key});

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

String _formatDate(DateTime dateTime) {
  return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
}

class _DrawingScreenState extends State<DrawingScreen> {
  List<DrawingEntry> recentDrawings = [];
  List<DrawingEntry> allDrawings = [];
  bool isLoading = true;
  bool isLoading1 = true;

  final _drawingService = DrawingService(); // Initialize service

  @override
  void initState() {
    super.initState();
    loadRecentDrawings();
    loadAllDrawings();
  }

  Future<void> loadRecentDrawings() async {
    try {
      final drawings = await _drawingService.fetchRecentDrawings(userId: '14');
      setState(() {
        recentDrawings = drawings;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading drawings: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadAllDrawings() async {
    try {
      final drawings = await _drawingService.fetchAllDrawings(userId: '14');
      setState(() {
        allDrawings = drawings;
        isLoading1 = false;
      });
    } catch (e) {
      print('Error loading drawings: $e');
      setState(() {
        isLoading1 = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEDE6FB),
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
              'Drawing',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView( // <-- Add SingleChildScrollView here
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Start fresh',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async { // <<== make it async
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MyHomePage(),
                    ),
                  );
                  // After coming back, check if user saved a drawing
                  if (result == true) {
                    loadRecentDrawings();
                    loadAllDrawings();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC7B8F5),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Blank Canvas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Recent projects',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recentDrawings.length,
                  itemBuilder: (context, index) {
                    final drawing = recentDrawings[index];
                    return Container(
                      width: 150,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(drawing.imageData),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          color: Colors.black54,
                          padding: const EdgeInsets.all(4),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                drawing.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatDate(drawing.createdAt),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'All projects',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              // Grid of drawings
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 3 / 4,
                ),
                itemCount: allDrawings.length,
                itemBuilder: (context, index) {
                  final drawing = allDrawings[index];
                  return GestureDetector(
                      onLongPress: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Drawing'),
                            content: const Text('Are you sure you want to delete this drawing?'),
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

                        if (confirm == true) {
                          try {
                            // Call the drawing_service to delete
                            await _drawingService.deleteDrawing(drawing.imageData);
                            await _drawingService.deleteDrawingEntry(drawing.id);

                            setState(() {
                              allDrawings.removeWhere((d) => d.id == drawing.id);
                              recentDrawings.removeWhere((d) => d.id == drawing.id);
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Drawing deleted successfully')),
                            );
                          } catch (error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error deleting drawing: $error')),
                            );
                          }
                        }
                      },
                      child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(drawing.imageData),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          color: Colors.black54,
                          padding: const EdgeInsets.all(4),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                drawing.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatDate(drawing.createdAt),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )

            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.art_track), label: 'Drawing'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Diary'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
