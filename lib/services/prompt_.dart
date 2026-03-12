

class PromptGenerator {

  // Room type specific requirements
  static final Map<String, String> _roomSpecificRequirements = {
    'Living room': 'comfortable seating arrangement, entertainment center, social space, cozy atmosphere, conversation area',
    'Bedroom': 'relaxing ambiance, comfortable bed, storage solutions, personal space, calming colors',
    'Bathroom': 'functional layout, hygiene focus, storage, lighting for grooming, waterproof materials',
    'Kitchen': 'efficient workflow, storage, counter space, appliances placement, ventilation',
    'Dining room': 'dining table setup, ambiance for meals, lighting for dining, serving area',
    'Home office': 'productive environment, desk setup, storage, good lighting, minimal distractions',
    'Home Theater': 'immersive experience, seating arrangement, acoustics, lighting control, screen placement',
    'Kids Room': 'playful design, safety considerations, storage for toys, creative space, durable materials',
    'Guest Bedroom': 'comfortable for visitors, storage, welcoming atmosphere, hotel-like comfort',
    'Home Spa': 'relaxing ambiance, spa features, calming colors, luxury materials, tranquil atmosphere',
    'Home Bar': 'entertainment focus, bar counter, seating, mood lighting, glassware storage',
    'Library': 'reading comfort, book storage, quiet atmosphere, good lighting, comfortable seating',
    'Yoga Studio': 'peaceful environment, open space, natural elements, calming colors, mirror placement',
    'Gaming room': 'entertainment setup, comfortable seating, tech integration, mood lighting, cable management',
    'Workshop': 'functional workspace, tool storage, good lighting, safety considerations, ventilation',
  };

  // Budget level parameters
  static final Map<String, String> _budgetQuality = {
    'Low': 'cost-effective materials, budget-friendly solutions, affordable furnishings, practical choices, DIY options',
    'Medium': 'standard quality materials, balanced cost, durable furnishings, ready-made solutions, value for money',
    'High': 'premium materials, high-end finishes, quality craftsmanship, designer items, custom solutions',
    'Premium': 'luxury materials, bespoke design, exclusive finishes, premium brands, architectural details'
  };

