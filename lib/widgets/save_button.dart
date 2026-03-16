import 'package:flutter/material.dart';
import '../utils/theme.dart';

class SaveButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double? height;
  final double? width;

  const SaveButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    this.label = 'Save',
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final bool isProcessing = isLoading;
    final String buttonLabel = isProcessing ? 'Saving...' : label;

    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: borderColor ?? AppTheme.primaryColor,
            width: 2,
          ),
        ),
        child: ElevatedButton.icon(
          onPressed: isProcessing ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppTheme.primaryColor,
            foregroundColor: foregroundColor ?? AppTheme.secondaryColor,
            disabledBackgroundColor: (backgroundColor ?? AppTheme.primaryColor).withOpacity(0.6),
            disabledForegroundColor: (foregroundColor ?? AppTheme.secondaryColor).withOpacity(0.6),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
            elevation: 0,
            minimumSize: Size(width ?? 0, height ?? 0),
            maximumSize: Size(width ?? double.infinity, height ?? double.infinity),
          ),
          icon: isProcessing
              ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: foregroundColor ?? AppTheme.secondaryColor,
            ),
          )
              : const Icon(Icons.save_alt),
          label: Text(
            buttonLabel,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}