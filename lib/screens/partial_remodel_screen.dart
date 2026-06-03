import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:ai_remodeling/screens/login_screen.dart';
import 'package:ai_remodeling/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

enum DrawingTool { none, area, brush, lasso }

class PartialRemodelScreen extends StatefulWidget {
  const PartialRemodelScreen({super.key});

  @override
  State<PartialRemodelScreen> createState() => _PartialRemodelScreenState();
}

class _PartialRemodelScreenState extends State<PartialRemodelScreen> {
  DrawingTool _activeTool = DrawingTool.none;
  bool _isSelecting = true;
  List<DrawingPath> _paths = [];
  DrawingPath? _currentPath;
  final TextEditingController _promptController = TextEditingController();
  double _currentWidth = 20.0;

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

  Future<void> _generateInpaint() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.currentUser == null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
      return;
    }

    final up = Provider.of<UploadProvider>(context, listen: false);
    final cm = Provider.of<CreditManager>(context, listen: false);

    if (up.selectedImage == null) { ExceptionHandler.showToast('Please upload an image first'); return; }
    if (_paths.isEmpty) { ExceptionHandler.showToast('Please select an area to remodel'); return; }
    if (!cm.hasEnoughCredits(10)) {
      CreditDialog.show(context, 'You need at least 10 credits for Partial Remodel.', IAPManager().products);
      return;
    }

    try {
      LoadingOverlay.show(context, message: 'Generating remodel...');

      final maskBytes = await _buildMaskAtImageSize();
      if (maskBytes == null) {
        if (mounted) Navigator.pop(context);
        ExceptionHandler.showToast('Failed to generate mask');
        return;
      }

      final maskFile = File('${Directory.systemTemp.path}/mask_${DateTime.now().millisecondsSinceEpoch}.png');
      await maskFile.writeAsBytes(maskBytes);

      final prompt = _promptController.text.trim().isEmpty
          ? 'Remodel the selected (white masked) area with modern interior design while keeping the rest exactly the same'
          : _promptController.text.trim();

      final result = await GeminiService.generateImageInpaint(prompt: prompt, imageFile: up.selectedImage!, maskFile: maskFile);

      if (result != null) {
        await ImageStorageService.uploadAndStore(result);
      }

      await cm.deductCredits(10, reason: 'partial_remodel');

      if (mounted) Navigator.pop(context);
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ResultScreen(
          generatedImageUrls: [result], roomType: 'Partial Remodel',
          style: prompt, budget: 'N/A', prompt: prompt,
          beforeImageUrl: up.selectedImage?.path,
        )));
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ExceptionHandler.handleException(e);
    }
  }


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
          // Scale the rect to image pixels
          final r = Rect.fromPoints(
            Offset(p.points[0]!.dx * sx, p.points[0]!.dy * sy),
            Offset(p.points[1]!.dx * sx, p.points[1]!.dy * sy),
          );
          canvas.drawRect(r, paint);
        } else if (p.tool == DrawingTool.brush) {
          paint.style = PaintingStyle.stroke;
          paint.strokeWidth = p.width * sx; // scale stroke width
          for (int i = 0; i < p.points.length - 1; i++) {
            if (p.points[i] != null && p.points[i + 1] != null) {
              canvas.drawLine(
                Offset(p.points[i]!.dx * sx, p.points[i]!.dy * sy),
                Offset(p.points[i + 1]!.dx * sx, p.points[i + 1]!.dy * sy),
                paint,
              );
            }
          }
        } else if (p.tool == DrawingTool.lasso && p.points.length >= 3) {
          paint.style = PaintingStyle.fill;
          final path = Path();
          path.moveTo(p.points[0]!.dx * sx, p.points[0]!.dy * sy);
          for (final pt in p.points) {
            if (pt != null) path.lineTo(pt.dx * sx, pt.dy * sy);
          }
          path.close();
          canvas.drawPath(path, paint);
        }
      }

      final picture = recorder.endRecording();
      final img = await picture.toImage(_imgW, _imgH);
      final bd = await img.toByteData(format: ui.ImageByteFormat.png);
      return bd?.buffer.asUint8List();
    } catch (e) {
      print('Mask error: $e');
      return null;
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
              title: const Text('Partial Remodel'),
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
                  IconButton(icon: const Icon(Icons.refresh), onPressed: _clearCanvas, tooltip: 'Clear'),
              ],
            ),
            body: Column(
              children: [
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
                            child: ImageSelectionWidget(onImageSelected: (img) { _loadImage(img); }),
                          ),
                        )
                      : Stack(
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
                                      onPanStart: (_activeTool == DrawingTool.brush || _activeTool == DrawingTool.lasso || _activeTool == DrawingTool.area)
                                          ? (d) {
                                              setState(() {
                                                _currentPath = DrawingPath(
                                                  tool: _activeTool, 
                                                  isDeselection: !_isSelecting,
                                                  points: [d.localPosition], 
                                                  isRect: _activeTool == DrawingTool.area, 
                                                  width: _currentWidth,
                                                );
                                                _paths.add(_currentPath!);
                                              });
                                            }
                                          : null,
                                      onPanUpdate: (_activeTool == DrawingTool.brush || _activeTool == DrawingTool.lasso || _activeTool == DrawingTool.area)
                                          ? (d) { 
                                              if (_currentPath != null) {
                                                setState(() {
                                                  if (_activeTool == DrawingTool.area) {
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
                                          CustomPaint(painter: MaskPainter(paths: _paths), size: Size.infinite),
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
                  child: TabBarView(children: [_buildToolsTab(), _buildPromptTab()]),
                ),
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
            _circleBtn('Area', DrawingTool.area, Icons.crop_free, true),
            const SizedBox(width: 12),
            _circleBtn('Area', DrawingTool.area, Icons.crop_free, false),
            const SizedBox(width: 12),
            _circleBtn('Brush', DrawingTool.brush, Icons.brush, true),
            const SizedBox(width: 12),
            _circleBtn('Brush', DrawingTool.brush, Icons.brush, false),
            const SizedBox(width: 12),
            _circleBtn('Lasso', DrawingTool.lasso, Icons.gesture, true),
            const SizedBox(width: 12),
            _circleBtn('Lasso', DrawingTool.lasso, Icons.gesture, false),
          ]),
        ),
        if (_activeTool == DrawingTool.brush || _activeTool == DrawingTool.lasso) ...[
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

  Widget _circleBtn(String label, DrawingTool tool, IconData icon, bool isSelect) {
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

  Widget _buildPromptTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        TextField(
          controller: _promptController, maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Describe what to change in the selected area...',
            fillColor: AppTheme.primaryColor.withOpacity(0.05), filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton(
            onPressed: _generateInpaint,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor, foregroundColor: AppTheme.secondaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Partial Remodel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ),
      ]),
    );
  }
}

