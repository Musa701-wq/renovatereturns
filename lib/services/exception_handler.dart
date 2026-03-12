// utils/exception_handler.dart
// ✅ YEH FILE CREATE KAREIN - utils folder mein

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ExceptionHandler {
  // ✅ USER-FRIENDLY ERROR MESSAGES
  static String getUserFriendlyMessage(dynamic error) {
    String errorString = error.toString().toLowerCase();

    // Network/Internet errors
    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('internet') ||
        errorString.contains('socket') ||
        errorString.contains('failed host lookup')) {
      return 'No internet connection';
    }

    // Timeout errors
    if (errorString.contains('timeout') || errorString.contains('timed out')) {
      return 'Request timed out. Try again';
    }

    // Server errors
    if (errorString.contains('500') || errorString.contains('server error')) {
      return 'Server error. Try later';
    }

    // API/Service errors
    if (errorString.contains('api') || errorString.contains('service')) {
      return 'Service unavailable';
    }

    // Authentication errors
    if (errorString.contains('unauthorized') || errorString.contains('403')) {
      return 'Authentication failed';
    }

    // File/Image errors
    if (errorString.contains('file') || errorString.contains('image')) {
      return 'Image processing failed';
    }

    // Camera/Gallery errors
    if (errorString.contains('camera')) {
      return 'Camera not available';
    }

    if (errorString.contains('gallery')) {
      return 'Gallery not available';
    }

    // Credit errors
    if (errorString.contains('credit')) {
      return 'Insufficient credits';
    }

    // Selection errors - Room Design
    if (errorString.contains('select a room type')) {
      return 'Please select room type';
    }

    if (errorString.contains('select a style')) {
      return 'Please select design style';
    }

    if (errorString.contains('select a budget')) {
      return 'Please select budget';
    }

    if (errorString.contains('select an image')) {
      return 'Please upload an image';
    }

    // Selection errors - Floor Design
    if (errorString.contains('select a floor')) {
      return 'Please select floor type';
    }

    // Selection errors - Wall Design
    if (errorString.contains('select a wall')) {
      return 'Please select wall type';
    }

    // Selection errors - Exterior Design
    if (errorString.contains('select an exterior')) {
      return 'Please select exterior style';
    }

    // Selection errors - Object Remove/Replace
    if (errorString.contains('provide replacement')) {
      return 'Please provide instructions';
    }

    if (errorString.contains('provide fill space')) {
      return 'Please provide fill instructions';
    }

    // Reference Transform errors
    if (errorString.contains('reference image')) {
      return 'Please select reference image';
    }

    if (errorString.contains('target image')) {
      return 'Please select target image';
    }

    // Default friendly message
    return 'Something went wrong';
  }

  // ✅ SHOW TOAST MESSAGE (Simple)
  static void showToast(String message, {bool isError = true}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  // ✅ HANDLE EXCEPTION (Automatic message + toast)
  static void handleException(dynamic error, {String? customMessage}) {
    String message = customMessage ?? getUserFriendlyMessage(error);
    showToast(message, isError: true);

    // Log for debugging
    print('❌ Error: $error');
  }

  // ✅ SHOW SUCCESS TOAST
  static void showSuccess(String message) {
    showToast(message, isError: false);
  }

  // ✅ SHOW INFO TOAST (Neutral - Blue color)
  static void showInfo(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.blue.shade700,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  // ✅ SHOW WARNING TOAST (Yellow/Orange color)
  static void showWarning(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.orange.shade700,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }
}