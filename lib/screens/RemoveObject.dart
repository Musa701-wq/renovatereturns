import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/upload_provider.dart';
import '../utils/theme.dart';
import '../widgets/credit_dialog.dart';
import '../widgets/image_selection_widget.dart';
import '../services/api_services.dart';
import '../services/image_storage_service.dart';
import '../screens/result_screen.dart';
import '../services/exception_handler.dart';
import '../in_app_purchase/credit_manager.dart';
import '../in_app_purchase/i_ap_manager.dart';
import '../widgets/loading_overlay.dart';
import '../screens/login_screen.dart';
import '../provider/auth_provider.dart';

enum RemoveDrawingTool { none, area, brush, lasso }

class ObjectRemove extends StatefulWidget {
  const ObjectRemove({super.key});

  @override
  State<ObjectRemove> createState() => _ObjectRemoveState();
}

class _ObjectRemoveState extends State<ObjectRemove> {
  RemoveDrawingTool _activeTool = RemoveDrawingTool.none;
  bool _isSelecting = true;
  List<RemoveDrawingPath> _paths = [];
  RemoveDrawingPath? _currentPath;
  final TextEditingController _promptController = TextEditingController();
  double _currentWidth = 25.0;

  Size _canvasSize = Size.zero;
  int _imgW = 1, _imgH = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<UploadProvider>(context, listen: false);
      if (prov.selectedImage != null) _loadImage(prov.selectedImage!);
    });
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _loadImage(File f) async {
    final bytes = await f.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    if (mounted) {
      setState(() {
        _imgW = frame.image.width;
        _imgH = frame.image.height;
      });
    }
  }

  void _clearCanvas() => setState(() => _paths.clear());

  Future<Uint8List?> _buildMaskAtImageSize() async {
    if (_canvasSize == Size.zero || _imgW == 1) return null;

    final double sx = _imgW / _canvasSize.width;
    final double sy = _imgH / _canvasSize.height;

    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, _imgW.toDouble(), _imgH.toDouble()));

      canvas.drawRect(Rect.fromLTWH(0, 0, _imgW.toDouble(), _imgH.toDouble()), Paint()..color = Colors.black);

      for (final p in _paths) {
        final paint = Paint()
          ..strokeCap = StrokeCap.round
          ..color = p.isDeselection ? Colors.black : Colors.white
          ..blendMode = BlendMode.src;

        if (p.isRect && p.points.length >= 2) {
          paint.style = PaintingStyle.fill;
          final p0 = p.points[0];
          final p1 = p.points[1];
          if (p0 != null && p1 != null) {
            final r = Rect.fromPoints(
              Offset(p0.dx * sx, p0.dy * sy),
              Offset(p1.dx * sx, p1.dy * sy),
            );
            canvas.drawRect(r, paint);
          }
        } else if (p.tool == RemoveDrawingTool.brush) {
          paint.style = PaintingStyle.stroke;
          paint.strokeWidth = p.width * sx;
          for (int i = 0; i < p.points.length - 1; i++) {
            if (p.points[i] != null && p.points[i + 1] != null) {
              canvas.drawLine(
                Offset(p.points[i]!.dx * sx, p.points[i]!.dy * sy),
                Offset(p.points[i + 1]!.dx * sx, p.points[i + 1]!.dy * sy),
                paint,
              );
            }
          }
        } else if (p.tool == RemoveDrawingTool.lasso && p.points.length >= 3) {
          final startPt = p.points[0];
          if (startPt != null) {
            paint.style = PaintingStyle.fill;
            final path = Path();
            path.moveTo(startPt.dx * sx, startPt.dy * sy);
            for (final pt in p.points) {
              if (pt != null) path.lineTo(pt.dx * sx, pt.dy * sy);
            }
            path.close();
            canvas.drawPath(path, paint);
          }
        }
      }

      final picture = recorder.endRecording();
      final img = await picture.toImage(_imgW, _imgH);
      final bd = await img.toByteData(format: ui.ImageByteFormat.png);
      return bd?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  Future<void> _removeObjectAction() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.currentUser == null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
      return;
    }
    
    final up = Provider.of<UploadProvider>(context, listen: false);
    final cm = Provider.of<CreditManager>(context, listen: false);
    final int cost = up.isMultipleVariationsEnabled ? 15 : 5;

    if (up.selectedImage == null) {
      ExceptionHandler.showToast('Please upload an image first');
      return;
    }
    if (_paths.isEmpty) {
      ExceptionHandler.showToast('Please highlight the object to remove using the drawing tools');
      return;
    }
    if (!cm.hasEnoughCredits(cost)) {
      CreditDialog.show(context, 'You need at least $cost credits for object removal.', IAPManager().products);
      return;
    }

    try {
      LoadingOverlay.show(context, message: 'Removing object...');

      final maskBytes = await _buildMaskAtImageSize();
      if (maskBytes == null) {
        if (mounted) Navigator.pop(context);
        ExceptionHandler.showToast('Failed to generate object mask');
        return;
      }

      final maskFile = File('${Directory.systemTemp.path}/mask_${DateTime.now().millisecondsSinceEpoch}.png');
      await maskFile.writeAsBytes(maskBytes);

      final promptText = _promptController.text.trim();
      final prompt = promptText.isEmpty
          ? 'Absolutely remove the highlighted object entirely. Erase it and seamlessly fill the empty space with the matching background texture and logic. Do not leave traces.'
          : 'Remove this specific object entirely: "$promptText". Erase it from the highlighted area and reconstruct the background seamlessly behind it without any blur or leftover elements.';

      List<String> generatedImageUrls = [];
      
      // Since generateImageInpaint currently returns one string, we will just call it in a loop if variations are enabled.
      int iterations = up.isMultipleVariationsEnabled ? 3 : 1;
      
      for(int i = 0; i < iterations; i++) {
          final iterPrompt = iterations > 1 ? "$prompt (Variation ${i+1}: Ensure alternative background blending approach)" : prompt;
          final result = await GeminiService.generateImageInpaint(prompt: iterPrompt, imageFile: up.selectedImage!, maskFile: maskFile);
          if (result != null) generatedImageUrls.add(result);
      }

      if (generatedImageUrls.isNotEmpty) {
        for (var res in generatedImageUrls) {
             // History saving is now handled by ResultScreen to prevent duplicates
        }
      }

      final deductionSucceeded = await cm.deductCredits(cost, reason: up.isMultipleVariationsEnabled ? 'multiple_variations' : 'object_removal');

      if (!deductionSucceeded) {
          if (mounted) {
            Navigator.pop(context);
            ExceptionHandler.showToast('Unable to deduct credits');
          }
          return;
      }

      if (mounted) Navigator.pop(context);
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ResultScreen(
          generatedImageUrls: generatedImageUrls,
          roomType: 'Object Removal',
          style: promptText.isEmpty ? "Erased Selection" : "Removed: $promptText",
          budget: 'N/A',
          prompt: prompt,
          beforeImageUrl: up.selectedImage?.path,
        )));
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ExceptionHandler.handleException(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UploadProvider>(
      builder: (ctx, up, _) {
        final double imgAspect = _imgW / _imgH;

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: AppTheme.secondaryColor,
            appBar: AppBar(
              title: const Text('Remove Object'),
              backgroundColor: AppTheme.secondaryColor,
              foregroundColor: AppTheme.primaryColor,
              leading: IconButton(
                icon: Icon(AppTheme.backButtonIcon),
                onPressed: () {
                  if (up.selectedImage != null) {
                    up.reset();
                  }
                  Navigator.pop(context);
                },
              ),
              actions: [
                if (up.selectedImage != null)
                  IconButton(icon: const Icon(Icons.refresh), onPressed: _clearCanvas, tooltip: 'Clear Mask'),
              ],
            ),
            body: Column(
              children: [
                // IMAGE SECTION
                Expanded(
                  flex: 3,
                  child: up.selectedImage == null
                      ? Align(
                          alignment: Alignment.topCenter,
                          child: SingleChildScrollView(
                            padding: EdgeInsets.only(
                              top: 40.0,
                              left: AppTheme.responsivePadding(context),
                              right: AppTheme.responsivePadding(context),
                              bottom: AppTheme.responsivePadding(context),
                            ),
                            child: ImageSelectionWidget(onImageSelected: (img) { 
                              up.setSelectedImage(img);
                              _loadImage(img); 
                            }),
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          child: Stack(
                            children: [
                              Center(
                                child: AspectRatio(
                                  aspectRatio: imgAspect,
                                  child: LayoutBuilder(
                                    builder: (_, constraints) {
                                      final newSize = constraints.biggest;
                                      if (_canvasSize != newSize) {
                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          if (mounted && _canvasSize != newSize) {
                                            setState(() => _canvasSize = newSize);
                                          }
                                        });
                                      }
                                      return GestureDetector(
                                        onPanStart: (_activeTool == RemoveDrawingTool.brush || _activeTool == RemoveDrawingTool.lasso || _activeTool == RemoveDrawingTool.area)
                                            ? (d) {
                                                setState(() {
                                                  _currentPath = RemoveDrawingPath(
                                                    tool: _activeTool, 
                                                    isDeselection: !_isSelecting,
                                                    points: [d.localPosition], 
                                                    isRect: _activeTool == RemoveDrawingTool.area, 
                                                    width: _currentWidth,
                                                  );
                                                  _paths.add(_currentPath!);
                                                });
                                              }
                                            : null,
                                        onPanUpdate: (_activeTool == RemoveDrawingTool.brush || _activeTool == RemoveDrawingTool.lasso || _activeTool == RemoveDrawingTool.area)
                                            ? (d) { 
                                                if (_currentPath != null) {
                                                  setState(() {
                                                    if (_activeTool == RemoveDrawingTool.area) {
                                                      if (_currentPath!.points.length < 2) {
                                                        _currentPath!.points.add(d.localPosition);
                                                      } else {
                                                        _currentPath!.points[1] = d.localPosition;
                                                      }
                                                    } else {
                                                      _currentPath!.points.add(d.localPosition);
                                                    }
                                                  });
                                                }
                                              }
                                            : null,
                                        onPanEnd: (_) => setState(() => _currentPath = null),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.file(up.selectedImage!, fit: BoxFit.fill, width: double.infinity, height: double.infinity),
                                            CustomPaint(painter: RemoveMaskPainter(paths: _paths), size: Size.infinite),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                // SPACE CONTROL
                const SizedBox(height: 12),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TabBar(
                    labelColor: AppTheme.secondaryColor,
                    unselectedLabelColor: AppTheme.primaryColor.withOpacity(0.6),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppTheme.primaryColor,
                    ),
                    tabs: const [
                      Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Tools', style: TextStyle(fontWeight: FontWeight.bold))])),
                      Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.description, size: 18), SizedBox(width: 8), Text('Prompt', style: TextStyle(fontWeight: FontWeight.bold))])),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: TabBarView(
                    children: [
                      _buildToolsTab(), 
                      _buildPromptTab(up)
                    ],
                  ),
                ),
                // Add minor bottom safety padding
                SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildToolsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _circleBtn('Brush', RemoveDrawingTool.brush, Icons.brush, true),
            const SizedBox(width: 12),
            _circleBtn('Brush', RemoveDrawingTool.brush, Icons.brush, false),
            const SizedBox(width: 12),
            _circleBtn('Lasso', RemoveDrawingTool.lasso, Icons.gesture, true),
            const SizedBox(width: 12),
            _circleBtn('Area', RemoveDrawingTool.area, Icons.crop_free, true),
            const SizedBox(width: 12),
            _circleBtn('Eraser', RemoveDrawingTool.area, Icons.delete_outline, false), // A fun shortcut for remove area
          ]),
        ),
        if (_activeTool == RemoveDrawingTool.brush || _activeTool == RemoveDrawingTool.lasso) ...[
          const SizedBox(height: 16),
          Row(children: [
            const Icon(Icons.line_weight, size: 18),
            Expanded(child: Slider(value: _currentWidth, min: 5, max: 80, activeColor: AppTheme.primaryColor, onChanged: (v) => setState(() => _currentWidth = v))),
            Text('${_currentWidth.toInt()}px', style: const TextStyle(fontSize: 12)),
          ]),
        ],
      ]),
    );
  }

  Widget _circleBtn(String label, RemoveDrawingTool tool, IconData icon, bool isSelect) {
    final bool active = _activeTool == tool && _isSelecting == isSelect;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      GestureDetector(
        onTap: () => setState(() { _activeTool = tool; _isSelecting = isSelect; }),
        child: Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: active ? AppTheme.primaryColor : AppTheme.primaryColor.withOpacity(0.12),
            shape: BoxShape.circle,
            boxShadow: active ? [const BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))] : [],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: active ? AppTheme.secondaryColor : AppTheme.primaryColor, size: 24),
              Positioned(right: 4, top: 4, child: Icon(isSelect ? Icons.add_circle : Icons.remove_circle, size: 16, color: isSelect ? Colors.green : Colors.red)),
            ],
          ),
        ),
      ),
      const SizedBox(height: 6),
      Text(isSelect ? '$label+' : '$label-',
        style: TextStyle(fontSize: 11, fontWeight: active ? FontWeight.bold : FontWeight.normal, color: AppTheme.primaryColor)),
    ]);
  }

  Widget _buildPromptTab(UploadProvider uploadProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        TextField(
          controller: _promptController, maxLines: 2,
          decoration: InputDecoration(
            hintText: 'What are we removing? (Optional, e.g. "chair" or "person")',
            fillColor: AppTheme.primaryColor.withOpacity(0.05), filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 10),
        
        Container(
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: SwitchListTile(
            title: Text(
              'Generate 3 Variations',
              style: TextStyle(
                fontSize: AppTheme.responsiveFont(context, phone: 13, tablet: 15),
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            subtitle: Text(
              'Costs 15 credits instead of 5',
              style: TextStyle(
                fontSize: AppTheme.responsiveFont(context, phone: 11, tablet: 13),
                color: AppTheme.primaryColor.withOpacity(0.7),
              ),
            ),
            value: uploadProvider.isMultipleVariationsEnabled,
            activeColor: AppTheme.primaryColor,
            onChanged: (value) => uploadProvider.setMultipleVariationsEnabled(value),
          ),
        ),
        
        const Spacer(),
        SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton(
            onPressed: _removeObjectAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor, foregroundColor: AppTheme.secondaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Highlight & Remove Object', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ]),
    );
  }
}

class RemoveDrawingPath {
  final List<Offset?> points;
  final RemoveDrawingTool tool;
  final bool isDeselection;
  final double width;
  final bool isRect;
  RemoveDrawingPath({required this.points, required this.tool, required this.isDeselection, required this.isRect, this.width = 20.0});
}

class RemoveMaskPainter extends CustomPainter {
  final List<RemoveDrawingPath> paths;
  RemoveMaskPainter({required this.paths});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    for (final p in paths) {
      final paint = Paint()
        ..strokeCap = StrokeCap.round
        ..color = p.isDeselection ? Colors.transparent : Colors.red.withOpacity(0.5) // Red color for highlight!
        ..blendMode = p.isDeselection ? BlendMode.clear : BlendMode.srcOver;

      if (p.isRect && p.points.length >= 2 && p.points[0] != null && p.points[1] != null) {
        paint.style = PaintingStyle.fill;
        canvas.drawRect(Rect.fromPoints(p.points[0]!, p.points[1]!), paint);
      } else if (p.tool == RemoveDrawingTool.brush) {
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = p.width;
        for (int i = 0; i < p.points.length - 1; i++) {
          if (p.points[i] != null && p.points[i + 1] != null) canvas.drawLine(p.points[i]!, p.points[i + 1]!, paint);
        }
      } else if (p.tool == RemoveDrawingTool.lasso && p.points.length >= 3) {
        paint.style = PaintingStyle.fill;
        final path = Path();
        path.moveTo(p.points[0]!.dx, p.points[0]!.dy);
        for (final pt in p.points) { if (pt != null) path.lineTo(pt.dx, pt.dy); }
        path.close();
        canvas.drawPath(path, paint);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant RemoveMaskPainter old) => true;
}