import 'package:ai_remodeling/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/upload_provider.dart';

class GenerateButtonWidget extends StatelessWidget {
  final VoidCallback onGeneratePressed;

  const GenerateButtonWidget({
    super.key,
    required this.onGeneratePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UploadProvider>(
      builder: (context, uploadProvider, child) {
        bool isGenerateEnabled = uploadProvider.selectedImage != null &&
            uploadProvider.selectedRoomType != null &&
            uploadProvider.selectedStyle != null &&
            uploadProvider.selectedBudget != null;

        return ElevatedButton(
          onPressed: onGeneratePressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              vertical: AppTheme.responsiveSize(context, phone: 15, tablet: 22),
              horizontal: AppTheme.responsiveSize(context, phone: 30, tablet: 50),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.responsiveSize(context, phone: 12, tablet: 18)),
            ),
          ),
          child: Text(
            'Generate',
            style: TextStyle(
              fontSize: AppTheme.responsiveFont(context, phone: 16, tablet: 22),
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}