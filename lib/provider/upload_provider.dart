// provider/upload_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../services/api_services.dart';
import '../services/prompt_.dart';

class UploadProvider with ChangeNotifier {
  String? _selectedStyle = 'Soft';
  String? _selectedBudget = 'Medium';
  String? _selectedRoomType;
  String? _selectedImageSource;
  File? _selectedImage;
  bool _isMultipleVariationsEnabled = false; // ✅ Multiple variations state
  final ImagePicker _imagePicker = ImagePicker();

  // Options lists
  final List<String> _styleOptions = ['Soft', 'Medium', 'Extreme', 'Professional', 'Creative'];
  final List<String> _budgetOptions = ['Low', 'Medium', 'High', 'Premium'];
  final List<String> _roomTypes = [
    'Home Spa', 'Mudroom', 'Craft Room', 'Dressing Room', 'Guest Bedroom',
    'Home Bar', 'Library', 'Art Studio', 'Yoga Studio', 'Photo Studio',
    'Multimedia Room', 'Auditorium', 'Medical Exam Room', 'Reception Area',
    'Music Room', 'Science Laboratory', 'Living room', 'Bedroom', 'Bathroom',
    'Kitchen', 'Dining room', 'Attic', 'Study room', 'Home office', 'Family Room',
    'Formal Dining Room', 'Home Theater', 'Kids Room', 'Balcony', 'Gaming room',
    'Meeting room', 'Workshop', 'Kitchen'
  ];

  // Floor types list
  final List<String> _floorTypes = [
    'Carpet', 'Hardwood', 'Vinyl', 'Stone', 'Concrete', 'Rubber',
    'Tile & Stone', 'Concrete Flooring', 'Cork', 'Laminate', 'Terrazzo',
    'Bamboo', 'Linoleum', 'Porcelain Tile', 'Engineered Wood', 'Epoxy',
    'Parquet', 'Slate', 'Marble', 'Granite'
  ];

  // Getters
  String? get selectedStyle => _selectedStyle;
  String? get selectedBudget => _selectedBudget;
  String? get selectedRoomType => _selectedRoomType;
  String? get selectedImageSource => _selectedImageSource;
  File? get selectedImage => _selectedImage;
  List<String> get styleOptions => _styleOptions;
  List<String> get budgetOptions => _budgetOptions;
  List<String> get roomTypes => _roomTypes;
  List<String> get floorTypes => _floorTypes;
  bool get isMultipleVariationsEnabled => _isMultipleVariationsEnabled;
  bool get isReadyForGeneration {
    return _selectedImage != null && _selectedRoomType != null;
  }

  // Add this method (for exterior validation) - Method 2
  bool get isReadyForExteriorGeneration {
    return _selectedImage != null && _selectedRoomType != null;
  }

  // Setters
  void setSelectedStyle(String? style) {
    _selectedStyle = style;
    notifyListeners();
  }

  void setSelectedBudget(String? budget) {
    _selectedBudget = budget;
    notifyListeners();
  }

  void setSelectedRoomType(String? roomType) {
    _selectedRoomType = roomType;
    notifyListeners();
  }

  void setSelectedImageSource(String? source) {
    _selectedImageSource = source;
    notifyListeners();
  }

  void setSelectedImage(File? image) {
    _selectedImage = image;
    notifyListeners();
  }

  void setMultipleVariationsEnabled(bool enabled) {
    _isMultipleVariationsEnabled = enabled;
    notifyListeners();
  }

