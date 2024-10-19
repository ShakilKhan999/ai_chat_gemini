import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  String? id; // Firestore document ID will be a String
  String? text;
  String? imagePath;
  String? pdfPath;
  bool isFromUser;
  DateTime timestamp;

  ChatMessage({
    this.id, // Firestore document ID
    this.text,
    this.imagePath,
    this.pdfPath,
    required this.isFromUser,
    required this.timestamp,
  });

  // Convert a ChatMessage object to a map for Firestore insertion
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'imagePath': imagePath,
      'pdfPath': pdfPath,
      'isFromUser': isFromUser ? 1 : 0,
      'timestamp': Timestamp.fromDate(
          timestamp), // Convert DateTime to Firestore Timestamp
    };
  }

  // Convert a map from Firestore to a ChatMessage object
  factory ChatMessage.fromMap(Map<String, dynamic> map, {String? id}) {
    return ChatMessage(
      id: id, // Assign Firestore document ID if provided
      text: map['text'],
      imagePath: map['imagePath'],
      pdfPath: map['pdfPath'],
      isFromUser: map['isFromUser'] == 1,
      timestamp: (map['timestamp'] as Timestamp)
          .toDate(), // Convert Firestore Timestamp to DateTime
    );
  }
}
