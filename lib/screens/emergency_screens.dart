import 'package:flutter/material.dart';

class EmergencyScreens {
  // Moderna color paleta
  static const Color primaryColor = Color(0xFF2D3436);    // Tamno siva
  static const Color accentColor = Color(0xFF00B894);     // Mint zelena
  static const Color secondaryColor = Color(0xFF6C5CE7);  // Ljubičasta
  static const Color backgroundColor = Color(0xFFF5F6FA); // Svetlo siva
  static const Color surfaceColor = Color(0xFFFFFFFF);    // Bela
  static const Color errorColor = Color(0xFFFF7675);      // Crvena
  static const Color warningColor = Color(0xFFFED330);    // Žuta
  static const Color successColor = Color(0xFF26DE81);    // Zelena

  // Main Screen (Home)
  static Widget buildMainScreen() {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Modern Status Bar
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfaceColor,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.radio_button_checked,
                          color: successColor,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Povezani ste',
                          style: TextStyle(
                            color: successColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: secondaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '3 aktivna glasnika',
                      style: TextStyle(
                        color: secondaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Message List with modern cards
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(20),
                children: [
                  _buildModernMessageCard(
                    'Dobrodošli na događaj! Molimo pratite uputstva organizatora.',
                    'info',
                    Icons.info_outline,
                  ),
                  SizedBox(height: 12),
                  _buildModernMessageCard(
                    'Nova poruka od glasnika: Okupljanje počinje za 15 minuta.',
                    'success',
                    Icons.check_circle_outline,
                  ),
                ],
              ),
            ),

            // Modern Action Bar
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfaceColor,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildModernButton(
                      'Kontakti',
                      onPressed: () {},
                      icon: Icons.people_outline,
                      isSecondary: true,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildModernButton(
                      'Nova Poruka',
                      onPressed: () {},
                      icon: Icons.edit_outlined,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Contact Screen with modern design
  static Widget buildContactScreen() {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        title: Text(
          'Kontakti',
          style: TextStyle(
            color: primaryColor,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Icon(Icons.person_add_outlined, color: accentColor),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          _buildModernContactCard('Ana M.', 'Online', true),
          SizedBox(height: 12),
          _buildModernContactCard('Marko S.', 'Offline', false),
          SizedBox(height: 12),
          _buildModernContactCard('Jana K.', 'Online', true),
        ],
      ),
    );
  }

  // Messenger Screen with modern chat interface
  static Widget buildMessengerScreen() {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [accentColor, secondaryColor],
                ),
              ),
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Text(
                  'G1',
                  style: TextStyle(
                    color: surfaceColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Glasnik 1',
              style: TextStyle(
                color: primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                image: DecorationImage(
                  image: NetworkImage('https://i.imgur.com/44DXJWW.png'),
                  repeat: ImageRepeat.repeat,
                  opacity: 0.05,
                ),
              ),
              child: ListView(
                padding: EdgeInsets.all(20),
                children: [
                  _buildModernMessageBubble(
                    'Važno obaveštenje za sve učesnike',
                    true,
                    DateTime.now(),
                  ),
                  _buildModernMessageBubble(
                    'Primljeno, hvala na informaciji',
                    false,
                    DateTime.now().subtract(Duration(minutes: 1)),
                  ),
                ],
              ),
            ),
          ),
          _buildModernMessageInput(),
        ],
      ),
    );
  }

  // Modern Helper Widgets
  static Widget _buildModernMessageCard(String message, String type, IconData icon) {
    Color cardColor;
    Color iconColor;
    
    switch (type) {
      case 'info':
        cardColor = secondaryColor.withOpacity(0.1);
        iconColor = secondaryColor;
        break;
      case 'success':
        cardColor = successColor.withOpacity(0.1);
        iconColor = successColor;
        break;
      default:
        cardColor = primaryColor.withOpacity(0.1);
        iconColor = primaryColor;
    }

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildModernButton(
    String label, {
    required VoidCallback onPressed,
    required IconData icon,
    bool isSecondary = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSecondary ? surfaceColor : accentColor,
            borderRadius: BorderRadius.circular(16),
            border: isSecondary ? Border.all(color: accentColor) : null,
            boxShadow: isSecondary ? null : [
              BoxShadow(
                color: accentColor.withOpacity(0.3),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSecondary ? accentColor : surfaceColor,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSecondary ? accentColor : surfaceColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildModernContactCard(String name, String status, bool isOnline) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [accentColor, secondaryColor],
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 24,
                      child: Text(
                        name[0],
                        style: TextStyle(
                          color: surfaceColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isOnline ? successColor : errorColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 6),
                            Text(
                              status,
                              style: TextStyle(
                                color: isOnline ? successColor : errorColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: primaryColor.withOpacity(0.3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildModernMessageBubble(String message, bool isMe, DateTime time) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isMe ? accentColor : surfaceColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        constraints: BoxConstraints(maxWidth: 280),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                color: isMe ? surfaceColor : primaryColor,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: isMe ? surfaceColor.withOpacity(0.7) : primaryColor.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildModernMessageInput() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Unesite poruku...',
                  hintStyle: TextStyle(
                    color: primaryColor.withOpacity(0.5),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentColor, secondaryColor],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Icon(
                    Icons.send_rounded,
                    color: surfaceColor,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