  // Image Source Methods
  Future<void> openCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 80,
      );

      if (image != null) {
        _selectedImage = File(image.path);
        _selectedImageSource = 'Camera';
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Camera not available: $e');
    }
  }

  Future<void> openGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 80,
      );

      if (image != null) {
        _selectedImage = File(image.path);
        _selectedImageSource = 'Gallery';
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Gallery not available: $e');
    }
  }

  Future<String> generateImage() async {
    try {
      if (_selectedRoomType == null) {
        throw Exception('Please select a room type');
      }
      if (_selectedImage == null) {
        throw Exception('Please select an image');
      }

      print('=== GENERATING IMAGE ===');
      print('Room Type: $_selectedRoomType');
      print('Style: $_selectedStyle');
      print('Budget: $_selectedBudget');
      print('Image Source: $_selectedImageSource');
      print('Image Path: ${_selectedImage!.path}');
      print('========================');
      String generatedImageUrl = await generateImageWithAPI();

      return generatedImageUrl;

    } catch (e) {
      throw Exception('Image generation failed: $e');
    }
  }

  String generateAIPrompt() {
    if (_selectedRoomType == null) throw Exception('Please select a room type');
    if (_selectedStyle == null) throw Exception('Please select a style');
    if (_selectedBudget == null) throw Exception('Please select a budget');
    if (_selectedImage == null) throw Exception('Please select an image');

    // Use PromptGenerator class to generate prompt
    String prompt = PromptGenerator.generatePrompt(
      roomType: _selectedRoomType!,
      style: _selectedStyle!,
      budget: _selectedBudget!,
      imageSource: _selectedImageSource ?? 'Unknown',
    );

    // Save prompt to file
    _savePromptToFile(prompt);

    return prompt;
  }

  // Save prompt to file
  Future<void> _savePromptToFile(String prompt) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/design_prompts_history.txt');

      String timestamp = DateTime.now().toString().split('.')[0];
      String savedText = '''
=== DESIGN PROMPT - $timestamp ===
Room Type: $_selectedRoomType
AI Intervention: $_selectedStyle
Budget: $_selectedBudget
Image Source: $_selectedImageSource
Image Path: ${_selectedImage?.path}

PROMPT:
$prompt
================================
\n
''';

      await file.writeAsString(savedText, mode: FileMode.append);
      print('✅ Prompt saved to: ${file.path}');
    } catch (e) {
      print('❌ Error saving prompt: $e');
    }
  }

  Future<String> generateImageWithAPI() async {
    try {
      if (_selectedRoomType == null) throw Exception('Please select a room type');
      if (_selectedImage == null) throw Exception('Please select an image');

      // Generate prompt
      String prompt = generateAIPrompt();
      print('🚀 Starting image generation...');
      print('📝 Prompt: ${prompt.substring(0, 100)}...');

      // ✅ ACTUAL IMAGE GENERATION CALL
      String generatedImageUrl = await GeminiService.generateImageFromPrompt(
        prompt: prompt,
        imageFile: _selectedImage!,
      );

      print('✅ Image generated successfully: $generatedImageUrl');
      return generatedImageUrl;

    } catch (e) {
      throw Exception('Image generation failed: $e');
    }
  }

  Future<String> getPromptHistory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/design_prompts_history.txt');

      if (await file.exists()) {
        return await file.readAsString();
      } else {
        return 'No prompt history found.';
      }
    } catch (e) {
      return 'Error reading prompt history: $e';
    }
  }