  // Intervention level parameters
  static final Map<String, String> _interventionLevel = {
    'Soft': 'subtle enhancements, minor changes, preserve original character, light modifications, cosmetic updates',
    'Medium': 'moderate transformation, noticeable improvements, significant upgrades, layout optimization, style update',
    'Extreme': 'complete makeover, radical changes, dramatic transformation, structural modifications, total redesign',
    'Professional': 'expert design, sophisticated layout, professional finish, architectural planning, detailed execution',
    'Creative': 'artistic, innovative, unique design elements, imaginative approach, unconventional solutions'
  };
  static String generatePromptWithCustomization({
    required String roomType,
    required String style,
    required String budget,
    required String imageSource,
    String? customRequirements, // NEW PARAMETER
  }) {
    String roomRequirements = _roomSpecificRequirements[roomType] ??
        'functional layout, appropriate furnishings, comfortable atmosphere, practical design';

    // Build customization section if provided
    String customizationSection = '';
    if (customRequirements != null && customRequirements.trim().isNotEmpty) {
      customizationSection = """

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 USER SPECIFIC CUSTOMIZATION REQUIREMENTS 🎯
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CRITICAL: The user has provided specific customization requirements.
These requirements MUST be incorporated into the design WHILE maintaining
all the structural preservation rules above.

USER'S CUSTOM REQUIREMENTS:
"$customRequirements"

IMPLEMENTATION INSTRUCTIONS:
✓ INTEGRATE these custom requirements into the interior design
✓ MAINTAIN all structural preservation rules (walls, doors, windows)
✓ ENSURE custom requirements fit within the existing space
✓ BALANCE user preferences with professional design principles
✓ PRIORITIZE user requirements while respecting budget level
✓ KEEP room structure unchanged - only modify interior elements

CUSTOMIZATION PRIORITY:
1. User's specific requirements (colors, items, style preferences)
2. Room type functionality requirements
3. Budget level quality standards
4. Design style intensity level

If custom requirements conflict with space limitations:
- Adapt the requirement to fit the actual room size
- Suggest appropriate scale versions
- Maintain realistic proportions
""";
    }

    return """
🔒 STRICT LAYOUT PRESERVATION MODE - MANDATORY RULES 🔒

⚠️ CRITICAL: DO NOT CHANGE ROOM STRUCTURE ⚠️

ABSOLUTE LAYOUT LOCK REQUIREMENTS:
✓ Keep EXACT same room dimensions and shape
✓ Keep ALL walls in SAME positions
✓ Keep ALL doors in SAME locations - do NOT move, add, or remove
✓ Keep ALL windows in SAME locations - do NOT move, add, or remove
✓ Keep SAME floor area and room boundaries
✓ Keep SAME ceiling height and architectural features
✓ Keep SAME camera angle and perspective
✓ Keep SAME room orientation and viewing direction

🔒 SPACE & VOLUME CONSTRAINTS - MANDATORY 🔒
✓ Work ONLY within the visible area shown in reference image
✓ Respect the EXACT room size - if small, keep it small
✓ Do NOT imagine or add areas beyond what's visible
✓ Match furniture scale to actual room dimensions
✓ If room is 10x12 ft, design for 10x12 ft - NOT for 20x30 ft
✓ Use appropriate-sized furniture for the actual space
✓ Do NOT create a "dream room" - recreate THIS room
✓ Maintain realistic proportions based on reference image

❌ ABSOLUTELY FORBIDDEN - DO NOT:
❌ Move any walls or change room shape
❌ Add or remove doors
❌ Add or remove windows
❌ Change window or door sizes
❌ Alter room dimensions
❌ Change structural elements
❌ Modify architectural layout
❌ Add new openings or close existing ones
❌ Expand the room beyond reference image boundaries
❌ Create a bigger/grander space than shown
❌ Add imaginary areas not visible in reference
❌ Make a small room look like a large room
❌ Ignore actual space limitations
$customizationSection
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

TASK: INTERIOR REDESIGN ONLY (NOT RECONSTRUCTION)

Reference Image: $imageSource
Target Room Type: $roomType
Design Style: $style
Budget Level: $budget

WHAT YOU CAN CHANGE (Interior Design Elements Only):
✓ Furniture - placement, style, color, type
✓ Wall colors, paint, wallpaper, textures
✓ Flooring - materials, colors, patterns
✓ Lighting fixtures - chandeliers, lamps, bulbs
✓ Curtains, blinds, window treatments
✓ Decorative items - art, plants, accessories
✓ Textiles - cushions, rugs, throws, bedding
✓ Storage furniture - shelves, cabinets (non-structural)
✓ Color schemes and material finishes

DESIGN PARAMETERS:
• Room Function: $roomType
• Requirements: $roomRequirements
• Design Intensity: ${_interventionLevel[style]}
• Budget Quality: ${_budgetQuality[budget]}

TRANSFORMATION APPROACH:
1. First STUDY the reference image carefully
2. MEASURE the visible space - note the actual room size
3. IDENTIFY all structural elements (walls, doors, windows)
4. LOCK those structural elements in your mind
5. UNDERSTAND the space limitations - work within them
6. ${customRequirements != null && customRequirements.trim().isNotEmpty ? 'REVIEW user\'s custom requirements' : 'Now REDESIGN only the interior elements'}
7. Choose furniture that FITS the actual room size
8. ${customRequirements != null && customRequirements.trim().isNotEmpty ? 'INCORPORATE custom requirements appropriately' : 'Arrange furniture appropriate for $roomType within available space'}
9. Apply colors and materials matching $budget level
10. Add decorations and finishes per ${_interventionLevel[style]}
11. Keep everything proportional to the REAL room size

⚠️ CRITICAL FOR PREMIUM/HIGH BUDGET:
Even with premium budget, you CANNOT:
- Make the room physically larger
- Add space that doesn't exist
- Create a palace from a small room
- Ignore the actual square footage

You CAN only:
- Use premium materials within the existing space
- Add luxury finishes to actual walls/floors
- Place high-end furniture that fits the real dimensions
- Enhance lighting within the existing room
- Add elegant details within space constraints

ATMOSPHERE TO CREATE:
${getRoomAtmosphere(roomType)}

FINAL OUTPUT REQUIREMENTS:
• Same room structure - different interior design
• Photorealistic quality matching reference image
• Professional $roomType design
• Respects $budget constraints
• Achieves ${_interventionLevel[style]} transformation
• Maintains exact spatial layout from reference
${customRequirements != null && customRequirements.trim().isNotEmpty ? '• Incorporates user\'s custom requirements appropriately' : ''}

REMEMBER: You are an INTERIOR DESIGNER, not an ARCHITECT. 
Work WITHIN the existing structure, do NOT modify the structure itself.

🎯 SIZE REALITY CHECK:
- If reference shows a 12x10 room, your output = 12x10 room with premium finishes
- If reference shows a 20x15 room, your output = 20x15 room with premium finishes
- Premium budget = Better materials, NOT bigger space
- Luxury = Quality of items, NOT quantity of space

The result should look like: "The SAME room (same size), beautifully redesigned as a $roomType${customRequirements != null && customRequirements.trim().isNotEmpty ? ' with user\'s custom touches' : ''}"
NOT: "A different room" or "A reconstructed space" or "A bigger, grander version"
""";
  }
  // Generate AI prompt with all 4 elements
  static String generatePrompt({
    required String roomType,
    required String style,
    required String budget,
    required String imageSource,
  }) {
    String roomRequirements = _roomSpecificRequirements[roomType] ??
        'functional layout, appropriate furnishings, comfortable atmosphere, practical design';

    return """
🔒 STRICT LAYOUT PRESERVATION MODE - MANDATORY RULES 🔒

⚠️ CRITICAL: DO NOT CHANGE ROOM STRUCTURE ⚠️

ABSOLUTE LAYOUT LOCK REQUIREMENTS:
✓ Keep EXACT same room dimensions and shape
✓ Keep ALL walls in SAME positions
✓ Keep ALL doors in SAME locations - do NOT move, add, or remove
✓ Keep ALL windows in SAME locations - do NOT move, add, or remove
✓ Keep SAME floor area and room boundaries
✓ Keep SAME ceiling height and architectural features
✓ Keep SAME camera angle and perspective
✓ Keep SAME room orientation and viewing direction

🔒 SPACE & VOLUME CONSTRAINTS - MANDATORY 🔒
✓ Work ONLY within the visible area shown in reference image
✓ Respect the EXACT room size - if small, keep it small
✓ Do NOT imagine or add areas beyond what's visible
✓ Match furniture scale to actual room dimensions
✓ If room is 10x12 ft, design for 10x12 ft - NOT for 20x30 ft
✓ Use appropriate-sized furniture for the actual space
✓ Do NOT create a "dream room" - recreate THIS room
✓ Maintain realistic proportions based on reference image

❌ ABSOLUTELY FORBIDDEN - DO NOT:
❌ Move any walls or change room shape
❌ Add or remove doors
❌ Add or remove windows
❌ Change window or door sizes
❌ Alter room dimensions
❌ Change structural elements
❌ Modify architectural layout
❌ Add new openings or close existing ones
❌ Expand the room beyond reference image boundaries
❌ Create a bigger/grander space than shown
❌ Add imaginary areas not visible in reference
❌ Make a small room look like a large room
❌ Ignore actual space limitations

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

TASK: INTERIOR REDESIGN ONLY (NOT RECONSTRUCTION)

Reference Image: $imageSource
Target Room Type: $roomType
Design Style: $style
Budget Level: $budget

WHAT YOU CAN CHANGE (Interior Design Elements Only):
✓ Furniture - placement, style, color, type
✓ Wall colors, paint, wallpaper, textures
✓ Flooring - materials, colors, patterns
✓ Lighting fixtures - chandeliers, lamps, bulbs
✓ Curtains, blinds, window treatments
✓ Decorative items - art, plants, accessories
✓ Textiles - cushions, rugs, throws, bedding
✓ Storage furniture - shelves, cabinets (non-structural)
✓ Color schemes and material finishes

DESIGN PARAMETERS:
• Room Function: $roomType
• Requirements: $roomRequirements
• Design Intensity: ${_interventionLevel[style]}
• Budget Quality: ${_budgetQuality[budget]}

TRANSFORMATION APPROACH:
1. First STUDY the reference image carefully
2. MEASURE the visible space - note the actual room size
3. IDENTIFY all structural elements (walls, doors, windows)
4. LOCK those structural elements in your mind
5. UNDERSTAND the space limitations - work within them
6. Now REDESIGN only the interior elements
7. Choose furniture that FITS the actual room size
8. Arrange furniture appropriate for $roomType within available space
9. Apply colors and materials matching $budget level
10. Add decorations and finishes per ${_interventionLevel[style]}
11. Keep everything proportional to the REAL room size

⚠️ CRITICAL FOR PREMIUM/HIGH BUDGET:
Even with premium budget, you CANNOT:
- Make the room physically larger
- Add space that doesn't exist
- Create a palace from a small room
- Ignore the actual square footage

You CAN only:
- Use premium materials within the existing space
- Add luxury finishes to actual walls/floors
- Place high-end furniture that fits the real dimensions
- Enhance lighting within the existing room
- Add elegant details within space constraints

ATMOSPHERE TO CREATE:
${getRoomAtmosphere(roomType)}

FINAL OUTPUT REQUIREMENTS:
• Same room structure - different interior design
• Photorealistic quality matching reference image
• Professional $roomType design
• Respects $budget constraints
• Achieves ${_interventionLevel[style]} transformation
• Maintains exact spatial layout from reference

REMEMBER: You are an INTERIOR DESIGNER, not an ARCHITECT. 
Work WITHIN the existing structure, do NOT modify the structure itself.

🎯 SIZE REALITY CHECK:
- If reference shows a 12x10 room, your output = 12x10 room with premium finishes
- If reference shows a 20x15 room, your output = 20x15 room with premium finishes
- Premium budget = Better materials, NOT bigger space
- Luxury = Quality of items, NOT quantity of space

The result should look like: "The SAME room (same size), beautifully redesigned as a $roomType"
NOT: "A different room" or "A reconstructed space" or "A bigger, grander version"
""";
  }

