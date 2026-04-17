import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image/image.dart' as img;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'exception_handler.dart';
import 'image_utils.dart';
import 'prompt_v2.dart';

class GeminiService {
  static final String? _apiKey = dotenv.env['GEMINI_API_KEY'];

  static const String _imageGenEndpoint =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image:generateContent";
  static const String _variationEndpoint =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image:generateContent";
  // ==========================================
  // api_services.dart - SIRF YEH METHOD ADD KARO
  // ==========================================

  /// Detects objects in an image and returns a list of bounding boxes.
  static Future<List<Map<String, dynamic>>> detectObjects({
    required File imageFile,
  }) async {
    try {
      if (_apiKey == null) throw Exception('API key not found');

      File compressed = await ImageUtils.compressImage(
        imageFile,
        quality: 80,
        maxDimension: 768,
      );
      String base64Img = base64Encode(await compressed.readAsBytes());

      final requestBody = {
        "contents": [
          {
            "parts": [
              {
                "text":
                    "Detect all prominent objects for remodeling (furniture, windows, doors, floor, walls, ceiling) and return a JSON list of objects with their normalized coordinates [ymin, xmin, ymax, xmax] in the format: {'objects': [{'label': 'sofa', 'box_2d': [ymin, xmin, ymax, xmax]}]}. Return ONLY the JSON.",
              },
              {
                "inline_data": {"mime_type": "image/jpeg", "data": base64Img},
              },
            ],
          },
        ],
        "generationConfig": {"temperature": 0.1},
      };

      final response = await http.post(
        Uri.parse(
          "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey",
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String text = data['candidates'][0]['content']['parts'][0]['text'];

        // Extract JSON from potential markdown code blocks
        if (text.contains('```json')) {
          text = text.split('```json')[1].split('```')[0];
        } else if (text.contains('```')) {
          text = text.split('```')[1].split('```')[0];
        }

        final result = jsonDecode(text);
        return List<Map<String, dynamic>>.from(result['objects'] ?? []);
      }
      return [];
    } catch (e) {
      print('Object detection failed: $e');
      return [];
    }
  }

  static String userPreferences = "";

  static Future<void> _loadUserPreferences() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      userPreferences = "None specified";
      return;
    }

    try {
      final DatabaseReference dbRef = FirebaseDatabase.instance.ref("users");
      final snapshot = await dbRef.child(uid).get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);

        final region = data["region"] ?? "Unknown region";
        final style = data["styleType"] ?? "general interior design";
        final favColors = (data["favoriteColors"] as List?)?.join(", ") ?? "no preference";
        final budget = data["budgetTier"] ?? "medium";

