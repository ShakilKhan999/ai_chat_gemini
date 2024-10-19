import 'package:get/get.dart';
import 'package:gemini_chat_app_tutorial/dbHelper/db_service.dart';
import 'package:gemini_chat_app_tutorial/model/chat_model.dart';

class ChatController extends GetxController {
  final DBService _dbService = DBService();
  var chatMessages = <ChatMessage>[].obs;
  var isImageChat = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    final messages = await _dbService.getChatMessages();
    chatMessages.assignAll(messages);
  }

  Future<void> refreshChatHistory() async {
    await _loadChatHistory();
  }

  Future<void> addMessage(ChatMessage message) async {
    await _dbService.insertChatMessage(message);
    chatMessages.add(message);
  }

  Future<void> deleteMessage(String id) async {
    await _dbService.deleteChatMessage(id);
    chatMessages.removeWhere((msg) => msg.id == id);
  }

  Future<void> clearChatHistory() async {
    await _dbService.clearChatHistory();
    chatMessages.clear();
  }

  void switchToTextChat() {
    isImageChat.value = false;
  }

  void switchToImageChat() {
    isImageChat.value = true;
  }
}
