/*
import 'package:ai_remodeling/screens/result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../in_app_purchase/credit_manager.dart';
import '../in_app_purchase/credit_purchase_screen.dart';
import '../provider/upload_provider.dart';
import '../utils/theme.dart';
import '../widgets/image_selection_widget.dart';

class ReplaceScreen extends StatefulWidget {
  const ReplaceScreen({super.key});

  @override
  State<ReplaceScreen> createState() => _ReplaceScreenState();
}

class _ReplaceScreenState extends State<ReplaceScreen> {
  static const int _creditsPerGeneration = 5;
  final TextEditingController _replaceInstructionController = TextEditingController();

  @override
  void dispose() {
    _replaceInstructionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: const Text('Replace Object'),
        backgroundColor: AppTheme.secondaryColor,
        foregroundColor: AppTheme.primaryColor,
        leading: IconButton(
          icon: Icon(
            AppTheme.backButtonIcon,
            size: AppTheme.backButtonIconSize(context),
          ),
          onPressed: () {
            final uploadProvider = Provider.of<UploadProvider>(
              context,
              listen: false,
            );
            uploadProvider.reset();
            Navigator.pop(context);
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: EdgeInsets.all(AppTheme.responsivePadding(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // IMAGE SELECTION WIDGET
                    ImageSelectionWidget(),

                    SizedBox(
                      height: AppTheme.responsiveSize(
                        context,
                        phone: 40,
                        tablet: 55,
                      ),
                    ),

                    // REPLACEMENT INSTRUCTIONS SECTION
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Replace Instructions',
                          style: TextStyle(
                            fontSize: AppTheme.responsiveFont(
                              context,
                              phone: 16,
                              tablet: 22,
                            ),
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        SizedBox(
                          height: AppTheme.responsiveSize(
                            context,
                            phone: 10,
                            tablet: 12,
                          ),
                        ),

                        // TEXT INPUT FIELD
                        Container(
                          height: AppTheme.responsiveSize(
                            context,
                            phone: 120,
                            tablet: 160,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(
                              AppTheme.responsiveSize(
                                context,
                                phone: 12,
                                tablet: 14,
                              ),
                            ),
                            border: Border.all(
                              color: AppTheme.primaryColor,
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _replaceInstructionController,
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: AppTheme.responsiveFont(
                                context,
                                phone: 16,
                                tablet: 22,
                              ),
                            ),
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: InputDecoration(
                              hintText:
                              'Example: Replace the sofa with a modern blue sectional sofa',
                              hintStyle: TextStyle(
                                color: AppTheme.primaryColor.withOpacity(0.5),
                                fontSize: AppTheme.responsiveFont(
                                  context,
                                  phone: 14,
                                  tablet: 18,
                                ),
                              ),
                              contentPadding: EdgeInsets.all(
                                AppTheme.responsiveSize(
                                  context,
                                  phone: 16,
                                  tablet: 20,
                                ),
                              ),
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                      height: AppTheme.responsiveSize(
                        context,
                        phone: 20,
                        tablet: 26,
                      ),
                    ),

                    // EXAMPLE SUGGESTIONS
                    Container(
                      padding: EdgeInsets.all(
                        AppTheme.responsiveSize(context, phone: 16, tablet: 20),
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(
                          AppTheme.responsiveSize(
                            context,
                            phone: 12,
                            tablet: 14,
                          ),
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Examples:',
                            style: TextStyle(
                              fontSize: AppTheme.responsiveFont(
                                context,
                                phone: 14,
                                tablet: 16,
                              ),
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          SizedBox(
                            height: AppTheme.responsiveSize(
                              context,
                              phone: 8,
                              tablet: 10,
                            ),
                          ),
                          Text(
                            '• "Replace the chair with a modern blue armchair"\n• "Change the table to a glass dining table"\n• "Replace the lamp with a crystal chandelier"\n• "Swap the sofa with a leather sectional"',
                            style: TextStyle(
                              fontSize: AppTheme.responsiveFont(
                                context,
                                phone: 12,
                                tablet: 14,
                              ),
                              color: AppTheme.primaryColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // SPACER
                    SizedBox(
                      height: AppTheme.responsiveSize(
                        context,
                        phone: 100,
                        tablet: 130,
                      ),
                    ),

                    // CUSTOM BUTTON FOR REPLACE
                    Consumer<UploadProvider>(
                      builder: (context, uploadProvider, child) {
                        bool isGenerateEnabled =
                            uploadProvider.selectedImage != null &&
                                _replaceInstructionController.text.trim().isNotEmpty;

                        return ElevatedButton(
                          onPressed: isGenerateEnabled
                              ? () => _generateReplacement(uploadProvider, context)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isGenerateEnabled
                                ? AppTheme.primaryColor
                                : AppTheme.primaryColor.withOpacity(0.3),
                            foregroundColor: isGenerateEnabled
                                ? AppTheme.secondaryColor
                                : AppTheme.primaryColor,
                            padding: EdgeInsets.symmetric(
                              vertical: AppTheme.responsiveSize(
                                context,
                                phone: 15,
                                tablet: 18,
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.responsiveSize(
                                  context,
                                  phone: 12,
                                  tablet: 14,
                                ),
                              ),
                            ),
                          ),
                          child: Text(
                            isGenerateEnabled
                                ? 'Generate Replacement'
                                : 'Select Image & Enter Replacement Instructions',
                            style: TextStyle(
                              fontSize: AppTheme.responsiveFont(
                                context,
                                phone: 16,
                                tablet: 22,
                              ),
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                    SizedBox(
                      height: AppTheme.responsiveSize(
                        context,
                        phone: 10,
                        tablet: 14,
                      ),
                    ),
                    // Add bottom safe area padding
                    SizedBox(height: MediaQuery.of(context).padding.bottom),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _generateReplacement(
      UploadProvider uploadProvider,
      BuildContext context,
      ) async {
    final creditManager = Provider.of<CreditManager>(context, listen: false);
    try {
      // Validation check
      if (uploadProvider.selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an image first'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_replaceInstructionController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please provide replacement instructions'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (!creditManager.hasEnoughCredits(cost)) {
        if (mounted) {
          CreditDialog.show(
            context,
            'You need at least $cost credits to generate this replacement.',
            IAPManager().products,
          );
        }
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.secondaryColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppTheme.primaryColor),
              const SizedBox(height: 20),
              Text(
                'Generating replacement...',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ],
          ),
        ),
      );

      // USING PROVIDER METHOD FOR REPLACEMENT
      String replaceInstruction = _replaceInstructionController.text.trim();

      String generatedImageUrl = await uploadProvider.generateReplaceImage(
        replaceInstruction: replaceInstruction,
      );

      final deductionSucceeded = await creditManager.deductCredits(
        _creditsPerGeneration,
        reason: 'replace_generation',
      );

      if (!deductionSucceeded) {
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to deduct credits. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        // Get the generated prompt from provider
        String replacePrompt = uploadProvider.generateReplaceAIPrompt(
          replaceInstruction: replaceInstruction,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              generatedImageUrls: [generatedImageUrl],
              roomType: 'Replace',
              style: "Object Replacement",
              budget: "Not Specified",
              prompt: replacePrompt,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Replacement failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showInsufficientCreditsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.secondaryColor,
          title: Text(
            'Not enough credits',
            style: TextStyle(color: AppTheme.primaryColor),
          ),
          content: Text(
            'You need at least $_creditsPerGeneration credits to generate this replacement.',
            style: TextStyle(color: AppTheme.primaryColor),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppTheme.responsiveSize(context, phone: 16, tablet: 20),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _returnToPreviousScreen(context);
              },
              child: const Text(
                'Maybe later',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (_) => const CreditsPurchaseScreen(),
                  ),
                )
                    .then((_) => _returnToPreviousScreen(context));
              },
              child: const Text(
                'Purchase Credits',
                style: TextStyle(color: AppTheme.secondaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  void _returnToPreviousScreen(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}*/
