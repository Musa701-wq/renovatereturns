import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../utils/theme.dart';

class BeforeAfterSlider extends StatefulWidget {
  final String? beforeImageUrl;
  final dynamic afterImage; // Can be String (URL) or Uint8List (Memory)
  final double height;

  const BeforeAfterSlider({
    super.key,
    required this.beforeImageUrl,
    required this.afterImage,
    required this.height,
  });

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  late final ValueNotifier<double> _sliderValueNotifier;
  late final Widget _beforeImage;
  late final Widget _afterImage;

  @override
  void initState() {
    super.initState();
    _sliderValueNotifier = ValueNotifier<double>(0.5);
    // Pre-build images to avoid multi-rebuilds inside LayoutBuilder
    _beforeImage = _buildImageWidget(widget.beforeImageUrl);
    _afterImage = _buildImageWidget(widget.afterImage);
  }

  @override
  void dispose() {
    _sliderValueNotifier.dispose();
    super.dispose();
  }

  Widget _buildImageWidget(dynamic imageSource) {
    if (imageSource == null) return const SizedBox.shrink();

    final Key imageKey = ValueKey(imageSource.toString());

    Widget img;
    if (imageSource is Uint8List) {
      img = Image.memory(
        imageSource,
        key: imageKey,
        fit: BoxFit.cover,
        width: double.infinity,
        height: widget.height,
      );
    } else if (imageSource is String) {
      if (imageSource.startsWith('data:image')) {
        try {
          String base64Data = imageSource.split(',').last;
          img = Image.memory(
            base64Decode(base64Data),
            key: imageKey,
            fit: BoxFit.cover,
            width: double.infinity,
            height: widget.height,
          );
        } catch (e) {
          img = const Icon(Icons.error, color: Colors.white);
        }
      } else if (imageSource.startsWith('http')) {
        img = Image.network(
          imageSource,
          key: imageKey,
          fit: BoxFit.cover,
          width: double.infinity,
          height: widget.height,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.error, color: Colors.white),
        );
      } else {
        try {
          img = Image.memory(
            base64Decode(imageSource),
            key: imageKey,
            fit: BoxFit.cover,
            width: double.infinity,
            height: widget.height,
          );
        } catch (_) {
          img = Image.file(
            File(imageSource),
            key: imageKey,
            fit: BoxFit.cover,
            width: double.infinity,
            height: widget.height,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.error, color: Colors.white),
          );
        }
      }
    } else {
      img = const SizedBox.shrink();
    }

    return RepaintBoundary(child: img);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanUpdate: (details) {
            if (width > 0) {
              _sliderValueNotifier.value = (details.localPosition.dx / width).clamp(0.0, 1.0);
            }
          },
          onPanStart: (details) {
            if (width > 0) {
              _sliderValueNotifier.value = (details.localPosition.dx / width).clamp(0.0, 1.0);
            }
          },
          child: ValueListenableBuilder<double>(
            valueListenable: _sliderValueNotifier,
            builder: (context, value, child) {
              return SizedBox(
                width: width,
                height: widget.height,
                child: Stack(
                  children: [
                    // After Image (Base) - Constrained to full width
                    SizedBox(
                      width: width,
                      height: widget.height,
                      child: _afterImage,
                    ),

                    // Before Image (Revealed from Left) - Constrained to full width then clipped
                    ClipRect(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: value,
                        child: SizedBox(
                          width: width,
                          height: widget.height,
                          child: _beforeImage,
                        ),
                      ),
                    ),

                    // Divider Line
                    Positioned(
                      left: (width * value).clamp(0.0, width) - 1,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 2,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),

                    // Slider Handle (Circle with Arrows)
                    Positioned(
                      left: (width * value).clamp(0.0, width) - 20,
                      top: (widget.height / 2) - 20,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                          border: Border.all(color: Colors.white, width: 2.5),
                        ),
                        child: const Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_left_rounded, color: Colors.white, size: 16),
                              Icon(Icons.arrow_right_rounded, color: Colors.white, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Labels
                    Positioned(
                      left: 15,
                      top: 15,
                      child: _buildLabel('Before'),
                    ),
                    Positioned(
                      right: 15,
                      top: 15,
                      child: _buildLabel('After'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
