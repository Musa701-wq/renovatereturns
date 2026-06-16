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
import '../widgets/generate_button.dart';
import '../widgets/image_selection_widget.dart';
import '../utils/theme.dart';
import '../widgets/item_design_card.dart';
import '../widgets/credit_dialog.dart';
import '../services/image_storage_service.dart';
import '../in_app_purchase/i_ap_manager.dart';
import '../screens/login_screen.dart';
import '../provider/auth_provider.dart';

class RoomFurnishingScreen extends StatefulWidget {
  const RoomFurnishingScreen({super.key});

  @override
  State<RoomFurnishingScreen> createState() => _RoomFurnishingScreenState();
}

class _RoomFurnishingScreenState extends State<RoomFurnishingScreen> {
  // Currently selected room style (optional)
  String? _selectedRoomStyle;

  // Multi-selected items user wants in the room
  final Set<String> _selectedItems = {};

  // Available room styles with images
  final List<Map<String, String>> _roomStyles = [
    {
      'name': 'Modern Minimalist',
      'image': 'assets/room_furnashing/Modern.jpg',
      'description': 'Simple, clean room with neutral colors (white, beige, gray), straight lines, minimal furniture and no extra decoration.',
    },
    {
      'name': 'Contemporary',
      'image': 'assets/room_furnashing/Contemporary.jpg',
      'description': 'Modern trendy look with clean lines, bold accents, mixed textures and statement lighting.',
    },
    {
      'name': 'Scandinavian',
      'image': 'assets/room_furnashing/Scandinavian.jpg',
      'description': 'Bright, light wood furniture, white walls, cozy textiles, many plants and natural light.',
    },
    {
      'name': 'Japandi',
      'image': 'assets/room_furnashing/Japandi.jpg',
      'description': 'Minimal Japanese + Scandinavian mix — light wood, low furniture, neutral tones, zen and calm.',
    },
    {
      'name': 'Bohemian (Boho)',
      'image': 'assets/room_furnashing/Bohemian.jpg',
      'description': 'Colorful, layered rugs, cushions, plants, macramé, rattan and mixed patterns.',
    },
    {
      'name': 'Coastal / Mediterranean',
      'image': 'assets/room_furnashing/Coastal.jpg',
      'description': 'Breezy light colors (white, blue, beige), rattan furniture, linen curtains and beachy feel.',
    },
    {
      'name': 'Art Deco',
      'image': 'assets/room_furnashing/Deco.jpeg',
      'description': 'Glamorous geometric patterns, gold, brass, velvet and bold luxury details.',
    },
    {
      'name': 'Hollywood Regency / Glam',
      'image': 'assets/room_furnashing/Hollywood.png',
      'description': 'Luxurious mirrors, crystal chandeliers, velvet, metallics and dramatic lighting.',
    },
    {
      'name': 'Maximalist',
      'image': 'assets/room_furnashing/Maximalist.jpeg',
      'description': 'Bold, colorful, full of patterns, layers, art and decorative objects.',
    },
    {
      'name': 'Biophilic',
      'image': 'assets/room_furnashing/Biophilic.jpeg',
      'description': 'Lots of indoor plants, natural wood, stone and maximum nature connection.',
    },
    {
      'name': 'Organic Modern',
      'image': 'assets/room_furnashing/Organic.jpeg',
      'description': 'Curvy furniture, soft fabrics (bouclé, linen), warm earthy tones and cozy feel.',
    },
    {
      'name': 'Wabi-Sabi',
      'image': 'assets/room_furnashing/Wabi-Sabi.jpg',
      'description': 'Natural, imperfect, handmade items, muted colors and simple serene look.',
    },
    {
      'name': 'Modern Farmhouse / Rustic',
      'image': 'assets/room_furnashing/Farmhouse.jpg',
      'description': 'Distressed wood, cozy textiles, neutral colors with warm and homely touch.',
    },
    {
      'name': 'Transitional',
      'image': 'assets/room_furnashing/Transitional.jpeg',
      'description': 'Balanced mix of traditional and modern, elegant, neutral and timeless.',
    },
    {
      'name': 'Cottagecore',
      'image': 'assets/room_furnashing/Cottagecore.jpeg',
      'description': 'Romantic floral patterns, vintage furniture, soft pastels and dreamy cozy vibe.',
    },
    {
      'name': 'Monochrome',
      'image': 'assets/room_furnashing/Monochrome.jpg',
      'description': 'Entire room in one strong color (all teal or all terracotta) with different shades.',
    },
  ];


