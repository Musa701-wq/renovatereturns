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

class FillSpaceScreen extends StatefulWidget {
  const FillSpaceScreen({super.key});

  @override
  State<FillSpaceScreen> createState() => _FillSpaceScreenState();
}

class _FillSpaceScreenState extends State<FillSpaceScreen> {
  static const int _creditsPerGeneration = 5;
  final TextEditingController _fillInstructionController = TextEditingController();

  @override
  void dispose() {
    _fillInstructionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: const Text('Fill Space'),
        backgroundColor: AppTheme.secondaryColor,
        foregroundColor: AppTheme.primaryColor,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            final uploadProvider = Provider.of<UploadProvider>(
              context,
              listen: false,
            );
            uploadProvider.reset();
            Navigator.pop(context);
          },
          child: Icon(
            CupertinoIcons.back,
            size: AppTheme.backButtonIconSize(context),
          ),
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

                    // FILL SPACE INSTRUCTIONS SECTION
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Describe what to fill the space with',
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
                            controller: _fillInstructionController,
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
                              'Example: Fill the empty corner with a modern floor lamp and small plant',
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
                            '• "Fill the empty corner with a reading chair and lamp"\n• "Add a console table and mirror to the blank wall"\n• "Place a potted plant in the empty space near the window"\n• "Fill the bare wall with artwork and floating shelves"',
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

                    // CUSTOM BUTTON FOR FILL SPACE
                    Consumer<UploadProvider>(
                      builder: (context, uploadProvider, child) {
                        bool isGenerateEnabled =
                            uploadProvider.selectedImage != null &&
                                _fillInstructionController.text.trim().isNotEmpty;

                        return ElevatedButton(
                          onPressed: isGenerateEnabled
                              ? () => _fillSpace(uploadProvider, context)
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
                                ? 'Fill Space'
                                : 'Select Image & Enter Fill Instructions',
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

  void _fillSpace(
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

      if (_fillInstructionController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please describe what to fill the space with'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (!creditManager.hasEnoughCredits(_creditsPerGeneration)) {
        _showInsufficientCreditsDialog(context);
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
                'Filling space...',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ],
          ),
        ),
      );

      // USING PROVIDER METHOD FOR FILL SPACE
      String fillInstruction = _fillInstructionController.text.trim();

      String generatedImageUrl = await uploadProvider.generateFillSpaceImage(
        fillInstruction: fillInstruction,
      );

      final deductionSucceeded = await creditManager.deductCredits(
        _creditsPerGeneration,
        reason: 'fill_space_generation',
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
        String fillPrompt = uploadProvider.generateFillSpaceAIPrompt(
          fillInstruction: fillInstruction,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              generatedImageUrls: [generatedImageUrl],
              roomType: 'Fill Space',
              style: "Space Filling",
              budget: "Not Specified",
              prompt: fillPrompt,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fill space failed: ${e.toString()}'),
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
            'You need at least $_creditsPerGeneration credits to fill space.',
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
import '../in_app_purchase/i_ap_manager.dart';
import '../provider/upload_provider.dart';
import '../services/exception_handler.dart';
import '../utils/theme.dart';
import '../widgets/credit_dialog.dart';
import '../widgets/image_selection_widget.dart';

class FillSpaceScreen extends StatefulWidget {
  const FillSpaceScreen({super.key});

  @override
  State<FillSpaceScreen> createState() => _FillSpaceScreenState();
}

class _FillSpaceScreenState extends State<FillSpaceScreen> {
  static const int _creditsPerGeneration = 5;
  final TextEditingController _fillInstructionController = TextEditingController();

  @override
  void dispose() {
    _fillInstructionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: const Text('Fill Space'),
        backgroundColor: AppTheme.secondaryColor,
        foregroundColor: AppTheme.primaryColor,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            final uploadProvider = Provider.of<UploadProvider>(
              context,
              listen: false,
            );
            uploadProvider.reset();
            Navigator.pop(context);
          },
          child: const Icon(CupertinoIcons.back),
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
                          'Describe what to fill the space with',
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
                            controller: _fillInstructionController,
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
                              'Example: Fill the empty corner with a modern floor lamp and small plant',
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
                            '• "Fill the empty corner with a reading chair and lamp"\n• "Add a console table and mirror to the blank wall"\n• "Place a potted plant in the empty space near the window"\n• "Fill the bare wall with artwork and floating shelves"',
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
                                _fillInstructionController.text.trim().isNotEmpty;

                        return ElevatedButton(
                          onPressed: isGenerateEnabled
                              ? () => _fillSpace(uploadProvider, context)
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
                                ? 'Fill Space'
                                : 'Select Image & Enter Fill Instructions',
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

  void _fillSpace(
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

      if (_fillInstructionController.text.trim().isEmpty) {
        ExceptionHandler.showToast('Please describe what to fill the space with');
        return;
      }

      if (!creditManager.hasEnoughCredits(cost)) {
        if (mounted) {
          CreditDialog.show(
            context,
            'You need at least $cost credits to fill space.',
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
                'Filling space...',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ],
          ),
        ),
      );

      String fillInstruction = _fillInstructionController.text.trim();
      String fillPrompt = uploadProvider.generateFillSpaceAIPrompt(
        fillInstruction: fillInstruction,
      );

      List<String> generatedImageUrls = [];
      if (uploadProvider.isMultipleVariationsEnabled) {
        generatedImageUrls = await uploadProvider.generateMultipleImagesFromAPI(
          basePrompt: fillPrompt,
          imageFile: uploadProvider.selectedImage!,
        );
      } else {
        String url = await uploadProvider.generateFillSpaceImage(
          fillInstruction: fillInstruction,
        );
        generatedImageUrls = [url];
      }

      final deductionSucceeded = await creditManager.deductCredits(
        cost,
        reason: uploadProvider.isMultipleVariationsEnabled ? 'multiple_variations' : 'fill_space_generation',
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
              roomType: 'Fill Space',
              style: "Space Filling",
              budget: "Not Specified",
              prompt: fillPrompt,
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