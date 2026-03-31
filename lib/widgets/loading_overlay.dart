import 'package:flutter/material.dart';
import '../utils/theme.dart';

class LoadingOverlay {
  static void show(BuildContext context, {String message = 'Generating your design...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: AppTheme.primaryColor.withOpacity(0.85),
      builder: (context) => _LoadingWidget(message: message),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}

class _LoadingWidget extends StatefulWidget {
  final String message;
  const _LoadingWidget({required this.message});

  @override
  State<_LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<_LoadingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.zero,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeTransition(
              opacity: _animation,
              child: Image.asset(
                'assets/images/logo-watermark.png',
                width: 120,
                height: 120,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              widget.message,
              style: TextStyle(
                color: AppTheme.secondaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
