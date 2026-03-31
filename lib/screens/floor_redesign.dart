import 'package:ai_remodeling/screens/result_screen.dart';
import '../widgets/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../in_app_purchase/credit_manager.dart';
import '../in_app_purchase/credit_purchase_screen.dart';
import '../provider/upload_provider.dart';
import '../services/api_services.dart';
import '../services/exception_handler.dart';
import '../services/prompt_v2.dart';
import '../widgets/generate_button.dart';
import '../widgets/image_selection_widget.dart';
import '../utils/theme.dart';
import '../widgets/item_design_card.dart';
import '../services/image_storage_service.dart';
import '../widgets/credit_dialog.dart';
import '../in_app_purchase/i_ap_manager.dart';

class FloorRedesign extends StatefulWidget {
  const FloorRedesign({super.key});

  @override
  State<FloorRedesign> createState() => _FloorRedesignState();
}

class _FloorRedesignState extends State<FloorRedesign> {
  final TextEditingController _descriptionController = TextEditingController();
  bool _showDescriptionField = false;

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
      phone: 40,
      tablet: 60,
    );

    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: const Text('Floor Redesign'),
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
                  if (uploadProvider.selectedRoomType != null)
                    _buildDescriptionContainer(uploadProvider),
                  
                  SizedBox(height: 20),

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
      margin: const EdgeInsets.only(top: 10),
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
    final int cost = uploadProvider.isMultipleVariationsEnabled ? 15 : 5;

    try {
      if (uploadProvider.selectedImage == null) {
        ExceptionHandler.showToast('Please select an image first');
        return;
      }

      if (uploadProvider.selectedRoomType == null) {
        ExceptionHandler.showToast('Please select a floor design type');
        return;
      }

      if (creditManager.isLoading) {
        await creditManager.init();
        if (!mounted) return;
      }

      if (!creditManager.hasEnoughCredits(cost)) {
        if (mounted) {
          CreditDialog.show(
            context,
            'You need at least $cost credits to generate this floor design.',
            IAPManager().products,
          );
        }
        return;
      }

      LoadingOverlay.show(context);

      String customDescription = _descriptionController.text.trim();
      bool isFreeTier = !creditManager.hasPurchased;

      String finalPrompt = isFreeTier
          ? PromptGeneratorV2.generateFreeTierFloorPrompt(
              floorType: uploadProvider.selectedRoomType!,
              imageSource: uploadProvider.selectedImageSource ?? 'Unknown',
            )
          : _generateCombinedPrompt(
              uploadProvider,
              customDescription,
            );

      List<String> generatedImageUrls = [];
      if (uploadProvider.isMultipleVariationsEnabled) {
        generatedImageUrls = await uploadProvider.generateMultipleImagesFromAPI(
          basePrompt: finalPrompt,
          imageFile: uploadProvider.selectedImage!,
        );
      } else {
        String url;
        if (isFreeTier) {
          url = await GeminiService.generateImageFreeTier(
            prompt: finalPrompt,
            imageFile: uploadProvider.selectedImage!,
          );
        } else {
          url = await GeminiService.generateImageFromPrompt(
            prompt: finalPrompt,
            imageFile: uploadProvider.selectedImage!,
          );
        }
        generatedImageUrls = [url];
      }

      if (generatedImageUrls.isNotEmpty) {
        for (final img in generatedImageUrls) {
          await ImageStorageService.uploadAndStore(img);
        }
      }

      final deductionSucceeded = await creditManager.deductCredits(
        cost,
        reason: uploadProvider.isMultipleVariationsEnabled ? 'multiple_variations' : 'floor_generation',
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
              roomType: uploadProvider.selectedRoomType!,
              style: "Floor Design",
              budget: "Not Specified",
              prompt: finalPrompt,
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
}