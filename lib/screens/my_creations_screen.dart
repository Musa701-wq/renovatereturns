import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import '../utils/theme.dart';
import '../widgets/full_screen_view.dart';
import '../widgets/loading_overlay.dart';

class MyCreationsScreen extends StatefulWidget {
  const MyCreationsScreen({super.key});

  @override
  State<MyCreationsScreen> createState() => _MyCreationsScreenState();
}

class _MyCreationsScreenState extends State<MyCreationsScreen> {
  Future<void> _deleteImage(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('images').doc(docId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Creation removed successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing creation: $e')),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Delete Creation'),
        content: const Text('Are you sure you want to remove this masterpiece?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text('Cancel', style: TextStyle(color: Colors.grey))
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteImage(docId);
            }, 
            child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  Future<void> _shareToCommunity(String docId, bool isPublic) async {
    if (isPublic) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This creation is already public!')),
      );
      return;
    }

    try {
      LoadingOverlay.show(context, message: 'Publishing to Community...');
      await FirebaseFirestore.instance.collection('images').doc(docId).update({
        'isPublic': true,
      });
      if (mounted) {
        LoadingOverlay.hide(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your masterpiece is now live in the community!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        LoadingOverlay.hide(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final uid = auth.getFirebaseUser()?.uid;

    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        toolbarHeight: AppTheme.appBarHeight(context),
        foregroundColor: AppTheme.primaryColor,
        backgroundColor: AppTheme.secondaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: AppTheme.appBarIconTheme(context),
        title: Text(
          "My Creations",
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
          child: uid == null 
            ? const Center(child: Text("Please login to see creations"))
            : _buildImageGrid(context, uid),
        ),
      ),
    );
  }

  Widget _buildImageGrid(BuildContext context, String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('images')
          .where('uid', isEqualTo: uid)
          .where('type', isEqualTo: 'generation')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CupertinoActivityIndicator(radius: 16));
        }
        
        if (snapshot.hasError) return const Center(child: Text("Error loading creations"));
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_outlined, size: 64, color: AppTheme.primaryColor.withOpacity(0.2)),
                const SizedBox(height: 16),
                Text('No creations yet.', 
                  style: TextStyle(color: AppTheme.primaryColor.withOpacity(0.4), fontSize: 18)),
              ],
            ),
          );
        }

        final docs = snapshot.data!.docs.toList();
        docs.sort((a, b) {
          final aTime = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
          final bTime = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime);
        });

        final screenWidth = MediaQuery.of(context).size.width;
        final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
        final isTablet = screenWidth >= 600 && screenWidth < 1024;
        final isDesktop = screenWidth >= 1024;

        int getCrossAxisCount() {
          if (isDesktop) return 3;
          if (isTablet) return 2;
          return 2;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: getCrossAxisCount(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: isPortrait ? 0.8 : 0.9, 
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final url = data['url'] as String?;

            if (url == null) return const SizedBox.shrink();

            return Stack(
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (_) => FullScreenImageView(
                        imageUrl: url, 
                        title: "My Creation",
                        description: 'AI Generated Masterpiece',
                      ),
                    ),
                  ),
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
                        width: double.infinity,
                        height: double.infinity,
                        placeholder: (context, url) => Container(
                          color: AppTheme.primaryColor.withOpacity(0.05),
                          child: const Center(child: CupertinoActivityIndicator()),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'share') {
                        _shareToCommunity(doc.id, data['isPublic'] ?? false);
                      } else if (value == 'delete') {
                        _confirmDelete(context, doc.id);
                      }
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                      ),
                      child: const Icon(Icons.more_vert, color: Colors.white, size: 16),
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(Icons.share, size: 18, color: (data['isPublic'] ?? false) ? Colors.grey : AppTheme.primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              (data['isPublic'] ?? false) ? 'Already Shared' : 'Share to Community',
                              style: TextStyle(color: (data['isPublic'] ?? false) ? Colors.grey : null),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red, size: 18),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
