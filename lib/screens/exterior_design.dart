import 'package:ai_remodeling/screens/result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../in_app_purchase/credit_manager.dart';
import '../in_app_purchase/credit_purchase_screen.dart';
import '../provider/upload_provider.dart';
import '../services/api_services.dart';
import '../services/exception_handler.dart';
import '../services/prompt_.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uploadProvider = Provider.of<UploadProvider>(
        context,
        listen: false,
      );
      uploadProvider.setSelectedRoomType(null);
    });
  }

  @override
  Widget build(BuildContext context) {
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
          child: Icon(
            CupertinoIcons.back,
            size: AppTheme.backButtonIconSize(context),
          ),
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
                  ImageSelectionWidget(),
                  SizedBox(
                    height: isSmallScreen
                        ? 30.0
                        : isTablet
                        ? 50.0
                        : 40.0,
                  ),
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
                  SizedBox(height: AppTheme.responsiveSize(context, phone: 15, tablet: 20)),

                  // MULTIPLE VARIATIONS TOGGLE
                  Container(
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
                  ),

                  SizedBox(
                    height: AppTheme.responsiveSize(
                      context,
                      phone: 20,
                      tablet: 30,
                    ),
                  ),
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
      height: AppTheme.responsiveSize(context, phone: 190, tablet: 260),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: exteriorDesigns.length,
        cacheExtent: 1000,
        itemBuilder: (context, index) {
          final design = exteriorDesigns[index];
          final isSelected = uploadProvider.selectedRoomType == design['name'];

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

  void _generateExteriorDesign(
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

      if (uploadProvider.selectedRoomType == null) {
        ExceptionHandler.showToast('Please select an exterior design type');
        return;
      }

      if (creditManager.isLoading) {
        await creditManager.init();
        if (!mounted) return;
      }

      if (!creditManager.hasEnoughCredits(cost)) {
        _showInsufficientCreditsDialog(context, cost);
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
      String designRequirements = ExteriorPromptGenerator.exteriorDesignRequirements[selectedStyle] ??
          'architectural transformation, improved aesthetics, functional design';
      
      String exteriorPrompt = """
ARCHITECTURAL EXTERIOR REDESIGN - CRITICAL TRANSFORMATION PROMPT

REFERENCE IMAGE ANALYSIS:
- Analyze the provided building image carefully.
- Note the exact building structure, shape, and proportions.
- Identify current roof type, window positions, door locations.
- Understand the existing architectural layout and scale.

📐 PERSPECTIVE & ANGLE PRESERVATION (STRICT):
- Analyze the exact camera angle (front, side, or diagonally slanted).
- If the house is photographed from the side or at an angle, the output MUST maintain that SAME PERSPECTIVE.
- Do NOT shift to a flat front-facing view; respect the original photo's 3D perspective.

🏠 MANDATORY STRUCTURAL PRESERVATION:
- MAINTAIN the EXACT SAME building structure, footprint, and height.
- DO NOT build a "new house"; only restyle the existing one.
- KEEP identical roof shape, pitch, and profile.
- PRESERVE all window and door positions exactly as they are.
- DO NOT alter the fundamental building layout or shape.

$selectedStyle ARCHITECTURAL FEATURES:
$designRequirements

DESIGN ELEMENTS TO TRANSFORM:
- EXTERIOR MATERIALS: Update wall finishes, siding, or cladding.
- COLOR SCHEME: Apply $selectedStyle appropriate colors and tones.
- WINDOW STYLES: Change window designs while keeping same positions.
- DOOR DESIGNS: Update door styles within existing openings.
- ROOFING: Modify roof materials and details.
- LANDSCAPING: Enhance surrounding environment and landscaping.
- ARCHITECTURAL DETAILS: Add or modify decorative elements.
- LIGHTING: Improve exterior lighting features.

STRICT TRANSFORMATION RULES:
- ONLY modify surface materials, colors, and details.
- KEEP all structural elements in their exact positions.
- WORK within the existing building footprint and boundaries.

FINAL RESULT: The generated image must show the SAME building (same size, same structure, same angle) beautifully transformed into $selectedStyle architecture.
""";

      List<String> generatedImageUrls = [];
      if (uploadProvider.isMultipleVariationsEnabled) {
        generatedImageUrls = await uploadProvider.generateMultipleImagesFromAPI(
          basePrompt: exteriorPrompt,
          imageFile: uploadProvider.selectedImage!,
        );
      } else {
        String url = await GeminiService.generateImageFromPrompt(
          prompt: exteriorPrompt,
          imageFile: uploadProvider.selectedImage!,
        );
        generatedImageUrls = [url];
      }

      final deductionSucceeded = await creditManager.deductCredits(
        cost,
        reason: uploadProvider.isMultipleVariationsEnabled ? 'multiple_variations' : 'exterior_generation',
      );

      if (!deductionSucceeded) {
        if (mounted) {
          Navigator.pop(context);
          ExceptionHandler.showToast('Unable to deduct credits');
        }
        return;
      }

      if (mounted) Navigator.pop(context);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              generatedImageUrls: generatedImageUrls,
              roomType: uploadProvider.selectedRoomType!,
              style: "Exterior Design",
              budget: "Not Specified",
              prompt: exteriorPrompt,
              beforeImageUrl: uploadProvider.selectedImage?.path,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ExceptionHandler.handleException(e);
    }
  }

  void _showInsufficientCreditsDialog(BuildContext context, int requiredCredits) {
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
            'You need at least $requiredCredits credits to generate this exterior design.',
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
              child: const Text('Maybe later', style: TextStyle(color: AppTheme.primaryColor)),
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