// 📍 EXISTING reset() METHOD MEIN YEH 2 LINES ADD KARO:
  void reset() {
    _selectedStyle = 'Soft';
    _selectedBudget = 'Medium';
    _selectedRoomType = null;
    _selectedImageSource = null;
    _selectedImage = null;
    _secondaryImage = null;
    _secondaryImageSource = null;
    _isMultipleVariationsEnabled = false; // Reset toggle
    notifyListeners();
  }

  // EXTERIOR DESIGN METHODS
  Future<String> generateExteriorImage() async {
    try {
      if (_selectedRoomType == null) {
        throw Exception('Please select an exterior design style');
      }
      if (_selectedImage == null) {
        throw Exception('Please select an image');
      }

      print('=== GENERATING EXTERIOR DESIGN ===');
      print('Design Style: $_selectedRoomType');
      print('Image Path: ${_selectedImage!.path}');
      print('========================');

      String generatedImageUrl = await generateExteriorImageWithAPI();
      return generatedImageUrl;

    } catch (e) {
      throw Exception('Exterior design generation failed: $e');
    }
  }
  // UploadProvider mein yeh method add karo
  Future<String> generateFloorImageWithCustomPrompt(String customPrompt) async {
    try {
      if (_selectedRoomType == null) {
        throw Exception('Please select a floor design type');
      }
      if (_selectedImage == null) {
        throw Exception('Please select an image');
      }

      print('=== GENERATING FLOOR DESIGN WITH CUSTOM PROMPT ===');
      print('Floor Type: $_selectedRoomType');
      print('Custom Requirements: ${customPrompt.substring(0, 50)}...');
      print('Image Path: ${_selectedImage!.path}');
      print('========================');

      String generatedImageUrl = await GeminiService.generateImageFromPrompt(
        prompt: customPrompt,
        imageFile: _selectedImage!,
      );

      return generatedImageUrl;

    } catch (e) {
      throw Exception('Floor design generation with custom prompt failed: $e');
    }
  }

  String generateExteriorAIPrompt() {
    if (_selectedRoomType == null) throw Exception('Please select an exterior design style');
    if (_selectedImage == null) throw Exception('Please select an image');

    // Use Exterior PromptGenerator with imageSource parameter
    String prompt = ExteriorPromptGenerator.generateExteriorPrompt(
      designStyle: _selectedRoomType!,
      imageSource: _selectedImageSource ?? 'Unknown',
    );

    // Save prompt to file
    _saveExteriorPromptToFile(prompt);

    return prompt;
  }

  Future<void> _saveExteriorPromptToFile(String prompt) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/exterior_design_prompts_history.txt');

      String timestamp = DateTime.now().toString().split('.')[0];
      String savedText = '''
=== EXTERIOR DESIGN PROMPT - $timestamp ===
Design Style: $_selectedRoomType
Image Source: $_selectedImageSource
Image Path: ${_selectedImage?.path}

PROMPT:
$prompt
================================
\n
''';

      await file.writeAsString(savedText, mode: FileMode.append);
      print('✅ Exterior Prompt saved to: ${file.path}');
    } catch (e) {
      print('❌ Error saving exterior prompt: $e');
    }
  }

  Future<String> generateExteriorImageWithAPI() async {
    try {
      if (_selectedRoomType == null) throw Exception('Please select an exterior design style');
      if (_selectedImage == null) throw Exception('Please select an image');

      // Generate exterior-specific prompt
      String prompt = generateExteriorAIPrompt();
      print('🚀 Starting exterior design generation...');
      print('📝 Prompt: ${prompt.substring(0, 100)}...');

      // ✅ EXTERIOR IMAGE GENERATION CALL
      String generatedImageUrl = await GeminiService.generateImageFromPrompt(
        prompt: prompt,
        imageFile: _selectedImage!,
      );

      print('✅ Exterior design generated successfully: $generatedImageUrl');
      return generatedImageUrl;

    } catch (e) {
      throw Exception('Exterior design generation failed: $e');
    }
  }

  // FLOOR DESIGN METHODS
  Future<String> generateFloorImage() async {
    try {
      if (_selectedRoomType == null) {
        throw Exception('Please select a floor design type');
      }
      if (_selectedImage == null) {
        throw Exception('Please select an image');
      }

      print('=== GENERATING FLOOR DESIGN ===');
      print('Floor Type: $_selectedRoomType');
      print('Image Path: ${_selectedImage!.path}');
      print('========================');

      String generatedImageUrl = await generateFloorImageWithAPI();
      return generatedImageUrl;

    } catch (e) {
      throw Exception('Floor design generation failed: $e');
    }
  }

  String generateFloorAIPrompt() {
    if (_selectedRoomType == null) throw Exception('Please select a floor design type');
    if (_selectedImage == null) throw Exception('Please select an image');

    // Use Floor PromptGenerator with imageSource parameter
    String prompt = FloorPromptGenerator.generateFloorPrompt(
      floorType: _selectedRoomType!,
      imageSource: _selectedImageSource ?? 'Unknown',
    );

    // Save prompt to file
    _saveFloorPromptToFile(prompt);

    return prompt;
  }

  Future<void> _saveFloorPromptToFile(String prompt) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/floor_design_prompts_history.txt');

      String timestamp = DateTime.now().toString().split('.')[0];
      String savedText = '''
=== FLOOR DESIGN PROMPT - $timestamp ===
Floor Type: $_selectedRoomType
Image Source: $_selectedImageSource
Image Path: ${_selectedImage?.path}

PROMPT:
$prompt
================================
\n
''';

      await file.writeAsString(savedText, mode: FileMode.append);
      print('✅ Floor Prompt saved to: ${file.path}');
    } catch (e) {
      print('❌ Error saving floor prompt: $e');
    }
  }

  Future<String> generateFloorImageWithAPI() async {
    try {
      if (_selectedRoomType == null) throw Exception('Please select a floor design type');
      if (_selectedImage == null) throw Exception('Please select an image');

      // Generate floor-specific prompt
      String prompt = generateFloorAIPrompt();
      print('🚀 Starting floor design generation...');
      print('📝 Prompt: ${prompt.substring(0, 100)}...');

      // ✅ FLOOR IMAGE GENERATION CALL
      String generatedImageUrl = await GeminiService.generateImageFromPrompt(
        prompt: prompt,
        imageFile: _selectedImage!,
      );

      print('✅ Floor design generated successfully: $generatedImageUrl');
      return generatedImageUrl;

    } catch (e) {
      throw Exception('Floor design generation failed: $e');
    }
  }

  // Get floor design history
  Future<String> getFloorPromptHistory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/floor_design_prompts_history.txt');

      if (await file.exists()) {
        return await file.readAsString();
      } else {
        return 'No floor design prompt history found.';
      }
    } catch (e) {
      return 'Error reading floor design prompt history: $e';
    }
  }

  // Reset for floor design (optional - can use main reset)
  void resetForFloorDesign() {
    _selectedRoomType = null;
    _selectedImageSource = null;
    _selectedImage = null;
    notifyListeners();
  }
  // UploadProvider mein yeh methods add karo
  Future<String> generateObjectRemoveImage({required String objectToRemove}) async {
    try {
      if (_selectedImage == null) {
        throw Exception('Please select an image');
      }

      print('=== GENERATING OBJECT REMOVAL ===');
      print('Object to Remove: $objectToRemove');
      print('Image Path: ${_selectedImage!.path}');
      print('========================');

      String generatedImageUrl = await generateObjectRemoveImageWithAPI(
        objectToRemove: objectToRemove,
      );

      return generatedImageUrl;

    } catch (e) {
      throw Exception('Object removal generation failed: $e');
    }
  }

  String generateObjectRemoveAIPrompt({required String objectToRemove}) {
    if (_selectedImage == null) throw Exception('Please select an image');

    String prompt = ObjectRemovePromptGenerator.generateObjectRemovePrompt(
      objectToRemove: objectToRemove,
      imageSource: _selectedImageSource ?? 'Unknown',
    );

    _saveObjectRemovePromptToFile(prompt, objectToRemove);

    return prompt;
  }

  Future<void> _saveObjectRemovePromptToFile(String prompt, String objectToRemove) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/object_remove_prompts_history.txt');

      String timestamp = DateTime.now().toString().split('.')[0];
      String savedText = '''
=== OBJECT REMOVAL PROMPT - $timestamp ===
Object to Remove: $objectToRemove
Image Source: $_selectedImageSource
Image Path: ${_selectedImage?.path}

PROMPT:
$prompt
================================
\n
''';

      await file.writeAsString(savedText, mode: FileMode.append);
      print('✅ Object Removal Prompt saved to: ${file.path}');
    } catch (e) {
      print('❌ Error saving object removal prompt: $e');
    }
  }

  Future<String> generateObjectRemoveImageWithAPI({required String objectToRemove}) async {
    try {
      if (_selectedImage == null) throw Exception('Please select an image');

      String prompt = generateObjectRemoveAIPrompt(objectToRemove: objectToRemove);
      print('🚀 Starting object removal generation...');
      print('📝 Prompt: ${prompt.substring(0, 100)}...');

      String generatedImageUrl = await GeminiService.generateImageFromPrompt(
        prompt: prompt,
        imageFile: _selectedImage!,
      );

      print('✅ Object removal generated successfully: $generatedImageUrl');
      return generatedImageUrl;

    } catch (e) {
      throw Exception('Object removal generation failed: $e');
    }
  }

  Future<String> getObjectRemovePromptHistory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/object_remove_prompts_history.txt');

      if (await file.exists()) {
        return await file.readAsString();
      } else {
        return 'No object removal prompt history found.';
      }
    } catch (e) {
      return 'Error reading object removal prompt history: $e';
    }
  }
  // provider/upload_provider.dart (New methods to add ONLY)
