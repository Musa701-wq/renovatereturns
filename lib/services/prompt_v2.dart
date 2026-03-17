class PromptGeneratorV2 {
  static String generateFreeTierRedesignPrompt({
    required String roomType,
    required String style,
    required String budget,
    required String imageSource,
  }) {
    return "LOW QUALITY JPEG $style $roomType redesign. 256px resolution. HIGH COMPRESSION. Simple decor. REF: $imageSource";
  }

  static String generateFreeTierPrompt({
    required String roomType,
    required String style,
    required String imageSource,
  }) {
    return "LOW QUALITY JPEG SD redesign $roomType. Style: $style. 256px. HIGH COMPRESSION. REF: $imageSource";
  }

  static String generateFreeTierWallPrompt({
    required String wallType,
    required String imageSource,
  }) {
    return "LOW QUALITY JPEG Redesign wall: $wallType. 256px SD. HIGH COMPRESSION. REF: $imageSource";
  }

  static String generateFreeTierFloorPrompt({
    required String floorType,
    required String imageSource,
  }) {
    return "LOW QUALITY JPEG Replace floor: $floorType. 256px SD. HIGH COMPRESSION. REF: $imageSource";
  }

  static String generateFreeTierRemovePrompt({
    required String objectToRemove,
    required String imageSource,
  }) {
    return "LOW QUALITY JPEG Remove: $objectToRemove. 256px SD. HIGH COMPRESSION. REF: $imageSource";
  }

  static String generateFreeTierFillPrompt({
    required String fillInstruction,
    required String imageSource,
  }) {
    return "LOW QUALITY JPEG Fill space: $fillInstruction. 256px SD. HIGH COMPRESSION. REF: $imageSource";
  }
}
