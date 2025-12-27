import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../../../Core/utiles/Colors.dart';
import '../../../../../../../generated/l10n.dart';
import '../ProductDetailsPage.dart';
import 'RelatedDataProvider.dart';
import '../RelatedPage.dart';

class RelatedSection extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  const RelatedSection({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  State<RelatedSection> createState() => _RelatedSectionState();
}

class _RelatedSectionState extends State<RelatedSection> {
  bool isLoading = true;
  late List<Map<String, dynamic>> relatedItems;

  @override
  void initState() {
    super.initState();
    relatedItems = RelatedDataProvider.getRelatedData();

    // Simulate loading for 2 seconds
    Timer(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===== Header =====
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              S.of(context).relatedItems,
              style: TextStyle(
                fontSize: widget.screenWidth * 0.035,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RelatedPage(items: relatedItems),
                  ),
                );
              },
              child: Text(
                S.of(context).seeMore,
                style: TextStyle(
                  fontSize: widget.screenWidth * 0.03,
                  fontWeight: FontWeight.bold,
                  color: KprimaryColor,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: widget.screenHeight * 0.01),

        // ===== Content Area =====
        SizedBox(
          height: widget.screenWidth * 0.65,
          child: isLoading
              ? ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (_, __) =>
                SizedBox(width: widget.screenWidth * 0.04),
            itemBuilder: (_, __) => Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: widget.screenWidth * 0.45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(widget.screenWidth * 0.03),
                ),
              ),
            ),
          )
              : ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: relatedItems.length,
            separatorBuilder: (_, __) =>
                SizedBox(width: widget.screenWidth * 0.04),
            itemBuilder: (_, index) {
              final item = relatedItems[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetails(ad: item),
                    ),
                  );
                },
                // ===== Direction fixed RTL inside container =====
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Container(
                    width: widget.screenWidth * 0.45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(widget.screenWidth * 0.03),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft:
                            Radius.circular(widget.screenWidth * 0.03),
                            topRight:
                            Radius.circular(widget.screenWidth * 0.03),
                          ),
                          child: Image.asset(
                            item['images'][0],
                            width: double.infinity,
                            height: widget.screenWidth * 0.4,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(widget.screenWidth * 0.025),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                style: TextStyle(
                                  fontSize: widget.screenWidth * 0.035,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: widget.screenHeight * 0.005),
                              Text(
                                item['description'],
                                style: TextStyle(
                                  fontSize: widget.screenWidth * 0.03,
                                  color: Colors.grey[700],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: widget.screenHeight * 0.005),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "${item['price']} ${item['currency']}",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: widget.screenWidth * 0.035,
                                    color: const Color(0xffFF580E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
