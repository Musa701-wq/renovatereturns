import 'package:ai_remodeling/screens/result_screen.dart';
import 'package:flutter/cupertino.dart'
    show
        StatefulWidget,
        State,
        TextEditingController,
        BuildContext,
        Widget,
        Text,
        Icon,
        SizedBox,
        MediaQuery,
        EdgeInsets,
        CupertinoIcons,
        Navigator,
        CupertinoButton,
        BoxConstraints,
        CrossAxisAlignment,
        FontWeight,
        TextStyle,
        BorderRadius,
        Border,
        BoxDecoration,
        TextAlignVertical,
        Container,
        Column,
        RoundedRectangleBorder,
        TextAlign,
        Padding,
        ConstrainedBox,
        SingleChildScrollView,
        LayoutBuilder,
        MainAxisSize;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../in_app_purchase/credit_manager.dart';
import '../in_app_purchase/credit_purchase_screen.dart';
import '../provider/upload_provider.dart';
import '../utils/theme.dart' show AppTheme;
import '../widgets/image_selection_widget.dart';

/*import 'package:ai_remodeling/screens/result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../provider/upload_provider.dart';
import '../widgets/generate_button.dart';
import '../widgets/image_selection_widget.dart';
import '../utils/theme.dart';

class ObjectRemove extends StatefulWidget {
  const ObjectRemove({super.key});

  @override
  State<ObjectRemove> createState() => _ObjectRemoveState();
}

class _ObjectRemoveState extends State<ObjectRemove> {
  static const int _creditsPerGeneration = 5;
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
        toolbarHeight: AppTheme.appBarHeight(context),
        title: Text(
          'Remove Object',
          style: AppTheme.appBarTitleStyle(context),
        ),
        backgroundColor: AppTheme.secondaryColor,
        foregroundColor: AppTheme.primaryColor,
        iconTheme: AppTheme.appBarIconTheme(context),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            final uploadProvider = Provider.of<UploadProvider>(context, listen: false);
            uploadProvider.reset();
            Navigator.pop(context);
          },
          child: const Icon(CupertinoIcons.back),
        ),
      ),
      body: Consumer<UploadProvider>(
        builder: (context, uploadProvider, child) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // IMAGE SELECTION WIDGET
                  ImageSelectionWidget(),

                  const SizedBox(height: 40),

                  // TEXTBOX FOR OBJECT TO REMOVE
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter the object you want to remove',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryColor,
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _objectController,
                          style: TextStyle(color: AppTheme.primaryColor),
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: InputDecoration(
                            hintText: 'Example: Remove the chair, delete the table, erase the person...',
                            hintStyle: TextStyle(color: AppTheme.primaryColor.withOpacity(0.5)),
                            contentPadding: const EdgeInsets.all(16),
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Examples
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Examples:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• "Remove the red chair in the corner"\n• "Delete the table from the center"\n• "Erase the person standing near the window"\n• "Remove the lamp on the desk"',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),



                  // CUSTOM BUTTON FOR OBJECT REMOVE
                  Consumer<UploadProvider>(
                    builder: (context, uploadProvider, child) {
                      bool isGenerateEnabled = uploadProvider.selectedImage != null &&
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
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isGenerateEnabled
                              ? 'Remove Object'
                              : 'Select Image & Enter Object Description',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _removeObject(UploadProvider uploadProvider, BuildContext context) async {
    final creditManager = Provider.of<CreditManager>(context, listen: false);
    try {
      final creditManager = Provider.of<CreditManager>(context, listen: false);
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

      if (_objectController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please describe the object to remove'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (creditManager.isLoading) {
        await creditManager.init();
        if (!mounted) return;
      }

      if (!creditManager.hasEnoughCredits(_creditsPerGeneration)) {
        _showInsufficientCreditsDialog(context);
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
                'Removing object...',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ],
          ),
        ),
      );

      // USING PROVIDER METHOD FOR OBJECT REMOVAL
      String generatedImageUrl = await uploadProvider.generateObjectRemoveImage(
        objectToRemove: _objectController.text.trim(),
      );

      final deductionSucceeded = await creditManager.deductCredits(
        _creditsPerGeneration,
        reason: 'object_removal',
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

      final deductionSucceeded = await creditManager.deductCredits(
        _creditsPerGeneration,
        reason: 'object_removal',
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
        String removePrompt = uploadProvider.generateObjectRemoveAIPrompt(
          objectToRemove: _objectController.text.trim(),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              generatedImageUrl: generatedImageUrl,
              roomType: "Object Removal",
              style: "Remove: ${_objectController.text.trim()}",
              budget: "Not Specified",
              prompt: removePrompt,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Object removal failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}*/

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
                    // IMAGE SELECTION WIDGET
                    ImageSelectionWidget(),

                    SizedBox(
                      height: AppTheme.responsiveSize(
                        context,
                        phone: 40,
                        tablet: 55,
                      ),
                    ),

                    // TEXTBOX FOR OBJECT TO REMOVE
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

                    SizedBox(
                      height: AppTheme.responsiveSize(
                        context,
                        phone: 20,
                        tablet: 26,
                      ),
                    ),

                    // Examples
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

                    // SPACER
                    SizedBox(
                      height: AppTheme.responsiveSize(
                        context,
                        phone: 100,
                        tablet: 130,
                      ),
                    ),

                    // CUSTOM BUTTON FOR OBJECT REMOVE
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

  void _removeObject(
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

      if (_objectController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please describe the object to remove'),
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
                'Removing object...',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ],
          ),
        ),
      );

      // USING PROVIDER METHOD FOR OBJECT REMOVAL
      String generatedImageUrl = await uploadProvider.generateObjectRemoveImage(
        objectToRemove: _objectController.text.trim(),
      );

      final deductionSucceeded = await creditManager.deductCredits(
        _creditsPerGeneration,
        reason: 'object_removal',
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
        String removePrompt = uploadProvider.generateObjectRemoveAIPrompt(
          objectToRemove: _objectController.text.trim(),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              generatedImageUrl: generatedImageUrl,
              roomType: "Object Removal",
              style: "Remove: ${_objectController.text.trim()}",
              budget: "Not Specified",
              prompt: removePrompt,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Object removal failed: ${e.toString()}'),
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
            'You need at least $_creditsPerGeneration credits to remove an object.',
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
              child: const Text('Maybe later',style: TextStyle(color: AppTheme.primaryColor),),
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
              child: const Text('Purchase Credits',style: TextStyle(color: AppTheme.secondaryColor),),
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
