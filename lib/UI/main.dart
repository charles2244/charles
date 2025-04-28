import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zenzone2/UI/diary_screen.dart';
import 'package:zenzone2/UI/drawing_screen.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://qnvoajikwadxpgertimm.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFudm9hamlrd2FkeHBnZXJ0aW1tIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUzNzQ3NDAsImV4cCI6MjA2MDk1MDc0MH0.l_20rtGh4ZOLXNkVBLhhdKy3TSQBTt3ugosmi8XFigI',
  );
  runApp(ReliefMoodApp());
}

class ReliefMoodApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Relief ',
      theme: ThemeData(fontFamily: 'Arial'),
      home: ReliefMoodHome(),
    );
  }
}

class ReliefMoodHome extends StatelessWidget {
  final Color softPurple = Color(0xFFCCB6F8);
  final Color lightPurple = Color(0xFFEDE6FB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightPurple,
      appBar: AppBar(
        backgroundColor: lightPurple,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            'assets/backButton.png', // 👈 Your custom image
            width: 32,
            height: 32,
          ),
          onPressed: () {
            // Navigator.of(context).pop(); // 👈 Navigate back
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset("assets/faceRightRabbit.png", width: 80),
                Text(
                  "Relief\nMood",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                Image.asset("assets/faceLeftRabbit.png", width: 80),
              ],
            ),
            SizedBox(height: 30),
            OptionTile(
              leading: Image.asset("assets/writeDiary.png", width: 52, height: 52),
              text: "Diary",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DiaryScreen(), // Replace with your class name
                  ),
                );
              },
            ),
            SizedBox(height: 30),
            OptionTile(
              leading: Image.asset("assets/drawing.png", width: 45, height: 45),
              text: "Drawing",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DrawingScreen(), // Replace with your class name
                  ),
                );
              },
            ),
            SizedBox(height: 30),
            OptionTile(
              leading: Image.asset("assets/AIbot.png", width: 48, height: 48),
              text: "Chat with AI",
              onTap: () {},
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.purple,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: "Gift"),
          BottomNavigationBarItem(icon: Icon(Icons.bolt), label: "Goals"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class OptionTile extends StatelessWidget {
  final Widget leading; // Now accepts either Icon or Image
  final String text;
  final VoidCallback onTap;

  const OptionTile({
    required this.leading,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: Color(0xFFD2CCF8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            leading,
            SizedBox(width: 16),
            Text(
              text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}