import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import '../utils/theme.dart';
import '../widgets/full_screen_view.dart';
import 'other_user_profile_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  // Cache for user profiles to avoid redundant Firestore fetches during scroll
  static final Map<String, Map<String, dynamic>> _userCache = {};
  
  // Ephemeral Cache: Persistent Stream Subscription and Local List
  StreamSubscription<QuerySnapshot>? _streamSubscription;
  List<DocumentSnapshot> _images = [];
  bool _isLoading = true;
  String? _error;

  // Filter State
  bool _showOnlyFavorites = false;

  @override
  void initState() {
    super.initState();
    _setupStream();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  void _setupStream() {
    _streamSubscription = FirebaseFirestore.instance
        .collection('images')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          // Local Filter: Only show public images in Community Feed
          _images = snapshot.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['isPublic'] == true;
          }).toList();
          
          _isLoading = false;
          _error = null;
        });
      }
    }, onError: (err) {
      if (mounted) {
        setState(() {
          _error = 'Error loading feed';
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
          "Community Feed",
          style: AppTheme.appBarTitleStyle(context),
        ),
        actions: [
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildBody(getCrossAxisCount, getGridSpacing, getPadding, getChildAspectRatio),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    int Function() getCrossAxisCount,
    double Function() getGridSpacing,
    EdgeInsets Function() getPadding,
    double Function() getChildAspectRatio
  ) {
    if (_isLoading && _images.isEmpty) {
      return const Center(child: CupertinoActivityIndicator(radius: 16));
    }

    if (_error != null && _images.isEmpty) {
      return Center(
        child: Text(_error!, style: TextStyle(color: AppTheme.primaryColor.withOpacity(0.6))),
      );
    }

    if (_images.isEmpty) {
      return Center(
        child: Text('No creations yet.', style: TextStyle(color: AppTheme.primaryColor.withOpacity(0.6))),
      );
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final currentUid = auth.getFirebaseUser()?.uid;

    // Filter images based on favorites toggle
    final filteredImages = _showOnlyFavorites 
        ? _images.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final List favBy = data['favBy'] ?? [];
            return favBy.contains(currentUid);
          }).toList()
        : _images;

    if (filteredImages.isEmpty && _showOnlyFavorites) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, color: AppTheme.primaryColor.withOpacity(0.3), size: 64),
            const SizedBox(height: 16),
            Text(
              'No favorites yet.',
              style: TextStyle(
                color: AppTheme.primaryColor.withOpacity(0.6),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Support the community by liking creations!',
              style: TextStyle(
                color: AppTheme.primaryColor.withOpacity(0.4),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: getPadding(),
      addAutomaticKeepAlives: true,
      cacheExtent: 2000, 
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: getCrossAxisCount(),
        crossAxisSpacing: getGridSpacing(),
        mainAxisSpacing: getGridSpacing(),
        childAspectRatio: getChildAspectRatio(), 
      ),
      itemCount: filteredImages.length,
      itemBuilder: (context, index) {
        final doc = filteredImages[index];
        final data = doc.data() as Map<String, dynamic>;
        final url = data['url'] as String?;
        final uid = data['uid'] as String?;
        final List favBy = data['favBy'] ?? [];
        
        if (url == null || uid == null) return const SizedBox.shrink();

        return RepaintBoundary(
          child: _CommunityGridItem(
            key: ValueKey(doc.id),
            url: url,
            uid: uid,
            docId: doc.id,
            favBy: favBy,
            userCache: _userCache,
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppTheme.responsiveSize(context, phone: 20, tablet: 30),
        10,
        AppTheme.responsiveSize(context, phone: 20, tablet: 30),
        20
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: AppTheme.primaryColor, size: AppTheme.responsiveSize(context, phone: 20, tablet: 24)),
                  const SizedBox(width: 8),
                  Text(
                    'THE CURATED FEED',
                    style: TextStyle(
                      color: AppTheme.primaryColor.withOpacity(0.6),
                      fontSize: AppTheme.responsiveFont(context, phone: 12, tablet: 14),
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // Favorites Toggle Button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showOnlyFavorites = !_showOnlyFavorites;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _showOnlyFavorites ? AppTheme.primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(_showOnlyFavorites ? 1.0 : 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _showOnlyFavorites ? Icons.favorite : Icons.favorite_border,
                        color: _showOnlyFavorites ? Colors.white : AppTheme.primaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Favorites',
                        style: TextStyle(
                          color: _showOnlyFavorites ? Colors.white : AppTheme.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _showOnlyFavorites ? 'My Loved Pieces' : 'Ethereal Creations',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: AppTheme.responsiveFont(context, phone: 32, tablet: 36),
              height: 1.1,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _showOnlyFavorites 
              ? 'Your personal collection of favorited AI art.'
              : 'A high-definition sanctuary for the world\'s\nmost sophisticated AI masterpieces.',
            style: TextStyle(
              color: AppTheme.primaryColor.withOpacity(0.7),
              fontSize: AppTheme.responsiveFont(context, phone: 14, tablet: 18),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Divider(
            color: AppTheme.primaryColor.withOpacity(0.1),
            thickness: 1.5,
          ),
        ],
      ),
    );
  }
}

class _CommunityGridItem extends StatefulWidget {
  final String url;
  final String uid;
  final String docId;
  final List favBy;
  final Map<String, Map<String, dynamic>> userCache;

  const _CommunityGridItem({
    required Key key,
    required this.url,
    required this.uid,
    required this.docId,
    required this.favBy,
    required this.userCache,
  }) : super(key: key);

  @override
  State<_CommunityGridItem> createState() => _CommunityGridItemState();
}

class _CommunityGridItemState extends State<_CommunityGridItem> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; 

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    if (widget.userCache.containsKey(widget.uid)) {
      final userData = widget.userCache[widget.uid]!;
      return _buildUI(userData['name'] ?? 'Unknown', userData['photoUrl']);
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(widget.uid).get(),
      builder: (context, snapshot) {
        String userName = 'Unknown';
        String? photoUrl;

        if (snapshot.hasData && snapshot.data!.exists) {
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          userName = userData['name'] ?? 'Unknown';
          photoUrl = userData['photoUrl'];
          widget.userCache[widget.uid] = userData;
        }

        return _buildUI(userName, photoUrl);
      },
    );
  }

  Widget _buildUI(String userName, String? photoUrl) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final currentUid = auth.getFirebaseUser()?.uid;
    final bool isFavorited = widget.favBy.contains(currentUid);

    return Container(
      margin: EdgeInsets.all(AppTheme.responsiveSize(context, phone: 2, tablet: 4)),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FullScreenImageView(
                imageUrl: widget.url,
                title: "${userName}'s Creation",
                description: 'AI Generated Masterpiece',
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.responsiveSize(context, phone: 15, tablet: 20)),
            border: Border.all(
              color: AppTheme.primaryColor,
              width: AppTheme.responsiveSize(context, phone: 3, tablet: 4),
            ),
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
            borderRadius: BorderRadius.circular(AppTheme.responsiveSize(context, phone: 12, tablet: 16)),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: widget.url,
                  fit: BoxFit.cover,
                  memCacheWidth: 400, 
                  placeholder: (context, url) => Container(
                    color: AppTheme.primaryColor.withOpacity(0.05),
                    child: const Center(child: CupertinoActivityIndicator()),
                  ),
                  errorWidget: (context, url, _) => Icon(
                    Icons.image_not_supported, 
                    color: AppTheme.primaryColor.withOpacity(0.3)
                  ),
                ),
                Positioned(
                  bottom: 0, left: 0, right: 0, height: 80,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      if (currentUid == null) return;
                      final docRef = FirebaseFirestore.instance.collection('images').doc(widget.docId);
                      if (isFavorited) {
                        docRef.update({'favBy': FieldValue.arrayRemove([currentUid])});
                      } else {
                        docRef.update({'favBy': FieldValue.arrayUnion([currentUid])});
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Icon(
                        isFavorited ? Icons.favorite : Icons.favorite_border,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OtherUserProfileScreen(
                            uid: widget.uid,
                            userName: userName,
                            photoUrl: photoUrl,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (photoUrl != null)
                                Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  width: 22, height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 1),
                                  ),
                                  child: ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: photoUrl, 
                                      fit: BoxFit.cover,
                                      memCacheWidth: 60,
                                    ),
                                  ),
                                )
                              else
                                const Icon(Icons.account_circle, color: Colors.white, size: 22),
                              Text(
                                userName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: AppTheme.responsiveFont(context, phone: 12, tablet: 16),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 2,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