  // Get room atmosphere description
  static String getRoomAtmosphere(String roomType) {
    switch (roomType) {
      case 'Bedroom':
      case 'Home Spa':
        return 'calming, relaxing, peaceful, serene, tranquil';
      case 'Living room':
      case 'Family Room':
        return 'welcoming, comfortable, social, inviting, cozy';
      case 'Home office':
      case 'Study room':
        return 'productive, focused, organized, professional, distraction-free';
      case 'Home Theater':
      case 'Gaming room':
        return 'immersive, entertaining, dramatic, engaging, exciting';
      case 'Kitchen':
        return 'functional, efficient, clean, inviting, hygienic';
      case 'Dining room':
        return 'elegant, comfortable, social, warm, inviting';
      case 'Kids Room':
        return 'playful, safe, creative, stimulating, fun';
      case 'Guest Bedroom':
        return 'welcoming, comfortable, hotel-like, peaceful, inviting';
      default:
        return 'functional, comfortable, aesthetically pleasing, well-designed';
    }
  }

  // Get style description
  static String getStyleDescription(String style) {
    return _interventionLevel[style] ?? 'professional design transformation';
  }

  // Get budget description
  static String getBudgetDescription(String budget) {
    return _budgetQuality[budget] ?? 'appropriate material selection';
  }

}
class ReplacePromptGenerator {
  static String generateReplacePrompt({
    required String replaceInstruction,
    required String imageSource,
  }) {
    return """
OBJECT REPLACEMENT TRANSFORMATION - CRITICAL AI REPLACEMENT PROMPT

REFERENCE IMAGE ANALYSIS:
- Analyze the provided image completely and carefully ($imageSource)
- Study the entire scene composition, perspective, and layout
- Identify all objects, their positions, sizes, and relationships
- Understand the lighting conditions, shadows, and ambiance
- Note the background, foreground, and overall context

REPLACEMENT INSTRUCTION FROM USER:
"$replaceInstruction"

MANDATORY PRESERVATION REQUIREMENTS:
- MAINTAIN the EXACT SAME image composition and perspective
- KEEP all other objects and elements completely unchanged
- PRESERVE identical room layout, structure, and proportions
- RETAIN the same camera angle, viewpoint, and framing
- MAINTAIN identical lighting conditions, color temperature, and atmosphere
- PRESERVE all background elements exactly as they appear
- KEEP the same image quality and resolution

REPLACEMENT PROCESS - STEP BY STEP:
1. IDENTIFY the object(s) to be replaced based on user instruction
2. UNDERSTAND the replacement object specifications from instruction
3. REMOVE the original object(s) completely
4. PLACE the new object(s) in the same position
5. MATCH the scale and proportion realistically
6. INTEGRATE with proper lighting and shadows
7. BLEND seamlessly with surroundings
8. ENSURE photorealistic appearance

CRITICAL REPLACEMENT RULES:
- ONLY replace what is specified in the instruction
- MATCH the size and scale appropriately for the space
- MAINTAIN realistic perspective and positioning
- CREATE proper shadows and reflections for new object
- ENSURE lighting matches the scene (direction, intensity, color)
- PRESERVE depth and spatial relationships
- KEEP surrounding elements completely untouched
- MAINTAIN photorealistic quality throughout

LIGHTING AND SHADOW REQUIREMENTS:
- Match existing lighting direction and intensity
- Create appropriate shadows for the new object
- Maintain consistent light source behavior
- Add reflections if surface materials require
- Preserve ambient lighting conditions
- Keep color temperature consistent

INTEGRATION REQUIREMENTS:
- Seamless blending with floor/surface contact points
- Natural occlusion with other objects if needed
- Proper perspective distortion matching room geometry
- Realistic material properties for new object
- Appropriate texture and surface details
- Natural color grading matching the scene

SPATIAL AWARENESS:
- Respect room boundaries and available space
- Maintain proper distance from walls and other objects
- Ensure new object fits naturally in the space
- Keep appropriate clearance and spacing
- Preserve realistic room proportions

QUALITY STANDARDS:
- Generate photorealistic output
- High-resolution details and textures
- Professional-grade image quality
- No visible artifacts or inconsistencies
- Natural and believable final result
- Sharp focus and clarity

FORBIDDEN ACTIONS - DO NOT:
❌ Change the room layout or structure
❌ Alter camera perspective or angle
❌ Modify lighting conditions
❌ Change background elements
❌ Add objects not specified in instruction
❌ Remove objects not specified in instruction
❌ Alter colors of unchanged elements
❌ Modify room dimensions or proportions

FINAL OUTPUT REQUIREMENTS:
- The result must look like a professional photograph
- The replacement must appear completely natural
- No one should be able to tell it's AI-generated
- The new object must blend perfectly with the scene
- All other elements must remain pixel-perfect unchanged
- The image should maintain original quality and resolution

REPLACEMENT INSTRUCTION INTERPRETATION:
Parse the user instruction carefully:
- Identify WHAT to replace (source object)
- Identify WITH WHAT to replace (target object)
- Note any specific details (color, style, material, size)
- Understand any positioning requirements
- Follow any additional specifications given

FINAL RESULT: Generate a photorealistic image where ONLY the specified replacement has been made according to the instruction "$replaceInstruction", while everything else remains identical to the reference image.
""";
  }

