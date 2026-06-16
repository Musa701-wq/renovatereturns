class ImageComparison {
  final String? id;
  final String beforeImage;
  final String afterImage;
  final String title;
  final String subtitle;
  final String? userId;
  bool isLiked;
  bool isPublic;

  ImageComparison({
    this.id,
    required this.beforeImage,
    required this.afterImage,
    required this.title,
    required this.subtitle,
    this.userId,
    this.isLiked = false,
    this.isPublic = false,
  });
}