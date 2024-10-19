import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gemini_chat_app_tutorial/consts.dart';
import 'package:gemini_chat_app_tutorial/dbHelper/db_service.dart';
import 'package:gemini_chat_app_tutorial/model/chat_model.dart';

import 'package:gemini_chat_app_tutorial/widget/msg_widget.dart';
import 'package:get/get.dart';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

import '../controller/controller.dart';

class ChatWithAI extends StatefulWidget {
  const ChatWithAI({super.key, required this.isImageChat});

  final bool isImageChat;

  @override
  State<ChatWithAI> createState() => _ChatWithAIState();
}

class _ChatWithAIState extends State<ChatWithAI> {
  final ChatController chatController = Get.find<ChatController>();
  late final GenerativeModel _model;
  late final ChatSession _chat;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode();
  final List<({Image? image, String? text, bool fromUser})> _generatedContent =
      [];
  final ImagePicker _picker = ImagePicker();
  final DBService _dbService = DBService();
  bool _loading = false;
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: GEMINI_API_KEY,
    );
    _chat = _model.startChat();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeOutCirc,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textFieldDecoration = InputDecoration(
      contentPadding: const EdgeInsets.all(15),
      hintText: 'Enter a prompt...',
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isImageChat
            ? 'Chat with AI (Image)'
            : 'Chat with AI (Text)'),
        actions: [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GEMINI_API_KEY.isNotEmpty
                  ? ListView.builder(
                      controller: _scrollController,
                      itemBuilder: (context, idx) {
                        final content = _generatedContent[idx];
                        return MessageWidget(
                          text: content.text,
                          image: content.image,
                          isFromUser: content.fromUser,
                        );
                      },
                      itemCount: _generatedContent.length,
                    )
                  : ListView(
                      children: const [
                        Text(
                          'No API key found. Please provide an API Key using '
                          "'--dart-define' to set the 'API_KEY' declaration.",
                        ),
                      ],
                    ),
            ),
            if (_selectedImage != null && widget.isImageChat)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Stack(
                  children: [
                    Image.file(
                      File(_selectedImage!.path),
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 0,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedImage = null;
                          });
                        },
                        icon: const Icon(Icons.cancel, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      focusNode: _textFieldFocus,
                      decoration: textFieldDecoration,
                      controller: _textController,
                      onSubmitted: _sendChatMessage,
                    ),
                  ),
                  const SizedBox.square(dimension: 15),
                  if (widget.isImageChat)
                    IconButton(
                      onPressed: !_loading
                          ? () async {
                              await _pickImage();
                            }
                          : null,
                      icon: Icon(
                        Icons.image,
                        color: _loading
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  if (!_loading)
                    IconButton(
                      onPressed: () async {
                        _sendChatMessage(_textController.text);
                      },
                      icon: Icon(
                        Icons.send,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  else
                    const CircularProgressIndicator(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _sendImagePrompt(XFile imageFile) async {
    setState(() {
      _loading = true;
    });

    try {
      // Read image bytes
      final bytes = await imageFile.readAsBytes();

      // Add the user's image message to the chat
      _generatedContent.add((
        image: Image.file(File(imageFile.path)),
        text: _textController.text,
        fromUser: true
      ));

      // Save user message with image to the database
      await chatController.addMessage(ChatMessage(
        text: _textController.text,
        imagePath: imageFile.path,
        isFromUser: true,
        timestamp: DateTime.now(),
      ));

      // Prepare content for AI model
      final content = [
        Content.multi([
          TextPart(_textController.text),
          DataPart('image/jpeg', bytes),
        ])
      ];

      // Send image and prompt to the AI model
      var response = await _model.generateContent(content);
      var text = response.text;

      // Add the AI's response to the chat
      _generatedContent.add((image: null, text: text, fromUser: false));

      // Save AI response to the database
      await chatController.addMessage(ChatMessage(
        text: text,
        isFromUser: false,
        timestamp: DateTime.now(),
      ));

      // Update UI
      setState(() {
        _loading = false;
        _scrollDown(); // Scroll to the bottom of the chat
      });
    } catch (e) {
      _showError(e.toString());
      setState(() {
        _loading = false;
      });
    } finally {
      _textController.clear(); // Clear the text field
      _textFieldFocus.requestFocus(); // Focus the text field
      setState(() {
        _selectedImage = null; // Clear the selected image
      });
    }
  }

  Future<void> _sendChatMessage(String message) async {
    if (message.trim().isEmpty &&
        (widget.isImageChat && _selectedImage == null)) {
      return;
    }

    setState(() {
      _loading = true;
    });

    if (widget.isImageChat && _selectedImage != null) {
      await _sendImagePrompt(_selectedImage!);
    } else {
      try {
        _generatedContent.add((image: null, text: message, fromUser: true));

        // Save user message to database
        await chatController.addMessage(ChatMessage(
          text: message,
          isFromUser: true,
          timestamp: DateTime.now(),
        ));

        final response = await _chat.sendMessage(Content.text(message));
        final text = response.text;
        _generatedContent.add((image: null, text: text, fromUser: false));

        // Save AI response to database
        await chatController.addMessage(ChatMessage(
          text: text,
          isFromUser: false,
          timestamp: DateTime.now(),
        ));

        setState(() {
          _loading = false;
          _scrollDown();
        });
      } catch (e) {
        _showError(e.toString());
        setState(() {
          _loading = false;
        });
      } finally {
        _textController.clear();
        _textFieldFocus.requestFocus();
      }
    }
  }

  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Something went wrong'),
          content: SingleChildScrollView(
            child: SelectableText(message),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }
}
