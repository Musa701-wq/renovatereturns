/*

import 'package:ai_remodeling/screens/upload_image.dart';
import 'package:ai_remodeling/screens/wall_screen.dart';
import 'package:ai_remodeling/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/image_provider.dart';
import '../widgets/comparison_card_widget.dart';
import '../widgets/custom_app_bar.dart';
import 'RemoveObject.dart' show ObjectRemove;
import 'exterior_design.dart';
import 'floor_redesign.dart';
import '../ads/ad_helper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  List<NativeAd?> _nativeAds = [];
  List<bool> _adLoading = [];

  @override
  void initState() {
    super.initState();
    _nativeAds = List.filled(3, null);
    _adLoading = List.filled(3, false);
    for (int i = 0; i < 3; i++) {
      _loadNativeAd(i);
    }
  }

  @override
  void dispose() {
    for (var ad in _nativeAds) {
      ad?.dispose();
    }
    super.dispose();
  }

  void _loadNativeAd(int index) {
    if (index >= _nativeAds.length) return;

    setState(() => _adLoading[index] = true);

    String adKey = index == 0
        ? 'homeAd1'
        : index == 1
        ? 'homeAd2'
        : 'selectionAd';

    final ad = NativeAd(
      adUnitId: AdHelper.getNative(adKey),
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() => _adLoading[index] = false);
        },
        onAdFailedToLoad: (ad, error) {
          print("Native Ad failed: $error");
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _nativeAds[index] = null;
            _adLoading[index] = false;
          });
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
        cornerRadius: 10.0,
      ),
    );

    _nativeAds[index] = ad;
    ad.load();
  }

  Widget safeCard(List list, int index, Widget Function() builder) {
    if (list.length > index) {
      return builder();
    } else {
      return const SizedBox(); // safe empty
    }
  }

  Widget safeAd(int index, double height, double horizontalMargin, double verticalMargin) {
    if (index >= _nativeAds.length) return const SizedBox();

    if (_nativeAds[index] != null && !_adLoading[index]) {
      return Container(
        height: height,
        margin: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: verticalMargin),
        child: AdWidget(ad: _nativeAds[index]!),
      );
    }

    return const SizedBox.shrink();
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
      case 'Furniture Makeover':
        return Icons.chair_rounded;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Responsive Values via AppTheme helpers
    double getAdHeight() => 130.0;
    double getAdHorizontalMargin() => AppTheme.responsiveSize(context, phone: 16, tablet: 20);
    double getAdVerticalMargin() => 0.0;
    double getAdSpacing() => AppTheme.responsiveSize(context, phone: 6, tablet: 8);
    double getCardSpacing() => AppTheme.responsiveSize(context, phone: 12, tablet: 16);
    double getTopSpacing() => AppTheme.responsiveSize(context, phone: 16, tablet: 20);
    double getBottomSpacing() => AppTheme.responsiveSize(context, phone: 20, tablet: 24);

    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: AppTheme.secondaryColor,
      body: SafeArea(
        child: Consumer<ImageDataProvider>(
          builder: (context, provider, _) {
            final list = provider.imageList;

            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: getTopSpacing()),

                  // CARD 1
                  safeCard(list, 0, () {
                    final item = list[0];
                    return ComparisonCardWidget(
                      beforeImage: item.beforeImage,
                      afterImage: item.afterImage,
                      title: item.title,
                      subtitle: item.subtitle,
                      isLiked: item.isLiked,
                    categoryIcon: _getIconForTitle(item.title),
                      onLikePressed: () => provider.toggleLike(0),
                      onArrowPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const UploadScreen()));
                      },
                    );
                  }),

                  SizedBox(height: getCardSpacing()),

                  // CARD 2
                  safeCard(list, 1, () {
                    final item = list[1];
                    return ComparisonCardWidget(
                      beforeImage: item.beforeImage,
                      afterImage: item.afterImage,
                      title: item.title,
                      subtitle: item.subtitle,
                      isLiked: item.isLiked,
                      categoryIcon: _getIconForTitle(item.title),
                      onLikePressed: () => provider.toggleLike(1),
                      onArrowPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const ExteriorRedesign()));
                      },
                    );
                  }),

                  SizedBox(height: getAdSpacing()),
                  safeAd(0, getAdHeight(), getAdHorizontalMargin(), getAdVerticalMargin()),
                  SizedBox(height: getAdSpacing()),

                  // CARD 3
                  safeCard(list, 2, () {
                    final item = list[2];
                    return ComparisonCardWidget(
                      beforeImage: item.beforeImage,
                      afterImage: item.afterImage,
                      title: item.title,
                      subtitle: item.subtitle,
                      isLiked: item.isLiked,
                        categoryIcon: _getIconForTitle(item.title),
                      onLikePressed: () => provider.toggleLike(2),
                      onArrowPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const WaalRedesign()));
                      },
                    );
                  }),

                  SizedBox(height: getCardSpacing()),

                  // CARD 4
                  safeCard(list, 3, () {
                    final item = list[3];
                    return ComparisonCardWidget(
                      beforeImage: item.beforeImage,
                      afterImage: item.afterImage,
                      title: item.title,
                      subtitle: item.subtitle,
                      isLiked: item.isLiked,
                        categoryIcon: _getIconForTitle(item.title),
                      onLikePressed: () => provider.toggleLike(3),
                      onArrowPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const FloorRedesign()));
                      },
                    );
                  }),

                  SizedBox(height: getAdSpacing()),
                  safeAd(1, getAdHeight(), getAdHorizontalMargin(), getAdVerticalMargin()),
                  SizedBox(height: getAdSpacing()),

                  // CARD 5
                  safeCard(list, 4, () {
                    final item = list[4];
                    return ComparisonCardWidget(
                      beforeImage: item.beforeImage,
                      afterImage: item.afterImage,
                      title: item.title,
                      subtitle: item.subtitle,
                      isLiked: item.isLiked,
                        categoryIcon: _getIconForTitle(item.title),
                      onLikePressed: () => provider.toggleLike(4),
                      onArrowPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const ObjectRemove()));
                      },
                    );
                  }),

                  SizedBox(height: getBottomSpacing()),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}*//*
import 'package:ai_remodeling/screens/upload_image.dart';
import 'package:ai_remodeling/screens/wall_screen.dart';
import 'package:ai_remodeling/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/image_provider.dart';
import '../widgets/comparison_card_widget.dart';
import '../widgets/custom_app_bar.dart';
import 'RemoveObject.dart' show ObjectRemove;
import 'exterior_design.dart';
import 'floor_redesign.dart';
import 'replace_screen.dart'; // NEW IMPORT
import '../ads/ad_helper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  List<NativeAd?> _nativeAds = [];
  List<bool> _adLoading = [];

  @override
  void initState() {
    super.initState();
    _nativeAds = List.filled(3, null);
    _adLoading = List.filled(3, false);
    for (int i = 0; i < 3; i++) {
      _loadNativeAd(i);
    }
  }

  @override
  void dispose() {
    for (var ad in _nativeAds) {
      ad?.dispose();
    }
    super.dispose();
  }

  void _loadNativeAd(int index) {
    if (index >= _nativeAds.length) return;

    setState(() => _adLoading[index] = true);

    String adKey = index == 0
        ? 'homeAd1'
        : index == 1
        ? 'homeAd2'
        : 'selectionAd';

    final ad = NativeAd(
      adUnitId: AdHelper.getNative(adKey),
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() => _adLoading[index] = false);
        },
        onAdFailedToLoad: (ad, error) {
          print("Native Ad failed: $error");
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _nativeAds[index] = null;
            _adLoading[index] = false;
          });
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
        cornerRadius: 10.0,
      ),
    );

    _nativeAds[index] = ad;
    ad.load();
  }

  Widget safeCard(List list, int index, Widget Function() builder) {
    if (list.length > index) {
      return builder();
    } else {
      return const SizedBox();
    }
  }

  Widget safeAd(int index, double height, double horizontalMargin, double verticalMargin) {
    if (index >= _nativeAds.length) return const SizedBox();

    if (_nativeAds[index] != null && !_adLoading[index]) {
      return Container(
        height: height,
        margin: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: verticalMargin),
        child: AdWidget(ad: _nativeAds[index]!),
      );
    }

    return const SizedBox.shrink();
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
      case 'Furniture Makeover':
        return Icons.chair_rounded;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    double getAdHeight() => 130.0;
    double getAdHorizontalMargin() => AppTheme.responsiveSize(context, phone: 16, tablet: 20);
    double getAdVerticalMargin() => 0.0;
    double getAdSpacing() => AppTheme.responsiveSize(context, phone: 6, tablet: 8);
    double getCardSpacing() => AppTheme.responsiveSize(context, phone: 12, tablet: 16);
    double getTopSpacing() => AppTheme.responsiveSize(context, phone: 16, tablet: 20);
    double getBottomSpacing() => AppTheme.responsiveSize(context, phone: 20, tablet: 24);

    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: AppTheme.secondaryColor,
      body: SafeArea(
        child: Consumer<ImageDataProvider>(
          builder: (context, provider, _) {
            final list = provider.imageList;

            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: getTopSpacing()),

                  // CARD 1 - Instant Redesign
                  safeCard(list, 0, () {
                    final item = list[0];
                    return ComparisonCardWidget(
                      beforeImage: item.beforeImage,
                      afterImage: item.afterImage,
                      title: item.title,
                      subtitle: item.subtitle,
                      isLiked: item.isLiked,
                      categoryIcon: _getIconForTitle(item.title),
                      onLikePressed: () => provider.toggleLike(0),
                      onArrowPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const UploadScreen()));
                      },
                    );
                  }),

                  SizedBox(height: getCardSpacing()),

                  // CARD 2 - Exterior Redesign
                  safeCard(list, 1, () {
                    final item = list[1];
                    return ComparisonCardWidget(
                      beforeImage: item.beforeImage,
                      afterImage: item.afterImage,
                      title: item.title,
                      subtitle: item.subtitle,
                      isLiked: item.isLiked,
                      categoryIcon: _getIconForTitle(item.title),
                      onLikePressed: () => provider.toggleLike(1),
                      onArrowPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const ExteriorRedesign()));
                      },
                    );
                  }),

                  SizedBox(height: getAdSpacing()),
                  safeAd(0, getAdHeight(), getAdHorizontalMargin(), getAdVerticalMargin()),
                  SizedBox(height: getAdSpacing()),

                  // CARD 3 - Wall Redesign
                  safeCard(list, 2, () {
                    final item = list[2];
                    return ComparisonCardWidget(
                      beforeImage: item.beforeImage,
                      afterImage: item.afterImage,
                      title: item.title,
                      subtitle: item.subtitle,
                      isLiked: item.isLiked,
                      categoryIcon: _getIconForTitle(item.title),
                      onLikePressed: () => provider.toggleLike(2),
                      onArrowPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const WaalRedesign()));
                      },
                    );
                  }),

                  SizedBox(height: getCardSpacing()),

                  // CARD 4 - Floor Redesign
                  safeCard(list, 3, () {
                    final item = list[3];
                    return ComparisonCardWidget(
                      beforeImage: item.beforeImage,
                      afterImage: item.afterImage,
                      title: item.title,
                      subtitle: item.subtitle,
                      isLiked: item.isLiked,
                      categoryIcon: _getIconForTitle(item.title),
                      onLikePressed: () => provider.toggleLike(3),
                      onArrowPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const FloorRedesign()));
                      },
                    );
                  }),

                  SizedBox(height: getAdSpacing()),
                  safeAd(1, getAdHeight(), getAdHorizontalMargin(), getAdVerticalMargin()),
                  SizedBox(height: getAdSpacing()),

                  // CARD 5 - Remove Object
                  safeCard(list, 4, () {
                    final item = list[4];
                    return ComparisonCardWidget(
                      beforeImage: item.beforeImage,
                      afterImage: item.afterImage,
                      title: item.title,
                      subtitle: item.subtitle,
                      isLiked: item.isLiked,
                      categoryIcon: _getIconForTitle(item.title),
                      onLikePressed: () => provider.toggleLike(4),
                      onArrowPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const ObjectRemove()));
                      },
                    );
                  }),

                  SizedBox(height: getCardSpacing()),

                  // NEW CARD 6 - Replace (NEW FEATURE)
                  ComparisonCardWidget(
                    beforeImage: 'assets/images/replace_before.jpg',
                    afterImage: 'assets/images/replace_after.jpg',
                    title: 'Replace',
                    subtitle: 'Replace any object with AI',
                    isLiked: false,
                    categoryIcon: _getIconForTitle('Replace'),
                    onLikePressed: () {},
                    onArrowPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const ReplaceScreen()));
                    },
                  ),

                  SizedBox(height: getBottomSpacing()),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}*/