// ─── Models ───────────────────────────────────────────────────────────────────
class DrawingPath {
  final List<Offset?> points;
  final DrawingTool tool;
  final bool isDeselection;
  final double width;
  final bool isRect;
  DrawingPath({required this.points, required this.tool, required this.isDeselection, required this.isRect, this.width = 20.0});
}

class MaskPainter extends CustomPainter {
  final List<DrawingPath> paths;
  MaskPainter({required this.paths});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    for (final p in paths) {
      final paint = Paint()
        ..strokeCap = StrokeCap.round
        ..color = p.isDeselection ? Colors.transparent : Colors.blue.withOpacity(0.5)
        ..blendMode = p.isDeselection ? BlendMode.clear : BlendMode.srcOver;

      if (p.isRect && p.points.length >= 2 && p.points[0] != null && p.points[1] != null) {
        paint.style = PaintingStyle.fill;
        canvas.drawRect(Rect.fromPoints(p.points[0]!, p.points[1]!), paint);
      } else if (p.tool == DrawingTool.brush) {
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = p.width;
        for (int i = 0; i < p.points.length - 1; i++) {
          if (p.points[i] != null && p.points[i + 1] != null) canvas.drawLine(p.points[i]!, p.points[i + 1]!, paint);
        }
      } else if (p.tool == DrawingTool.lasso && p.points.length >= 3) {
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
  bool shouldRepaint(covariant MaskPainter old) => true;
}
