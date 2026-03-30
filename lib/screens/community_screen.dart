import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import '../utils/theme.dart';
import '../widgets/full_screen_view.dart';
import 'dart:typed_data';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  String _selectedCategory = 'ALL FEED';
  
  final List<String> _categories = [
    'ALL FEED',
    'ABSTRACT',
    'PORTRAIT',
    'INTERIOR',
    'EXTERIOR'
  ];

  final List<String> _aestheticTags = [
    'AURALENS',
    'SPIRITAI',
    'PIXELMUSE',
    'ICEQUEEN',
    'NOVA_GEN',
    'STRUCTUREAI'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildCategoryFilters(),
            Expanded(
              child: _buildImageGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'THE CURATED FEED',
            style: TextStyle(
              color: AppTheme.primaryColor.withOpacity(0.6),
              fontSize: 12,
              letterSpacing: 2.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ethereal\nCreations',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 36,
              height: 1.1,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'A high-definition sanctuary for the world\'s\nmost sophisticated AI masterpieces.',
            style: TextStyle(
              color: AppTheme.primaryColor.withOpacity(0.7),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppTheme.primaryColor.withOpacity(0.8) 
                    : AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? AppTheme.secondaryColor : AppTheme.primaryColor.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageGrid() {
    return StreamBuilder<QuerySnapshot>(
      // We order by createdAt. Note: Requires a matching composite index if filtering further.
      stream: FirebaseFirestore.instance
          .collection('images')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CupertinoActivityIndicator(radius: 16),
          );
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading feed',
              style: TextStyle(color: AppTheme.primaryColor.withOpacity(0.6)),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No creations yet.',
              style: TextStyle(color: AppTheme.primaryColor.withOpacity(0.6)),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 0.85, 
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final url = data['url'] as String?;
            
            // Cycle through tags
            final tagName = _aestheticTags[index % _aestheticTags.length];

            if (url == null) return const SizedBox.shrink();

            return _buildGridItem(url, tagName);
          },
        );
      },
    );
  }

  Widget _buildGridItem(String url, String tagName) {
    return GestureDetector(
      onTap: () {
        // Open fullscreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FullScreenImageView(
              imageUrl: url,
              title: 'Creation',
              description: 'AI Generated Masterpiece',
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: AppTheme.tilescolor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image Phase
              CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppTheme.primaryColor.withOpacity(0.05),
                  child: const Center(
                    child: CupertinoActivityIndicator(),
                  ),
                ),
                errorWidget: (context, url, _) => Icon(
                  Icons.image_not_supported, 
                  color: AppTheme.primaryColor.withOpacity(0.3)
                ),
              ),

              // Gradient Overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 80,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),

              // Glassmorphic Tag
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    tagName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
