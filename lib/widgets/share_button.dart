// widgets/share_button.dart
import 'package:flutter/material.dart';
import '../utils/theme.dart';

class ShareButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double? height;
  final double? width;

  const ShareButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    this.label = 'Share',
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: borderColor ?? AppTheme.primaryColor,
          width: 2,
        ),
      ),
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppTheme.tilescolor,
          foregroundColor: foregroundColor ?? AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          elevation: 0,
        ),
        icon: isLoading
            ? SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: foregroundColor ?? AppTheme.primaryColor,
          ),
        )
            : const Icon(Icons.share),
        label: Text(
          isLoading ? 'Sharing...' : label,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}