  static String getReplaceDescription(String replaceInstruction) {
    return "Replace as instructed: $replaceInstruction";
  }
}
class ExteriorPromptGenerator {
  // Exterior design specific requirements
  static final Map<String, String> exteriorDesignRequirements = {
    'Modern': 'sleek geometric forms, flat roofs, floor-to-ceiling windows, minimalist aesthetic, neutral color palette, clean lines, modern materials like glass and steel',
    'Small House': 'compact footprint, efficient layout, cozy proportions, multi-functional spaces, smart storage, practical design, cost-effective materials',
    'Bunglow': 'single-story layout, wide verandas, low-pitched roofs, exposed rafters, cozy accessible living, traditional charm, wooden elements',
    'Simple': 'clean rectangular forms, basic rooflines, uncomplicated details, practical construction, budget-friendly approach, minimal ornamentation',
    'Residential': 'traditional family home, pitched roof, front porch, balanced windows, comfortable neighborhood aesthetic, welcoming entrance',
    'Building': 'multi-level structure, rectangular massing, repetitive window patterns, functional scalable design, commercial appearance',
    'Villa': 'spacious luxury residence, grand entrance, landscaped surroundings, premium finishes, pool area, high-end materials',
    'Contemporary': 'current architectural trends, asymmetrical forms, mixed materials, large glass areas, energy-efficient features, innovative design',
    '3ds Max': 'photorealistic 3D rendering, detailed textures, accurate lighting, realistic materials, environmental context, professional visualization',
    'Commercial Building': 'professional facade, large entrance, corporate identity, durable materials, business functional, modern corporate design',
    'Old Times': 'classic architectural elements, ornate details, traditional materials, historical references, timeless character, vintage aesthetics',
  };

  // Generate AI prompt for exterior redesign
  static String generateExteriorPrompt({
    required String designStyle,
    required String imageSource, // ✅ YEH PARAMETER ADD KIA
  }) {
    String designRequirements = exteriorDesignRequirements[designStyle] ??
        'architectural transformation, improved aesthetics, functional design';

    return """
ARCHITECTURAL EXTERIOR REDESIGN - CRITICAL TRANSFORMATION PROMPT

REFERENCE IMAGE ANALYSIS:
- Analyze the provided building image carefully ($imageSource)
- Note the exact building structure, shape, and proportions
- Identify current roof type, window positions, door locations
- Understand the existing architectural layout and scale

MANDATORY PRESERVATION REQUIREMENTS:
- MAINTAIN the EXACT SAME building structure and footprint
- KEEP identical roof shape and basic architecture
- PRESERVE all window and door positions exactly as they are
- RETAIN the same camera perspective, angle, and scale
- DO NOT alter the fundamental building layout or shape

DESIGN TRANSFORMATION REQUEST:
Apply $designStyle architectural style to this exact building while preserving all structural elements.

$designStyle ARCHITECTURAL FEATURES:
$designRequirements

DESIGN ELEMENTS TO TRANSFORM:
- EXTERIOR MATERIALS: Update wall finishes, siding, or cladding
- COLOR SCHEME: Apply $designStyle appropriate colors and tones
- WINDOW STYLES: Change window designs while keeping same positions
- DOOR DESIGNS: Update door styles within existing openings
- ROOFING: Modify roof materials and details
- LANDSCAPING: Enhance surrounding environment and landscaping
- ARCHITECTURAL DETAILS: Add or modify decorative elements
- LIGHTING: Improve exterior lighting features

STRICT TRANSFORMATION RULES:
- ONLY modify surface materials, colors, and details
- KEEP all structural elements in their exact positions
- WORK within the existing building footprint and boundaries
- ENHANCE aesthetics while respecting original architecture
- CREATE a cohesive $designStyle architectural appearance

OUTPUT REQUIREMENTS:
- Generate a photorealistic transformation of the reference building
- Maintain identical building structure and layout
- Apply $designStyle architectural features appropriately
- Ensure the output looks like the SAME building but redesigned
- Produce professional-quality architectural visualization

FINAL RESULT: The generated image must clearly show the original building beautifully transformed into $designStyle architecture, not a different building.
""";
  }

  // Get design style description
  static String getDesignDescription(String designStyle) {
    return exteriorDesignRequirements[designStyle] ?? 'architectural redesign';
  }
}
// models/floor_prompt_generator.dart
class FloorPromptGenerator {
  // Floor design specific requirements
  static final Map<String, String> _floorDesignRequirements = {
    'Carpet': 'soft textile flooring, plush pile, comfortable underfoot, sound-absorbing, warm texture, available in various colors and patterns, cozy atmosphere',
    'Hardwood': 'natural wood planks, visible grain patterns, durable finish, classic elegance, warm tones, can be oak, maple, walnut, or bamboo, timeless appeal',
    'Vinyl': 'water-resistant synthetic flooring, realistic wood or stone prints, comfortable cushioning, easy maintenance, versatile installation options, durable wear layer',
    'Stone': 'natural stone materials including marble, granite, slate, or travertine, elegant veining, cool surface, luxurious appearance, durable and long-lasting',
    'Concrete': 'polished concrete finish, industrial aesthetic, seamless surface, modern minimalism, can be stained or dyed, durable and low-maintenance',
    'Rubber': 'resilient rubber flooring, slip-resistant surface, excellent traction, impact-absorbing, ideal for gyms or play areas, available in tiles or rolls',
    'Tile & Stone': 'combination of ceramic or porcelain tiles with natural stone accents, geometric patterns, mosaic designs, durable and water-resistant, artistic layouts',
    'Concrete Flooring': 'specialized concrete finishes including stained concrete, polished concrete, stamped patterns, epoxy coatings, industrial-chic appearance',
    'Cork': 'natural cork material, warm and soft underfoot, eco-friendly sustainable option, natural insulation properties, unique textured appearance, comfortable walking surface',
  };