// Wall design specific lists
  final List<String> _wallTypes = [
    'Paint', 'Wallpaper', 'Wood Paneling', 'Stone Veneer', 'Brick',
    'Tile', 'Wainscoting', 'Concrete', 'Fabric', 'Metal',
    'Venetian Plaster', 'Murals', 'Glass', 'Mosaic', 'Cork',
    'Leather', '3D Wall Panels', 'Mirror', 'Chalkboard', 'Bamboo'
  ];

// Getters ke section mein add karein:
  List<String> get wallTypes => _wallTypes;

// Wall design methods (UploadProvider class ke ander add karein):
  Future<String> generateWallImage() async {
    try {
      if (_selectedRoomType == null) {
        throw Exception('Please select a wall design type');
      }
      if (_selectedImage == null) {
        throw Exception('Please select an image');
      }

      print('=== GENERATING WALL DESIGN ===');
      print('Wall Type: $_selectedRoomType');
      print('Image Path: ${_selectedImage!.path}');
      print('========================');

      String generatedImageUrl = await generateWallImageWithAPI();
      return generatedImageUrl;

    } catch (e) {
      throw Exception('Wall design generation failed: $e');
    }
  }

  String generateWallAIPrompt() {
    if (_selectedRoomType == null) throw Exception('Please select a wall design type');
    if (_selectedImage == null) throw Exception('Please select an image');

    // Use Wall PromptGenerator with imageSource parameter
    String prompt = WallPromptGenerator.generateWallPrompt(
      wallType: _selectedRoomType!,
      imageSource: _selectedImageSource ?? 'Unknown',
    );

    // Save prompt to file
    _saveWallPromptToFile(prompt);

    return prompt;
  }

  Future<void> _saveWallPromptToFile(String prompt) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/wall_design_prompts_history.txt');

      String timestamp = DateTime.now().toString().split('.')[0];
      String savedText = '''
=== WALL DESIGN PROMPT - $timestamp ===
Wall Type: $_selectedRoomType
Image Source: $_selectedImageSource
Image Path: ${_selectedImage?.path}

PROMPT:
$prompt
================================
\n
''';

      await file.writeAsString(savedText, mode: FileMode.append);
      print('✅ Wall Prompt saved to: ${file.path}');
    } catch (e) {
      print('❌ Error saving wall prompt: $e');
    }
  }

  Future<String> generateWallImageWithAPI() async {
    try {
      if (_selectedRoomType == null) throw Exception('Please select a wall design type');
      if (_selectedImage == null) throw Exception('Please select an image');

      // Generate wall-specific prompt
      String prompt = generateWallAIPrompt();
      print('🚀 Starting wall design generation...');
      print('📝 Prompt: ${prompt.substring(0, 100)}...');

      // ✅ WALL IMAGE GENERATION CALL
      String generatedImageUrl = await GeminiService.generateImageFromPrompt(
        prompt: prompt,
        imageFile: _selectedImage!,
      );

      print('✅ Wall design generated successfully: $generatedImageUrl');
      return generatedImageUrl;

    } catch (e) {
      throw Exception('Wall design generation failed: $e');
    }
  }

  Future<String> getWallPromptHistory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/wall_design_prompts_history.txt');

      if (await file.exists()) {
        return await file.readAsString();
      } else {
        return 'No wall design prompt history found.';
      }
    } catch (e) {
      return 'Error reading wall design prompt history: $e';
    }
  }
  // Add these methods to your UploadProvider class

