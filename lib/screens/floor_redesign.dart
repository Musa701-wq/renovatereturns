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

class FloorRedesign extends StatefulWidget {
  const FloorRedesign({super.key});

  @override
  State<FloorRedesign> createState() => _FloorRedesignState();
}

class _FloorRedesignState extends State<FloorRedesign> {
  final TextEditingController _descriptionController = TextEditingController();
  bool _showDescriptionField = false;
  static const int _creditsPerGeneration = 5;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double listHeight = AppTheme.responsiveSize(
      context,
      phone: 190,
      tablet: 280,
    );
    final double afterListSpacing = AppTheme.responsiveSize(
      context,
      phone: 16,
      tablet: 20,
    );
    final double gapBetweenImageAndList = AppTheme.responsiveSize(
      context,
      phone: 40,
      tablet: 55,
    );
    final double descriptionToButtonSpacing = AppTheme.responsiveSize(
      context,
      phone: 90,
      tablet: 130,
    );

    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: const Text('Floor Redesign'),
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
              padding: EdgeInsets.all(AppTheme.responsivePadding(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ImageSelectionWidget(),

                  SizedBox(height: gapBetweenImageAndList),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Floor Design',
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
                      SizedBox(height: afterListSpacing),
                      _buildFloorDesignsList(uploadProvider, listHeight),
                    ],
                  ),

                 // SizedBox(height: afterListSpacing),

                  if (uploadProvider.selectedRoomType != null)
                    _buildDescriptionContainer(uploadProvider),

                  SizedBox(height: descriptionToButtonSpacing),

