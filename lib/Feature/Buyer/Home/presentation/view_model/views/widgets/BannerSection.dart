import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../../../../Core/Widgets/buildImageError.dart';
import 'ImageHome.dart';
import 'ShimmerContainer.dart';

class BannerSection extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final List<String> banners;
  final bool isLoading;
  final bool hasError;

  const BannerSection({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.banners,
    this.isLoading = false,
    this.hasError = false,
  });

  @override
  State<BannerSection> createState() => _BannerSectionState();
}

class _BannerSectionState extends State<BannerSection> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoFade();
  }

  @override
  void didUpdateWidget(covariant BannerSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banners != widget.banners) {
      _startAutoFade();
    }
  }

  void _startAutoFade() {
    _timer?.cancel();
    if (widget.banners.length <= 1) return;

    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.banners.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int _getVisibleDotsCount() {
    final totalBanners = widget.banners.length;
    if (totalBanners == 0) return 0;
    return totalBanners > 3 ? 3 : totalBanners;
  }

  int _getDotIndex(int dotPosition) {
    final totalBanners = widget.banners.length;
    if (totalBanners <= 3) return dotPosition;

    if (_currentIndex == 0) {
      return dotPosition;
    } else if (_currentIndex == totalBanners - 1) {
      return totalBanners - 3 + dotPosition;
    } else {
      return _currentIndex - 1 + dotPosition;
    }
  }

  bool _isDotActive(int dotPosition) {
    final dotIndex = _getDotIndex(dotPosition);
    return dotIndex == _currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return ShimmerContainer(
        height: widget.screenWidth * 0.4,
        width: double.infinity,
        radius: widget.screenWidth * 0.03,
      );
    }

    if (widget.hasError || widget.banners.isEmpty) {
      return buildImageErrorPlaceholder(
        context,
        widget.screenWidth,
        widget.screenWidth * 0.4,
      );
    }

    return Column(
      children: [
        SizedBox(
          height: widget.screenWidth * 0.4,
          child: Stack(
            children: widget.banners.asMap().entries.map((entry) {
              int idx = entry.key;
              String url = entry.value;
              final validUrl = ImageHome.getValidImageUrl(url);
              return AnimatedOpacity(
                opacity: _currentIndex == idx ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.screenWidth * 0.03),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: CachedNetworkImage(
                    imageUrl: validUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    placeholder: (context, url) => ShimmerContainer(
                      height: widget.screenWidth * 0.4,
                      width: double.infinity,
                      radius: widget.screenWidth * 0.03,
                    ),
                    errorWidget: (context, url, error) {
                      return buildImageErrorPlaceholder(
                        context,
                        widget.screenWidth/2,
                        widget.screenWidth * 0.4/2,
                      );
                    },
                    httpHeaders: {
                      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
                      'Accept': 'image/*',
                      'Referer': 'https://toknagah.viking-iceland.online/',
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: widget.screenHeight * 0.015),
        _buildDotsIndicator(),
      ],
    );
  }

  Widget _buildDotsIndicator() {
    final visibleDotsCount = _getVisibleDotsCount();

    if (visibleDotsCount <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(visibleDotsCount, (index) {
        final isActive = _isDotActive(index);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: widget.screenWidth * 0.01),
          width: isActive ? widget.screenWidth * 0.06 : widget.screenWidth * 0.02, // غيرت القيمة للغير شغالة
          height: widget.screenWidth * 0.02,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xffFF580E) : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(widget.screenWidth), // بدل circle عشان الشكل يكون مستدير حتى لو أكبر عرض
          ),
        );
      }),
    );
  }
}
