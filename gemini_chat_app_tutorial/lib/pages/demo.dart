// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_markdown/flutter_markdown.dart';

// import 'package:image_picker/image_picker.dart';
// import 'package:gemini_chat_app_tutorial/consts.dart';
// import 'package:google_generative_ai/google_generative_ai.dart';

// class ChatScreen extends StatefulWidget {
//   const ChatScreen({super.key, required this.title});

//   final String title;

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: const ChatWidget(apiKey: GEMINI_API_KEY),
//     );
//   }
// }

// class ChatWidget extends StatefulWidget {
//   const ChatWidget({
//     required this.apiKey,
//     super.key,
//   });

//   final String apiKey;

//   @override
//   State<ChatWidget> createState() => _ChatWidgetState();
// }

// class _ChatWidgetState extends State<ChatWidget> {
//   late final GenerativeModel _model;
//   late final ChatSession _chat;
//   final ScrollController _scrollController = ScrollController();
//   final TextEditingController _textController = TextEditingController();
//   final FocusNode _textFieldFocus = FocusNode();
//   final List<({Image? image, String? text, bool fromUser})> _generatedContent =
//       <({Image? image, String? text, bool fromUser})>[];
//   bool _loading = false;
//   final ImagePicker _picker = ImagePicker();
//   XFile? _selectedImage;

//   @override
//   void initState() {
//     super.initState();
//     _model = GenerativeModel(
//       model: 'gemini-1.5-flash-latest',
//       apiKey: widget.apiKey,
//     );
//     _chat = _model.startChat();
//   }

//   void _scrollDown() {
//     WidgetsBinding.instance.addPostFrameCallback(
//       (_) => _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent,
//         duration: const Duration(
//           milliseconds: 750,
//         ),
//         curve: Curves.easeOutCirc,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final textFieldDecoration = InputDecoration(
//       contentPadding: const EdgeInsets.all(15),
//       hintText: 'Enter a prompt...',
//       border: OutlineInputBorder(
//         borderRadius: const BorderRadius.all(
//           Radius.circular(14),
//         ),
//         borderSide: BorderSide(
//           color: Theme.of(context).colorScheme.secondary,
//         ),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: const BorderRadius.all(
//           Radius.circular(14),
//         ),
//         borderSide: BorderSide(
//           color: Theme.of(context).colorScheme.secondary,
//         ),
//       ),
//     );

//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             child: GEMINI_API_KEY.isNotEmpty
//                 ? ListView.builder(
//                     controller: _scrollController,
//                     itemBuilder: (context, idx) {
//                       final content = _generatedContent[idx];
//                       return MessageWidget(
//                         text: content.text,
//                         image: content.image,
//                         isFromUser: content.fromUser,
//                       );
//                     },
//                     itemCount: _generatedContent.length,
//                   )
//                 : ListView(
//                     children: const [
//                       Text(
//                         'No API key found. Please provide an API Key using '
//                         "'--dart-define' to set the 'API_KEY' declaration.",
//                       ),
//                     ],
//                   ),
//           ),
//           if (_selectedImage != null)
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8.0),
//               child: Stack(
//                 children: [
//                   Image.file(
//                     File(_selectedImage!.path),
//                     height: 100,
//                     width: 100,
//                     fit: BoxFit.cover,
//                   ),
//                   Positioned(
//                       top: 0,
//                       child: IconButton(
//                         onPressed: () {
//                           setState(() {
//                             _selectedImage = null;
//                           });
//                         },
//                         icon: const Icon(
//                           Icons.cancel,
//                           color: Colors.red,
//                         ),
//                       ))
//                 ],
//               ),
//             ),
//           Padding(
//             padding: const EdgeInsets.symmetric(
//               vertical: 25,
//               horizontal: 15,
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     autofocus: true,
//                     focusNode: _textFieldFocus,
//                     decoration: textFieldDecoration,
//                     controller: _textController,
//                     onSubmitted: _sendChatMessage,
//                   ),
//                 ),
//                 const SizedBox.square(dimension: 15),
//                 IconButton(
//                   onPressed: !_loading
//                       ? () async {
//                           await _pickImage();
//                         }
//                       : null,
//                   icon: Icon(
//                     Icons.image,
//                     color: _loading
//                         ? Theme.of(context).colorScheme.secondary
//                         : Theme.of(context).colorScheme.primary,
//                   ),
//                 ),
//                 if (!_loading)
//                   IconButton(
//                     onPressed: () async {
//                       _sendChatMessage(_textController.text);
//                     },
//                     icon: Icon(
//                       Icons.send,
//                       color: Theme.of(context).colorScheme.primary,
//                     ),
//                   )
//                 else
//                   const CircularProgressIndicator(),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _pickImage() async {
//     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//     if (image != null) {
//       setState(() {
//         _selectedImage = image;
//       });
//     }
//   }