        userPreferences = """
Region: $region
Style Preferences: $style
Favorite Colors: $favColors
Budget: $budget
""";
      } else {
        userPreferences = "None specified";
      }
    } catch (e) {
      print("Error loading preferences: $e");
      userPreferences = "None specified";
    }
  }

  /// Chatbot text generation using Gemini with User Preferences
  static Future<String> chatMessage({required String userMessage, int retries = 3}) async {
    await _loadUserPreferences();

    final systemPrompt = """
You are a professional interior design and decoration AI assistant in a remodeling app.
Only answer questions about interior design, decoration, room layouts, colors, or styling.
Base your suggestions on the provided user preferences: $userPreferences.
Provide concise, highly relevant, and professional advice. Do not include unnecessary conversational filler.
""";

    int attempt = 0;
    while (attempt < retries) {
      try {
        if (_apiKey == null) throw Exception('API key not found');

        final requestBody = {
          "contents": [
            {
              "parts": [
                {
                  "text": "$systemPrompt\nUser: $userMessage"
                }
              ]
            }
          ],
          "generationConfig": {"temperature": 0.7, "maxOutputTokens": 500},
        };

        final response = await http.post(
          Uri.parse("https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_apiKey"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['candidates'][0]['content']['parts'][0]['text'] as String;
        } else {
          print("API Error ${response.statusCode}: ${response.body}");
        }
      } catch (e) {
        print("Chatbot error attempt $attempt: $e");
      }
      attempt++;
      await Future.delayed(Duration(seconds: 2 * attempt));
    }
    return "Server is busy or temporarily unavailable. Please try again later.";
  }

  // GeminiService class ke andar, generateImageFromPrompt() method ke BAAD
  // yeh naya method add kar do:

  /// 2-Step Reference Style Transfer:
  /// Step 1: Analyze the reference image to extract a rich style description.
  /// Step 2: Use that description + target image to generate the transformed output.
  static Future<String> generateImageFromDualPrompt({
    required String prompt,
    required File referenceImageFile,
    required File targetImageFile,
  }) async {
    try {
      if (_apiKey == null) {
        throw Exception('Gemini API key not found in .env file');
      }

      print('🔑 Using API Key: ${_apiKey!.substring(0, 10)}...');
      print('🚀 Starting 2-Step Reference Style Transfer...');

      // ── STEP 1: Analyze reference image to get a rich style description ────
      print('📸 Step 1: Analyzing reference image for style extraction...');

      File compressedReference = await ImageUtils.compressImage(
        referenceImageFile,
        quality: 85,
        maxDimension: 1024,
      );
      File compressedTarget = await ImageUtils.compressImage(
        targetImageFile,
        quality: 85,
        maxDimension: 1024,
      );

      String referenceBase64 = base64Encode(await compressedReference.readAsBytes());
      String targetBase64 = base64Encode(await compressedTarget.readAsBytes());

      // Text-only call to extract style
      final styleAnalysisBody = {
        "contents": [
          {
            "parts": [
              {
                "text": """You are a world-class interior design forensic analyst. Your job is to produce the most detailed, precise style fingerprint possible of this image so another AI can FULLY REPLICATE this aesthetic in a completely different room.

Analyze EVERY visual element with obsessive precision:

1. DOMINANT COLOR PALETTE:
   - List all main colors with specific names (e.g. "deep espresso brown", "warm amber gold", "dusty rose blush")
   - What is the overall color temperature? (warm / cool / neutral)
   - What emotion do the colors evoke?

2. CONTEXTUAL STATE & CONDITION (CRITICAL):
   - Is the room pristine, clean, messy, dirty, or ruined?
   - What is the era/theme? (e.g., modern, vintage, medieval, prehistoric, futuristic sci-fi, post-apocalyptic)
   - Describe the level of wear, tear, rust, aging, or decay.

3. ENVIRONMENTAL & ATMOSPHERIC EFFECTS:
   - Are there specific effects present? (fog, smoke, dust in the air, spiderwebs, mold, water puddles, futuristic neon holograms, vines overgrown)
   - Describe any scattered clutter, trash, or specific "mess" elements on the floor or surfaces.

4. WALL SURFACES (describe as if painting them):
   - Exact color name and finish (matte, satin, gloss)
   - Material (plaster, wood panel, exposed brick, wallpaper pattern etc.)
   - Any patterns, textures, decorative moldings, or damage/peeling?

5. FLOOR SURFACES (describe so someone can buy the exact material):
   - Material type (marble, hardwood, herringbone oak, terracotta tiles etc.)
   - Color and finish
   - Pattern or layout (plank direction, tile size, grout color)

6. FURNITURE VISUAL STYLE:
   - Design era / style name
   - Upholstery material and color on seating
   - Frame material and structural condition (e.g., pristine wood vs. broken iron)

7. LIGHTING ATMOSPHERE:
   - Is it warm (orange/amber) or cool (white/blue)?
   - Intensity: dim and moody OR bright and airy?
   - Shadow depth and contrast level
   - Visible light fixtures style

8. ONE-SENTENCE STYLE & STATE LABEL:
   Write a precise style name, e.g. "Pristine Luxury Modern", "Dirty Abandoned Kitchen", "Old-Times Victorian with Dust", "Cyberpunk Neon Mess"

9. OVERALL ATMOSPHERE SUMMARY:
   Describe the feeling someone would get walking into this room — the vibe, the luxury/decay level, the mood.

This description MUST be detailed enough that someone reading it could fully recreate this exact interior aesthetic and its physical STATE without ever seeing the image."""
              },
              {
                "inline_data": {"mime_type": "image/jpeg", "data": referenceBase64},
              },
            ],
          },
        ],
        "generationConfig": {"temperature": 0.1, "maxOutputTokens": 2048},
      };

      final styleResponse = await http.post(
        Uri.parse(
          "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_apiKey",
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(styleAnalysisBody),
      );

      String styleDescription = "a sophisticated, carefully designed interior space";
      if (styleResponse.statusCode == 200) {
        final styleData = jsonDecode(styleResponse.body);
        try {
          styleDescription = styleData['candidates'][0]['content']['parts'][0]['text'] as String;
          print('✅ Step 1 Complete. Style extracted (${styleDescription.length} chars)');
          print('🎨 Style Description:\n${styleDescription.substring(0, styleDescription.length.clamp(0, 300))}...');
        } catch (_) {
          print('⚠️ Style extraction partial - using fallback description');
        }
      } else {
        print('⚠️ Step 1 failed (${styleResponse.statusCode}), proceeding with generic style');
      }

      // ── STEP 2: Transform target image using extracted style ────────────────
      print('🎨 Step 2: Transforming target image using extracted style...');

      final transformBody = {
        "contents": [
          {
            "role": "user",
            "parts": [
              {
                "text": """You are an expert condition and design rendering AI. You will receive a room photo and a detailed style/state description. Your job is to OUTPUT a new version of that room photo, completely morphed to match the described style and STATE (clean, dirty, old, futuristic), while keeping the room's physical layout identical.

⚠️ IMPORTANT: Your output must be the TARGET ROOM restyled — NOT the reference image. Generate a new image of the room below.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
THE ROOM TO RESTYLE (your output must show this room):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"""
              },
              {
                "inline_data": {"mime_type": "image/jpeg", "data": targetBase64},
              },
              {
                "text": """━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STYLE & CONDITION TO APPLY TO THE ROOM ABOVE:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
$styleDescription
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

WHAT TO KEEP UNCHANGED (from the room photo):
• Room shape, dimensions, and camera angle — identical
• All wall, window, door positions — identical
• All furniture positions and silhouettes — identical
• Ceiling height and architectural layout — identical

WHAT TO CHANGE (APPLY WITH MAXIMUM INTENSITY AND OBSESSIVE DETAILING):
• STATE & ERA → OVERRIDE COMPLETELY: If the style says "old times", "ruined", or "dirty", apply extreme weathering, dirt, damage, aging, or futuristic elements to all surfaces of the target room. Ensure the room fully embodies the target era and condition.
• Wall surfaces → OVERRIDE COMPLETELY: Use the exact specified colors, deeply detailed textures, materials, and any damage/aging from the style recipe.
• Floor → OVERRIDE COMPLETELY: Replace entirely with the specific floor material, finish, pattern, and clutter/dirt level from the style recipe.
• Furniture finishes → OVERRIDE COMPLETELY: Re-skin all upholstery, wood/metal finishes, and materials to strictly match the requested condition, colors, and rich textures.
• Lighting & Shadows → OVERRIDE COMPLETELY: Shift the color temperature and mood, but ensure the scene is beautifully illuminated with high contrast and depth. No flat or dull lighting!
• Color Grading & Vibrancy → PUMP UP THE COLORS: Ensure the final output has incredibly rich, vivid, and highly saturated colors. Eliminate any washed-out, dim, or dull fading. The image must visually "pop" and look incredibly lively and immersive.
• Decorations, Mess & Details → AGGRESSIVELY ADD DETAILING: Inject rugs, rich curtains, textured cushions, thematic art, or contextual clutter (trash, cobwebs, vines, neon) that perfectly embodies the style and state recipe. Make it look highly detailed and professionally painted.
• SHARPNESS & RENDERING QUALITY → RAZOR SHARP: The output MUST be an 8k-quality photorealistic render. Every texture, line, and material must be razor-sharp and crystal clear. ❌ NO BLUR, NO SMUDGING, NO SOFT/WASHED PIXELS.

FINAL CHECK BEFORE GENERATING:
✅ Is the structural layout identical to the room photo? Yes → proceed
✅ Is the visual style AND physical condition/messiness applied with extreme intensity? Yes → proceed
✅ Is the image crystal clear, razor-sharp, and highly detailed? Yes → proceed
✅ Output is the ROOM restyled (not the reference image) → YES"""
              },
            ],
          },
        ],
        "generationConfig": <String, dynamic>{
          "temperature": 0.65,
          "topK": 40,
          "topP": 0.95,
          "maxOutputTokens": 8192,
          "responseModalities": ["IMAGE"],
        },
      };

      print('📤 Step 2: Sending transform request to Gemini...');

      final response = await http.post(
        Uri.parse('$_imageGenEndpoint?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(transformBody),
      );

      print('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('✅ Step 2 Complete — Style Transfer Success!');

        if (data['usageMetadata'] != null) {
          final usage = data['usageMetadata'];
          print('📊 Token Usage:');
          print('   Input Tokens: ${usage["promptTokenCount"]}');
          print('   Output Tokens: ${usage["candidatesTokenCount"]}');
          print('   Total Tokens: ${usage["totalTokenCount"]}');
        }

        String generatedImage = _extractGeneratedImage(data);
        return generatedImage;
      } else {
        print('❌ Gemini API Error: ${response.statusCode}');
        print('❌ Error Body: ${response.body}');
        throw Exception('Gemini API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 2-Step Style Transfer Failed: $e');
      throw Exception('Reference transform generation failed: $e');
    }
  }

  /// Smart inpainting: crops the selected region, transforms it via Gemini,
  /// then composites the result back onto the original image at the exact location.
  static Future<String> generateImageInpaint({
    required String prompt,
    required File imageFile,
    required File maskFile,
  }) async {
    try {
      if (_apiKey == null) throw Exception('Gemini API key not found');

      print('🚀 Starting Crop-Transform-Composite Inpainting...');

      // ── Step 1: Decode original image and mask ─────────────────────────
      final imgBytes = await imageFile.readAsBytes();
      final maskBytes = await maskFile.readAsBytes();

      final img.Image? originalImg = img.decodeImage(imgBytes);
      final img.Image? maskImg = img.decodeImage(maskBytes);
      if (originalImg == null || maskImg == null)
        throw Exception('Failed to decode images');

      // ── Step 2: Scale mask to original image dimensions (v4 API) ─────────
      final img.Image scaledMask = img.copyResize(
        maskImg,
        width: originalImg.width,
        height: originalImg.height,
      );

      // ── Step 3: Find bounding box of white area in mask (v4 pixel API) ───
      int minX = originalImg.width,
          minY = originalImg.height,
          maxX = 0,
          maxY = 0;
      for (int y = 0; y < scaledMask.height; y++) {
        for (int x = 0; x < scaledMask.width; x++) {
          final pixel = scaledMask.getPixel(x, y);
          // v4: pixel.r, pixel.g, pixel.b are num values 0-255
          final double brightness = (pixel.r + pixel.g + pixel.b) / 3.0;
          if (brightness > 128) {
            if (x < minX) minX = x;
            if (y < minY) minY = y;
            if (x > maxX) maxX = x;
            if (y > maxY) maxY = y;
          }
        }
      }

      if (maxX <= minX || maxY <= minY)
        throw Exception('No valid selection area found in mask');

      // Add padding around selection so Gemini has context
      final int padX = ((maxX - minX) * 0.1).toInt().clamp(5, 80);
      final int padY = ((maxY - minY) * 0.1).toInt().clamp(5, 80);
      final int cropX = (minX - padX).clamp(0, originalImg.width - 1);
      final int cropY = (minY - padY).clamp(0, originalImg.height - 1);
      final int cropW = ((maxX - minX) + padX * 2).clamp(
        10,
        originalImg.width - cropX,
      );
      final int cropH = ((maxY - minY) + padY * 2).clamp(
        10,
        originalImg.height - cropY,
      );

      print('🖼  Crop region: ($cropX, $cropY) ${cropW}x${cropH}');

      // ── Step 4: Crop the region (v4 uses named params) ──────────────────
      final img.Image cropped = img.copyCrop(
        originalImg,
        x: cropX,
        y: cropY,
        width: cropW,
        height: cropH,
      );
      final List<int> croppedJpg = img.encodeJpg(cropped, quality: 90);
      final String croppedBase64 = base64Encode(croppedJpg);

      // ── Step 5: Send cropped region to Gemini ───────────────────────────
      final requestBody = {
        "contents": [
          {
            "parts": [
              {
                "text":
                    "CRITICAL INSTRUCTION: You are given a tightly cropped image of a specific area from a room. Your ONLY task is to apply this change: \"$prompt\" inside this cropped region. Completely replace whatever is currently in this crop with what the user requested, OR modify it exactly as asked. DO NOT change the perspective or lighting. The output must be EXACTLY the same size and shape as the input crop, containing ONLY the new requested item blending into the existing background.",
              },
              {
                "inline_data": {
                  "mime_type": "image/jpeg",
                  "data": croppedBase64,
                },
              },
            ],
          },
        ],
        "generationConfig": <String, dynamic>{
          "temperature": 0.4,
          "topK": 32,
          "topP": 0.95,
          "maxOutputTokens": 2048,
          "responseModalities": ["IMAGE"],
        },
      };

      final response = await http.post(
        Uri.parse('$_imageGenEndpoint?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        print(
          '❌ Gemini Inpainting Error: ${response.statusCode} - ${response.body}',
        );
        throw Exception('Gemini API Error: ${response.statusCode}');
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      final String transformedBase64 = _extractRawBase64Image(data);
      final Uint8List transformedBytes = base64Decode(transformedBase64);
      img.Image? transformedImg = img.decodeImage(transformedBytes);
      if (transformedImg == null)
        throw Exception('Failed to decode transformed image');

      // ── Step 6: Resize transformed region to match crop dimensions (v4) ──
      transformedImg = img.copyResize(
        transformedImg,
        width: cropW,
        height: cropH,
      );

      // ── Step 7: Composite back onto a clone of the original (v4 API) ─────
      final img.Image result = originalImg.clone();
      img.compositeImage(result, transformedImg, dstX: cropX, dstY: cropY);

      // ── Step 8: Encode and return ────────────────────────────────────────
      final List<int> resultJpg = img.encodeJpg(result, quality: 90);
      return 'data:image/jpeg;base64,${base64Encode(resultJpg)}';
    } catch (e) {
      print('❌ Inpainting Failed: $e');
      throw Exception('Inpainting generation failed: $e');
    }
  }

  /// Optimized image generation for free tier users
  /// Compresses image by 30-35% and limits output to 1000 tokens
  static Future<String> generateImageFreeTier({
    required String prompt,
    required File imageFile,
  }) async {
    try {
      if (_apiKey == null) {
        throw Exception('Gemini API key not found in .env file');
      }

      print('🚀 Starting Free Tier Optimized Image Generation...');

      // 1. Compress & Resize image for all tiers (Quality 85%, Max 1024px)
      File compressedFile = await ImageUtils.compressImage(
        imageFile,
        quality: 85,
        maxDimension: 1024,
      );
      print(
        '📦 Image compressed & resized for free tier: ${compressedFile.path}',
      );

      List<int> imageBytes = await compressedFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      final Map<String, dynamic> requestBody = {
        "contents": [
          {
            "parts": [
              {"text": prompt},
              {
                "inline_data": {"mime_type": "image/jpeg", "data": base64Image},
              },
            ],
          },
        ],
        "generationConfig": <String, dynamic>{
          "temperature": 0.7,
          "topK": 40,
          "topP": 0.95,
          "maxOutputTokens": 2048,
        },
      };

      // Both tiers use 1024px resolution for consistency as requested
      (requestBody["generationConfig"]
          as Map<String, dynamic>)["responseModalities"] = [
        "IMAGE",
      ];
      (requestBody["generationConfig"] as Map<String, dynamic>)["imageConfig"] =
          {"aspectRatio": "1:1", "imageSize": "1024"};

      print('📤 Sending restricted request to Gemini (Free Tier)...');

      final response = await http.post(
        Uri.parse('$_imageGenEndpoint?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('✅ Free Tier Image Generation Success!');

        if (data['usageMetadata'] != null) {
          final usage = data['usageMetadata'];
          print('📊 Token Usage (FREE TIER):');
          print('   Input Tokens: ${usage["promptTokenCount"]}');
          print('   Output Tokens: ${usage["candidatesTokenCount"]}');
        }

        String generatedImage = _extractGeneratedImage(data);
        return generatedImage;
      } else {
        print('❌ Gemini Free Tier API Error: ${response.statusCode}');
        throw Exception('Gemini API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Gemini Free Tier Failed: $e');
      throw Exception('Free tier generation failed: $e');
    }
  }

  // ==========================================
  // BAS! ITNA HI ADD KARNA HAI
  // Baaki sab existing code same rahega
  // ==========================================
  static Future<String> generateImageFromPrompt({
    required String prompt,
    required File imageFile,
  }) async {
    /*
    try {
      if (_apiKey == null) {
        throw Exception('Gemini API key not found in .env file');
      }

      print('📝 Prompt: ${prompt.substring(0, 100)}...');

      // Compress & Resize image for global optimization (Quality 85%, Max 1024px)
      File compressedFile = await ImageUtils.compressImage(
        imageFile,
        quality: 85,
        maxDimension: 1024,
      );
      print('📦 Image compressed & resized: ${compressedFile.path}');

      List<int> imageBytes = await compressedFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      final Map<String, dynamic> requestBody = {
        "contents": [
          {
            "parts": [
              {"text": prompt},
              {
                "inline_data": {"mime_type": "image/jpeg", "data": base64Image},
              },
            ],
          },
        ],
        "generationConfig": <String, dynamic>{
          "temperature": 0.9,
          "topK": 40,
          "topP": 0.95,
          "maxOutputTokens": 2048,
        },
      };

      // Add imageConfig for standard/paid requests to use higher resolution
      (requestBody["generationConfig"]
          as Map<String, dynamic>)["responseModalities"] = [
        "TEXT",
        "IMAGE",
      ];
      (requestBody["generationConfig"]
          as Map<String, dynamic>)["imageConfig"] = {
        "aspectRatio": "1:1",
        "imageSize": "1K", // 1024x1024 or higher for premium
      };

      print('📤 Sending request to Gemini 2.5 Flash Image...');

      final response = await http.post(
        Uri.parse('$_imageGenEndpoint?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('✅ Gemini 2.5 Flash Image Generation Success!');

        if (data['usageMetadata'] != null) {
          final usage = data['usageMetadata'];
          print('📊 Token Usage:');
          print(
            '   Input Tokens (Prompt Text + Image): ${usage["promptTokenCount"]}',
          );
          print(
            '   Output Tokens (Generated Content): ${usage["candidatesTokenCount"]}',
          );
          print('   Total Tokens: ${usage["totalTokenCount"]}');
        }

        String generatedImage = _extractGeneratedImage(data);
        return generatedImage;
      } else {
        print('❌ Gemini 2.5 Flash API Error: ${response.statusCode}');
        print('❌ Error Body: ${response.body}');
        throw Exception(
          'Gemini API Error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Gemini Image Generation Failed: $e');
      throw Exception('Image generation failed: $e');
    }
    */

    // TEMPORARY: Use Free Tier logic inside Paid Tier as requested by user
    try {
      if (_apiKey == null) {
        throw Exception('Gemini API key not found in .env file');
      }

      print('🚀 Starting TEMPORARY Free Tier Logic for Paid users...');

      File compressedFile = await ImageUtils.compressImage(
        imageFile,
        quality: 85,
        maxDimension: 1024,
      );
      List<int> imageBytes = await compressedFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      final Map<String, dynamic> requestBody = {
        "contents": [
          {
            "parts": [
              {"text": prompt},
              {
                "inline_data": {"mime_type": "image/jpeg", "data": base64Image},
              },
            ],
          },
        ],
        "generationConfig": <String, dynamic>{
          "temperature": 0.9,
          "topK": 40,
          "topP": 0.95,
          "maxOutputTokens": 2048,
        },
      };

      (requestBody["generationConfig"]
          as Map<String, dynamic>)["responseModalities"] = [
        "IMAGE",
      ];
      (requestBody["generationConfig"] as Map<String, dynamic>)["imageConfig"] =
          {"aspectRatio": "1:1", "imageSize": "1024"};

      print(
        '📤 Sending restricted request to Gemini (Temporary Paid->Free)...',
      );

      final response = await http.post(
        Uri.parse('$_imageGenEndpoint?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('✅ Temporary Free Tier (Paid) Generation Success!');

        if (data['usageMetadata'] != null) {
          final usage = data['usageMetadata'];
          print('📊 Token Usage (TEMPORARY PAID):');
          print('   Input Tokens: ${usage["promptTokenCount"]}');
          print('   Output Tokens: ${usage["candidatesTokenCount"]}');
        }

        String generatedImage = _extractGeneratedImage(data);
        return generatedImage;
      } else {
        throw Exception('Gemini API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Generation Failed: $e');
      throw Exception('Image generation failed: $e');
    }
  }

  static Future<String> generateImageFromVariationPrompt({
    required String prompt,
    required File imageFile,
  }) async {
    try {
      if (_apiKey == null) {
        throw Exception('Gemini API key not found in .env file');
      }

      print('🔑 Using API Key: ${_apiKey!.substring(0, 10)}...');
      print('📝 Prompt: ${prompt.substring(0, 100)}...');

      // Compress & Resize image for global optimization (Quality 85%, Max 1024px)
      File compressedFile = await ImageUtils.compressImage(
        imageFile,
        quality: 85,
        maxDimension: 1024,
      );
      print(
        '📦 Image compressed & resized (Variations): ${compressedFile.path}',
      );

      List<int> imageBytes = await compressedFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      final Map<String, dynamic> requestBody = {
        "contents": [
          {
            "parts": [
              {"text": prompt},
              {
                "inline_data": {"mime_type": "image/jpeg", "data": base64Image},
              },
            ],
          },
        ],
        "generationConfig": <String, dynamic>{
          "temperature": 0.9,
          "topK": 40,
          "topP": 0.95,
          "maxOutputTokens": 2048,
        },
      };

      // Add imageConfig for standard/paid variations requests to use higher resolution
      (requestBody["generationConfig"]
          as Map<String, dynamic>)["responseModalities"] = [
        "TEXT",
        "IMAGE",
      ];
      (requestBody["generationConfig"]
          as Map<String, dynamic>)["imageConfig"] = {
        "aspectRatio": "1:1",
        "imageSize": "1K", // 1024x1024 or higher for premium
      };

      print('📤 Sending request to Gemini 2.5 Flash Image (Variations)...');

      final response = await http.post(
        Uri.parse('$_variationEndpoint?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('✅ Gemini 2.5 Flash Image Generation Success!');

        if (data['usageMetadata'] != null) {
          final usage = data['usageMetadata'];
          print('📊 Token Usage:');
          print(
            '   Input Tokens (Prompt Text + Image): ${usage["promptTokenCount"]}',
          );
          print(
            '   Output Tokens (Generated Content): ${usage["candidatesTokenCount"]}',
          );
          print('   Total Tokens: ${usage["totalTokenCount"]}');
        }

        String generatedImage = _extractGeneratedImage(data);
        return generatedImage;
      } else {
        print('❌ Gemini 2.5 Flash API Error: ${response.statusCode}');
        print('❌ Error Body: ${response.body}');
        throw Exception(
          'Gemini API Error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Gemini Image Generation Failed: $e');
      throw Exception('Image generation failed: $e');
    }
  }

  /// Extracts just the raw base64 string (without the data: prefix).
  /// Used for crop-composite inpainting so we can decode the image directly.
  static String _extractRawBase64Image(Map<String, dynamic> data) {
    try {
      final parts = data['candidates'][0]['content']['parts'] as List;
      for (final part in parts) {
        if (part['inlineData'] != null && part['inlineData']['data'] != null) {
          return part['inlineData']['data'] as String;
        }
      }
    } catch (_) {}
    throw Exception('No image found in Gemini response');
  }

  static String _extractGeneratedImage(Map<String, dynamic> data) {
    try {
      print('🔍 Extracting generated image from response...');

      if (data['candidates'] != null &&
          data['candidates'].isNotEmpty &&
          data['candidates'][0]['content'] != null &&
          data['candidates'][0]['content']['parts'] != null &&
          data['candidates'][0]['content']['parts'].isNotEmpty) {
        var parts = data['candidates'][0]['content']['parts'];

        for (var part in parts) {
          if (part['inlineData'] != null &&
              part['inlineData']['data'] != null) {
            String base64Image = part['inlineData']['data'];
            String mimeType = part['inlineData']['mimeType'] ?? 'image/png';

            if (base64Image.isNotEmpty) {
              print('✅ Found generated image: ${mimeType}');
              return 'data:$mimeType;base64,$base64Image';
            }
          }

          if (part['text'] != null) {
            String text = part['text'];
            if (text.isNotEmpty) {
              print('📄 Text response length: ${text.length}');

              if (text.contains('data:image')) {
                List<String> imageParts = text.split('data:image');
                if (imageParts.length > 1) {
                  String imageData = 'data:image${imageParts[1]}';
                  return imageData;
                }
              }
            }
          }
        }
      }

      print('❌ No valid image data found in response');
      throw Exception('No image data received from Gemini API');
    } catch (e) {
      print('❌ Error extracting image: $e');
      throw Exception('Image extraction failed: $e');
    }
  }

  static Future<void> _saveAPIResponse(
    String prompt,
    Map<String, dynamic> response,
  ) async {
    try {
      final directory = Directory.current;
      final file = File('${directory.path}/gemini_2.5_responses.txt');

      String timestamp = DateTime.now().toString().split('.')[0];
      String savedText =
          '''
=== GEMINI 2.5 FLASH RESPONSE - $timestamp ===
PROMPT:
$prompt

FULL RESPONSE:
${jsonEncode(response)}
================================
\n
''';

      await file.writeAsString(savedText, mode: FileMode.append);
      print('💾 API response saved to: ${file.path}');
    } catch (e) {
      print('❌ Error saving API response: $e');
    }
  }
}