  // Floor installation patterns
  static final Map<String, String> _floorPatterns = {
    'Carpet': 'wall-to-wall installation, seamless appearance, plush pile direction, proper stretching and fitting',
    'Hardwood': 'strip flooring, plank installation, herringbone pattern, parquet design, or wide-plank layout',
    'Vinyl': 'plank installation, tile pattern, sheet flooring, or luxury vinyl tile (LVT) with realistic textures',
    'Stone': 'large format tiles, mosaic patterns, random ashlar layout, or geometric stone arrangements',
    'Concrete': 'seamless polished surface, decorative scoring, or stained geometric patterns',
    'Rubber': 'interlocking tiles, rolled sheets, or custom-cut pieces with safety borders',
    'Tile & Stone': 'subway pattern, herringbone layout, mosaic borders, or mixed material combinations',
    'Concrete Flooring': 'stamped patterns, polished finish, decorative scoring, or exposed aggregate',
    'Cork': 'floating floor installation, plank or tile format, puzzle-piece edges, seamless appearance',
  };

  // Generate AI prompt for floor redesign
  static String generateFloorPrompt({
    required String floorType,
    required String imageSource,
  }) {
    String floorRequirements = _floorDesignRequirements[floorType] ??
        'functional flooring, appropriate material, durable surface, aesthetically pleasing';

    String floorPattern = _floorPatterns[floorType] ?? 'appropriate installation pattern';

    return """
COMPLETE FLOOR TRANSFORMATION - FULL COVERAGE REQUIRED

REFERENCE IMAGE ANALYSIS:
- Analyze the ENTIRE room image completely ($imageSource)
- Study EVERY visible floor area including corners, edges, and under furniture
- Identify ALL floor surfaces in the image without any exceptions
- Note the complete room perspective and ALL visible floor sections
- Understand the FULL floor layout from wall to wall

CRITICAL REQUIREMENT - COMPLETE FLOOR COVERAGE:
- TRANSFORM EVERY SINGLE visible floor area in the image
- COVER 100% of the floor surface from wall to wall
- DO NOT leave any original floor areas unchanged
- ENSURE floor transformation extends to ALL corners and edges
- INCLUDE floor areas under and around ALL furniture
- MAKE SURE no part of the original floor remains visible

MANDATORY PRESERVATION REQUIREMENTS:
- MAINTAIN the EXACT SAME room layout and structure
- KEEP all walls, windows, doors in their exact positions
- PRESERVE identical furniture placement and room objects
- RETAIN the same camera perspective, angle, and lighting
- DO NOT alter any architectural elements or room proportions

FLOOR TRANSFORMATION REQUEST:
COMPLETELY transform ALL visible floor areas to $floorType flooring. Replace EVERY part of the existing floor.

AI INTERVENTION LEVEL: HIGH - Complete floor material replacement with full coverage

$floorType FLOORING CHARACTERISTICS:
$floorRequirements

INSTALLATION PATTERN:
$floorPattern

FLOOR-SPECIFIC TRANSFORMATION DETAILS:
- FULL COVERAGE: Transform 100% of visible floor area
- MATERIAL APPLICATION: Apply $floorType material to ENTIRE floor
- TEXTURE AND FINISH: Create consistent surface texture across ALL areas
- COLOR AND TONE: Use authentic $floorType colors throughout
- PATTERN LAYOUT: Implement $floorPattern installation across complete floor
- EDGE-TO-EDGE: Ensure floor covers from wall to wall in ALL directions
- UNDER FURNITURE: Include floor transformation beneath ALL objects

STRICT TRANSFORMATION RULES:
- TRANSFORM EVERY visible floor surface without exception
- COVER ALL floor areas including hidden and partially visible sections
- ENSURE complete wall-to-wall coverage
- MAINTAIN identical room layout and object positions
- PRESERVE exact camera perspective and lighting
- CREATE seamless floor transformation across entire image

COMPLETE COVERAGE CHECKLIST:
- All main floor areas transformed ✓
- All corners and edges covered ✓
- Floor under furniture included ✓
- Wall-to-wall coverage achieved ✓
- No original floor remains visible ✓
- Consistent material throughout ✓

OUTPUT REQUIREMENTS:
- Generate photorealistic transformation with COMPLETE floor coverage
- Transform 100% of visible floor surfaces
- Maintain perfect room perspective and layout
- Create realistic $floorType material across entire floor
- Ensure NO original floor areas remain
- Show professional installation with full coverage

FINAL RESULT: The generated image must show the IDENTICAL room with COMPLETE floor transformation - EVERY visible floor area must be changed to $floorType flooring with zero exceptions.
""";
  }

  // Get floor type description
  static String getFloorDescription(String floorType) {
    return _floorDesignRequirements[floorType] ?? 'flooring transformation';
  }

