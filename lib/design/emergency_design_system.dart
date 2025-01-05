import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Custom classes
class EmergencyColorScheme {
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color background;
  final Color surface;
  final Color error;
  final Color warning;
  final Color success;

  const EmergencyColorScheme({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.background,
    required this.surface,
    required this.error,
    required this.warning,
    required this.success,
  });
}

class EmergencyTypography {
  final TextStyle headingLarge;
  final TextStyle headingMedium;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;

  const EmergencyTypography({
    required this.headingLarge,
    required this.headingMedium,
    required this.bodyLarge,
    required this.bodyMedium,
  });
}

class EmergencySpacing {
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;

  const EmergencySpacing({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
  });
}

class EmergencyComponents {
  final ButtonStyle button;
  final CardTheme card;
  final InputDecorationTheme input;

  const EmergencyComponents({
    required this.button,
    required this.card,
    required this.input,
  });
}

class EmergencyAnimations {
  final Duration duration;
  final Curve curve;

  const EmergencyAnimations({
    required this.duration,
    required this.curve,
  });
}

class EmergencyDesignSystem {
  // Core design
  static const colorScheme = EmergencyColorScheme(
    // Moderna ali umirujuća paleta
    primary: Color(0xFF2D3436), // Tamno siva - glavna
    secondary: Color(0xFF00B894), // Mint zelena - akcenti
    tertiary: Color(0xFF6C5CE7), // Ljubičasta - posebne akcije
    background: Color(0xFFF5F6FA), // Svetlo siva - pozadina
    surface: Color(0xFFFFFFFF), // Bela - površine
    error: Color(0xFFFF7675), // Crvena - greške
    warning: Color(0xFFFED330), // Žuta - upozorenja
    success: Color(0xFF26DE81), // Zelena - uspeh
  );

  // Typography
  static const typography = EmergencyTypography(
    // Moderan i čitljiv font sistem
    headingLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      height: 1.2,
    ),
    headingMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
      height: 1.3,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.1,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
  );

  // Spacing & Layout
  static const spacing = EmergencySpacing(
    xs: 4.0,
    sm: 8.0,
    md: 16.0,
    lg: 24.0,
    xl: 32.0,
  );

  // Components
  static final components = EmergencyComponents(
    // Modern button style
    button: ButtonStyle(
      elevation: 0,
      padding: EdgeInsets.symmetric(
        horizontal: spacing.lg,
        vertical: spacing.md,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      minimumSize: Size(120, 48),
    ),

    // Card style
    card: CardStyle(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(spacing.md),
    ),

    // Input field style
    input: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.md,
      ),
    ),
  );

  // Animations
  static final animations = EmergencyAnimations(
    duration: Duration(milliseconds: 200),
    curve: Curves.easeInOut,
  );

  // Example Message Card Widget
  static Widget messageCard({
    required String message,
    required MessageType type,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: spacing.sm,
        horizontal: spacing.md,
      ),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.surface,
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getMessageIcon(type),
                      color: _getMessageColor(type),
                      size: 20,
                    ),
                    SizedBox(width: spacing.sm),
                    Text(
                      _getMessageTitle(type),
                      style: typography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: spacing.sm),
                Text(
                  message,
                  style: typography.bodyMedium.copyWith(
                    color: colorScheme.primary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Example Action Button Widget
  static Widget actionButton({
    required String label,
    required VoidCallback onPressed,
    bool isSecondary = false,
  }) {
    return Container(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: components.button.copyWith(
          backgroundColor: MaterialStateProperty.all(
            isSecondary ? colorScheme.surface : colorScheme.primary,
          ),
          foregroundColor: MaterialStateProperty.all(
            isSecondary ? colorScheme.primary : colorScheme.surface,
          ),
          side: MaterialStateProperty.all(
            isSecondary
                ? BorderSide(color: colorScheme.primary)
                : BorderSide.none,
          ),
        ),
        child: Text(
          label,
          style: typography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// Helper enums and functions
enum MessageType { info, success, warning, error }

IconData _getMessageIcon(MessageType type) {
  switch (type) {
    case MessageType.info:
      return Icons.info_outline;
    case MessageType.success:
      return Icons.check_circle_outline;
    case MessageType.warning:
      return Icons.warning_amber_outlined;
    case MessageType.error:
      return Icons.error_outline;
  }
}

Color _getMessageColor(MessageType type) {
  switch (type) {
    case MessageType.info:
      return EmergencyDesignSystem.colorScheme.tertiary;
    case MessageType.success:
      return EmergencyDesignSystem.colorScheme.success;
    case MessageType.warning:
      return EmergencyDesignSystem.colorScheme.warning;
    case MessageType.error:
      return EmergencyDesignSystem.colorScheme.error;
  }
}

String _getMessageTitle(MessageType type) {
  switch (type) {
    case MessageType.info:
      return 'Informacija';
    case MessageType.success:
      return 'Uspešno';
    case MessageType.warning:
      return 'Upozorenje';
    case MessageType.error:
      return 'Greška';
  }
}
