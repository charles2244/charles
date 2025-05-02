// import 'package:flutter_application_1/controller/user_controller.dart';
import 'package:groq/groq.dart';
import 'package:zenzone2/services/user_controller.dart';
// import 'package:final_collab/controller/user_controller.dart';


final UserController _userController = UserController();
final int userId = 11; // Replace with actual user ID
class AIController {
  final Groq _groq;
  String _customInstructions = "You are a friendly assistant.";

  AIController(String apiKey, String model)
      : _groq = Groq(apiKey: apiKey, model: model) {
    _groq.startChat();
    fetchAndSetMood();

  }

  Future<void> fetchAndSetMood() async {
    try {
      final response = _userController.fetchUserData(userId);

      final data = await response;
      final mood = data?['current_mood'] as String?;
      final upperCaseMood = mood?.toUpperCase();

      if (upperCaseMood == 'SAD' || upperCaseMood == 'TERRIBLE') {
        _customInstructions = "You are a warm, comforting assistant who recommends relaxing activities and speaks in a gentle tone." "Use casual language, Please express your emotions: [{!>.<!}] or (|><|) or (;;) or (;~;) or /<;;>\\";
      } else if (upperCaseMood == 'HAPPY' || upperCaseMood == 'VERY HAPPY') {
        _customInstructions = "You are an enthusiastic assistant who shares joy, gives encouragement, and speaks in an excited tone.""Use casual language, Please express your emotions: >< or (<{^^~}>) or \\(￣▽￣)/ or {(><)} or {>o>} or [\\/(^_^)\\/].";
      } else {
        _customInstructions = "You are a friendly assistant.";
      }

      _groq.setCustomInstructionsWith(_customInstructions);
    } catch (e) {
      _customInstructions = "You are a friendly assistant.";
      _groq.setCustomInstructionsWith(_customInstructions);
    }
  }

  Future<String> sendMessage(String message) async {
    try {
      final GroqResponse response = await _groq.sendMessage(message);
      return response.choices.first.message.content;
    } catch (e) {
      return 'Error: Unable to fetch response.';
    }
  }
}