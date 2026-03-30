import 'package:ai_remodeling/screens/refrence_screen.dart' hide FloorRedesign;
import 'package:ai_remodeling/screens/upload_image.dart';
import 'package:ai_remodeling/screens/wall_screen.dart';
import 'package:ai_remodeling/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../in_app_purchase/credit_manager.dart';
import '../in_app_purchase/i_ap_manager.dart';
import '../widgets/animated_special_offer_banner.dart';
import 'special_offer_screen.dart';
import '../provider/image_provider.dart';
import '../services/google_analytics_services.dart';
import '../widgets/comparison_card_widget.dart';
import '../widgets/custom_app_bar.dart';
import 'RemoveObject.dart' show ObjectRemove;
import 'exterior_design.dart';
import 'fill_spce_screen.dart';
import 'floor_redesign.dart';
import 'package:ai_remodeling/provider/ad_provider.dart';
import 'package:ai_remodeling/screens/replace_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:ai_remodeling/screens/partial_remodel_screen.dart';

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  @override
  void initState() {
    super.initState();
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
        child: Consumer<ImageDataProvider>(
          builder: (context, imageProvider, _) {
            final list = imageProvider.imageList;

            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: getTopSpacing()),

                  // Special Offer Banner
                  const AnimatedSpecialOfferBanner(),
                  SizedBox(height: getCardSpacing()),

                  // CARD 1 - Instant Redesign
                  if (list.isNotEmpty)
                    ComparisonCardWidget(
                      beforeImage: list[0].beforeImage,
                      afterImage: list[0].afterImage,
                      title: list[0].title,
                      subtitle: list[0].subtitle,
                      isLiked: list[0].isLiked,
                      categoryIconPath: _getIconPathForTitle(list[0].title),
                      onLikePressed: () => imageProvider.toggleLike(0),
                      onArrowPressed: () {
                        AnalyticsService.logInstantClick();

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const UploadScreen()),
                        );
                      },
                    ),

                  // Banner Ad
                  Consumer2<AdProvider, CreditManager>(
                    builder: (context, adProvider, creditManager, child) {
                      if (creditManager.hasPurchased) {
                        return const SizedBox.shrink(); // Hide ad for paid users
                      }
                      if (adProvider.isBannerAdLoaded && adProvider.bannerAd != null) {
                        return Column(
                          children: [
                            SizedBox(height: getCardSpacing()),
                            Container(
                              alignment: Alignment.center,
                              width: adProvider.bannerAd!.size.width.toDouble(),
                              height: adProvider.bannerAd!.size.height.toDouble(),
                              child: AdWidget(ad: adProvider.bannerAd!),
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
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
                  if (list.length > 1)
                    ComparisonCardWidget(
                      beforeImage: list[1].beforeImage,
                      afterImage: list[1].afterImage,
                      title: list[1].title,
                      subtitle: list[1].subtitle,
                      isLiked: list[1].isLiked,
                      categoryIconPath: _getIconPathForTitle(list[1].title),
                      onLikePressed: () => imageProvider.toggleLike(1),
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
                  if (list.length > 2)
                    ComparisonCardWidget(
                      beforeImage: list[2].beforeImage,
                      afterImage: list[2].afterImage,
                      title: list[2].title,
                      subtitle: list[2].subtitle,
                      isLiked: list[2].isLiked,
                      categoryIconPath: _getIconPathForTitle(list[2].title),
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

                  // CARD 6 - Floor Redesign
                  if (list.length > 3)
                    ComparisonCardWidget(
                      beforeImage: list[3].beforeImage,
                      afterImage: list[3].afterImage,
                      title: list[3].title,
                      subtitle: list[3].subtitle,
                      isLiked: list[3].isLiked,
                      categoryIconPath: _getIconPathForTitle(list[3].title),
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

                  // CARD 7 - Remove Object
                  if (list.length > 4)
                    ComparisonCardWidget(
                      beforeImage: list[4].beforeImage,
                      afterImage: list[4].afterImage,
                      title: list[4].title,
                      subtitle: list[4].subtitle,
                      isLiked: list[4].isLiked,
                      categoryIconPath: _getIconPathForTitle(list[4].title),
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}