import 'package:ai_remodeling/screens/result_screen.dart';
import '../services/backend_api_service.dart';
import '../services/prompt_.dart';
import '../widgets/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../in_app_purchase/credit_manager.dart';
import '../in_app_purchase/credit_purchase_screen.dart';
import '../provider/upload_provider.dart';
import '../services/exception_handler.dart';
import '../widgets/generate_button.dart';
import '../widgets/image_selection_widget.dart';
import '../utils/theme.dart';
import '../widgets/item_design_card.dart';
import '../services/image_storage_service.dart';
import '../widgets/credit_dialog.dart';
import '../in_app_purchase/i_ap_manager.dart';
import '../screens/login_screen.dart';
import '../provider/auth_provider.dart';

class GardenRedesignScreen extends StatefulWidget {
  const GardenRedesignScreen({super.key});

  @override
  State<GardenRedesignScreen> createState() => _GardenRedesignScreenState();
}

class _GardenRedesignScreenState extends State<GardenRedesignScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _customController = TextEditingController();
  late TabController _tabController;
  String? _selectedTemplate;
  final Map<String, int> _selectedItems = {
    'Tree': 0,
    'Flower Pot': 0,
    'Chair': 0,
    'Table': 0,
    'Bench': 0,
    'Lighting': 0,
    'BBQ Area': 0,
  };

  final List<Map<String, String>> _gardenTemplates = [
    {'name': 'Modern', 'image': 'assets/images/modern.jpg'},
    {'name': 'Japanese', 'image': 'assets/garden/japanese.jpg'},
    {'name': 'Tropical', 'image': 'assets/garden/tropical.png'},
    {'name': 'English Garden', 'image': 'assets/garden/english.png'},
    {'name': 'Minimalist', 'image': 'assets/garden/minimmalist.jpg'},
    {'name': 'Desert', 'image': 'assets/garden/desert.jpg'},
    {'name': 'Mediterranean', 'image': 'assets/garden/Mediterranean.jpg'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _customController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: const Text('Garden Redesign'),
        backgroundColor: AppTheme.secondaryColor,
        foregroundColor: AppTheme.primaryColor,
        leading: IconButton(
          icon: Icon(
            AppTheme.backButtonIcon,
            size: AppTheme.backButtonIconSize(context),
          ),
          onPressed: () {
            final uploadProvider = Provider.of<UploadProvider>(context, listen: false);
            uploadProvider.reset();
            Navigator.pop(context);
          },
        ),
      ),
      body: Consumer<UploadProvider>(
        builder: (context, uploadProvider, child) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(AppTheme.responsivePadding(context)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const ImageSelectionWidget(),
                        const SizedBox(height: 10),
                        TabBar(
                          controller: _tabController,
                          indicatorColor: AppTheme.primaryColor,
                          labelColor: AppTheme.primaryColor,
                          unselectedLabelColor: AppTheme.primaryColor.withOpacity(0.5),
                          tabs: const [
                            Tab(text: 'Templates', icon: Icon(Icons.grid_view)),
                            Tab(text: 'Custom', icon: Icon(Icons.edit_note)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        
                        SizedBox(
                          height: AppTheme.responsiveSize(
                            context,
                            phone: 300,
                            tablet: 450,
                          ),
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // Tab 1: Templates
                              _buildTemplatesTab(uploadProvider),
                              // Tab 2: Custom
                              _buildCustomTab(),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

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
                      ],
                    ),
                  ),
                ),
              ),
              
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.responsiveSize(context, phone: 20, tablet: 40),
                  vertical: AppTheme.responsiveSize(context, phone: 10, tablet: 15),
                ),
                child: GenerateButtonWidget(
                  onGeneratePressed: () => _handleGenerate(uploadProvider, context),
                ),
              ),
              SizedBox(height: mediaQuery.padding.bottom),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTemplatesTab(UploadProvider uploadProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Style Template',
          style: TextStyle(
            fontSize: AppTheme.responsiveFont(context, phone: 16, tablet: 22),
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: AppTheme.responsiveSize(
            context,
            phone: 190,
            tablet: 280,
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _gardenTemplates.length,
            itemBuilder: (context, index) {
              final template = _gardenTemplates[index];
              final isSelected = _selectedTemplate == template['name'];
              
              return FloorDesignCard(
                name: template['name']!,
                image: template['image']!,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedTemplate = template['name'];
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCustomTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Specific Additions',
          style: TextStyle(
            fontSize: AppTheme.responsiveFont(context, phone: 16, tablet: 22),
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          flex: 2,
          child: ListView(
            children: _selectedItems.keys.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: AppTheme.responsiveFont(context, phone: 14, tablet: 18),
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      color: AppTheme.primaryColor,
                      onPressed: () {
                        if (_selectedItems[item]! > 0) {
                          setState(() {
                            _selectedItems[item] = _selectedItems[item]! - 1;
                          });
                        }
                      },
                    ),
                    Text(
                      '${_selectedItems[item]}',
                      style: TextStyle(
                        fontSize: AppTheme.responsiveFont(context, phone: 16, tablet: 20),
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppTheme.primaryColor,
                      onPressed: () {
                        setState(() {
                          _selectedItems[item] = _selectedItems[item]! + 1;
                        });
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const Divider(),
        Text(
          'Custom Instructions (Optional)',
          style: TextStyle(
            fontSize: AppTheme.responsiveFont(context, phone: 14, tablet: 18),
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          flex: 1,
          child: TextField(
            controller: _customController,
            maxLines: 2,
            style: TextStyle(color: AppTheme.primaryColor, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Any other requests...',
              hintStyle: TextStyle(color: AppTheme.primaryColor.withOpacity(0.4)),
              filled: true,
              fillColor: AppTheme.primaryColor.withOpacity(0.05),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleGenerate(UploadProvider uploadProvider, BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.currentUser == null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
      return;
    }

    final creditManager = Provider.of<CreditManager>(context, listen: false);
    final int cost = uploadProvider.isMultipleVariationsEnabled ? 15 : 5;

    if (uploadProvider.selectedImage == null) {
      ExceptionHandler.showToast('Please select a garden image first');
      return;
    }

    bool hasItems = _selectedItems.values.any((count) => count > 0);
    bool hasCustomText = _customController.text.trim().isNotEmpty;
    bool hasTemplate = _selectedTemplate != null;

    if (!hasTemplate && !hasItems && !hasCustomText) {
      ExceptionHandler.showToast('Please select a template, add items, or enter instructions');
      return;
    }

    if (!creditManager.hasEnoughCredits(cost)) {
      CreditDialog.show(
        context,
        'You need at least $cost credits for this garden redesign.',
        IAPManager().products,
      );
      return;
    }

    try {
      LoadingOverlay.show(context);

      String template = _selectedTemplate ?? 'Modern';
      String? custom = _customController.text.trim().isEmpty ? null : _customController.text.trim();
      Map<String, int> selectedItems = Map.from(_selectedItems)..removeWhere((k, v) => v == 0);

      List<String> results = [];
      String finalPrompt = "";
      
      if (uploadProvider.isMultipleVariationsEnabled) {
        finalPrompt = GardenPromptGenerator.generateGardenPrompt(
          gardenTemplate: template,
          imageSource: uploadProvider.selectedImageSource ?? 'Unknown',
          customInstructions: custom,
          customItems: selectedItems,
        );
        results = await uploadProvider.generateMultipleImagesFromAPI(
          basePrompt: finalPrompt,
          imageFile: uploadProvider.selectedImage!,
        );
      } else {
        String url = await uploadProvider.generateGardenImage(
          gardenTemplate: template,
          customInstructions: custom,
          customItems: selectedItems,
        );
        finalPrompt = GardenPromptGenerator.generateGardenPrompt(
          gardenTemplate: template,
          imageSource: uploadProvider.selectedImageSource ?? 'Unknown',
          customInstructions: custom,
          customItems: selectedItems,
        );
        results = [url];
      }

      if (results.isNotEmpty) {
        // 1. Upload "before" image to get a public URL
        String? beforeUrl = await BackendApiService.uploadImage(uploadProvider.selectedImage!);

        // History saving is now handled by ResultScreen to prevent duplicates
        await creditManager.deductCredits(cost, reason: 'garden_redesign');

        if (context.mounted) {
          LoadingOverlay.hide(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(
                generatedImageUrls: results,
                roomType: 'Garden',
                style: template,
                budget: 'Professional',
                prompt: finalPrompt,
                beforeImageUrl: uploadProvider.selectedImage?.path,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) LoadingOverlay.hide(context);
      ExceptionHandler.handleException(e);
    }
  }
}
