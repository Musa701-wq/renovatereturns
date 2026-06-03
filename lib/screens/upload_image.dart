import 'package:ai_remodeling/screens/result_screen.dart';
import '../widgets/loading_overlay.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../in_app_purchase/credit_manager.dart';
import '../in_app_purchase/credit_purchase_screen.dart';
import '../provider/upload_provider.dart';
import '../services/exception_handler.dart';
import '../widgets/generate_button.dart';
import '../widgets/image_selection_widget.dart';
import '../utils/theme.dart';
import '../services/api_services.dart';
import '../services/prompt_v2.dart';
import '../services/image_storage_service.dart';
import '../screens/login_screen.dart';
import '../provider/auth_provider.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  static const int _creditsPerGeneration = 5;

  final TextEditingController _roomTypeSearchController = TextEditingController();
  final TextEditingController _styleSearchController = TextEditingController();
  final TextEditingController _budgetSearchController = TextEditingController();
  final TextEditingController _customizationController = TextEditingController();

  List<String> _filteredRoomTypes = [];
  List<String> _filteredStyles = [];
  List<String> _filteredBudgets = [];

  @override
  void initState() {
    super.initState();
    _filteredRoomTypes = Provider.of<UploadProvider>(context, listen: false).roomTypes;
    _filteredStyles = Provider.of<UploadProvider>(context, listen: false).styleOptions;
    _filteredBudgets = Provider.of<UploadProvider>(context, listen: false).budgetOptions;
  }

  @override
  void dispose() {
    _roomTypeSearchController.dispose();
    _styleSearchController.dispose();
    _budgetSearchController.dispose();
    _customizationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: const Text('Upload & Generate'),
        backgroundColor: AppTheme.secondaryColor,
        foregroundColor: AppTheme.primaryColor,
        leading: IconButton(
          icon: Icon(
            AppTheme.backButtonIcon,
            size: AppTheme.backButtonIconSize(context),
          ),
          onPressed: () {
            final uploadProvider = Provider.of<UploadProvider>(context, listen: false);
            uploadProvider.setSelectedRoomType(null);
            uploadProvider.setSelectedImage(null);
            uploadProvider.setSelectedImageSource(null);
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
                  // IMAGE SELECTION WIDGET
                  ImageSelectionWidget(),

                  SizedBox(height: AppTheme.responsiveSize(context, phone: 20, tablet: 28)),

                  // ROOM TYPE CATEGORY
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Room Type',
                        style: TextStyle(
                          fontSize: AppTheme.responsiveFont(context, phone: 16, tablet: 18),
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      SizedBox(height: AppTheme.responsiveSize(context, phone: 8, tablet: 10)),
                      _buildSelectionField(
                        value: uploadProvider.selectedRoomType,
                        onTap: () => _showRoomTypeBottomSheet(context, uploadProvider),
                      ),
                    ],
                  ),

                  SizedBox(height: AppTheme.responsiveSize(context, phone: 20, tablet: 28)),

                  // STYLE AND BUDGET CATEGORIES
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ai Intervention',
                              style: TextStyle(
                                fontSize: AppTheme.responsiveFont(context, phone: 16, tablet: 22),
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            SizedBox(height: AppTheme.responsiveSize(context, phone: 8, tablet: 10)),
                            _buildSelectionField(
                              value: uploadProvider.selectedStyle,
                              onTap: () => _showStyleBottomSheet(context, uploadProvider),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: AppTheme.responsiveSize(context, phone: 15, tablet: 20)),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Budget',
                              style: TextStyle(
                                fontSize: AppTheme.responsiveFont(context, phone: 16, tablet: 22),
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            SizedBox(height: AppTheme.responsiveSize(context, phone: 8, tablet: 10)),
                            _buildSelectionField(
                              value: uploadProvider.selectedBudget,
                              onTap: () => _showBudgetBottomSheet(context, uploadProvider),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppTheme.responsiveSize(context, phone: 20, tablet: 28)),

                  // CUSTOMIZATION TEXT FIELD (OPTIONAL)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Custom Requirements ',
                            style: TextStyle(
                              fontSize: AppTheme.responsiveFont(context, phone: 16, tablet: 18),
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          Text(
                            '(Optional)',
                            style: TextStyle(
                              fontSize: AppTheme.responsiveFont(context, phone: 12, tablet: 14),
                              color: AppTheme.primaryColor.withOpacity(0.6),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppTheme.responsiveSize(context, phone: 8, tablet: 10)),
                      Container(
                        height: AppTheme.responsiveSize(context, phone: 100, tablet: 130),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(
                            AppTheme.responsiveSize(context, phone: 12, tablet: 14),
                          ),
                          border: Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _customizationController,
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: AppTheme.responsiveFont(context, phone: 14, tablet: 18),
                          ),
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: InputDecoration(
                            hintText: 'e.g., Add a fireplace, use blue color scheme, include plants...',
                            hintStyle: TextStyle(
                              color: AppTheme.primaryColor.withOpacity(0.5),
                              fontSize: AppTheme.responsiveFont(context, phone: 12, tablet: 16),
                            ),
                            contentPadding: EdgeInsets.all(
                              AppTheme.responsiveSize(context, phone: 12, tablet: 16),
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(height: AppTheme.responsiveSize(context, phone: 6, tablet: 8)),
                      Text(
                        'Leave blank for standard AI design or add your specific requirements',
                        style: TextStyle(
                          fontSize: AppTheme.responsiveFont(context, phone: 11, tablet: 13),
                          color: AppTheme.primaryColor.withOpacity(0.6),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
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

                  SizedBox(height: AppTheme.responsiveSize(context, phone: 30, tablet: 40)),

                  // GENERATE BUTTON WIDGET
                  GenerateButtonWidget(
                    onGeneratePressed: () => _generateImage(uploadProvider, context),
                  ),

                  SizedBox(height: AppTheme.responsiveSize(context, phone: 20, tablet: 24)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectionField({
    required String? value,
    required VoidCallback onTap,
  }) {
    final double paddingH = AppTheme.responsiveSize(context, phone: 16, tablet: 24);
    final double paddingV = AppTheme.responsiveSize(context, phone: 14, tablet: 20);
    final double fontSize = AppTheme.responsiveFont(context, phone: 16, tablet: 22);
    final double iconSize = AppTheme.responsiveSize(context, phone: 20, tablet: 30);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? 'Select',
                style: TextStyle(color: AppTheme.primaryColor, fontSize: fontSize),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor, size: iconSize),
          ],
        ),
      ),
    );
  }

  void _showRoomTypeBottomSheet(BuildContext context, UploadProvider uploadProvider) {
    _roomTypeSearchController.clear();
    _filteredRoomTypes = uploadProvider.roomTypes;
    _showSelectionBottomSheet(
      context: context,
      title: 'Room Type',
      searchController: _roomTypeSearchController,
      allItems: uploadProvider.roomTypes,
      filteredItems: _filteredRoomTypes,
      selectedItem: uploadProvider.selectedRoomType,
      onSearchChanged: (query) {
        setState(() {
          _filteredRoomTypes = uploadProvider.roomTypes
              .where((item) => item.toLowerCase().contains(query.toLowerCase()))
              .toList();
        });
      },
      onSelect: (value) => uploadProvider.setSelectedRoomType(value),
    );
  }

  void _showStyleBottomSheet(BuildContext context, UploadProvider uploadProvider) {
    _styleSearchController.clear();
    _filteredStyles = uploadProvider.styleOptions;
    _showSelectionBottomSheet(
      context: context,
      title: 'Intervention',
      description: 'Choose the design intensity for your room',
      searchController: _styleSearchController,
      allItems: uploadProvider.styleOptions,
      filteredItems: _filteredStyles,
      selectedItem: uploadProvider.selectedStyle,
      onSearchChanged: (query) {
        setState(() {
          _filteredStyles = uploadProvider.styleOptions
              .where((item) => item.toLowerCase().contains(query.toLowerCase()))
              .toList();
        });
      },
      onSelect: (value) => uploadProvider.setSelectedStyle(value),
    );
  }

  void _showBudgetBottomSheet(BuildContext context, UploadProvider uploadProvider) {
    _budgetSearchController.clear();
    _filteredBudgets = uploadProvider.budgetOptions;
    _showSelectionBottomSheet(
      context: context,
      title: 'Budget',
      description: 'Choose your budget level for the project',
      searchController: _budgetSearchController,
      allItems: uploadProvider.budgetOptions,
      filteredItems: _filteredBudgets,
      selectedItem: uploadProvider.selectedBudget,
      onSearchChanged: (query) {
        setState(() {
          _filteredBudgets = uploadProvider.budgetOptions
              .where((item) => item.toLowerCase().contains(query.toLowerCase()))
              .toList();
        });
      },
      onSelect: (value) => uploadProvider.setSelectedBudget(value),
    );
  }

  void _showSelectionBottomSheet({
    required BuildContext context,
    required String title,
    String? description,
    required TextEditingController searchController,
    required List<String> allItems,
    required List<String> filteredItems,
    required String? selectedItem,
    required Function(String) onSearchChanged,
    required Function(String) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.secondaryColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: 5),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.primaryColor.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 15),

              Expanded(
                child: filteredItems.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        color: AppTheme.primaryColor.withOpacity(0.5),
                        size: 50,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'No results found',
                        style: TextStyle(
                          color: AppTheme.primaryColor.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        onSelect(item);
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: selectedItem == item
                              ? AppTheme.primaryColor.withOpacity(0.3)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          title: Text(
                            item,
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 16,
                            ),
                          ),
                          trailing: selectedItem == item
                              ? Icon(
                            Icons.check,
                            color: AppTheme.primaryColor,
                          )
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.3),
                    foregroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _generateImage(UploadProvider uploadProvider, BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.currentUser == null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
      return;
    }

    final creditManager = Provider.of<CreditManager>(context, listen: false);
    final int cost = uploadProvider.isMultipleVariationsEnabled ? 15 : 5;

    try {
      if (creditManager.isLoading) {
        await creditManager.init();
        if (!mounted) return;
      }

      if (!creditManager.hasEnoughCredits(cost)) {
        _showInsufficientCreditsDialog(context, cost);
        return;
      }

      LoadingOverlay.show(context);

      String customization = _customizationController.text.trim();
      bool isFreeTier = !creditManager.hasPurchased;

      String prompt = isFreeTier
          ? PromptGeneratorV2.generateFreeTierRedesignPrompt(
              roomType: uploadProvider.selectedRoomType!,
              style: uploadProvider.selectedStyle!,
              budget: uploadProvider.selectedBudget!,
              imageSource: uploadProvider.selectedImageSource ?? 'Unknown',
            )
          : uploadProvider.generateAIPromptWithCustomization(
              customization: customization.isEmpty ? null : customization,
            );

      List<String> generatedImageUrls = [];
      if (uploadProvider.isMultipleVariationsEnabled) {
        generatedImageUrls = await uploadProvider.generateMultipleImagesFromAPI(
          basePrompt: prompt,
          imageFile: uploadProvider.selectedImage!,
        );
      } else {
        String url;
        if (isFreeTier) {
          url = await GeminiService.generateImageFreeTier(
            prompt: prompt,
            imageFile: uploadProvider.selectedImage!,
          );
        } else {
          url = await uploadProvider.generateImageWithCustomization(
            customization: customization.isEmpty ? null : customization,
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
        reason: uploadProvider.isMultipleVariationsEnabled ? 'multiple_variations' : 'instant_generation',
      );

      if (!deductionSucceeded) {
        if (context.mounted) {
          Navigator.pop(context);
          ExceptionHandler.showToast('Unable to deduct credits');
        }
        return;
      }

      if (context.mounted) Navigator.pop(context);

      ExceptionHandler.showSuccess(
        '${uploadProvider.selectedRoomType} design generated!',
      );

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              generatedImageUrls: generatedImageUrls,
              roomType: uploadProvider.selectedRoomType!,
              style: uploadProvider.selectedStyle!,
              budget: uploadProvider.selectedBudget!,
              prompt: prompt,
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
            'You need at least $requiredCredits credits to generate this design.',
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
}