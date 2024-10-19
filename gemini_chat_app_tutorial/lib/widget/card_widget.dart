import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CardButton extends StatelessWidget {
  const CardButton({
    required this.title,
    required this.imagePath,
    required this.color,
    required this.isMainButton,
    required this.onPressed,
    super.key,
  });
  final String title;
  final String imagePath;
  final Color color;
  final bool isMainButton;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(
                    imagePath,
                    color: Theme.of(context).colorScheme.onPrimaryFixedVariant,
                  ),
                ),
              ),
              Icon(
                CupertinoIcons.arrow_up_right,
                color: Theme.of(context).colorScheme.secondary,
                size: 32,
              ),
            ],
          ),
          SizedBox(
            height: isMainButton ? 50 : 8,
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              title,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 17.sp),
            ),
          ),
        ],
      ),
    );
  }
}
