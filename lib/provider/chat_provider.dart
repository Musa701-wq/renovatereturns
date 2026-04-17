import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/api_services.dart';
import '../models/message.dart';

class ChatProvider extends ChangeNotifier {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  List<Message> messages = [];
  bool isLoading = false;
  final String _userId;

  // ⚠️ TESTING BYPASS — set to false before release
  static const bool _testModeBypassCredits = true; // Use true if user wants to bypass, or false

  ChatProvider({String? userId})
      : _userId = userId ?? FirebaseAuth.instance.currentUser?.uid ?? "guest" {
    _listenToMessages();
  }

  void _listenToMessages() {
    _dbRef.child("chats/\$_userId").onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        messages = data.values
            .map((e) => Message.fromMap(Map<String, dynamic>.from(e)))
            .toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
        notifyListeners();
      }
    });
  }

  Future<void> sendMessage(String text) async {
    // Generate Firebase push key instead of UUID
    final userMsgId = _dbRef.child("chats/\$_userId").push().key!;

    final userMsg = Message(
      id: userMsgId,
      role: "user",
      text: text,
      timestamp: DateTime.now(),
    );
    _saveMessage(userMsg);

    isLoading = true;
    notifyListeners();

    try {
      // Check credits first
      if (!_testModeBypassCredits) {
        final currentCredits = await getCredits();
        final isPro = await _isProUser();
        
        if (!isPro && currentCredits <= 0) {
          throw Exception("INSUFFICIENT_CREDITS");
        }
      }

      final replyText = await GeminiService.chatMessage(userMessage: text);

      if (!_testModeBypassCredits) {
        final isPro = await _isProUser();
        if (!isPro) await _deductCredit();
      }

      final aiMsgId = _dbRef.child("chats/\$_userId").push().key!;
      final aiMsg = Message(
        id: aiMsgId,
        role: "ai",
        text: replyText,
        timestamp: DateTime.now(),
      );
      _saveMessage(aiMsg);
    } catch (e) {
      final errMsgId = _dbRef.child("chats/\$_userId").push().key!;
      final errMsg = Message(
        id: errMsgId,
        role: "ai",
        text: "Error: \${e.toString()}",
        timestamp: DateTime.now(),
      );
      _saveMessage(errMsg);
    }

    isLoading = false;
    notifyListeners();
  }

  void _saveMessage(Message message) {
    _dbRef.child("chats/\$_userId/\${message.id}").set(message.toMap());
  }

  Future<int> getCredits() async {
    try {
      final snapshot = await _dbRef.child("users/\$_userId/credits").get();
      if (!snapshot.exists) return 0;
      final data = snapshot.value;
      if (data is int) return data;
      if (data is Map) return (data['amount'] as num?)?.toInt() ?? 0;
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<bool> _isProUser() async {
    try {
      final snapshot = await _dbRef.child("users/\$_userId/isPro").get();
      return snapshot.exists && snapshot.value == true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _deductCredit() async {
    try {
      final ref = _dbRef.child("users/\$_userId");
      final snapshot = await ref.get();
      if (!snapshot.exists) return;

      final data = snapshot.value as Map<dynamic, dynamic>;
      int currentCredits = await getCredits();
      final newCredits = (currentCredits - 1).clamp(0, currentCredits);

      if (data['credits'] is int) {
        await ref.child('credits').set(newCredits);
      } else {
        await ref.child('credits/amount').set(newCredits);
      }
    } catch (e) {
      print("Error deducting chat credit: \$e");
    }
  }
}