// REPLACE FEATURE METHODS
  Future<String> generateReplaceImage({required String replaceInstruction}) async {
    try {
      if (_selectedImage == null) {
        throw Exception('Please select an image');
      }

      if (replaceInstruction.trim().isEmpty) {
        throw Exception('Please provide replacement instructions');
      }

      print('=== GENERATING OBJECT REPLACEMENT ===');
      print('Instruction: $replaceInstruction');
      print('Image Path: ${_selectedImage!.path}');
      print('========================');

      String generatedImageUrl = await generateReplaceImageWithAPI(
        replaceInstruction: replaceInstruction,
      );

      return generatedImageUrl;

    } catch (e) {
      throw Exception('Object replacement generation failed: $e');
    }
  }

  String generateReplaceAIPrompt({required String replaceInstruction}) {
    if (_selectedImage == null) throw Exception('Please select an image');
    if (replaceInstruction.trim().isEmpty) throw Exception('Please provide replacement instructions');

    String prompt = ReplacePromptGenerator.generateReplacePrompt(
      replaceInstruction: replaceInstruction,
      imageSource: _selectedImageSource ?? 'Unknown',
    );

    _saveReplacePromptToFile(prompt, replaceInstruction);

    return prompt;
  }

  Future<void> _saveReplacePromptToFile(String prompt, String replaceInstruction) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/replace_prompts_history.txt');

      String timestamp = DateTime.now().toString().split('.')[0];
      String savedText = '''
=== REPLACE PROMPT - $timestamp ===
Instruction: $replaceInstruction
Image Source: $_selectedImageSource
Image Path: ${_selectedImage?.path}

PROMPT:
$prompt
================================
\n
''';

      await file.writeAsString(savedText, mode: FileMode.append);
      print('✅ Replace Prompt saved to: ${file.path}');
    } catch (e) {
      print('❌ Error saving replace prompt: $e');
    }
  }

  Future<String> generateReplaceImageWithAPI({required String replaceInstruction}) async {
    try {
      if (_selectedImage == null) throw Exception('Please select an image');
      if (replaceInstruction.trim().isEmpty) throw Exception('Please provide replacement instructions');

      String prompt = generateReplaceAIPrompt(replaceInstruction: replaceInstruction);
      print('🚀 Starting object replacement generation...');
      print('📝 Prompt: ${prompt.substring(0, 100)}...');

      String generatedImageUrl = await GeminiService.generateImageFromPrompt(
        prompt: prompt,
        imageFile: _selectedImage!,
      );

      print('✅ Object replacement generated successfully: $generatedImageUrl');
      return generatedImageUrl;

    } catch (e) {
      throw Exception('Object replacement generation failed: $e');
    }
  }

  Future<String> getReplacePromptHistory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/replace_prompts_history.txt');

      if (await file.exists()) {
        return await file.readAsString();
      } else {
        return 'No replace prompt history found.';
      }
    } catch (e) {
      return 'Error reading replace prompt history: $e';
    }
  }
// Add these methods to your UploadProvider class



// FILL SPACE FEATURE METHODS (NEW)
  Future<String> generateKitchenImage({required String customPrompt}) async {
    try {
      if (_selectedImage == null) {
        throw Exception('Please select an image');
      }

      print('=== GENERATING KITCHEN DESIGN ===');
      print('Custom Requirements: ${customPrompt.substring(0, customPrompt.length > 50 ? 50 : customPrompt.length)}...');
      print('Image Path: ${_selectedImage!.path}');
      print('========================');

      String generatedImageUrl = await GeminiService.generateImageFromPrompt(
        prompt: customPrompt,
        imageFile: _selectedImage!,
      );

      return generatedImageUrl;

    } catch (e) {
      throw Exception('Kitchen design generation failed: $e');
    }
  }

  String generateKitchenAIPrompt({String? customRequirements}) {
    if (_selectedImage == null) throw Exception('Please select an image');

    // Use the new specialized KitchenPromptGenerator
    String prompt = KitchenPromptGenerator.generateKitchenPrompt(
      style: _selectedStyle ?? 'Modern',
      imageSource: _selectedImageSource ?? 'Unknown',
      customRequirements: customRequirements,
    );

    _saveKitchenPromptToFile(prompt);

    return prompt;
  }

  Future<void> _saveKitchenPromptToFile(String prompt) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/kitchen_design_prompts_history.txt');

      String timestamp = DateTime.now().toString().split('.')[0];
      String savedText = '''
=== KITCHEN DESIGN PROMPT - $timestamp ===
Image Source: $_selectedImageSource
Image Path: ${_selectedImage?.path}

PROMPT:
$prompt
================================
\n
''';

      await file.writeAsString(savedText, mode: FileMode.append);
      print('✅ Kitchen Prompt saved to: ${file.path}');
    } catch (e) {
      print('❌ Error saving kitchen prompt: $e');
    }
  }