//   Future<void> _sendImagePrompt(XFile imageFile) async {
//     setState(() {
//       _loading = true;
//     });
//     try {
//       // Read the image bytes
//       final bytes = await imageFile.readAsBytes();

//       // Add the user image to the chat
//       _generatedContent.add((
//         image: Image.file(File(imageFile.path)),
//         text: _textController.text,
//         fromUser: true
//       ));

//       // Create content with image bytes
//       final content = [
//         Content.multi([
//           TextPart(_textController.text),
//           DataPart('image/jpeg', bytes),
//         ])
//       ];

//       // Generate content with API
//       var response = await _model.generateContent(content);
//       var text = response.text;
//       _generatedContent.add((image: null, text: text, fromUser: false));

//       if (text == null) {
//         _showError('No response from API.');
//         return;
//       } else {
//         setState(() {
//           _loading = false;
//           _scrollDown();
//         });
//       }
//     } catch (e) {
//       _showError(e.toString());
//       setState(() {
//         _loading = false;
//       });
//     } finally {
//       _textController.clear();
//       setState(() {
//         _loading = false;
//       });
//       _textFieldFocus.requestFocus();
//       setState(() {
//         _selectedImage = null;
//       });
//     }
//   }

//   Future<void> _sendChatMessage(String message) async {
//     if (_selectedImage != null) {
//       await _sendImagePrompt(_selectedImage!);
//     } else {
//       setState(() {
//         _loading = true;
//       });

//       try {
//         _generatedContent.add((image: null, text: message, fromUser: true));
//         final response = await _chat.sendMessage(
//           Content.text(message),
//         );
//         final text = response.text;
//         _generatedContent.add((image: null, text: text, fromUser: false));

//         if (text == null) {
//           _showError('No response from API.');
//           return;
//         } else {
//           setState(() {
//             _loading = false;
//             _scrollDown();
//           });
//         }
//       } catch (e) {
//         _showError(e.toString());
//         setState(() {
//           _loading = false;
//         });
//       } finally {
//         _textController.clear();
//         setState(() {
//           _loading = false;
//         });
//         _textFieldFocus.requestFocus();
//       }
//     }
//   }

//   void _showError(String message) {
//     showDialog<void>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Something went wrong'),
//           content: SingleChildScrollView(
//             child: SelectableText(message),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('OK'),
//             )
//           ],
//         );
//       },
//     );
//   }
// }

// class MessageWidget extends StatelessWidget {
//   const MessageWidget({
//     super.key,
//     this.image,
//     this.text,
//     required this.isFromUser,
//   });

//   final Image? image;
//   final String? text;
//   final bool isFromUser;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       // mainAxisAlignment:
//       //     isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
//       crossAxisAlignment:
//           isFromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//       children: [
//         if (!isFromUser)
//           Padding(
//             padding: const EdgeInsets.only(right: 8.0),
//             child: CircleAvatar(
//               backgroundColor: Theme.of(context).colorScheme.secondary,
//               child: Text(
//                 'AI',
//                 style: TextStyle(
//                   color: Theme.of(context).colorScheme.onSecondary,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//         if (isFromUser)
//           Padding(
//             padding: const EdgeInsets.only(left: 8.0),
//             child: CircleAvatar(
//               backgroundColor: Theme.of(context).colorScheme.primary,
//               child: Text(
//                 'U',
//                 style: TextStyle(
//                   color: Theme.of(context).colorScheme.onPrimary,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//         if (image != null)
//           Container(
//             height: 150,
//             width: 150,
//             margin: const EdgeInsets.all(8.0),
//             child: image!,
//           ),
//         if (text != null)
//           Container(
//             margin: const EdgeInsets.all(8.0),
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: isFromUser
//                   ? Theme.of(context).colorScheme.primary
//                   : Theme.of(context).colorScheme.secondary,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: MarkdownBody(
//               data: text!,
//               styleSheet: MarkdownStyleSheet(
//                 h1: Theme.of(context)
//                     .textTheme
//                     .headlineMedium
//                     ?.copyWith(color: Colors.black),
//                 p: Theme.of(context)
//                     .textTheme
//                     .bodyMedium
//                     ?.copyWith(color: Colors.black, fontSize: 16),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }
