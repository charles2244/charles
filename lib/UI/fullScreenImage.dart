import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImagePage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer( // allow zoom/pan
          child: Center( // <--- this Center makes it vertically centered
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain, // important to keep the aspect ratio
            ),
          ),
        ),
      ),
    );
  }
}