// FILL SPACE FEATURE METHODS (NEW)
  Future<String> generateFillSpaceImage({required String fillInstruction}) async {
    try {
      if (_selectedImage == null) {
        throw Exception('Please select an image');
      }

      if (fillInstruction.trim().isEmpty) {
        throw Exception('Please provide fill space instructions');
      }

      print('=== GENERATING FILL SPACE ===');
      print('Instruction: $fillInstruction');
      print('Image Path: ${_selectedImage!.path}');
      print('========================');

      String generatedImageUrl = await generateFillSpaceImageWithAPI(
        fillInstruction: fillInstruction,
      );

      return generatedImageUrl;

    } catch (e) {
      throw Exception('Fill space generation failed: $e');
    }
  }

  String generateFillSpaceAIPrompt({required String fillInstruction}) {
    if (_selectedImage == null) throw Exception('Please select an image');
    if (fillInstruction.trim().isEmpty) throw Exception('Please provide fill space instructions');

    String prompt = FillSpacePromptGenerator.generateFillSpacePrompt(
      fillInstruction: fillInstruction,
      imageSource: _selectedImageSource ?? 'Unknown',
    );

    _saveFillSpacePromptToFile(prompt, fillInstruction);

    return prompt;
  }

  Future<void> _saveFillSpacePromptToFile(String prompt, String fillInstruction) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/fill_space_prompts_history.txt');

      String timestamp = DateTime.now().toString().split('.')[0];
      String savedText = '''
=== FILL SPACE PROMPT - $timestamp ===
Instruction: $fillInstruction
Image Source: $_selectedImageSource
Image Path: ${_selectedImage?.path}

PROMPT:
$prompt
================================
\n
''';

      await file.writeAsString(savedText, mode: FileMode.append);
      print('✅ Fill Space Prompt saved to: ${file.path}');
    } catch (e) {
      print('❌ Error saving fill space prompt: $e');
    }
  }

  Future<String> generateFillSpaceImageWithAPI({required String fillInstruction}) async {
    try {
      if (_selectedImage == null) throw Exception('Please select an image');
      if (fillInstruction.trim().isEmpty) throw Exception('Please provide fill space instructions');

      String prompt = generateFillSpaceAIPrompt(fillInstruction: fillInstruction);
      print('🚀 Starting fill space generation...');
      print('📝 Prompt: ${prompt.substring(0, 100)}...');

      String generatedImageUrl = await GeminiService.generateImageFromPrompt(
        prompt: prompt,
        imageFile: _selectedImage!,
      );

      print('✅ Fill space generated successfully: $generatedImageUrl');
      return generatedImageUrl;

    } catch (e) {
      throw Exception('Fill space generation failed: $e');
    }
  }

  Future<String> getFillSpacePromptHistory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/fill_space_prompts_history.txt');

      if (await file.exists()) {
        return await file.readAsString();
      } else {
        return 'No fill space prompt history found.';
      }
    } catch (e) {
      return 'Error reading fill space prompt history: $e';
    }
  }
// REFERENCE TRANSFORM PROPERTIES
  File? _secondaryImage;
  String? _secondaryImageSource;

// GETTERS
  File? get secondaryImage => _secondaryImage;
  String? get secondaryImageSource => _secondaryImageSource;

  bool get isReadyForReferenceTransform {
    return _selectedImage != null && _secondaryImage != null;
  }

// SETTERS
  void setSecondaryImage(File? image) {
    _secondaryImage = image;
    notifyListeners();
  }

  void setSecondaryImageSource(String? source) {
    _secondaryImageSource = source;
    notifyListeners();
  }

