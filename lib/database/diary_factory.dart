import '../../services/content.dart';
import '../../services/diary_controller.dart';
import 'content_factory.dart'; // Import the ContentFactory interface

class DiaryFactory implements ContentFactory {
  @override
  Content createContent(Map<String, dynamic> data) {
    return DiaryEntry.fromJson(data);
  }
}