  // Get installation pattern
  static String getFloorPattern(String floorType) {
    return _floorPatterns[floorType] ?? 'standard installation';
  }
}
// services/object_remove_prompt_generator.dart
class ObjectRemovePromptGenerator {
  static String generateObjectRemovePrompt({
    required String objectToRemove,
    required String imageSource,
  }) {
    return """
OBJECT REMOVAL TRANSFORMATION - CRITICAL PROMPT

REFERENCE IMAGE ANALYSIS:
- Analyze the provided image carefully ($imageSource)
- Identify the exact object to remove: "$objectToRemove"
- Study the object's position, size, and surroundings
- Understand the background and context around the object
- Note the lighting, shadows, and perspective

MANDATORY PRESERVATION REQUIREMENTS:
- MAINTAIN the EXACT SAME image composition and layout
- KEEP all other objects and elements completely unchanged
- PRESERVE identical lighting, colors, and atmosphere
- RETAIN the same camera perspective and angle
- DO NOT alter any other parts of the image

OBJECT REMOVAL REQUEST:
Remove ONLY the specified object "$objectToRemove" from the image while preserving everything else exactly as shown.

REMOVAL SPECIFICATIONS:
- TARGET OBJECT: "$objectToRemove"
- REMOVAL TYPE: Complete and seamless removal
- BACKGROUND RECONSTRUCTION: Natural and realistic
- CONTEXT PRESERVATION: Maintain surrounding environment

REMOVAL PROCESS:
1. IDENTIFY the exact object "$objectToRemove" in the image
2. REMOVE the object completely without any traces
3. RECONSTRUCT the background where the object was located
4. BLEND the reconstructed area seamlessly with surroundings
5. MAINTAIN realistic lighting and shadows in the removed area

STRICT TRANSFORMATION RULES:
- ONLY remove the specified object "$objectToRemove"
- KEEP all other objects, people, and elements completely unchanged
- PRESERVE exact image composition and layout
- MAINTAIN identical lighting conditions and colors
- CREATE seamless background reconstruction
- ENSURE no visual artifacts or inconsistencies

BACKGROUND RECONSTRUCTION:
- Analyze the background behind and around the object
- Reconstruct the area naturally based on surrounding context
- Match colors, textures, and patterns from adjacent areas
- Maintain consistent lighting and shadows
- Create believable continuation of the background

QUALITY REQUIREMENTS:
- The removed area should look completely natural
- No traces of the original object should remain
- Background reconstruction should be photorealistic
- Lighting and shadows should be consistent
- The overall image should appear untouched

OUTPUT SPECIFICATION:
- Generate a photorealistic image with the object removed
- Maintain perfect alignment with original image perspective
- Preserve all other elements exactly as they appear
- Create seamless background reconstruction
- Ensure the result looks like the original image without the object

FINAL RESULT: The generated image must show the IDENTICAL image with ONLY the object "$objectToRemove" completely removed - everything else must remain perfectly unchanged with natural background reconstruction.
""";
  }

  static String getObjectRemoveDescription(String objectToRemove) {
    return "Remove $objectToRemove from the image with seamless background reconstruction";
  }
}
// models/wall_prompt_generator.dart
class WallPromptGenerator {
  // Wall design specific requirements
  static final Map<String, String> _wallDesignRequirements = {
    'Paint': 'flat paint finish, smooth application, uniform color coverage, seamless edges, professional painting, various finishes (matte, eggshell, satin, semi-gloss, gloss)',
    'Wallpaper': 'patterned or textured wallpaper, proper alignment and matching, seamless installation, various designs (floral, geometric, abstract, traditional), removable or traditional adhesive',
    'Wood Paneling': 'natural wood paneling, shiplap installation, tongue and groove boards, rustic or modern finishes, wood grain visible, warm appearance',
    'Stone Veneer': 'natural or manufactured stone, realistic texture, proper installation pattern, grout lines, durable surface, rustic or contemporary appearance',
    'Brick': 'exposed brick wall, painted brick finish, whitewashed effect, industrial aesthetic, traditional red brick or modern gray brick, mortar joints',
    'Tile': 'ceramic, porcelain, or glass tiles, proper alignment and grouting, backsplash patterns or full wall coverage, various sizes (subway, mosaic, large format)',
    'Wainscoting': 'lower wall paneling, beadboard texture, raised panel design, traditional molding, proper chair rail height, painted finish',
    'Concrete': 'polished concrete finish, industrial aesthetic, seamless appearance, modern minimalism, gray tones, smooth texture',
    'Fabric': 'upholstered walls, fabric panels, padded surface, acoustic treatment, luxurious texture, various fabrics (velvet, linen, silk)',
    'Metal': 'metal panels, corrugated metal sheets, copper or brass accents, industrial style, modern finishes (brushed, polished, patina)',
    'Venetian Plaster': 'polished plaster finish, marble-like appearance, depth and texture, luxurious look, hand-applied technique, subtle color variations',
    'Murals': 'custom painted murals, scenic designs, artistic expressions, focal point walls, hand-painted or printed, various themes (nature, abstract, cityscape)',
    'Glass': 'glass panels, frosted glass finish, decorative glass, modern translucent walls, back-painted glass, mirror effects',
    'Mosaic': 'mosaic tile patterns, intricate designs, colorful arrangements, artistic walls, glass or ceramic tiles, detailed craftsmanship',
    'Cork': 'cork wall covering, natural texture, sound-absorbing properties, eco-friendly material, warm appearance, pin-board functionality',
    'Leather': 'leather panels, luxurious finish, rich texture, sophisticated appearance, tufted or flat installation, various colors and finishes',
    '3D Wall Panels': 'geometric 3D panels, modern texture, dimensional patterns, contemporary style, modular installation, various materials (wood, MDF, plastic)',
    'Mirror': 'mirrored walls, decorative mirrors, space-expanding effect, reflective surfaces, framed or frameless installation, various shapes and sizes',
    'Chalkboard': 'chalkboard paint, writable surface, functional and decorative, playful element, black or colored chalkboard, smooth writing surface',
    'Bamboo': 'bamboo wall covering, sustainable material, natural texture, eco-friendly design, warm tones, renewable resource',
  };

  // Wall installation patterns
  static final Map<String, String> _wallPatterns = {
    'Paint': 'smooth uniform application, professional brush/roller marks, consistent color, seamless corners and edges',
    'Wallpaper': 'pattern matching at seams, proper alignment, smooth installation without bubbles or wrinkles',
    'Wood Paneling': 'horizontal or vertical installation, proper spacing, consistent board widths, aligned joints',
    'Stone Veneer': 'random ashlar pattern, staggered joints, natural stone arrangement, proper mortar application',
    'Brick': 'running bond pattern, stacked bond, herringbone, proper mortar joints and spacing',
    'Tile': 'straight lay, offset pattern, herringbone, brick bond, mosaic layout, proper grout lines',
    'Wainscoting': 'vertical panels, beadboard, raised panel design, proper molding details and proportions',
    'Concrete': 'seamless polished finish, consistent texture, smooth surface without imperfections',
    'Fabric': 'stretched fabric panels, padded installation, seamless joins, professional upholstery work',
    'Metal': 'panel installation, corrugated pattern, sheet metal application, proper fastening and joints',
    'Venetian Plaster': 'hand-troweled application, polished finish, subtle texture variations, seamless appearance',
    'Murals': 'full wall coverage, seamless image transition, proper scale and perspective, realistic artwork',
    'Glass': 'panel installation, seamless joints, proper framing or frameless installation, clean appearance',
    'Mosaic': 'intricate pattern arrangement, proper grout application, detailed craftsmanship, artistic design',
    'Cork': 'panel or tile installation, seamless joins, consistent texture, proper cutting and fitting',
    'Leather': 'panel installation, tufted or flat application, proper stitching or joining, luxurious appearance',
    '3D Wall Panels': 'geometric pattern arrangement, proper alignment, seamless joins, dimensional appearance',
    'Mirror': 'panel installation, proper alignment, seamless or framed appearance, reflective quality',
    'Chalkboard': 'smooth painted surface, uniform black or colored finish, proper edges and corners',
    'Bamboo': 'panel or strip installation, natural pattern, proper joining, sustainable appearance',
  };

