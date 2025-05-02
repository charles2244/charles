import '../services/drawing_controller.dart';
import '../services/content.dart';
import 'content_factory.dart'; // Import the ContentFactory interface

class DrawingFactory implements ContentFactory {
  @override
  Content createContent(Map<String, dynamic> data) {
    // You might need to adjust this based on how drawing data is structured
    return DrawingEntry(
      id: data['id'],
      title: data['title'],
      imageData: data['image_data'],
      canvasSize: data['canvas_size'],
      createdAt: DateTime.parse(data['created_at']),
      userId: data['user_id'],
    );
  }
}