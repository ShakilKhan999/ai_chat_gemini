import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gemini_chat_app_tutorial/consts.dart';
import 'package:gemini_chat_app_tutorial/controller/controller.dart';
import 'package:gemini_chat_app_tutorial/dbHelper/db_service.dart';
import 'package:gemini_chat_app_tutorial/model/chat_model.dart';
import 'package:gemini_chat_app_tutorial/widget/msg_widget.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatWithPDF extends StatefulWidget {
  const ChatWithPDF({super.key});

  @override
  State<ChatWithPDF> createState() => _ChatWithPDFState();
}

class _ChatWithPDFState extends State<ChatWithPDF> {
  final ChatController chatController = Get.find<ChatController>();
  late final GenerativeModel _model;
  late final ChatSession _chat;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode();
  final List<({File? pdfFile, String? text, bool fromUser})> _generatedContent =
      [];
  final DBService _dbService = DBService();
  bool _loading = false;
  PlatformFile? _selectedPdf;

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

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() {
        _selectedPdf = result.files.first;
      });
    }
  }

  Future<void> _sendPdfPrompt() async {
    if (_selectedPdf == null && _textController.text.trim().isEmpty) return;

    setState(() {
      _loading = true;
    });

    try {
      // Add the user's PDF message to the chat
      _generatedContent.add((
        pdfFile: _selectedPdf != null ? File(_selectedPdf!.path!) : null,
        text: _textController.text,
        fromUser: true,
      ));

      // Save user message with PDF to the database
      await chatController.addMessage(ChatMessage(
        text: _textController.text,
        pdfPath: _selectedPdf?.path,
        isFromUser: true,
        timestamp: DateTime.now(),
      ));

      // Prepare content for AI model
      final content = [
        if (_selectedPdf != null)
          Content.multi([
            TextPart(_textController.text),
            FilePart(
                Uri.file(_selectedPdf!.path!)), // Use the URI for the FilePart
          ])
        else
          Content.text(_textController.text),
      ];

      // Send PDF and prompt to the AI model
      var response = await _model.generateContent(content);
      var text = response.text;

      // Add the AI's response to the chat
      _generatedContent.add((pdfFile: null, text: text, fromUser: false));

      // Save AI response to the database
      await chatController.addMessage(ChatMessage(
        text: text,
        isFromUser: false,
        timestamp: DateTime.now(),
      ));

      setState(() {
        _loading = false;
        _scrollDown(); // Scroll to the bottom of the chat
        _selectedPdf = null; // Clear the selected PDF
        _textController.clear(); // Clear the text field
      });
    } catch (e) {
      _showError(e.toString());
      setState(() {
        _loading = false;
      });
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
        title: const Text('Chat with PDF'),
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
                          pdfFile: content.pdfFile,
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
            if (_selectedPdf != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Stack(
                  children: [
                    Text('Selected PDF: ${_selectedPdf!.name}'),
                    Positioned(
                      top: 0,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedPdf = null;
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
                      onSubmitted: (_) => _sendPdfPrompt(),
                    ),
                  ),
                  const SizedBox.square(dimension: 15),
                  IconButton(
                    onPressed: _pickPdf,
                    icon: Icon(
                      Icons.picture_as_pdf,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  if (!_loading)
                    IconButton(
                      onPressed: _sendPdfPrompt,
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
}
