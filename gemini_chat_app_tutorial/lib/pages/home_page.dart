import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gemini_chat_app_tutorial/consts.dart';
import 'package:gemini_chat_app_tutorial/controller/controller.dart';

import 'package:gemini_chat_app_tutorial/widget/card_widget.dart';
import 'package:get/get.dart';
import 'package:gemini_chat_app_tutorial/pages/chat_with_ai.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ChatController chatController =
        Get.find<ChatController>(); // Access controller

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await chatController.refreshChatHistory();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                height: 60,
              ),
              Row(
                children: [
                  Expanded(
                    child: CardButton(
                      title: 'Ask Image',
                      color: Theme.of(context).colorScheme.onPrimary,
                      imagePath: imageLogo,
                      isMainButton: true,
                      onPressed: () {
                        chatController.switchToImageChat();
                        Get.to(() => const ChatWithAI(isImageChat: true));
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CardButton(
                      title: 'Chat with AI',
                      color: Theme.of(context).colorScheme.onPrimary,
                      imagePath: 'assets/images/aichat.png',
                      isMainButton: false,
                      onPressed: () {
                        chatController.switchToTextChat();
                        Get.to(() => const ChatWithAI(isImageChat: false));
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent history',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete All Chat History'),
                          content: const Text(
                              'Are you sure you want to delete all chat history?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await chatController.clearChatHistory();
                      }
                    },
                    tooltip: 'Delete All Chat History',
                  ),
                ],
              ),
              Expanded(
                child: Obx(() {
                  final userMessages = chatController.chatMessages
                      .where((message) => message.isFromUser)
                      .toList();

                  if (userMessages.isEmpty) {
                    return const Center(child: Text('No chat history found.'));
                  } else {
                    return ListView.builder(
                      itemCount: userMessages.length,
                      itemBuilder: (context, index) {
                        final message = userMessages[index];
                        return Card(
                          color: Theme.of(context).colorScheme.onPrimary,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: message.isFromUser
                                  ? Colors.blue
                                  : Colors.green,
                              child: CircleAvatar(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                child: Center(
                                  child: Text(
                                    'U',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.sp),
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              message.text ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                            subtitle: message.imagePath != null
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(message.imagePath!),
                                        fit: BoxFit.cover,
                                        width: 100,
                                        height: 150,
                                      ),
                                    ),
                                  )
                                : null,
                            // trailing: IconButton(
                            //   icon: const Icon(Icons.delete, color: Colors.red),
                            //   onPressed: () async {
                            //     final confirm = await showDialog<bool>(
                            //       context: context,
                            //       builder: (context) => AlertDialog(
                            //         title: const Text('Delete Message'),
                            //         content: const Text(
                            //             'Are you sure you want to delete this message?'),
                            //         actions: [
                            //           TextButton(
                            //             onPressed: () =>
                            //                 Navigator.of(context).pop(false),
                            //             child: const Text('Cancel'),
                            //           ),
                            //           TextButton(
                            //             onPressed: () =>
                            //                 Navigator.of(context).pop(true),
                            //             child: const Text('Delete'),
                            //           ),
                            //         ],
                            //       ),
                            //     );

                            //     if (confirm == true) {
                            //       chatController.deleteMessage(message.id!);
                            //     }
                            //   },
                            // ),
                          ),
                        );
                      },
                    );
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
