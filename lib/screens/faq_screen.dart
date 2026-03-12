import 'package:flutter/material.dart';

import '../utils/theme.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  static const List<Map<String, String>> _faqs = [
    {
      'question': 'How do I upload an image for a redesign?',
      'answer':
          'Go to Upload > Select Image Source and either capture a camera shot or pick from the gallery. Once selected, the image fills the card and a preview is shown.',
    },
    {
      'question': 'What kinds of rooms can AI remodel?',
      'answer':
          'You can pick categories like Home Spa, Living Room, Bathroom, Kitchen, or even specialty spaces such as Yoga Studio, Media Room, and Studio setups.',
    },
    {
      'question': 'Is there a way to remove unwanted objects?',
      'answer':
          'Yes, choose the \"Remove Object\" project type from the Generate screen. Upload a reference image and the model will clean the background for you.',
    },
    {
      'question': 'How many credits do I have?',
      'answer':
          'Your profile shows total, used, and remaining credits at the top of the screen. Each generation consumes one credit.',
    },
    {
      'question': 'Can I export or share the final designs?',
      'answer':
          'After generation you can tap the design tile to enter fullscreen, use the built-in Save or Share buttons, or download the image to your device.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        backgroundColor: AppTheme.secondaryColor,
        foregroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: Text('FAQ', style: AppTheme.appBarTitleStyle(context)),
        leading: IconButton(
          icon: Icon(
            AppTheme.backButtonIcon,
            size: AppTheme.backButtonIconSize(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: _faqs.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final faq = _faqs[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  faq['question']!,
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  faq['answer']!,
                  style: TextStyle(
                    color: AppTheme.primaryColor.withOpacity(0.8),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

