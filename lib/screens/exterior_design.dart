import 'package:ai_remodeling/screens/result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../in_app_purchase/credit_manager.dart';
import '../in_app_purchase/credit_purchase_screen.dart';
import '../provider/upload_provider.dart';
import '../services/api_services.dart';
import '../widgets/generate_button.dart';
import '../widgets/image_selection_widget.dart';
import '../utils/theme.dart';
import '../widgets/item_design_card.dart';

class ExteriorRedesign extends StatefulWidget {
  const ExteriorRedesign({super.key});

  @override
  State<ExteriorRedesign> createState() => _ExteriorRedesignState();
}

class _ExteriorRedesignState extends State<ExteriorRedesign> {
  @override
  void initState() {
    super.initState();
    // Reset provider state when entering screen to avoid conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uploadProvider = Provider.of<UploadProvider>(
        context,
        listen: false,
      );
      uploadProvider.setSelectedRoomType(null); // Clear previous selection
    });
  }

  @override
  Widget build(BuildContext context) {
    // Media query for responsive design
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 375;
    final bool isTablet = screenWidth >= 600;

    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: const Text('Exterior Redesign'),
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
      body: Consumer<UploadProvider>(
        builder: (context, uploadProvider, child) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(
                isSmallScreen
                    ? 16.0
                    : isTablet
                    ? 24.0
                    : 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // IMAGE SELECTION WIDGET
                  ImageSelectionWidget(),

                  SizedBox(
                    height: isSmallScreen
                        ? 30.0
                        : isTablet
                        ? 50.0
                        : 40.0,
                  ),

                  // EXTERIOR DESIGNS - HORIZONTAL LIST
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Exterior Design',
                        style: TextStyle(
                          fontSize: isSmallScreen
                              ? 14.0
                              : isTablet
                              ? 18.0
                              : 16.0,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 12.0 : 15.0),
                      _buildExteriorDesignsList(uploadProvider, screenWidth),
                    ],
                  ),

                  // SPACER
                  SizedBox(
                    height: AppTheme.responsiveSize(
                      context,
                      phone: 20,
                      tablet: 30,
                    ),
                  ),

                  // GENERATE BUTTON WIDGET
                  GenerateButtonWidget(
                    onGeneratePressed: () =>
                        _generateExteriorDesign(uploadProvider, context),
                  ),
                  SizedBox(
                    height: AppTheme.responsiveSize(
                      context,
                      phone: 10,
                      tablet: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExteriorDesignsList(
    UploadProvider uploadProvider,
    double screenWidth,
  ) {
    final exteriorDesigns = [
      {
        'name': 'Modern',
        'image': 'assets/images/modern.jpg',
        'description':
            'Sleek geometric forms, flat roofs, floor-to-ceiling windows, minimalist aesthetic',
      },
      {
        'name': 'Small House',
        'image': 'assets/images/small.jpg',
        'description':
            'Compact footprint, efficient layout, cozy proportions, smart storage',
      },
      {
        'name': 'Bunglow',
        'image': 'assets/images/banglow.jpg',
        'description':
            'Single-story layout, wide verandas, low-pitched roofs, cozy living',
      },
      {
        'name': 'Simple',
        'image': 'assets/images/simple.jpg',
        'description':
            'Clean rectangular forms, basic rooflines, uncomplicated details',
      },
      {
        'name': 'Residential',
        'image': 'assets/images/residential.jpg',
        'description':
            'Traditional family home, pitched roof, front porch, balanced windows',
      },
      {
        'name': 'Building',
        'image': 'assets/images/building.jpg',
        'description':
            'Multi-level structure, rectangular massing, repetitive windows',
      },
      {
        'name': 'Villa',
        'image': 'assets/images/villa.jpg',
        'description':
            'Spacious luxury residence, grand entrance, landscaped surroundings',
      },
      {
        'name': 'Contemporary',
        'image': 'assets/images/contemporary.jpg',
        'description': 'Asymmetrical forms, mixed materials, large glass areas',
      },
      {
        'name': 'Commercial Building',
        'image': 'assets/images/commercial.jpg',
        'description':
            'Professional facade, large entrance, corporate identity',
      },
    ];

    return SizedBox(
      // Increased to avoid overflow on tablets
      height: AppTheme.responsiveSize(context, phone: 190, tablet: 260),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: exteriorDesigns.length,
        // Add cache extent to prevent memory issues
        cacheExtent: 1000,
        itemBuilder: (context, index) {
          final design = exteriorDesigns[index];
          final isSelected = uploadProvider.selectedRoomType == design['name'];

          // Use try-catch to prevent crashes from missing images
          return FloorDesignCard(
            name: design['name']!,
            image: design['image']!,
            isSelected: isSelected,
            onTap: () {
              uploadProvider.setSelectedRoomType(design['name']!);
            },
          );
        },
      ),
    );
  }

  static const int _creditsPerGeneration = 5;

  void _generateExteriorDesign(
    UploadProvider uploadProvider,
    BuildContext context,
  ) async {
    final creditManager = Provider.of<CreditManager>(context, listen: false);
    try {
      // Check if image is selected
      if (uploadProvider.selectedImage == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an image first'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Check if exterior design is selected
      if (uploadProvider.selectedRoomType == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an exterior design type'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (creditManager.isLoading) {
        await creditManager.init();
        if (!mounted) return;
      }

      // DIRECT API CALL
      if (!creditManager.hasEnoughCredits(_creditsPerGeneration)) {
        _showInsufficientCreditsDialog(context);
        return;
      }

      if (!mounted) return;
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
                'Generating your exterior design...',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ],
          ),
        ),
      );

      String selectedStyle = uploadProvider.selectedRoomType ?? 'Modern';
      String exteriorPrompt =
          """
EXTERIOR BUILDING REDESIGN: Transform this building into $selectedStyle style while keeping exact same structure, size, and layout. Only change exterior materials, colors, and details.
""";

      String generatedImageUrl = await GeminiService.generateImageFromPrompt(
        prompt: exteriorPrompt,
        imageFile: uploadProvider.selectedImage!,
      );

      final deductionSucceeded = await creditManager.deductCredits(
        _creditsPerGeneration,
        reason: 'exterior_generation',
      );

      if (!deductionSucceeded) {
        if (mounted) {
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

      if (mounted) Navigator.pop(context);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              generatedImageUrl: generatedImageUrl,
              roomType: uploadProvider.selectedRoomType!,
              style: "Exterior Design",
              budget: "Not Specified",
              prompt: exteriorPrompt,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Generation failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
            'You need at least $_creditsPerGeneration credits to generate this exterior design.',
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
