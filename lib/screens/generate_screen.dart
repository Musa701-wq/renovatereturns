import 'package:ai_remodeling/screens/refrence_screen.dart' hide FloorRedesign;
import 'package:ai_remodeling/screens/upload_image.dart';
import 'package:ai_remodeling/screens/wall_screen.dart';
import 'package:ai_remodeling/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/image_provider.dart';
import '../provider/Ad_provider.dart';
import '../services/google_analytics_services.dart';
import '../widgets/comparison_card_widget.dart';
import '../widgets/custom_app_bar.dart';
import 'RemoveObject.dart' show ObjectRemove;
import 'exterior_design.dart';
import 'fill_spce_screen.dart';
import 'floor_redesign.dart';
import 'replace_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  @override
  void initState() {
    super.initState();

    // Load native ad through AdProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adProvider = context.read<AdProvider>();

      if (!adProvider.isGenerateNativeAdLoaded) {
        adProvider.loadGenerateNativeAd(TemplateType.small);
      }
    });
  }

  IconData _getIconForTitle(String title) {
    switch (title) {
      case 'Instant Redesign':
        return Icons.room;
      case 'Exterior Redesign':
        return Icons.house;
      case 'Wall Redesign':
        return Icons.wallpaper;
      case 'Floor Redesign':
        return Icons.square_foot;
      case 'Remove Object':
        return Icons.remove_circle;
      case 'Replace':
        return Icons.swap_horiz;
      case 'Fill Space':
        return Icons.auto_fix_high;
      case 'Reference':
        return Icons.compare_arrows;
      default:
        return Icons.category;
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
        child: Consumer2<ImageDataProvider, AdProvider>(
          builder: (context, imageProvider, adProvider, _) {
            final list = imageProvider.imageList;

            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: getTopSpacing()),

                  // CARD 1 - Instant Redesign
                  if (list.isNotEmpty)
                    ComparisonCardWidget(
                      beforeImage: list[0].beforeImage,
                      afterImage: list[0].afterImage,
                      title: list[0].title,
                      subtitle: list[0].subtitle,
                      isLiked: list[0].isLiked,
                      categoryIcon: _getIconForTitle(list[0].title),
                      onLikePressed: () => imageProvider.toggleLike(0),
                      onArrowPressed: () {
                        AnalyticsService.logInstantClick();

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const UploadScreen()),
                        );
                      },
                    ),

                  SizedBox(height: getCardSpacing()),

                  // CARD 2 - Exterior Redesign
                  if (list.length > 1)
                    ComparisonCardWidget(
                      beforeImage: list[1].beforeImage,
                      afterImage: list[1].afterImage,
                      title: list[1].title,
                      subtitle: list[1].subtitle,
                      isLiked: list[1].isLiked,
                      categoryIcon: _getIconForTitle(list[1].title),
                      onLikePressed: () => imageProvider.toggleLike(1),
                      onArrowPressed: () {
                        AnalyticsService.logExteriorClick();

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ExteriorRedesign()),
                        );
                      },
                    ),

                  if (adProvider.isGenerateNativeAdLoaded && adProvider.generateNativeAd != null)
                    Container(
                      height: 130.0,
                      margin: EdgeInsets.symmetric(
                        horizontal: AppTheme.responsiveSize(context, phone: 16, tablet: 20),
                        vertical: AppTheme.responsiveSize(context, phone: 8, tablet: 8),
                      ),
                      child: AdWidget(ad: adProvider.generateNativeAd!),
                    )
                  else
                    SizedBox(height: getCardSpacing()),
                  
                  // CARD 3 - Wall Redesign
                  if (list.length > 2)
                    ComparisonCardWidget(
                      beforeImage: list[2].beforeImage,
                      afterImage: list[2].afterImage,
                      title: list[2].title,
                      subtitle: list[2].subtitle,
                      isLiked: list[2].isLiked,
                      categoryIcon: _getIconForTitle(list[2].title),
                      onLikePressed: () => imageProvider.toggleLike(2),
                      onArrowPressed: () {
                        AnalyticsService.logWallClick();

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const WaalRedesign()),
                        );
                      },
                    ),

                  SizedBox(height: getCardSpacing()),

                  // CARD 4 - Floor Redesign
                  if (list.length > 3)
                    ComparisonCardWidget(
                      beforeImage: list[3].beforeImage,
                      afterImage: list[3].afterImage,
                      title: list[3].title,
                      subtitle: list[3].subtitle,
                      isLiked: list[3].isLiked,
                      categoryIcon: _getIconForTitle(list[3].title),
                      onLikePressed: () => imageProvider.toggleLike(3),
                      onArrowPressed: () {
                        AnalyticsService.logFloorClick();

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FloorRedesign()),
                        );
                      },
                    ),

                  SizedBox(height: getCardSpacing()),

                  // CARD 5 - Remove Object
                  if (list.length > 4)
                    ComparisonCardWidget(
                      beforeImage: list[4].beforeImage,
                      afterImage: list[4].afterImage,
                      title: list[4].title,
                      subtitle: list[4].subtitle,
                      isLiked: list[4].isLiked,
                      categoryIcon: _getIconForTitle(list[4].title),
                      onLikePressed: () => imageProvider.toggleLike(4),
                      onArrowPressed: () {
                        AnalyticsService.logRemoveObjectClick();

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ObjectRemove()),
                        );
                      },
                    ),

                  SizedBox(height: getCardSpacing()),

                  // CARD 6 - Replace
                  ComparisonCardWidget(
                    beforeImage: 'assets/images/re1.jpg',
                    afterImage: 'assets/images/re.jpg',
                    title: 'Replace',
                    subtitle: 'Replace any object with AI',
                    isLiked: false,
                    categoryIcon: _getIconForTitle('Replace'),
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

                  // CARD 7 - Fill Space
                  ComparisonCardWidget(
                    beforeImage: 'assets/images/fi1.jpeg',
                    afterImage: 'assets/images/fi.png',
                    title: 'Fill Space',
                    subtitle: 'Fill empty areas intelligently',
                    isLiked: false,
                    categoryIcon: _getIconForTitle('Fill Space'),
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}