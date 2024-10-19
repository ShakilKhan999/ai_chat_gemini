import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget({
    super.key,
    this.image,
    this.text,
    required this.isFromUser,
    File? pdfFile,
  });

  final Image? image;
  final String? text;
  final bool isFromUser;

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment:
      //     isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment:
          isFromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (!isFromUser)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Center(
                child: Text(
                  'AI',
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Theme.of(context).colorScheme.onSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        if (isFromUser)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Center(
                child: Text(
                  'U',
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        if (image != null)
          Container(
            height: 150,
            width: 150,
            margin: const EdgeInsets.all(8.0),
            child: image!,
          ),
        if (text != null)
          Container(
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isFromUser
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: MarkdownBody(
              data: text!,
              styleSheet: MarkdownStyleSheet(
                h1: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: Colors.black, fontSize: 14.sp),
                p: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.black, fontSize: 14.sp),
              ),
            ),
          ),
      ],
    );
  }
}