  // Generate AI prompt for wall redesign
  static String generateWallPrompt({
    required String wallType,
    required String imageSource,
  }) {
    String wallRequirements = _wallDesignRequirements[wallType] ??
        'functional wall covering, appropriate material, durable surface, aesthetically pleasing';

    String wallPattern = _wallPatterns[wallType] ?? 'appropriate installation pattern';

    return """
COMPLETE WALL TRANSFORMATION - FULL COVERAGE REQUIRED

REFERENCE IMAGE ANALYSIS:
- Analyze the ENTIRE room image completely ($imageSource)
- Study EVERY visible wall area including all walls, corners, and edges
- Identify ALL wall surfaces in the image without any exceptions
- Note the complete room perspective and ALL visible wall sections
- Understand the FULL wall layout from floor to ceiling

CRITICAL REQUIREMENT - COMPLETE WALL COVERAGE:
- TRANSFORM EVERY SINGLE visible wall area in the image
- COVER 100% of the wall surface from floor to ceiling
- DO NOT leave any original wall areas unchanged
- ENSURE wall transformation extends to ALL corners and edges
- INCLUDE wall areas behind and around ALL furniture and objects
- MAKE SURE no part of the original wall remains visible

MANDATORY PRESERVATION REQUIREMENTS:
- MAINTAIN the EXACT SAME room layout and structure
- KEEP all furniture, objects, windows, and doors in their exact positions
- PRESERVE identical floor and ceiling surfaces
- RETAIN the same camera perspective, angle, and lighting
- DO NOT alter any architectural elements or room proportions
- KEEP all windows and doors exactly as they are

WALL TRANSFORMATION REQUEST:
COMPLETELY transform ALL visible wall areas to $wallType wall covering. Replace EVERY part of the existing walls.

AI INTERVENTION LEVEL: HIGH - Complete wall material replacement with full coverage

$wallType WALL CHARACTERISTICS:
$wallRequirements

INSTALLATION PATTERN:
$wallPattern

WALL-SPECIFIC TRANSFORMATION DETAILS:
- FULL COVERAGE: Transform 100% of visible wall area
- MATERIAL APPLICATION: Apply $wallType material to ENTIRE walls
- TEXTURE AND FINISH: Create consistent surface texture across ALL walls
- COLOR AND TONE: Use authentic $wallType colors throughout
- PATTERN LAYOUT: Implement $wallPattern installation across complete walls
- FLOOR-TO-CEILING: Ensure wall covers from floor to ceiling in ALL directions
- AROUND OBJECTS: Include wall transformation behind ALL furniture and objects

STRICT TRANSFORMATION RULES:
- TRANSFORM EVERY visible wall surface without exception
- COVER ALL wall areas including those partially visible or behind objects
- ENSURE complete floor-to-ceiling coverage on ALL walls
- MAINTAIN identical room layout and object positions
- PRESERVE exact camera perspective and lighting
- CREATE seamless wall transformation across entire image
- KEEP all windows, doors, and openings exactly as they are

COMPLETE COVERAGE CHECKLIST:
- All main wall areas transformed ✓
- All corners and edges covered ✓
- Walls behind furniture included ✓
- Floor-to-ceiling coverage achieved ✓
- No original wall remains visible ✓
- Consistent material throughout ✓
- Windows/doors preserved exactly ✓

OUTPUT REQUIREMENTS:
- Generate photorealistic transformation with COMPLETE wall coverage
- Transform 100% of visible wall surfaces
- Maintain perfect room perspective and layout
- Create realistic $wallType material across entire walls
- Ensure NO original wall areas remain
- Show professional installation with full coverage
- Preserve all windows and doors exactly as shown

FINAL RESULT: The generated image must show the IDENTICAL room with COMPLETE wall transformation - EVERY visible wall area must be changed to $wallType wall covering with zero exceptions.
""";
  }

  // Get wall type description
  static String getWallDescription(String wallType) {
    return _wallDesignRequirements[wallType] ?? 'wall covering transformation';
  }

