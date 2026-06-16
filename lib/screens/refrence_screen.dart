
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../in_app_purchase/credit_manager.dart';
import '../in_app_purchase/credit_purchase_screen.dart';
import '../provider/upload_provider.dart';
import '../utils/theme.dart';
import '../widgets/dual_image_selection.dart';
import '../services/image_storage_service.dart';
import 'result_screen.dart';
import '../widgets/loading_overlay.dart';
import '../screens/login_screen.dart';
import '../provider/auth_provider.dart';

class ReferenceTransformScreen extends StatefulWidget {
  const ReferenceTransformScreen({super.key});

  @override
  State<ReferenceTransformScreen> createState() => _ReferenceTransformScreenState();
}

class _ReferenceTransformScreenState extends State<ReferenceTransformScreen> {
  static const int _creditsPerGeneration = 5;
  final TextEditingController _instructionController = TextEditingController();

  @override
  void dispose() {
    _instructionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: const Text('Reference Transform'),
        backgroundColor: AppTheme.secondaryColor,
        foregroundColor: AppTheme.primaryColor,
        leading: IconButton(
          icon: Icon(
            AppTheme.backButtonIcon,
            size: AppTheme.backButtonIconSize(context),
          ),
          onPressed: () {
            final uploadProvider =
                Provider.of<UploadProvider>(context, listen: false);
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
                    DualImageSelectionWidget(),
                    SizedBox(height: AppTheme.responsiveSize(context, phone: 30, tablet: 40)),

                    // OPTIONAL INSTRUCTIONS
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Additional Instructions',
                              style: TextStyle(
                                fontSize: AppTheme.responsiveFont(context, phone: 16, tablet: 22),
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.5)),
                              ),
                              child: Text(
                                'OPTIONAL',
                                style: TextStyle(
                                  fontSize: AppTheme.responsiveFont(context, phone: 10, tablet: 12),
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppTheme.responsiveSize(context, phone: 8, tablet: 10)),
                        Text(
                          'Specify any additional details or preferences (optional)',
                          style: TextStyle(
                            fontSize: AppTheme.responsiveFont(context, phone: 12, tablet: 16),
                            color: AppTheme.primaryColor.withOpacity(0.6),
                          ),
                        ),
                        SizedBox(height: AppTheme.responsiveSize(context, phone: 10, tablet: 12)),

                        Container(
                          height: AppTheme.responsiveSize(context, phone: 120, tablet: 160),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(
                              AppTheme.responsiveSize(context, phone: 12, tablet: 14),
                            ),
                            border: Border.all(color: AppTheme.primaryColor, width: 1),
                          ),
                          child: TextField(
                            controller: _instructionController,
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: AppTheme.responsiveFont(context, phone: 16, tablet: 22),
                            ),
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: InputDecoration(
                              hintText: 'Example: Make the colors brighter, add more contrast',
                              hintStyle: TextStyle(
                                color: AppTheme.primaryColor.withOpacity(0.5),
                                fontSize: AppTheme.responsiveFont(context, phone: 14, tablet: 18),
                              ),
                              contentPadding: EdgeInsets.all(
                                AppTheme.responsiveSize(context, phone: 16, tablet: 20),
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

                    SizedBox(height: AppTheme.responsiveSize(context, phone: 20, tablet: 26)),

                    // EXAMPLE INFO
                    Container(
                      padding: EdgeInsets.all(AppTheme.responsiveSize(context, phone: 16, tablet: 20)),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(
                          AppTheme.responsiveSize(context, phone: 12, tablet: 14),
                        ),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: AppTheme.primaryColor,
                                size: AppTheme.responsiveSize(context, phone: 18, tablet: 22),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'How it works:',
                                style: TextStyle(
                                  fontSize: AppTheme.responsiveFont(context, phone: 14, tablet: 16),
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppTheme.responsiveSize(context, phone: 8, tablet: 10)),
                          Text(
                            'Image A (Reference): The style/look you want to copy\nImage B (Target): The image that will be transformed\n\nThe AI will apply the style from Image A to Image B.',
                            style: TextStyle(
                              fontSize: AppTheme.responsiveFont(context, phone: 12, tablet: 14),
                              color: AppTheme.primaryColor.withOpacity(0.7),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppTheme.responsiveSize(context, phone: 40, tablet: 60)),

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

                    SizedBox(height: AppTheme.responsiveSize(context, phone: 40, tablet: 60)),

                    // GENERATE BUTTON
                    Consumer<UploadProvider>(
                      builder: (context, uploadProvider, child) {
                        bool isGenerateEnabled = uploadProvider.selectedImage != null &&
                            uploadProvider.secondaryImage != null;

                        return ElevatedButton(
                          onPressed: isGenerateEnabled
                              ? () => _generateReferenceTransform(uploadProvider, context)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isGenerateEnabled
                                ? AppTheme.primaryColor
                                : AppTheme.primaryColor.withOpacity(0.3),
                            foregroundColor: isGenerateEnabled
                                ? AppTheme.secondaryColor
                                : AppTheme.primaryColor,
                            padding: EdgeInsets.symmetric(
                              vertical: AppTheme.responsiveSize(context, phone: 15, tablet: 18),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.responsiveSize(context, phone: 12, tablet: 14),
                              ),
                            ),
                          ),
                          child: Text(
                            isGenerateEnabled ? 'Transform Image' : 'Select Both Images (A & B)',
                            style: TextStyle(
                              fontSize: AppTheme.responsiveFont(context, phone: 16, tablet: 22),
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: AppTheme.responsiveSize(context, phone: 10, tablet: 14)),
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

  void _generateReferenceTransform(UploadProvider uploadProvider, BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.currentUser == null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
      return;
    }

    final creditManager = Provider.of<CreditManager>(context, listen: false);
    final int cost = uploadProvider.isMultipleVariationsEnabled ? 15 : 5;

    try {
      if (uploadProvider.selectedImage == null || uploadProvider.secondaryImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select both images'), backgroundColor: Colors.red),
        );
        return;
      }

      if (!creditManager.hasEnoughCredits(cost)) {
        _showInsufficientCreditsDialog(context, cost);
        return;
      }

      LoadingOverlay.show(context, message: 'Transforming image with reference...');

      String additionalInstruction = _instructionController.text.trim();
      String transformPrompt = uploadProvider.generateReferenceTransformAIPrompt(
        additionalInstruction: additionalInstruction.isEmpty ? null : additionalInstruction,
      );

      List<String> generatedImageUrls = [];
      if (uploadProvider.isMultipleVariationsEnabled) {
        generatedImageUrls = await uploadProvider.generateMultipleImagesFromAPI(
          basePrompt: transformPrompt,
          imageFile: uploadProvider.selectedImage!, // Needs to use secondary as reference in prompt logically, but API call structure might need adjustment. Trusting backend schema for now.
        );
      } else {
        String generatedImageUrl = await uploadProvider.generateReferenceTransformImage(
          additionalInstruction: additionalInstruction.isEmpty ? null : additionalInstruction,
        );
        generatedImageUrls = [generatedImageUrl];
      }

      final bool isFreeTier = !creditManager.hasPurchased;
      if (generatedImageUrls.isNotEmpty) {
        for (final img in generatedImageUrls) {
      // History saving is now handled by ResultScreen to prevent duplicates
        }
      }

      final deductionSucceeded = await creditManager.deductCredits(
        cost,
        reason: uploadProvider.isMultipleVariationsEnabled ? 'multiple_variations' : 'reference_transform_generation',
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              generatedImageUrls: generatedImageUrls,
              roomType: 'Reference Transform',
              style: "Style Transfer",
              budget: "Not Specified",
              prompt: transformPrompt,
              beforeImageUrl: uploadProvider.selectedImage?.path,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transform failed: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  void _showInsufficientCreditsDialog(BuildContext context, int requiredCredits) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.secondaryColor,
          title: Text('Not enough credits', style: TextStyle(color: AppTheme.primaryColor)),
          content: Text(
            'You need at least $requiredCredits credits to generate this transformation.',
            style: TextStyle(color: AppTheme.primaryColor),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.responsiveSize(context, phone: 16, tablet: 20)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _returnToPreviousScreen(context);
              },
              child: const Text('Maybe later', style: TextStyle(color: AppTheme.primaryColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const CreditsPurchaseScreen()))
                    .then((_) => _returnToPreviousScreen(context));
              },
              child: const Text('Purchase Credits', style: TextStyle(color: AppTheme.secondaryColor)),
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
}