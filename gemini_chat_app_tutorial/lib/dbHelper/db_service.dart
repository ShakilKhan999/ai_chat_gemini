import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gemini_chat_app_tutorial/model/chat_model.dart';

class DBService {
  static final DBService _instance = DBService._internal();
  factory DBService() => _instance;
  DBService._internal();

  // Reference to Firestore collection
  final CollectionReference _chatMessagesCollection =
      FirebaseFirestore.instance.collection('chat_messages');

  // Get all chat messages
  Future<List<ChatMessage>> getChatMessages() async {
    QuerySnapshot snapshot = await _chatMessagesCollection
        .orderBy('timestamp', descending: false)
        .get();

    return snapshot.docs.map((doc) {
      return ChatMessage.fromMap(doc.data() as Map<String, dynamic>,
          id: doc.id);
    }).toList();
  }

  // Insert a new chat message
  Future<void> insertChatMessage(ChatMessage message) async {
    await _chatMessagesCollection.add(message.toMap());
  }

  // Delete a chat message by document ID
  Future<void> deleteChatMessage(String id) async {
    await _chatMessagesCollection.doc(id).delete();
  }

  // Clear all chat messages
  Future<void> clearChatHistory() async {
    // Get all documents and delete them one by one
    QuerySnapshot snapshot = await _chatMessagesCollection.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