// REFERENCE TRANSFORM METHODS
  Future<void> openSecondaryCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 80,
      );

      if (image != null) {
        _secondaryImage = File(image.path);
        _secondaryImageSource = 'Camera';
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Camera not available: $e');
    }
  }

  Future<void> openSecondaryGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 80,
      );

      if (image != null) {
        _secondaryImage = File(image.path);
        _secondaryImageSource = 'Gallery';
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Gallery not available: $e');
    }
  }

  Future<String> generateReferenceTransformImage({String? additionalInstruction}) async {
    try {
      if (_selectedImage == null) {
        throw Exception('Please select reference image (Image A)');
      }
      if (_secondaryImage == null) {
        throw Exception('Please select target image (Image B)');
      }

      print('=== GENERATING REFERENCE TRANSFORM ===');
      print('Reference Image (A): ${_selectedImage!.path}');
      print('Target Image (B): ${_secondaryImage!.path}');
      if (additionalInstruction != null && additionalInstruction.isNotEmpty) {
        print('Additional Instructions: $additionalInstruction');
      }
      print('========================');

      String generatedImageUrl = await generateReferenceTransformWithAPI(
        additionalInstruction: additionalInstruction,
      );

      return generatedImageUrl;

    } catch (e) {
      throw Exception('Reference transform generation failed: $e');
    }
  }

  String generateReferenceTransformAIPrompt({String? additionalInstruction}) {
    if (_selectedImage == null) throw Exception('Please select reference image (Image A)');
    if (_secondaryImage == null) throw Exception('Please select target image (Image B)');

    String prompt = ReferenceTransformPromptGenerator.generateReferenceTransformPrompt(
      referenceImageSource: _selectedImageSource ?? 'Unknown',
      targetImageSource: _secondaryImageSource ?? 'Unknown',
      additionalInstruction: additionalInstruction,
    );

    _saveReferenceTransformPromptToFile(prompt, additionalInstruction);

    return prompt;
  }

  Future<void> _saveReferenceTransformPromptToFile(String prompt, String? additionalInstruction) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/reference_transform_prompts_history.txt');

      String timestamp = DateTime.now().toString().split('.')[0];
      String savedText = '''
=== REFERENCE TRANSFORM PROMPT - $timestamp ===
Reference Image (A): $_selectedImageSource - ${_selectedImage?.path}
Target Image (B): $_secondaryImageSource - ${_secondaryImage?.path}
Additional Instructions: ${additionalInstruction ?? 'None'}

PROMPT:
$prompt
================================
\n
''';

      await file.writeAsString(savedText, mode: FileMode.append);
      print('✅ Reference Transform Prompt saved to: ${file.path}');
    } catch (e) {
      print('❌ Error saving reference transform prompt: $e');
    }
  }

  Future<String> generateReferenceTransformWithAPI({String? additionalInstruction}) async {
    try {
      if (_selectedImage == null) throw Exception('Please select reference image (Image A)');
      if (_secondaryImage == null) throw Exception('Please select target image (Image B)');

      String prompt = generateReferenceTransformAIPrompt(additionalInstruction: additionalInstruction);
      print('🚀 Starting reference transform generation...');
      print('📝 Prompt: ${prompt.substring(0, 100)}...');

      String generatedImageUrl = await GeminiService.generateImageFromDualPrompt(
        prompt: prompt,
        referenceImageFile: _selectedImage!,
        targetImageFile: _secondaryImage!,
      );

      print('✅ Reference transform generated successfully: $generatedImageUrl');
      return generatedImageUrl;

    } catch (e) {
      throw Exception('Reference transform generation failed: $e');
    }
  }

  Future<String> getReferenceTransformPromptHistory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/reference_transform_prompts_history.txt');

      if (await file.exists()) {
        return await file.readAsString();
      } else {
        return 'No reference transform prompt history found.';
      }
    } catch (e) {
      return 'Error reading reference transform prompt history: $e';
    }
  }

// CUSTOMIZATION METHODS
  Future<String> generateImageWithCustomization({String? customization}) async {
    try {
      if (_selectedRoomType == null) {
        throw Exception('Please select a room type');
      }
      if (_selectedImage == null) {
        throw Exception('Please select an image');
      }

      print('=== GENERATING IMAGE WITH CUSTOMIZATION ===');
      print('Room Type: $_selectedRoomType');
      print('Style: $_selectedStyle');
      print('Budget: $_selectedBudget');
      print('Image Source: $_selectedImageSource');
      print('Customization: ${customization ?? "None"}');
      print('Image Path: ${_selectedImage!.path}');
      print('========================');

      String generatedImageUrl = await generateImageWithAPIAndCustomization(
        customization: customization,
      );

      return generatedImageUrl;

    } catch (e) {
      throw Exception('Image generation failed: $e');
    }
  }

// NEW METHOD 2: Generate AI prompt with customization embedded
  String generateAIPromptWithCustomization({String? customization}) {
    if (_selectedRoomType == null) throw Exception('Please select a room type');
    if (_selectedStyle == null) throw Exception('Please select a style');
    if (_selectedBudget == null) throw Exception('Please select a budget');
    if (_selectedImage == null) throw Exception('Please select an image');

    // Use PromptGenerator with customization
    String prompt = PromptGenerator.generatePromptWithCustomization(
      roomType: _selectedRoomType!,
      style: _selectedStyle!,
      budget: _selectedBudget!,
      imageSource: _selectedImageSource ?? 'Unknown',
      customRequirements: customization, // Pass customization
    );

    // Save prompt to file
    _savePromptToFileWithCustomization(prompt, customization);

    return prompt;
  }

