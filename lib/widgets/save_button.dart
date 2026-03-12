/*
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../ads/ad_helper.dart';
import '../utils/theme.dart';

class SaveButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double? height;
  final double? width;
  final String adKey;

  const SaveButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    this.label = 'Save',
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.height,
    this.width,
    this.adKey = 'saveAd',
  });

  @override
  State<SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton> {
  RewardedAd? _rewardedAd;
  bool _isAdLoading = false;
  bool _showAdBeforeSave = true;

  @override
  void initState() {
    super.initState();
    _loadRewardedAd();
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }

  void _loadRewardedAd() {
    setState(() {
      _isAdLoading = true;
    });

    _rewardedAd?.dispose();

    RewardedAd.load(
      adUnitId: AdHelper.getRewarded(widget.adKey),
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          setState(() {
            _rewardedAd = ad;
            _isAdLoading = false;
          });

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              print('Failed to show ad: $error');
              ad.dispose();
              _loadRewardedAd();
              _executeSaveFunctionality();
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('Failed to load rewarded ad: $error');
          setState(() {
            _isAdLoading = false;
          });
        },
      ),
    );
  }

  void _showRewardedAd() {
    if (_rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          print('User earned reward: ${reward.amount} ${reward.type}');
          _executeSaveFunctionality();
        },
      );
    } else {
      _executeSaveFunctionality();
    }
  }

  void _executeSaveFunctionality() {
    widget.onPressed();
  }

  void _handleButtonPress() {
    if (widget.isLoading || _isAdLoading) return;

    if (_showAdBeforeSave && _rewardedAd != null) {
      _showRewardedAd();
    } else {
      _executeSaveFunctionality();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isProcessing = widget.isLoading || _isAdLoading;
    final String buttonLabel = isProcessing
        ? (_isAdLoading ? 'Loading Ad...' : 'Saving...')
        : widget.label;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: widget.borderColor ?? AppTheme.primaryColor,
            width: 2,
          ),
        ),
        child: ElevatedButton.icon(
          onPressed: isProcessing ? null : _handleButtonPress,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.backgroundColor ?? AppTheme.primaryColor,
            foregroundColor: widget.foregroundColor ?? AppTheme.secondaryColor,
            disabledBackgroundColor: (widget.backgroundColor ?? AppTheme.primaryColor).withOpacity(0.6),
            disabledForegroundColor: (widget.foregroundColor ?? AppTheme.secondaryColor).withOpacity(0.6),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
            elevation: 0,
            minimumSize: Size(widget.width ?? 0, widget.height ?? 0),
            maximumSize: Size(widget.width ?? double.infinity, widget.height ?? double.infinity),
          ),
          icon: isProcessing
              ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: widget.foregroundColor ?? AppTheme.secondaryColor,
            ),
          )
              : const Icon(Icons.save_alt),
          label: Text(
            buttonLabel,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}*/import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/Ad_provider.dart';
import '../utils/theme.dart';

class SaveButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double? height;
  final double? width;

  const SaveButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    this.label = 'Save',
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.height,
    this.width,
  });

  @override
  State<SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton> {
  @override
  void initState() {
    super.initState();
    // Preload rewarded ad
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adProvider = context.read<AdProvider>();
      if (!adProvider.isRewardedAdLoaded && !adProvider.isLoadingRewardedAd) {
        adProvider.loadRewardedAd();
      }
    });
  }

  Future<void> _handleButtonPress() async {
    final adProvider = context.read<AdProvider>();

    if (adProvider.isRewardedAdLoaded) {
      // Show ad first
      await adProvider.showRewardedAd();
    }

    // Execute save (whether ad shown or not)
    if (mounted) {
      widget.onPressed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdProvider>(
      builder: (context, adProvider, _) {
        final bool isProcessing = widget.isLoading || adProvider.isLoadingRewardedAd;
        final String buttonLabel = isProcessing
            ? (adProvider.isLoadingRewardedAd ? 'Loading Ad...' : 'Saving...')
            : widget.label;

        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: widget.borderColor ?? AppTheme.primaryColor,
                width: 2,
              ),
            ),
            child: ElevatedButton.icon(
              onPressed: isProcessing ? null : _handleButtonPress,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.backgroundColor ?? AppTheme.primaryColor,
                foregroundColor: widget.foregroundColor ?? AppTheme.secondaryColor,
                disabledBackgroundColor: (widget.backgroundColor ?? AppTheme.primaryColor).withOpacity(0.6),
                disabledForegroundColor: (widget.foregroundColor ?? AppTheme.secondaryColor).withOpacity(0.6),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                elevation: 0,
                minimumSize: Size(widget.width ?? 0, widget.height ?? 0),
                maximumSize: Size(widget.width ?? double.infinity, widget.height ?? double.infinity),
              ),
              icon: isProcessing
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: widget.foregroundColor ?? AppTheme.secondaryColor,
                ),
              )
                  : const Icon(Icons.save_alt),
              label: Text(
                buttonLabel,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        );
      },
    );
  }
}