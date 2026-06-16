import 'package:flutter/material.dart';
import '../services/backend_api_service.dart';
import '../models/image_model.dart' show ImageComparison;

class ImageDataProvider with ChangeNotifier {
  List<ImageComparison> _historyList = [];
  List<ImageComparison> _galleryList = [];
  bool _isLoading = false;

  List<ImageComparison> get historyList => _historyList;
  List<ImageComparison> get galleryList => _galleryList;
  
  // Backwards compatibility for screens still using imageList
  List<ImageComparison> get imageList => _historyList;
  
  bool get isLoading => _isLoading;

  Future<void> fetchHistory() async {
    _isLoading = true;
    notifyListeners();
    try {
      final history = await BackendApiService.getHistory();
      _historyList = history.map((item) => ImageComparison(
        id: item['id']?.toString(),
        beforeImage: item['beforeImageUrl'] ?? '',
        afterImage: item['afterImageUrl'] ?? '',
        title: item['prompt'] ?? 'AI Generation',
        subtitle: item['category'] ?? 'Interior',
        userId: item['userId'] ?? item['uid'],
        isPublic: item['isPublic'] ?? false,
      )).toList();
    } catch (e) {
      debugPrint('Error fetching history: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPublicGallery() async {
    _isLoading = true;
    notifyListeners();
    try {
      final gallery = await BackendApiService.getPublicGallery();
      _galleryList = gallery.map((item) => ImageComparison(
        id: item['id']?.toString(),
        beforeImage: item['beforeImageUrl'] ?? '',
        afterImage: item['afterImageUrl'] ?? '',
        title: item['prompt'] ?? 'Public Design',
        subtitle: item['category'] ?? 'Interior',
        userId: item['userId'] ?? item['uid'],
        isPublic: item['isPublic'] ?? true,
      )).toList();
    } catch (e) {
      debugPrint('Error fetching gallery: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleLike(int index) {
    if (index >= 0 && index < _galleryList.length) {
      _galleryList[index].isLiked = !_galleryList[index].isLiked;
      notifyListeners();
    }
  }

  // Helper to add locally
  void addImageToHistory(ImageComparison newImage) {
    _historyList.insert(0, newImage);
    notifyListeners();
  }
}
