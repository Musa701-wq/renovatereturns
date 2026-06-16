import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../utils/theme.dart';

class ExceptionHandler {
  /// Displays a brief message to the user using a toast notification.
  static void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.black.withOpacity(0.8),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  /// Displays a success message to the user.
  static void showSuccess(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.green.withOpacity(0.9),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  /// Handles an exception by logging it and showing a toast message to the user.
  static void handleException(dynamic exception) {
    debugPrint('⚠️ [ExceptionHandler] Caught exception: $exception');
    
    String message = 'An unexpected error occurred';
    
    if (exception is String) {
      message = exception;
    } else if (exception is Exception) {
      message = exception.toString().replaceFirst('Exception: ', '');
    } else {
      message = exception.toString();
    }

    // Filter out some technical details if possible
    if (message.contains('XMLHttpRequest error')) {
      message = 'Network error: Please check your connection';
    } else if (message.contains('FirebaseException')) {
      message = 'Database error: Please try again later';
    }

    showToast(message);
  }
}