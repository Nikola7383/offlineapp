import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MessageInput extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  MessageInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Poruka...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppTheme.surface,
              ),
            ),
          ),
          SizedBox(width: 12),
          CircleAvatar(
            backgroundColor: AppTheme.primary,
            child: Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