// NEW METHOD 3: Save prompt with customization info
  Future<void> _savePromptToFileWithCustomization(
      String prompt,
      String? customization,
      ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/design_prompts_history.txt');

      String timestamp = DateTime.now().toString().split('.')[0];
      String customText = customization != null && customization.isNotEmpty
          ? 'Custom Requirements: $customization'
          : 'Custom Requirements: None';

      String savedText = '''
=== DESIGN PROMPT - $timestamp ===
Room Type: $_selectedRoomType
AI Intervention: $_selectedStyle
Budget: $_selectedBudget
Image Source: $_selectedImageSource
$customText
Image Path: ${_selectedImage?.path}

PROMPT:
$prompt
================================
\n
''';

      await file.writeAsString(savedText, mode: FileMode.append);
      print('✅ Prompt with customization saved to: ${file.path}');
    } catch (e) {
      print('❌ Error saving prompt: $e');
    }
  }

// NEW METHOD 4: API call with customization
  Future<String> generateImageWithAPIAndCustomization({
    String? customization,
  }) async {
    try {
      if (_selectedRoomType == null) throw Exception('Please select a room type');
      if (_selectedImage == null) throw Exception('Please select an image');

      // Generate prompt with customization
      String prompt = generateAIPromptWithCustomization(
        customization: customization,
      );
      print('🚀 Starting image generation with customization...');
      print('📝 Prompt: ${prompt.substring(0, 100)}...');

      // ✅ ACTUAL IMAGE GENERATION CALL
      String generatedImageUrl = await GeminiService.generateImageFromPrompt(
        prompt: prompt,
        imageFile: _selectedImage!,
      );

      print('✅ Image with customization generated successfully: $generatedImageUrl');
      return generatedImageUrl;

    } catch (e) {
      throw Exception('Image generation with customization failed: $e');
    }
  }

  // ✅ NEW METHOD: GENERATE MULTIPLE VARIATIONS
  Future<List<String>> generateMultipleImagesFromAPI({
    required String basePrompt,
    required File imageFile,
    int count = 3,
    double? temperature,
  }) async {
    try {
      print('🚀 Starting multiple variations (count: $count)...');
      List<String> results = [];

      for (int i = 0; i < count; i++) {
        String variationDetails = "";
        if (i == 0) variationDetails = " Create a first unique variation focused on high-end materials and sleek textures.";
        if (i == 1) variationDetails = " Create a second distinct variation with a different color palette but following the same design language.";
        if (i == 2) variationDetails = " Create a third alternative variation exploring a more creative interpretation of the original style.";

        String variedPrompt = "$basePrompt $variationDetails";
        print('🎨 Generating Variation ${i + 1}...');

        String url = await GeminiService.generateImageFromVariationPrompt(
          prompt: variedPrompt,
          imageFile: imageFile,
          temperature: temperature,
        );
        results.add(url);
      }
      return results;
    } catch (e) {
      throw Exception('Multiple variations generation failed: $e');
    }
  }

  // GARDEN REDESIGN METHODS
  Future<String> generateGardenImage({
    required String gardenTemplate,
    String? customInstructions,
    Map<String, int>? customItems,
  }) async {
    try {
      if (_selectedImage == null) {
        throw Exception('Please select a garden image');
      }

      print('=== GENERATING GARDEN REDESIGN ===');
      print('Template: $gardenTemplate');
      print('Custom Instructions: $customInstructions');
      print('Custom Items: $customItems');
      print('Image Path: ${_selectedImage!.path}');
      print('========================');

      String prompt = GardenPromptGenerator.generateGardenPrompt(
        gardenTemplate: gardenTemplate,
        imageSource: _selectedImageSource ?? 'Unknown',
        customInstructions: customInstructions,
        customItems: customItems,
      );

      // Save prompt to history
      _saveGardenPromptToFile(prompt, gardenTemplate, customInstructions, customItems);

      String generatedImageUrl = await GeminiService.generateImageFromPrompt(
        prompt: prompt,
        imageFile: _selectedImage!,
      );

      return generatedImageUrl;
    } catch (e) {
      throw Exception('Garden redesign failed: $e');
    }
  }

  Future<void> _saveGardenPromptToFile(
    String prompt,
    String template,
    String? custom,
    Map<String, int>? items,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/garden_design_prompts_history.txt');

      String timestamp = DateTime.now().toString().split('.')[0];
      String savedText = '''
=== GARDEN DESIGN PROMPT - $timestamp ===
Template: $template
Custom: $custom
Items: $items
Image Source: $_selectedImageSource
Image Path: ${_selectedImage?.path}

PROMPT:
$prompt
================================
\n
''';

      await file.writeAsString(savedText, mode: FileMode.append);
      print('✅ Garden Prompt saved to: ${file.path}');
    } catch (e) {
      print('❌ Error saving garden prompt: $e');
    }
  }
}
