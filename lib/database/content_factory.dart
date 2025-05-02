// lib/factories/content_factory.dart
import '../services/content.dart'; // Import the Content interface

abstract class ContentFactory {
  Content createContent(Map<String, dynamic> data);
}