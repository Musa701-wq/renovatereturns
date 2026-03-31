import 'package:flutter/material.dart';
import '../widgets/loading_overlay.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../in_app_purchase/credit_manager.dart';
import '../in_app_purchase/credit_purchase_screen.dart';
import '../provider/upload_provider.dart';
import '../screens/result_screen.dart';
import '../services/api_services.dart';
import '../services/exception_handler.dart';
import '../services/prompt_v2.dart';
import '../widgets/generate_button.dart';
import '../widgets/image_selection_widget.dart';
import '../widgets/wall_card.dart';
import '../utils/theme.dart';
import '../services/image_storage_service.dart';
import '../widgets/credit_dialog.dart';
import '../in_app_purchase/i_ap_manager.dart';

class WaalRedesign extends StatefulWidget {
  const WaalRedesign({super.key});

  @override
  State<WaalRedesign> createState() => _WaalRedesignState();
}

class _WaalRedesignState extends State<WaalRedesign> {
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;
    final double listHeight = AppTheme.responsiveSize(
      context,
      phone: 170,
      tablet: 220,
    );
    final double afterListSpacing = AppTheme.responsiveSize(
      context,
      phone: 16,
      tablet: 20,
    );
    final double descriptionToButtonSpacing = AppTheme.responsiveSize(
      context,
      phone: 80,
      tablet: 110,
    );

    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: const Text('Wall Redesign'),
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
          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: EdgeInsets.all(
                      AppTheme.responsivePadding(context),
                    ),
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
                              'Select Wall Design',
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
                            _buildWallDesignsList(uploadProvider, listHeight),
                          ],
                        ),
                        if (!isTablet)
                          SizedBox(
                            height: AppTheme.responsiveSize(
                              context,
                              phone: 20,
                              tablet: 26,
                            ),
                          ),
                        if (uploadProvider.selectedRoomType != null)
                          _buildDescriptionContainer(
                            uploadProvider,
                            MediaQuery.of(context).size.width,
                          ),
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
                          onGeneratePressed: () {
                            _generateWallDesign(uploadProvider, context);
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
          );
        },
      ),
    );
  }

  Widget _buildDescriptionContainer(
      UploadProvider uploadProvider,
      double screenWidth,
      ) {
    return Container(
      padding: EdgeInsets.all(
        AppTheme.responsiveSize(context, phone: 16, tablet: 20),
      ),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add Custom Requirements (Optional)',
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
            ],
          ),
          SizedBox(
            height: AppTheme.responsiveSize(context, phone: 10, tablet: 12),
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
                  borderRadius: BorderRadius.circular(
                    AppTheme.responsiveSize(context, phone: 8, tablet: 10),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: AppTheme.responsiveSize(
                    context,
                    phone: 12,
                    tablet: 14,
                  ),
                  horizontal: AppTheme.responsiveSize(
                    context,
                    phone: 14,
                    tablet: 18,
                  ),
                ),
              ),
              child: Text(
                'Add Custom Requirements',
                style: TextStyle(
                  fontSize: AppTheme.responsiveFont(
                    context,
                    phone: 14,
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
                    'Example: Light blue color, textured finish, wainscoting...',
                    hintStyle: TextStyle(
                      color: AppTheme.primaryColor.withOpacity(0.5),
                      fontSize: AppTheme.responsiveFont(
                        context,
                        phone: 13,
                        tablet: 15,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppTheme.responsiveSize(context, phone: 8, tablet: 10),
                      ),
                      borderSide: BorderSide(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppTheme.responsiveSize(context, phone: 8, tablet: 10),
                      ),
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppTheme.responsiveSize(context, phone: 8, tablet: 10),
                      ),
                      borderSide: BorderSide(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: AppTheme.responsiveSize(
                    context,
                    phone: 10,
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
                            borderRadius: BorderRadius.circular(
                              AppTheme.responsiveSize(
                                context,
                                phone: 8,
                                tablet: 10,
                              ),
                            ),
                            side: BorderSide(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: AppTheme.responsiveSize(
                              context,
                              phone: 12,
                              tablet: 14,
                            ),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: AppTheme.responsiveFont(
                              context,
                              phone: 14,
                              tablet: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: AppTheme.responsiveSize(
                        context,
                        phone: 10,
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
                            borderRadius: BorderRadius.circular(
                              AppTheme.responsiveSize(
                                context,
                                phone: 8,
                                tablet: 10,
                              ),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: AppTheme.responsiveSize(
                              context,
                              phone: 12,
                              tablet: 14,
                            ),
                          ),
                        ),
                        child: Text(
                          'Save',
                          style: TextStyle(
                            fontSize: AppTheme.responsiveFont(
                              context,
                              phone: 14,
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

  Widget _buildWallDesignsList(
      UploadProvider uploadProvider,
      double listHeight,
      ) {
    final wallDesigns = [
      {'name': 'Paint', 'image': 'assets/images/paint.jpg'},
      {'name': 'Wallpaper', 'image': 'assets/images/wallpaper.jpg'},
      {'name': 'Wood Paneling', 'image': 'assets/images/wood.jpg'},
      {'name': 'Stone Veneer', 'image': 'assets/images/stoneveneur.jpg'},
      {'name': 'Brick', 'image': 'assets/images/bricks.jpg'},
      {'name': 'Tile', 'image': 'assets/images/tiles.jpg'},
      {'name': 'Concrete', 'image': 'assets/images/concrete_floor.jpg'},
      {'name': 'Fabric', 'image': 'assets/images/fabric.jpg'},
      {'name': 'Venetian Plaster', 'image': 'assets/images/plaster.jpg'},
      {'name': 'Murals', 'image': 'assets/images/mural.jpg'},
      {'name': 'Glass', 'image': 'assets/images/glass.jpg'},
      {'name': 'Mosaic', 'image': 'assets/images/mosaic.jpg'},
      {'name': 'Cork', 'image': 'assets/images/cork.jpg'},
      {'name': '3D Wall Panels', 'image': 'assets/images/3dwallpaper.jpg'},
      {'name': 'Chalkboard', 'image': 'assets/images/chalkboardwall.jpg'},
    ];

    return SizedBox(
      height: listHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: wallDesigns.length,
        itemBuilder: (context, index) {
          final design = wallDesigns[index];
          final isSelected = uploadProvider.selectedRoomType == design['name'];

          return WallDesignCard(
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

  void _generateWallDesign(
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
        ExceptionHandler.showToast('Please select a wall design type');
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
            'You need at least $cost credits to generate this wall design.',
            IAPManager().products,
          );
        }
        return;
      }

      LoadingOverlay.show(context);

      String customDescription = _descriptionController.text.trim();
      bool isFreeTier = !creditManager.hasPurchased;

      String finalPrompt = isFreeTier
          ? PromptGeneratorV2.generateFreeTierWallPrompt(
              wallType: uploadProvider.selectedRoomType!,
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
          url = await _generateWallImageWithCustomPrompt(
            uploadProvider,
            finalPrompt,
            context,
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
        reason: uploadProvider.isMultipleVariationsEnabled ? 'multiple_variations' : 'wall_generation',
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
              style: "Wall Design",
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
    String basePrompt = uploadProvider.generateWallAIPrompt();

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

  Future<String> _generateWallImageWithCustomPrompt(
      UploadProvider uploadProvider,
      String prompt,
      BuildContext context,
      ) async {
    try {
      print('🚀 Starting wall design generation with custom prompt...');
      print('📝 Combined Prompt: ${prompt.substring(0, 100)}...');

      String generatedImageUrl = await GeminiService.generateImageFromPrompt(
        prompt: prompt,
        imageFile: uploadProvider.selectedImage!,
      );

      print('✅ Wall design generated successfully with custom requirements');
      return generatedImageUrl;
    } catch (e) {
      throw Exception('Wall design generation failed: $e');
    }
  }
}