class ImageComparison {
  final String beforeImage;
  final String afterImage;
  final String title;
  final String subtitle;
  bool isLiked;

  ImageComparison({
    required this.beforeImage,
    required this.afterImage,
    required this.title,
    required this.subtitle,
    this.isLiked = false,
  });
}