  final List<Map<String, dynamic>> _furnishingItems = [
    {'label': 'Sofa', 'icon': Icons.weekend},
    {'label': 'Bed', 'icon': Icons.bed},
    {'label': 'Wardrobe', 'icon': Icons.door_sliding},
    {'label': 'TV Unit', 'icon': Icons.tv},
    {'label': 'Dining Table', 'icon': Icons.table_restaurant},
    {'label': 'Study Desk', 'icon': Icons.desk},
    {'label': 'Bookshelf', 'icon': Icons.menu_book},
    {'label': 'Indoor Plants', 'icon': Icons.local_florist},
    {'label': 'Rug / Carpet', 'icon': Icons.grid_on},
    {'label': 'Curtains', 'icon': Icons.blinds},
    {'label': 'Lighting', 'icon': Icons.light},
    {'label': 'Wall Art', 'icon': Icons.image},
    {'label': 'Mirror', 'icon': Icons.crop_portrait},
    {'label': 'Coffee Table', 'icon': Icons.table_bar},
    {'label': 'Armchair', 'icon': Icons.chair},
    {'label': 'Fireplace', 'icon': Icons.fireplace},
    {'label': 'Shelves', 'icon': Icons.shelves},
    {'label': 'Ceiling Fan', 'icon': Icons.toys},
    {'label': 'Side Table', 'icon': Icons.nightlight},
    {'label': 'Dresser', 'icon': Icons.format_color_fill},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uploadProvider = Provider.of<UploadProvider>(context, listen: false);
      uploadProvider.setSelectedRoomType(null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width >= 600;
    final bool isSmall = MediaQuery.of(context).size.width < 375;

    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: const Text('Room Furnishing'),
        backgroundColor: AppTheme.secondaryColor,
        foregroundColor: AppTheme.primaryColor,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            final uploadProvider = Provider.of<UploadProvider>(context, listen: false);
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
                isSmall ? 16.0 : isTablet ? 24.0 : 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─── SECTION 1: Image Upload ───────────────────────────
                  ImageSelectionWidget(),

                  SizedBox(height: AppTheme.responsiveSize(context, phone: 28, tablet: 40)),

                  // ─── SECTION 2: Popular Room Styles (optional) ─────────
                  _buildSectionHeader(
                    title: 'Popular Room Styles',
                    subtitle: '(Optional)',
                    isSmall: isSmall,
                    isTablet: isTablet,
                  ),
                  SizedBox(height: AppTheme.responsiveSize(context, phone: 12, tablet: 16)),
                  _buildRoomStylesList(context),

                  SizedBox(height: AppTheme.responsiveSize(context, phone: 28, tablet: 40)),

                  // ─── SECTION 3: What to Include ────────────────────────
                  _buildSectionHeader(
                    title: 'What to Include',
                    subtitle: '(Optional — tap items you want)',
                    isSmall: isSmall,
                    isTablet: isTablet,
                  ),
                  SizedBox(height: AppTheme.responsiveSize(context, phone: 12, tablet: 16)),
                  _buildItemChips(context),

                  SizedBox(height: AppTheme.responsiveSize(context, phone: 12, tablet: 16)),

                  // Selected items summary
                  if (_selectedItems.isNotEmpty)
                    _buildSelectedItemsSummary(context),

                  SizedBox(height: AppTheme.responsiveSize(context, phone: 24, tablet: 32)),

                  // ─── MULTIPLE VARIATIONS TOGGLE ───────────────────────
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

                  SizedBox(height: AppTheme.responsiveSize(context, phone: 24, tablet: 32)),

                  // ─── GENERATE BUTTON ───────────────────────────────────
                  GenerateButtonWidget(
                    onGeneratePressed: () => _generateRoomFurnishing(uploadProvider, context),
                  ),

                  SizedBox(height: AppTheme.responsiveSize(context, phone: 20, tablet: 28)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required bool isSmall,
    required bool isTablet,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isSmall ? 14.0 : isTablet ? 18.0 : 16.0,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 6),
        Padding(
          padding: const EdgeInsets.only(bottom: 1),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: isSmall ? 10.0 : isTablet ? 13.0 : 11.5,
              color: AppTheme.primaryColor.withOpacity(0.55),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Horizontal room style cards ──────────────────────────────────────
  Widget _buildRoomStylesList(BuildContext context) {
    return SizedBox(
      height: AppTheme.responsiveSize(context, phone: 190, tablet: 260),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _roomStyles.length,
        cacheExtent: 1000,
        itemBuilder: (context, index) {
          final style = _roomStyles[index];
          final isSelected = _selectedRoomStyle == style['name'];

          return GestureDetector(
            onTap: () {
              setState(() {
                // Toggle: tap again to deselect
                _selectedRoomStyle = isSelected ? null : style['name'];
              });
            },
            child: FloorDesignCard(
              name: style['name']!,
              image: style['image']!,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _selectedRoomStyle = isSelected ? null : style['name'];
                });
              },
            ),
          );
        },
      ),
    );
  }

  // ─── Multi-select item chip grid ──────────────────────────────────────
  Widget _buildItemChips(BuildContext context) {
    return Wrap(
      spacing: AppTheme.responsiveSize(context, phone: 8, tablet: 12),
      runSpacing: AppTheme.responsiveSize(context, phone: 8, tablet: 12),
      children: _furnishingItems.map((item) {
        final label = item['label'] as String;
        final icon = item['icon'] as IconData;
        final isSelected = _selectedItems.contains(label);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedItems.remove(label);
              } else {
                _selectedItems.add(label);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.responsiveSize(context, phone: 10, tablet: 14),
              vertical: AppTheme.responsiveSize(context, phone: 7, tablet: 10),
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                AppTheme.responsiveSize(context, phone: 20, tablet: 24),
              ),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.primaryColor.withOpacity(0.35),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: AppTheme.responsiveSize(context, phone: 14, tablet: 18),
                  color: isSelected
                      ? AppTheme.secondaryColor
                      : AppTheme.primaryColor,
                ),
                SizedBox(width: AppTheme.responsiveSize(context, phone: 5, tablet: 7)),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: AppTheme.responsiveFont(context, phone: 12.5, tablet: 15),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? AppTheme.secondaryColor
                        : AppTheme.primaryColor,
                  ),
                ),
                if (isSelected) ...[
                  SizedBox(width: AppTheme.responsiveSize(context, phone: 4, tablet: 6)),
                  Icon(
                    Icons.check,
                    size: AppTheme.responsiveSize(context, phone: 12, tablet: 16),
                    color: AppTheme.secondaryColor,
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Selected items summary pill row ─────────────────────────────────
  Widget _buildSelectedItemsSummary(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.responsiveSize(context, phone: 10, tablet: 14)),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            color: AppTheme.primaryColor,
            size: AppTheme.responsiveSize(context, phone: 16, tablet: 20),
          ),
          SizedBox(width: AppTheme.responsiveSize(context, phone: 8, tablet: 10)),
          Expanded(
            child: Text(
              '${_selectedItems.length} item${_selectedItems.length == 1 ? '' : 's'} selected: ${_selectedItems.join(', ')}',
              style: TextStyle(
                fontSize: AppTheme.responsiveFont(context, phone: 12, tablet: 14),
                color: AppTheme.primaryColor.withOpacity(0.8),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _selectedItems.clear()),
            child: Icon(
              Icons.close,
              size: AppTheme.responsiveSize(context, phone: 16, tablet: 20),
              color: AppTheme.primaryColor.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Generate logic ───────────────────────────────────────────────────
  void _generateRoomFurnishing(UploadProvider uploadProvider, BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.currentUser == null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
      return;
    }

    final creditManager = Provider.of<CreditManager>(context, listen: false);
    final int cost = uploadProvider.isMultipleVariationsEnabled ? 15 : 5;

    try {
      if (uploadProvider.selectedImage == null) {
        ExceptionHandler.showToast('Please select an image first');
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
            'You need at least $cost credits to generate this room design.',
            IAPManager().products,
          );
        }
        return;
      }

      if (!mounted) return;
      LoadingOverlay.show(context);

      // Build prompt
      String prompt = _buildFurnishingPrompt();

      List<String> generatedImageUrls = [];
      if (uploadProvider.isMultipleVariationsEnabled) {
        generatedImageUrls = await uploadProvider.generateMultipleImagesFromAPI(
          basePrompt: prompt,
          imageFile: uploadProvider.selectedImage!,
          temperature: 0.1, // Strict structural preservation
        );
      } else {
        String url = await GeminiService.generateImageFromPrompt(
          prompt: prompt,
          imageFile: uploadProvider.selectedImage!,
          temperature: 0.1, // Strict structural preservation
        );
        generatedImageUrls = [url];
      }

          // History saving is now handled by ResultScreen to prevent duplicates

      final deductionSucceeded = await creditManager.deductCredits(
        cost,
        reason: uploadProvider.isMultipleVariationsEnabled
            ? 'multiple_variations'
            : 'room_furnishing',
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
              roomType: _selectedRoomStyle ?? 'Custom Room',
              style: _selectedItems.isNotEmpty
                  ? _selectedItems.join(', ')
                  : 'AI Curated',
              budget: 'Not Specified',
              prompt: prompt,
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

  // ─── Prompt builder ───────────────────────────────────────────────────
  String _buildFurnishingPrompt() {
    final style = _selectedRoomStyle;
    final items = _selectedItems.toList();
    final unselectedItems = _furnishingItems
        .map((e) => e['label'] as String)
        .where((label) => !_selectedItems.contains(label))
        .toList();

    String styleSection = style != null
        ? '''
🎨 ROOM STYLE — "$style":
- Apply a "$style" interior design style for all furniture, materials and color palette.
- Keep style consistent across every element in the room.
'''
        : '''
🎨 ROOM STYLE:
- Apply a modern, elegant interior design style that naturally complements the existing space.
''';

    String itemsSection = items.isNotEmpty
        ? '''
🛋️ REQUIRED ITEMS TO PLACE:
${items.map((item) => '▸ $item').join('\n')}

🚫 FORBIDDEN ITEMS (CRITICAL! DO NOT ADD THESE UNDER ANY CIRCUMSTANCES):
${unselectedItems.map((item) => '▸ NO $item').join('\n')}
- The ONLY furniture pieces allowed are the REQUIRED ITEMS listed above. Nothing else.

PLACEMENT RULES FOR REQUIRED ITEMS:
- ONLY put furniture against solid walls or in the very center of the floor space.
- NEVER put anything in front of a window. Windows must be 100% visible and unblocked.
- NEVER put anything in front of a door.
- Do not let furniture overlap.
'''
        : '''
🛋️ FURNISHING RULES:
- Furnish the room realistically based on its actual size.
- Include seating, storage, and lighting.
- NEVER block ANY windows or doors. 
- Leave plenty of walking space.
''';

    return '''
ROOM FURNISHING AI — STRICT ARCHITECTURAL PRESERVATION MODE

CRITICAL DIRECTIVE: You are an interior redesigner. You may ONLY add furniture and change surface materials. YOU ARE FORBIDDEN FROM CHANGING THE PHYSICAL ARCHITECTURE OF THE ROOM.

🚨 ABSOLUTE RULES (FAILURE WILL RESULT IN REJECTION):
1. PRESERVE DIMENSIONS: The output image MUST maintain the exact same physical dimensions, width, depth, and height ratio as the original room. Do not make the room bigger or smaller.
2. PRESERVE PERSPECTIVE: Keep the exact same camera angle, lens distortion, and vanishing point. Do not "straighten" or "flatten" the view.
3. PRESERVE WINDOWS (100% VISIBLE): Every window in the original photo MUST remain in exactly the same place, the same size, and be completely unobstructed. DO NOT PUT FURNITURE IN FRONT OF WINDOWS. 
4. PRESERVE DOORS (100% CLEAR): Every door and doorway MUST remain in exactly the same place. Do not block walkways. 
5. NO STRUCTURAL CHANGES: Keep all walls exactly where they are. Do not add or remove walls, niches, columns, or architectural features.

$styleSection

$itemsSection

FINAL INSTRUCTION: Add furniture and styled decor naturally into the OPEN floor space. The room itself (its shape, size, and layout of windows/doors) MUST look exactly identical to the input image, just beautifully furnished.
''';
  }
}
