import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import '../utils/theme.dart';
import '../widgets/full_screen_view.dart';
import 'dart:convert';

class OtherUserProfileScreen extends StatelessWidget {
  final String uid;
  final String userName;
  final String? photoUrl;

  const OtherUserProfileScreen({
    super.key,
    required this.uid,
    required this.userName,
    this.photoUrl,
  });

  Widget _buildProfileImage(String? photoData) {
    if (photoData == null || photoData.isEmpty) {
      return CircleAvatar(
        radius: 40,
        backgroundColor: AppTheme.primaryColor.withOpacity(0.3),
        child: Icon(Icons.person, size: 40, color: AppTheme.primaryColor),
      );
    }

    try {
      bool isBase64 = photoData.startsWith('/9j/') ||
          photoData.startsWith('iVBORw0KGgo') ||
          photoData.length > 1000;

      if (isBase64) {
        return CircleAvatar(
          radius: 40,
          backgroundImage: MemoryImage(base64Decode(photoData)),
        );
      } else {
        return CircleAvatar(
          radius: 40,
          backgroundImage: NetworkImage(photoData),
        );
      }
    } catch (e) {
      return CircleAvatar(
        radius: 40,
        backgroundColor: AppTheme.primaryColor.withOpacity(0.3),
        child: Icon(Icons.person, size: 40, color: AppTheme.primaryColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        toolbarHeight: AppTheme.appBarHeight(context),
        foregroundColor: AppTheme.primaryColor,
        backgroundColor: AppTheme.secondaryColor,
        iconTheme: AppTheme.appBarIconTheme(context),
        title: Text(
          userName,
          style: AppTheme.appBarTitleStyle(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.secondaryColor,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),
              // User Header
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: _buildProfileImage(photoUrl),
              ),
              const SizedBox(height: 16),
              Text(
                userName,
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: AppTheme.responsiveFont(context, phone: 24, tablet: 32),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'AI Space Designer',
                style: TextStyle(
                  color: AppTheme.primaryColor.withOpacity(0.5),
                  fontSize: AppTheme.responsiveFont(context, phone: 14, tablet: 18),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'CREATIONS',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Divider(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        thickness: 3.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              
              // User's Creations Grid
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('images')
                      .where('uid', isEqualTo: uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CupertinoActivityIndicator(radius: 16));
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_outlined, size: 64, color: AppTheme.primaryColor.withOpacity(0.2)),
                            const SizedBox(height: 16),
                            Text(
                              'No creations yet.',
                              style: TextStyle(color: AppTheme.primaryColor.withOpacity(0.6)),
                            ),
                          ],
                        ),
                      );
                    }
  
                    final rawDocs = snapshot.data!.docs.toList();
                    rawDocs.sort((a, b) {
                      final aData = a.data() as Map<String, dynamic>;
                      final bData = b.data() as Map<String, dynamic>;
                      final aTime = aData['createdAt'] as Timestamp?;
                      final bTime = bData['createdAt'] as Timestamp?;
                      if (aTime == null && bTime == null) return 0;
                      if (aTime == null) return 1;
                      if (bTime == null) return -1;
                      return bTime.compareTo(aTime);
                    });
  
                    final screenWidth = MediaQuery.of(context).size.width;
                    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
                    final isTablet = screenWidth >= 600 && screenWidth < 1024;
                    final isDesktop = screenWidth >= 1024;
                    final isLargeDesktop = screenWidth >= 1200;
  
                    int getCrossAxisCount() {
                      if (isLargeDesktop) return 4;
                      if (isDesktop) return 3;
                      if (isTablet) return 2;
                      return 2;
                    }
  
                    double getGridSpacing() {
                      if (isDesktop) return 16.0;
                      if (isTablet) return 12.0;
                      return 8.0;
                    }
  
                    EdgeInsets getPadding() {
                      if (isDesktop) return const EdgeInsets.all(20.0);
                      if (isTablet) return const EdgeInsets.all(16.0);
                      return const EdgeInsets.all(12.0);
                    }
  
                    double getChildAspectRatio() {
                      if (isDesktop) return isPortrait ? 0.85 : 1.0;
                      return isPortrait ? 0.8 : 0.9;
                    }
  
                    final docs = rawDocs;
  
                    return GridView.builder(
                      padding: getPadding(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: getCrossAxisCount(),
                        crossAxisSpacing: getGridSpacing(),
                        mainAxisSpacing: getGridSpacing(),
                        childAspectRatio: getChildAspectRatio(), 
                      ),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final url = data['url'] as String?;
  
                        if (url == null) return const SizedBox.shrink();
  
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FullScreenImageView(
                                  imageUrl: url,
                                  title: "${userName}'s Creation",
                                  description: 'AI Generated Masterpiece',
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                AppTheme.responsiveSize(context, phone: 15, tablet: 20),
                              ),
                              border: Border.all(
                                color: AppTheme.primaryColor,
                                width: AppTheme.responsiveSize(context, phone: 3, tablet: 4),
                              ),
                              color: AppTheme.tilescolor,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppTheme.responsiveSize(context, phone: 12, tablet: 16),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: url,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: AppTheme.primaryColor.withOpacity(0.05),
                                  child: const Center(child: CupertinoActivityIndicator()),
                                ),
                                errorWidget: (context, url, _) => Icon(
                                  Icons.image_not_supported, 
                                  color: AppTheme.primaryColor.withOpacity(0.3)
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
