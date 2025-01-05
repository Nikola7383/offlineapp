import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ChatListItem extends StatelessWidget {
  final String name;
  final String lastMessage;
  final IconData icon;

  const ChatListItem({
    Key? key,
    required this.name,
    required this.lastMessage,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary.withOpacity(0.1),
          child: Icon(icon, color: AppTheme.primary),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          lastMessage,
          style: TextStyle(
            color: AppTheme.textPrimary.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}
