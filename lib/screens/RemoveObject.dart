import 'package:ai_remodeling/screens/result_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../in_app_purchase/credit_manager.dart';
import '../in_app_purchase/credit_purchase_screen.dart';
import '../provider/upload_provider.dart';
import '../services/exception_handler.dart';
import '../utils/theme.dart';
import '../widgets/image_selection_widget.dart';
import '../widgets/credit_dialog.dart';
import '../in_app_purchase/i_ap_manager.dart';
import '../services/api_services.dart';
import '../services/prompt_v2.dart';

class ObjectRemove extends StatefulWidget {
  const ObjectRemove({super.key});

  @override
  State<ObjectRemove> createState() => _ObjectRemoveState();
}

class _ObjectRemoveState extends State<ObjectRemove> {
  static const int _creditsPerGeneration = 5;
  final TextEditingController _objectController = TextEditingController();

  @override
  void dispose() {
    _objectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: const Text('Remove Object'),
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
                          'Enter the object you want to remove',
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
                            controller: _objectController,
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
                              'Example: Remove the chair, delete the table, erase the person...',
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
                    SizedBox(height: AppTheme.responsiveSize(context, phone: 15, tablet: 20)),

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
                            '• "Remove the red chair in the corner"\n• "Delete the table from the center"\n• "Erase the person standing near the window"\n• "Remove the lamp on the desk"',
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
                        phone: 100,
                        tablet: 130,
                      ),
                    ),
                    Consumer<UploadProvider>(
                      builder: (context, uploadProvider, child) {
                        bool isGenerateEnabled =
                            uploadProvider.selectedImage != null &&
                                _objectController.text.trim().isNotEmpty;

                        return ElevatedButton(
                          onPressed: isGenerateEnabled
                              ? () => _removeObject(uploadProvider, context)
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
                                ? 'Remove Object'
                                : 'Select Image & Enter Object Description',
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

  void _removeObject(
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

      if (_objectController.text.isEmpty) {
        ExceptionHandler.showToast('Please describe the object to remove');
        return;
      }

      if (!creditManager.hasEnoughCredits(cost)) {
        if (mounted) {
          CreditDialog.show(
            context,
            'You need at least $cost credits to remove an object.',
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
                'Removing object...',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ],
          ),
        ),
      );

      if (context.mounted) {
        bool isFreeTier = !creditManager.hasPurchased;
        String removePrompt = isFreeTier
            ? PromptGeneratorV2.generateFreeTierRemovePrompt(
                objectToRemove: _objectController.text.trim(),
                imageSource: uploadProvider.selectedImageSource ?? 'Unknown',
              )
            : uploadProvider.generateObjectRemoveAIPrompt(
                objectToRemove: _objectController.text.trim(),
              );

        List<String> generatedImageUrls = [];
        if (uploadProvider.isMultipleVariationsEnabled) {
          generatedImageUrls = await uploadProvider.generateMultipleImagesFromAPI(
            basePrompt: removePrompt,
            imageFile: uploadProvider.selectedImage!,
          );
        } else {
          String url;
          if (isFreeTier) {
            url = await GeminiService.generateImageFreeTier(
              prompt: removePrompt,
              imageFile: uploadProvider.selectedImage!,
            );
          } else {
            url = await uploadProvider.generateObjectRemoveImage(
              objectToRemove: _objectController.text.trim(),
            );
          }
          generatedImageUrls = [url];
        }

        final deductionSucceeded = await creditManager.deductCredits(
          cost,
          reason: uploadProvider.isMultipleVariationsEnabled ? 'multiple_variations' : 'object_removal',
        );

        if (!deductionSucceeded) {
          if (context.mounted) {
            Navigator.pop(context);
            ExceptionHandler.showToast('Unable to deduct credits');
          }
          return;
        }

        if (context.mounted) Navigator.pop(context);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              generatedImageUrls: generatedImageUrls,
              roomType: "Object Removal",
              style: "Remove: ${_objectController.text.trim()}",
              budget: "Not Specified",
              prompt: removePrompt,
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