import 'package:ai_remodeling/screens/refrence_screen.dart';
import 'package:ai_remodeling/screens/upload_image.dart';
import 'package:ai_remodeling/screens/wall_screen.dart';
import 'package:ai_remodeling/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/image_provider.dart';
import '../widgets/comparison_card_widget.dart';
import '../widgets/custom_app_bar.dart';
import 'RemoveObject.dart' show ObjectRemove;
import 'exterior_design.dart';
import 'fill_spce_screen.dart';
import 'floor_redesign.dart';
import 'replace_screen.dart';
import '../ads/ad_helper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  List<NativeAd?> _nativeAds = [];
  List<bool> _adLoading = [];

  @override
  void initState() {
    super.initState();
    _nativeAds = List.filled(3, null);
    _adLoading = List.filled(3, false);
    for (int i = 0; i < 3; i++) {
      _loadNativeAd(i);
    }
  }

  @override
  void dispose() {
    for (var ad in _nativeAds) {
      ad?.dispose();
    }
    super.dispose();
  }

  void _loadNativeAd(int index) {
    if (index >= _nativeAds.length) return;

    setState(() => _adLoading[index] = true);

    String adKey = index == 0
        ? 'homeAd1'
        : index == 1
        ? 'homeAd2'
        : 'selectionAd';

    final ad = NativeAd(
      adUnitId: AdHelper.getNative(adKey),
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() => _adLoading[index] = false);
        },
        onAdFailedToLoad: (ad, error) {
          print("Native Ad failed: $error");
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _nativeAds[index] = null;
            _adLoading[index] = false;
          });
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
        cornerRadius: 10.0,
      ),
    );

    _nativeAds[index] = ad;
    ad.load();
  }

  Widget safeCard(List list, int index, Widget Function() builder) {
    if (list.length > index) {
      return builder();
    } else {
      return const SizedBox();
    }
  }

  Widget safeAd(int index, double height, double horizontalMargin, double verticalMargin) {
    if (index >= _nativeAds.length) return const SizedBox();

    if (_nativeAds[index] != null && !_adLoading[index]) {
      return Container(
        height: height,
        margin: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: verticalMargin),
        child: AdWidget(ad: _nativeAds[index]!),
      );
    }

    return const SizedBox.shrink();
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
      case 'Furniture Makeover':
        return Icons.chair_rounded;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    double getAdHeight() => 130.0;
    double getAdHorizontalMargin() => AppTheme.responsiveSize(context, phone: 16, tablet: 20);
    double getAdVerticalMargin() => 0.0;
    double getAdSpacing() => AppTheme.responsiveSize(context, phone: 6, tablet: 8);
    double getCardSpacing() => AppTheme.responsiveSize(context, phone: 12, tablet: 16);
    double getTopSpacing() => AppTheme.responsiveSize(context, phone: 16, tablet: 20);
    double getBottomSpacing() => AppTheme.responsiveSize(context, phone: 20, tablet: 24);

    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: AppTheme.secondaryColor,
      body: SafeArea(
        child: Consumer<ImageDataProvider>(
          builder: (context, provider, _) {
            final list = provider.imageList;

            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: getTopSpacing()),

                  // CARD 1 - Instant Redesign
                  safeCard(list, 0, () {
                    final item = list[0];
                    return ComparisonCardWidget(
                      beforeImage: item.beforeImage,
                      afterImage: item.afterImage,
                      title: item.title,
                      subtitle: item.subtitle,
                      isLiked: item.isLiked,
                      categoryIcon: _getIconForTitle(item.title),
                      onLikePressed: () => provider.toggleLike(0),
                      onArrowPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const UploadScreen()));
                      },
                    );
                  }),

                  SizedBox(height: getCardSpacing()),

                  // CARD 2 - Exterior Redesign
                  safeCard(list, 1, () {
                    final item = list[1];
                    return ComparisonCardWidget(
                      beforeImage: item.beforeImage,
                      afterImage: item.afterImage,
                      title: item.title,
                      subtitle: item.subtitle,
                      isLiked: item.isLiked,
                      categoryIcon: _getIconForTitle(item.title),
                      onLikePressed: () => provider.toggleLike(1),
                      onArrowPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const ExteriorRedesign()));
                      },
                    );
                  }),

                  SizedBox(height: getAdSpacing()),
                  safeAd(0, getAdHeight(), getAdHorizontalMargin(), getAdVerticalMargin()),
                  SizedBox(height: getAdSpacing()),

                  // CARD 3 - Wall Redesign
                  safeCard(list, 2, () {
                    final item = list[2];
                    return ComparisonCardWidget(
                      beforeImage: item.beforeImage,
                      afterImage: item.afterImage,
                      title: item.title,
                      subtitle: item.subtitle,
                      isLiked: item.isLiked,
                      categoryIcon: _getIconForTitle(item.title),
                      onLikePressed: () => provider.toggleLike(2),
                      onArrowPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const WaalRedesign()));
                      },
                    );
                  }),

                  SizedBox(height: getCardSpacing()),

                  // CARD 4 - Floor Redesign
                  safeCard(list, 3, () {
                    final item = list[3];
                    return ComparisonCardWidget(
                      beforeImage: item.beforeImage,
                      afterImage: item.afterImage,
                      title: item.title,
                      subtitle: item.subtitle,
                      isLiked: item.isLiked,
                      categoryIcon: _getIconForTitle(item.title),
                      onLikePressed: () => provider.toggleLike(3),
                      onArrowPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const FloorRedesign()));
                      },
                    );
                  }),

                  SizedBox(height: getAdSpacing()),
                  safeAd(1, getAdHeight(), getAdHorizontalMargin(), getAdVerticalMargin()),
                  SizedBox(height: getAdSpacing()),

                  // CARD 5 - Remove Object
                  safeCard(list, 4, () {
                    final item = list[4];
                    return ComparisonCardWidget(
                      beforeImage: item.beforeImage,
                      afterImage: item.afterImage,
                      title: item.title,
                      subtitle: item.subtitle,
                      isLiked: item.isLiked,
                      categoryIcon: _getIconForTitle(item.title),
                      onLikePressed: () => provider.toggleLike(4),
                      onArrowPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const ObjectRemove()));
                      },
                    );
                  }),

                  SizedBox(height: getCardSpacing()),

                  // NEW CARD 6 - Replace
                  ComparisonCardWidget(
                    beforeImage: 'assets/images/re1.jpg',
                    afterImage: 'assets/images/re.jpg',
                    title: 'Replace',
                    subtitle: 'Replace any object with AI',
                    isLiked: false,
                    categoryIcon: _getIconForTitle('Replace'),
                    onLikePressed: () {},
                    onArrowPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const ReplaceScreen()));
                    },
                  ),

                  SizedBox(height: getCardSpacing()),

                  // NEW CARD 7 - Fill Space (NEW FEATURE)
                  ComparisonCardWidget(
                    beforeImage: 'assets/images/fi1.jpeg',
                    afterImage: 'assets/images/fi.png',
                    title: 'Fill Space',
                    subtitle: 'Fill empty areas intelligently',
                    isLiked: false,
                    categoryIcon: _getIconForTitle('Fill Space'),
                    onLikePressed: () {},
                    onArrowPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const FillSpaceScreen()));
                    },
                  ),

                  SizedBox(height: getBottomSpacing()),
                  ComparisonCardWidget(
                    beforeImage: 'assets/images/ref1.jpg',
                    afterImage: 'assets/images/ref.png',
                    title: 'Reference',
                    subtitle: 'Provide the reference image',
                    isLiked: false,
                    categoryIcon: _getIconForTitle('Reference'),
                    onLikePressed: () {},
                    onArrowPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const ReferenceTransformScreen()));
                    },
                  ),

                  SizedBox(height: getBottomSpacing()),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}