import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../utils/theme.dart';
import '../screens/login_screen.dart';
import '../provider/auth_provider.dart';
import 'package:provider/provider.dart';
import '../in_app_purchase/credit_manager.dart';
import '../in_app_purchase/i_ap_manager.dart';
import '../widgets/credit_dialog.dart';

// Top-level variable for persisting chat history across screen navigations
final List<ChatMessage> _globalChatMessages = [
  ChatMessage(
    text: "Hi! I'm your AI Interior Design Assistant. Looking for decoration suggestions or styling tips? Let me know how I can help you today.",
    isUser: false,
  ),
];

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Scroll to bottom initially
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100, // extra push just in case
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  final List<String> _suggestions = [
    "Modern kitchen ideas",
    "Small room layout tips",
    "Best colors for bedroom",
    "Lighting for office",
    "Minimalist furniture",
  ];

  Future<void> _sendMessage({String? providedMessage}) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.currentUser == null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
      return;
    }

    final creditManager = Provider.of<CreditManager>(context, listen: false);
    if (!creditManager.hasEnoughCredits(1)) {
      CreditDialog.show(
        context,
        'You need at least 1 credit to chat with the AI Assistant.',
        IAPManager().products,
      );
      return;
    }

    final String userMessage = (providedMessage ?? _controller.text).trim();
    if (userMessage.isEmpty) return;

    setState(() {
      _globalChatMessages.add(ChatMessage(text: userMessage, isUser: true));
      _isLoading = true;
    });
    
    if (providedMessage == null) {
      _controller.clear();
    }
    
    // Slight delay to allow list view to rebuild before scrolling
    Future.delayed(const Duration(milliseconds: 100), () => _scrollToBottom());

    try {
      final responseText = await GeminiService.getChatbotResponse(userMessage: userMessage);
      
      // Attempt to deduct credit if successful response
      final bool isError = responseText.toLowerCase().contains('error') || 
                           responseText.contains('Connection trouble') ||
                           responseText.contains('Received empty response');

      if (!isError) {
         await creditManager.deductCredits(1, reason: 'chatbot_message');
      }

      if (mounted) {
        setState(() {
          _globalChatMessages.add(ChatMessage(text: responseText, isUser: false));
        });
        Future.delayed(const Duration(milliseconds: 100), () => _scrollToBottom());
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _globalChatMessages.add(ChatMessage(text: "Sorry, I couldn't process that right now. Please try again later.", isUser: false));
        });
        Future.delayed(const Duration(milliseconds: 100), () => _scrollToBottom());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Design Assistant', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              itemCount: _globalChatMessages.length,
              itemBuilder: (context, index) {
                final message = _globalChatMessages[index];
                final isUser = message.isUser;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!isUser) ...[
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.transparent,
                          child: ClipOval(
                            child: Image.asset('assets/icons/chat-bot.png', width: 24, height: 24, fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          decoration: BoxDecoration(
                            color: isUser ? AppTheme.primaryColor : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: Radius.circular(isUser ? 20 : 4),
                              bottomRight: Radius.circular(isUser ? 4 : 20),
                            ),
                            boxShadow: isUser ? [] : [
                              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))
                            ],
                          ),
                          child: Text(
                            message.text,
                            style: TextStyle(
                              color: isUser ? Colors.white : Colors.black87,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                      if (isUser) const SizedBox(width: 24), // Keep some spacing from left edge
                      if (!isUser) const SizedBox(width: 24), // Keep some spacing from right edge
                    ],
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 48.0, bottom: 16.0),
                child: SizedBox(
                  width: 40, height: 24,
                  child: Center(
                    child: SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor.withOpacity(0.5)),
                    ),
                  ),
                ),
              ),
            ),
          
          // Suggestion Chips
          if (!_isLoading)
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ActionChip(
                      label: Text(
                        _suggestions[index],
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      backgroundColor: Colors.white,
                      surfaceTintColor: Colors.transparent,
                      shape: StadiumBorder(side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.2))),
                      onPressed: () => _sendMessage(providedMessage: _suggestions[index]),
                    ),
                  );
                },
              ),
            ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Ask about design, colors, layouts...',
                          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _sendMessage(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