                  GenerateButtonWidget(
                    onGeneratePressed: () =>
                        _generateFloorDesign(uploadProvider, context),
                  ),
                  SizedBox(
                    height: AppTheme.responsiveSize(
                      context,
                      phone: 10,
                      tablet: 14,
                    ),
                  ),
                  SizedBox(height: mediaQuery.padding.bottom),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDescriptionContainer(UploadProvider uploadProvider) {
    final double paddingValue = AppTheme.responsiveSize(
      context,
      phone: 12,
      tablet: 20,
    );
    final double borderRadius = AppTheme.responsiveSize(
      context,
      phone: 10,
      tablet: 14,
    );
    final double buttonRadius = AppTheme.responsiveSize(
      context,
      phone: 6,
      tablet: 10,
    );

    return Container(
      padding: EdgeInsets.all(paddingValue),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 17, 10, 14).withOpacity(0.2),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Custom Requirements (Optional)',
            style: TextStyle(
              fontSize: AppTheme.responsiveFont(
                context,
                phone: 13,
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
              tablet: 12,
            ),
          ),
          if (!_showDescriptionField)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showDescriptionField = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: AppTheme.secondaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(buttonRadius),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: AppTheme.responsiveSize(
                    context,
                    phone: 10,
                    tablet: 14,
                  ),
                  horizontal: AppTheme.responsiveSize(
                    context,
                    phone: 12,
                    tablet: 20,
                  ),
                ),
              ),
              child: Text(
                'Add Custom Requirements',
                style: TextStyle(
                  fontSize: AppTheme.responsiveFont(
                    context,
                    phone: 13,
                    tablet: 15,
                  ),
                ),
              ),
            )
          else
            Column(
              children: [
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: AppTheme.responsiveFont(
                      context,
                      phone: 14,
                      tablet: 16,
                    ),
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'Example: Light oak color, wide planks, matte finish...',
                    hintStyle: TextStyle(
                      color: AppTheme.primaryColor.withOpacity(0.5),
                      fontSize: AppTheme.responsiveFont(
                        context,
                        phone: 13,
                        tablet: 15,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(buttonRadius),
                      borderSide: BorderSide(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(buttonRadius),
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(buttonRadius),
                      borderSide: BorderSide(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: AppTheme.responsiveSize(
                    context,
                    phone: 8,
                    tablet: 12,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showDescriptionField = false;
                            _descriptionController.clear();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryColor,
                          foregroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(buttonRadius),
                            side: BorderSide(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: AppTheme.responsiveSize(
                              context,
                              phone: 10,
                              tablet: 14,
                            ),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: AppTheme.responsiveFont(
                              context,
                              phone: 13,
                              tablet: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: AppTheme.responsiveSize(
                        context,
                        phone: 8,
                        tablet: 12,
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showDescriptionField = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: AppTheme.secondaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(buttonRadius),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: AppTheme.responsiveSize(
                              context,
                              phone: 10,
                              tablet: 14,
                            ),
                          ),
                        ),
                        child: Text(
                          'Save',
                          style: TextStyle(
                            fontSize: AppTheme.responsiveFont(
                              context,
                              phone: 13,
                              tablet: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFloorDesignsList(
    UploadProvider uploadProvider,
    double listHeight,
  ) {
    final floorDesigns = [
      {'name': 'Carpet', 'image': 'assets/images/carpet_floor.jpg'},
      {'name': 'Hardwood', 'image': 'assets/images/hardwood_floor.jpg'},
      {'name': 'Vinyl', 'image': 'assets/images/vinyl_floor.jpg'},
      {'name': 'Stone', 'image': 'assets/images/stone_flooe.jpg'},
      {'name': 'Concrete', 'image': 'assets/images/concrete_floor.jpg'},
      {'name': 'Rubber', 'image': 'assets/images/rubber_floor.jpg'},
      {'name': 'Tile & Stone', 'image': 'assets/images/tileandstone_floor.jpg'},
      {'name': 'Cork', 'image': 'assets/images/cork_floor.jpg'},
      {'name': 'Laminate', 'image': 'assets/images/laminate_floor.jpg'},
      {'name': 'Terrazzo', 'image': 'assets/images/terazoo_floor.jpg'},
      {'name': 'Bamboo', 'image': 'assets/images/bambo_floor.jpg'},
      {'name': 'Slate', 'image': 'assets/images/slate_floor.jpg'},
      {'name': 'Marble', 'image': 'assets/images/marbel_floor.jpg'},
      {'name': 'Granite', 'image': 'assets/images/granite_floor.jpg'},
    ];

    return SizedBox(
      height: listHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: floorDesigns.length,
        itemBuilder: (context, index) {
          final design = floorDesigns[index];
          final isSelected = uploadProvider.selectedRoomType == design['name'];

          // Using ItemDesignCard (from item_design_card.dart) instead of FloorDesignCard
          return FloorDesignCard(
            name: design['name']!,
            image: design['image']!,
            isSelected: isSelected,
            onTap: () {
              uploadProvider.setSelectedRoomType(design['name']!);
              setState(() {
                _showDescriptionField = false;
                _descriptionController.clear();
              });
            },
          );
        },
      ),
    );
  }

  void _generateFloorDesign(
    UploadProvider uploadProvider,
    BuildContext context,
  ) async {
    final creditManager = Provider.of<CreditManager>(context, listen: false);
    try {
      if (uploadProvider.selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an image first'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (uploadProvider.selectedRoomType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a floor design type'),
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
                'Generating your floor design...',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ],
          ),
        ),
      );

      String customDescription = _descriptionController.text.trim();
      String finalPrompt = _generateCombinedPrompt(
        uploadProvider,
        customDescription,
      );

      String generatedImageUrl = await _generateFloorImageWithCustomPrompt(
        uploadProvider,
        finalPrompt,
        context,
      );

      final deductionSucceeded = await creditManager.deductCredits(
        _creditsPerGeneration,
        reason: 'floor_generation',
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
              generatedImageUrl: generatedImageUrl,
              roomType: uploadProvider.selectedRoomType!,
              style: "Floor Design",
              budget: "Not Specified",
              prompt: finalPrompt,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Generation failed: ${e.toString()}'),
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
            'You need at least $_creditsPerGeneration credits to generate this floor design.',
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

  String _generateCombinedPrompt(
    UploadProvider uploadProvider,
    String customDescription,
  ) {
    String basePrompt = uploadProvider.generateFloorAIPrompt();

    if (customDescription.isNotEmpty) {
      return """
$basePrompt

ADDITIONAL USER REQUIREMENTS:
$customDescription

FINAL INSTRUCTIONS: Incorporate the above user requirements while maintaining all previous transformation rules.
""";
    }

    return basePrompt;
  }

  Future<String> _generateFloorImageWithCustomPrompt(
    UploadProvider uploadProvider,
    String prompt,
    BuildContext context,
  ) async {
    try {
      print('🚀 Starting floor design generation with custom prompt...');
      print('📝 Combined Prompt: ${prompt.substring(0, 100)}...');

      String generatedImageUrl = await GeminiService.generateImageFromPrompt(
        prompt: prompt,
        imageFile: uploadProvider.selectedImage!,
      );

      print('✅ Floor design generated successfully with custom requirements');
      return generatedImageUrl;
    } catch (e) {
      throw Exception('Floor design generation failed: $e');
    }
  }
}