import 'package:ai_remodeling/screens/result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../in_app_purchase/credit_manager.dart';
import '../in_app_purchase/credit_purchase_screen.dart';
import '../provider/upload_provider.dart';
import '../services/exception_handler.dart';
import '../utils/theme.dart';
import '../widgets/image_selection_widget.dart';

class ReplaceScreen extends StatefulWidget {
  const ReplaceScreen({super.key});

  @override
  State<ReplaceScreen> createState() => _ReplaceScreenState();
}

class _ReplaceScreenState extends State<ReplaceScreen> {
  static const int _creditsPerGeneration = 5;
  final TextEditingController _replaceInstructionController = TextEditingController();

  @override
  void dispose() {
    _replaceInstructionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: const Text('Replace Object'),
        backgroundColor: AppTheme.secondaryColor,
        foregroundColor: AppTheme.primaryColor,
        leading: IconButton(
          icon: Icon(
            AppTheme.backButtonIcon,
            size: AppTheme.backButtonIconSize(context),
          ),
          onPressed: () {
            final uploadProvider = Provider.of<UploadProvider>(
              context,
              listen: false,
            );
            uploadProvider.reset();
            Navigator.pop(context);
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: EdgeInsets.all(AppTheme.responsivePadding(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ImageSelectionWidget(),
                    SizedBox(
                      height: AppTheme.responsiveSize(
                        context,
                        phone: 40,
                        tablet: 55,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Replace Instructions',
                          style: TextStyle(
                            fontSize: AppTheme.responsiveFont(
                              context,
                              phone: 16,
                              tablet: 22,
                            ),
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        SizedBox(
                          height: AppTheme.responsiveSize(
                            context,
                            phone: 10,
                            tablet: 12,
                          ),
                        ),
                        Container(
                          height: AppTheme.responsiveSize(
                            context,
                            phone: 120,
                            tablet: 160,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(
                              AppTheme.responsiveSize(
                                context,
                                phone: 12,
                                tablet: 14,
                              ),
                            ),
                            border: Border.all(
                              color: AppTheme.primaryColor,
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _replaceInstructionController,
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: AppTheme.responsiveFont(
                                context,
                                phone: 16,
                                tablet: 22,
                              ),
                            ),
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: InputDecoration(
                              hintText:
                              'Example: Replace the sofa with a modern blue sectional sofa',
                              hintStyle: TextStyle(
                                color: AppTheme.primaryColor.withOpacity(0.5),
                                fontSize: AppTheme.responsiveFont(
                                  context,
                                  phone: 14,
                                  tablet: 18,
                                ),
                              ),
                              contentPadding: EdgeInsets.all(
                                AppTheme.responsiveSize(
                                  context,
                                  phone: 16,
                                  tablet: 20,
                                ),
                              ),
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: AppTheme.responsiveSize(
                        context,
                        phone: 20,
                        tablet: 26,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(
                        AppTheme.responsiveSize(context, phone: 16, tablet: 20),
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(
                          AppTheme.responsiveSize(
                            context,
                            phone: 12,
                            tablet: 14,
                          ),
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Examples:',
                            style: TextStyle(
                              fontSize: AppTheme.responsiveFont(
                                context,
                                phone: 14,
                                tablet: 16,
                              ),
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          SizedBox(
                            height: AppTheme.responsiveSize(
                              context,
                              phone: 8,
                              tablet: 10,
                            ),
                          ),
                          Text(
                            '• "Replace the chair with a modern blue armchair"\n• "Change the table to a glass dining table"\n• "Replace the lamp with a crystal chandelier"\n• "Swap the sofa with a leather sectional"',
                            style: TextStyle(
                              fontSize: AppTheme.responsiveFont(
                                context,
                                phone: 12,
                                tablet: 14,
                              ),
                              color: AppTheme.primaryColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: AppTheme.responsiveSize(
                        context,
                        phone: 40,
                        tablet: 60,
                      ),
                    ),

                    // MULTIPLE VARIATIONS TOGGLE
                    Consumer<UploadProvider>(
                      builder: (context, uploadProvider, child) {
                        return Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: SwitchListTile(
                            title: Text(
                              'Generate 3 Variations',
                              style: TextStyle(
                                fontSize: AppTheme.responsiveFont(context, phone: 15, tablet: 17),
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            subtitle: Text(
                              'Costs 15 credits instead of 5',
                              style: TextStyle(
                                fontSize: AppTheme.responsiveFont(context, phone: 12, tablet: 14),
                                color: AppTheme.primaryColor.withOpacity(0.7),
                              ),
                            ),
                            value: uploadProvider.isMultipleVariationsEnabled,
                            activeColor: AppTheme.primaryColor,
                            onChanged: (value) => uploadProvider.setMultipleVariationsEnabled(value),
                          ),
                        );
                      },
                    ),

                    SizedBox(
                      height: AppTheme.responsiveSize(
                        context,
                        phone: 40,
                        tablet: 60,
                      ),
                    ),
                    Consumer<UploadProvider>(
                      builder: (context, uploadProvider, child) {
                        bool isGenerateEnabled =
                            uploadProvider.selectedImage != null &&
                                _replaceInstructionController.text.trim().isNotEmpty;

                        return ElevatedButton(
                          onPressed: isGenerateEnabled
                              ? () => _generateReplacement(uploadProvider, context)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isGenerateEnabled
                                ? AppTheme.primaryColor
                                : AppTheme.primaryColor.withOpacity(0.3),
                            foregroundColor: isGenerateEnabled
                                ? AppTheme.secondaryColor
                                : AppTheme.primaryColor,
                            padding: EdgeInsets.symmetric(
                              vertical: AppTheme.responsiveSize(
                                context,
                                phone: 15,
                                tablet: 18,
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.responsiveSize(
                                  context,
                                  phone: 12,
                                  tablet: 14,
                                ),
                              ),
                            ),
                          ),
                          child: Text(
                            isGenerateEnabled
                                ? 'Generate Replacement'
                                : 'Select Image & Enter Replacement Instructions',
                            style: TextStyle(
                              fontSize: AppTheme.responsiveFont(
                                context,
                                phone: 16,
                                tablet: 22,
                              ),
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                    SizedBox(
                      height: AppTheme.responsiveSize(
                        context,
                        phone: 10,
                        tablet: 14,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).padding.bottom),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ✅ UPDATED WITH EXCEPTION HANDLER
  void _generateReplacement(
      UploadProvider uploadProvider,
      BuildContext context,
      ) async {
    final creditManager = Provider.of<CreditManager>(context, listen: false);
    final int cost = uploadProvider.isMultipleVariationsEnabled ? 15 : 5;

    try {
      if (uploadProvider.selectedImage == null) {
        ExceptionHandler.showToast('Please select an image first');
        return;
      }

      if (_replaceInstructionController.text.trim().isEmpty) {
        ExceptionHandler.showToast('Please provide replacement instructions');
        return;
      }

      if (!creditManager.hasEnoughCredits(cost)) {
        _showInsufficientCreditsDialog(context, cost);
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.secondaryColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppTheme.primaryColor),
              const SizedBox(height: 20),
              Text(
                'Generating replacement...',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ],
          ),
        ),
      );

      String replaceInstruction = _replaceInstructionController.text.trim();
      String replacePrompt = uploadProvider.generateReplaceAIPrompt(
        replaceInstruction: replaceInstruction,
      );

      List<String> generatedImageUrls = [];
      if (uploadProvider.isMultipleVariationsEnabled) {
        generatedImageUrls = await uploadProvider.generateMultipleImagesFromAPI(
          basePrompt: replacePrompt,
          imageFile: uploadProvider.selectedImage!,
        );
      } else {
        String url = await uploadProvider.generateReplaceImage(
          replaceInstruction: replaceInstruction,
        );
        generatedImageUrls = [url];
      }

      final deductionSucceeded = await creditManager.deductCredits(
        cost,
        reason: uploadProvider.isMultipleVariationsEnabled ? 'multiple_variations' : 'replace_generation',
      );

      if (!deductionSucceeded) {
        if (context.mounted) {
          Navigator.pop(context);
          ExceptionHandler.showToast('Unable to deduct credits');
        }
        return;
      }

      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              generatedImageUrls: generatedImageUrls,
              roomType: 'Replace',
              style: "Object Replacement",
              budget: "Not Specified",
              prompt: replacePrompt,
              beforeImageUrl: uploadProvider.selectedImage?.path,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      ExceptionHandler.handleException(e);
    }
  }

}