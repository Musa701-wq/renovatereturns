import 'package:ai_remodeling/screens/refrence_screen.dart' hide FloorRedesign;
import 'package:ai_remodeling/screens/upload_image.dart';
import 'package:ai_remodeling/screens/wall_screen.dart';
import 'package:ai_remodeling/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../in_app_purchase/credit_manager.dart';
import '../in_app_purchase/i_ap_manager.dart';
import '../widgets/animated_special_offer_banner.dart';
import 'partial_remodel_screen.dart';
import 'special_offer_screen.dart';
import '../provider/image_provider.dart';
import '../services/google_analytics_services.dart';
import '../widgets/comparison_card_widget.dart';
import '../widgets/custom_app_bar.dart';
import 'RemoveObject.dart' show ObjectRemove;
import 'exterior_design.dart';
import 'fill_spce_screen.dart';
import 'floor_redesign.dart';
import 'package:ai_remodeling/screens/replace_screen.dart';
import 'package:provider/provider.dart';
import 'kitchen_design_screen.dart';
import 'garden_redesign_screen.dart';
import 'room_furnishing_screen.dart';

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String? _getIconPathForTitle(String title) {
    switch (title) {
      case 'Instant Redesign':
        return 'assets/images/interior.png';
      case 'Exterior Redesign':
        return 'assets/images/exterior.png';
      case 'Wall Redesign':
        return 'assets/images/wall.png';
      case 'Floor Redesign':
        return 'assets/images/floor.png';
      case 'Remove Object':
        return 'assets/images/remove.png';
      case 'Replace':
        return 'assets/images/replace.png';
      case 'Fill Space':
        return 'assets/images/fill.png';
      case 'Kitchen Design':
        return 'assets/images/interior.png';
      case 'Garden Redesign':
        return 'assets/images/exterior.png';
      case 'Reference Design':
        return 'assets/images/interior.png';
      case 'Room Furnishing':
        return 'assets/images/interior.png';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    double getCardSpacing() => AppTheme.responsiveSize(context, phone: 12, tablet: 8);
    double getTopSpacing() => AppTheme.responsiveSize(context, phone: 16, tablet: 20);
    double getBottomSpacing() => AppTheme.responsiveSize(context, phone: 20, tablet: 24);

    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: AppTheme.secondaryColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: getTopSpacing()),

              // Special Offer Banner
              const AnimatedSpecialOfferBanner(),
              SizedBox(height: getCardSpacing()),

              // CARD 1 - Instant Redesign
              ComparisonCardWidget(
                beforeImage: 'assets/images/inta.jpg',
                afterImage: 'assets/images/int1.jpg',
                title: 'Instant Redesign',
                subtitle: 'Transform your room instantly',
                isLiked: false,
                categoryIconPath: _getIconPathForTitle('Instant Redesign'),
                onLikePressed: () {},
                onArrowPressed: () {
                  AnalyticsService.logInstantClick();

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UploadScreen()),
                  );
                },
              ),

              SizedBox(height: getCardSpacing()),
              
              // CARD 2 - Replace
              ComparisonCardWidget(
                beforeImage: 'assets/images/re1.jpg',
                afterImage: 'assets/images/re.jpg',
                title: 'Replace',
                subtitle: 'Replace any object with AI',
                isLiked: false,
                categoryIconPath: _getIconPathForTitle('Replace'),
                onLikePressed: () {},
                onArrowPressed: () {
                  AnalyticsService.logReplaceClick();

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReplaceScreen()),
                  );
                },
              ),

              SizedBox(height: getCardSpacing()),

              // CARD 3 - Exterior Redesign
              ComparisonCardWidget(
                beforeImage: 'assets/images/exta.jpg',
                afterImage: 'assets/images/ext1.jpg',
                title: 'Exterior Redesign',
                subtitle: 'Redesign your building exterior',
                isLiked: false,
                categoryIconPath: _getIconPathForTitle('Exterior Redesign'),
                onLikePressed: () {},
                onArrowPressed: () {
                  AnalyticsService.logExteriorClick();

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ExteriorRedesign()),
                  );
                },
              ),

              SizedBox(height: getCardSpacing()),

              // CARD 4 - Fill Space
              ComparisonCardWidget(
                beforeImage: 'assets/images/fi1.jpeg',
                afterImage: 'assets/images/fi.png',
                title: 'Fill Space',
                subtitle: 'Fill empty areas intelligently',
                isLiked: false,
                categoryIconPath: _getIconPathForTitle('Fill Space'),
                onLikePressed: () {},
                onArrowPressed: () {
                  AnalyticsService.logFillSpaceClick();

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FillSpaceScreen()),
                  );
                },
              ),
              
              SizedBox(height: getCardSpacing()),

              // CARD 5 - Wall Redesign
              ComparisonCardWidget(
                beforeImage: 'assets/images/wall1.jpg',
                afterImage: 'assets/images/wall1.jpg',
                title: 'Wall Redesign',
                subtitle: 'Change wall colors and textures',
                isLiked: false,
                categoryIconPath: _getIconPathForTitle('Wall Redesign'),
                onLikePressed: () {},
                onArrowPressed: () {
                  AnalyticsService.logWallClick();

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WaalRedesign()),
                  );
                },
              ),

              SizedBox(height: getCardSpacing()),

              // CARD 6 - Floor Redesign
              ComparisonCardWidget(
                beforeImage: 'assets/images/floora.jpg',
                afterImage: 'assets/images/floor1.jpg',
                title: 'Floor Redesign',
                subtitle: 'Redesign your floors with AI',
                isLiked: false,
                categoryIconPath: _getIconPathForTitle('Floor Redesign'),
                onLikePressed: () {},
                onArrowPressed: () {
                  AnalyticsService.logFloorClick();

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FloorRedesign()),
                  );
                },
              ),

              SizedBox(height: getCardSpacing()),

              // CARD 7 - Remove Object
              ComparisonCardWidget(
                beforeImage: 'assets/images/obj1.jpg',
                afterImage: 'assets/images/obj1.jpg',
                title: 'Remove Object',
                subtitle: 'Remove any unwanted object',
                isLiked: false,
                categoryIconPath: _getIconPathForTitle('Remove Object'),
                onLikePressed: () {},
                onArrowPressed: () {
                  AnalyticsService.logRemoveObjectClick();

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ObjectRemove()),
                  );
                },
              ),

              SizedBox(height: getCardSpacing()),

              // CARD 8 - Partial Remodel
              ComparisonCardWidget(
                beforeImage: 'assets/images/exta.jpg',
                afterImage: 'assets/images/partial.jpeg',
                title: 'Partial Remodel',
                subtitle: 'Select and remodel specific areas',
                isLiked: false,
                categoryIconPath: _getIconPathForTitle('Partial Remodel'),
                onLikePressed: () {},
                onArrowPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PartialRemodelScreen()),
                  );
                },
              ),
              
              SizedBox(height: getCardSpacing()),

              // CARD 9 - Kitchen Design
              ComparisonCardWidget(
                beforeImage: 'assets/kitchen/Classic.jpg',
                afterImage: 'assets/kitchen/Luxury.jpg',
                title: 'Kitchen Design',
                subtitle: 'AI-powered kitchen transformation',
                isLiked: false,
                categoryIconPath: _getIconPathForTitle('Kitchen Design'),
                onLikePressed: () {},
                onArrowPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const KitchenDesignScreen()),
                  );
                },
              ),

              SizedBox(height: getCardSpacing()),

              // CARD 10 - Garden Redesign
              ComparisonCardWidget(
                beforeImage: 'assets/images/ext1.jpg',
                afterImage: 'assets/garden/japanese.jpg',
                title: 'Garden Redesign',
                subtitle: 'Exterior and landscape transformation',
                isLiked: false,
                categoryIconPath: _getIconPathForTitle('Garden Redesign'),
                onLikePressed: () {},
                onArrowPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GardenRedesignScreen()),
                  );
                },
              ),

              SizedBox(height: getCardSpacing()),

              // CARD 11 - Reference Design
              ComparisonCardWidget(
                beforeImage: 'assets/images/ref.png',
                afterImage: 'assets/images/ref.png',
                title: 'Reference Design',
                subtitle: 'Redesign spaces using a reference image',
                isLiked: false,
                categoryIconPath: _getIconPathForTitle('Reference Design'),
                onLikePressed: () {},
                onArrowPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReferenceTransformScreen()),
                  );
                },
              ),

              SizedBox(height: getCardSpacing()),

              // CARD 12 - Room Furnishing
              ComparisonCardWidget(
                beforeImage: 'assets/kitchen/Minimalist.jpg',
                afterImage: 'assets/room_furnashing/Modern.jpg',
                title: 'Room Furnishing',
                subtitle: 'Upload your room, choose items & get AI-designed interior',
                isLiked: false,
                categoryIconPath: _getIconPathForTitle('Room Furnishing'),
                onLikePressed: () {},
                onArrowPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RoomFurnishingScreen()),
                  );
                },
              ),

              SizedBox(height: getCardSpacing()),
            ],
          ),
        ),
      ),
    );
  }
}