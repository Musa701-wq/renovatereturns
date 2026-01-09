// widgets/create_another_button.dart
import 'package:flutter/material.dart';
import '../utils/theme.dart';

class CreateAnotherButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const CreateAnotherButton({
    super.key,
    required this.onPressed,
    this.label = 'Create Another Design',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppTheme.primaryColor,
          width: 2,
        ),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.tilescolor,
          foregroundColor: AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          elevation: 0,
          minimumSize: const Size(double.infinity, 55),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}