import 'package:flutter/material.dart';

import '../models/image_model.dart' show ImageComparison;

class ImageDataProvider with ChangeNotifier {
  List<ImageComparison> _imageList = [
    ImageComparison(
      beforeImage: 'assets/images/int1.jpg',
      afterImage: 'assets/images/inta.jpg',
      title: 'Instant Redesign',
      subtitle: 'Modern living room transformation',
    ),
    ImageComparison(
      beforeImage: 'assets/images/ext1.jpg',
      afterImage: 'assets/images/exta.jpg',
      title: 'Exterior Redesign',
      subtitle: 'House facade makeover',
    ),
    ImageComparison(
      beforeImage: 'assets/images/wall1.jpg',
      afterImage: 'assets/images/villa.jpg',
      title: 'Wall Redesign',
      subtitle: 'Accent wall transformation',
    ),
    ImageComparison(
      beforeImage: 'assets/images/floor1.jpg',
      afterImage: 'assets/images/floora.jpg',
      title: 'Floor Redesign',
      subtitle: 'Accent wall transformation',
    ),
    ImageComparison(
      beforeImage: 'assets/images/obj1.jpg',
      afterImage: 'assets/images/img.png',
      title: 'Remove Object',
      subtitle: 'Clean background editing',
    ),
    ImageComparison(
      beforeImage: 'assets/images/replace_before.jpg', // NEW CARD
      afterImage: 'assets/images/replace_after.jpg',   // NEW CARD
      title: 'Replace',
      subtitle: 'Replace any object with AI',
    ),
    ImageComparison(
      beforeImage: 'assets/images/back1.jpg',
      afterImage: 'assets/images/back2.png',
      title: 'Furniture Makeover',
      subtitle: 'Interior styling upgrade',
    ),
    ImageComparison(
      beforeImage: 'assets/images/reference_before.jpg',
      afterImage: 'assets/images/reference_after.jpg',
      title: 'Reference Transform',
      subtitle: 'Apply style from reference image',
    ),
  ];

  List<ImageComparison> get imageList => _imageList;

  void toggleLike(int index) {
    _imageList[index].isLiked = !_imageList[index].isLiked;
    notifyListeners();
  }

  void addImage(ImageComparison newImage) {
    _imageList.add(newImage);
    notifyListeners();
  }

  void removeImage(int index) {
    _imageList.removeAt(index);
    notifyListeners();
  }
}