  // Get installation pattern
  static String getWallPattern(String wallType) {
    return _wallPatterns[wallType] ?? 'standard installation';
  }
}
// FILL SPACE PROMPT GENERATOR - NEW ADDITION
class FillSpacePromptGenerator {
  static String generateFillSpacePrompt({
    required String fillInstruction,
    required String imageSource,
  }) {
    return """
INTELLIGENT SPACE FILLING TRANSFORMATION - CRITICAL AI PROMPT

REFERENCE IMAGE ANALYSIS:
- Analyze the provided image completely and carefully ($imageSource)
- Study the entire scene composition, perspective, and layout
- Identify ALL empty spaces, blank areas, and gaps
- Understand the room's style, color scheme, and existing furniture
- Note the lighting conditions, shadows, and overall ambiance
- Recognize the architectural elements and spatial boundaries

FILL INSTRUCTION FROM USER:
"$fillInstruction"

MANDATORY PRESERVATION REQUIREMENTS:
- MAINTAIN the EXACT SAME image composition and perspective
- KEEP all existing objects and elements completely unchanged
- PRESERVE identical room layout, structure, and proportions
- RETAIN the same camera angle, viewpoint, and framing
- MAINTAIN identical lighting conditions, color temperature, and atmosphere
- PRESERVE all background elements exactly as they appear
- KEEP the same image quality and resolution

SPACE FILLING PROCESS - STEP BY STEP:
1. IDENTIFY the empty/blank areas in the image
2. UNDERSTAND what needs to be added based on user instruction
3. ANALYZE the existing room style and color palette
4. ENSURE new items match the room's aesthetic
5. PLACE items naturally in the empty spaces
6. MATCH the scale and proportion realistically
7. INTEGRATE with proper lighting and shadows
8. BLEND seamlessly with surroundings
9. CREATE photorealistic appearance

CRITICAL SPACE FILLING RULES:
- ONLY add items to EMPTY spaces
- DO NOT remove or replace existing objects
- MATCH the size and scale appropriately for the space
- MAINTAIN realistic perspective and positioning
- CREATE proper shadows and reflections for new items
- ENSURE lighting matches the scene (direction, intensity, color)
- PRESERVE depth and spatial relationships
- KEEP existing elements completely untouched
- MAINTAIN photorealistic quality throughout
- ENSURE new items complement existing decor style

STYLE MATCHING REQUIREMENTS:
- Analyze existing furniture style (modern, traditional, rustic, etc.)
- Match color scheme with existing palette
- Ensure new items fit the overall aesthetic
- Maintain design consistency throughout the room
- Consider the room's purpose and functionality

LIGHTING AND SHADOW REQUIREMENTS:
- Match existing lighting direction and intensity
- Create appropriate shadows for new items
- Maintain consistent light source behavior
- Add reflections if surface materials require
- Preserve ambient lighting conditions
- Keep color temperature consistent

INTEGRATION REQUIREMENTS:
- Seamless blending with floor/surface contact points
- Natural occlusion with other objects if needed
- Proper perspective distortion matching room geometry
- Realistic material properties for new items
- Appropriate texture and surface details
- Natural color grading matching the scene

SPATIAL AWARENESS:
- Respect room boundaries and available space
- Maintain proper distance from walls and other objects
- Ensure new items fit naturally in empty spaces
- Keep appropriate clearance and spacing
- Preserve realistic room proportions
- Do not overcrowd the space

QUALITY STANDARDS:
- Generate photorealistic output
- High-resolution details and textures
- Professional-grade image quality
- No visible artifacts or inconsistencies
- Natural and believable final result
- Sharp focus and clarity

FORBIDDEN ACTIONS - DO NOT:
❌ Remove any existing objects
❌ Replace existing furniture or decor
❌ Change the room layout or structure
❌ Alter camera perspective or angle
❌ Modify lighting conditions drastically
❌ Change background elements
❌ Alter colors of existing elements
❌ Modify room dimensions or proportions
❌ Add items that clash with existing style
❌ Overcrowd the space

FINAL OUTPUT REQUIREMENTS:
- The result must look like a professional photograph
- The new items must appear completely natural
- No one should be able to tell additions are AI-generated
- The new items must blend perfectly with the scene
- All existing elements must remain pixel-perfect unchanged
- The image should maintain original quality and resolution
- The filled space should look intentionally designed

FILL INSTRUCTION INTERPRETATION:
Parse the user instruction carefully:
- Identify WHAT to add (items/objects)
- Identify WHERE to add (empty spaces, corners, walls)
- Note any specific details (color, style, material, size)
- Understand any positioning requirements
- Follow any additional specifications given

FINAL RESULT: Generate a photorealistic image where ONLY the empty spaces have been filled according to the instruction "$fillInstruction", while everything else remains identical to the reference image. The new additions should look like they were always part of the original design.
""";
  }

  static String getFillSpaceDescription(String fillInstruction) {
    return "Fill space as instructed: $fillInstruction";
  }
}
// ========================================
// STEP 2.3: prompt_.dart ki END MEIN YEH CLASS ADD KARO
// FillSpacePromptGenerator ke baad
// ========================================

class ReferenceTransformPromptGenerator {
  static String generateReferenceTransformPrompt({
    required String referenceImageSource,
    required String targetImageSource,
    String? additionalInstruction,
  }) {
    String additionalText = '';
    if (additionalInstruction != null && additionalInstruction.isNotEmpty) {
      additionalText = '''

ADDITIONAL USER INSTRUCTIONS:
"$additionalInstruction"

CRITICAL: Follow these additional instructions while performing the style transfer.
''';
    }

    return """
REFERENCE-BASED IMAGE TRANSFORMATION - DUAL IMAGE STYLE TRANSFER

TASK OVERVIEW:
You are performing STYLE TRANSFER using TWO images:
- IMAGE A (Reference): Source of style/aesthetic ($referenceImageSource)
- IMAGE B (Target): Image to be transformed ($targetImageSource)

YOUR TASK: Apply visual style, aesthetic, color palette, and mood from IMAGE A to IMAGE B while preserving IMAGE B's content and structure.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 1: ANALYZE IMAGE A (REFERENCE)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EXTRACT FROM IMAGE A:
1. COLOR PALETTE: Primary colors, temperature, saturation, contrast
2. LIGHTING: Direction, intensity, shadows, highlights, mood
3. STYLE: Visual style, texture, edges, patterns
4. MOOD: Emotional tone, ambiance, energy level
5. POST-PROCESSING: Color grading, vignetting, blur, grain, filters

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 2: ANALYZE IMAGE B (TARGET)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

UNDERSTAND FROM IMAGE B:
1. CONTENT: Main subjects, objects, spatial layout
2. STRUCTURE: Composition, positions, relationships
3. PRESERVE: ALL objects, layout, perspective, architecture

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 3: APPLY STYLE TRANSFER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

APPLY FROM A TO B:
✓ Replace B's colors with A's color palette
✓ Match A's lighting direction and intensity
✓ Apply A's texture and style treatment
✓ Transfer A's mood and atmosphere
✓ Apply A's post-processing effects

PRESERVE IN B:
✓ Exact room/space structure
✓ All object positions
✓ Architectural elements
✓ Spatial relationships
✓ Camera perspective
✓ Image composition

❌ FORBIDDEN:
❌ Do NOT move objects
❌ Do NOT add/remove objects
❌ Do NOT change layout
❌ Do NOT alter perspective
$additionalText
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FINAL RESULT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Generate photorealistic image showing:
- IMAGE B's CONTENT (100% preserved)
- IMAGE A's STYLE (100% applied)
- Seamless style integration
- Natural, believable result

Result should look like: "Image B shot/edited in the same style as Image A"
""";
  }
}