import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../generated/l10n.dart';
import '../my_store_cubit.dart';
import '../my_store_state.dart';
import 'MyProductDetailsPage.dart';

class MyStorePage extends StatefulWidget {
  const MyStorePage({super.key});

  @override
  State<MyStorePage> createState() => _MyStorePageState();
}

class _MyStorePageState extends State<MyStorePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: AppBarWithBottomS(title: S.of(context).myStore),
      body: Padding(
        padding: EdgeInsets.all(w * 0.04),
        child: Column(
          children: [
            Container(
              height: w * 0.12,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xffE9E9E9)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 3))
                ],
              ),
              child: TextField(
                controller: _searchController,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: S.of(context).search,
                  hintStyle: TextStyle(
                      fontSize: w * 0.03, color: Colors.grey.shade600),
                  border: InputBorder.none,
                  prefixIcon:
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal:w * 0.02),
                    child: Icon(Icons.search, color: Colors.grey, size: w * 0.06),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                      vertical: w * 0.035, horizontal: w * 0.035),
                ),
              ),
            ),
            SizedBox(height: h * 0.02),
            Expanded(
              child: BlocBuilder<MyStoreCubit, MyStoreState>(
                builder: (context, state) {
                  final ads = state.ads;
                  final filtered = _searchQuery.isEmpty
                      ? ads
                      : ads
                      .where((ad) => ad['name']
                      .toString()
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()))
                      .toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('Assets/empty-cart 1.png', width: w * 0.5),
                          SizedBox(height: h * 0.04),
                          Text(
                            S.of(context).noAdsYet,
                            style: TextStyle(fontSize: w * 0.035, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: w * 0.04,
                        crossAxisSpacing: w * 0.04,
                        childAspectRatio: 0.65,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final ad = filtered[index];
                        final originalIndex = ads.indexOf(ad);

                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MyProductDetailsPage(adIndex: originalIndex),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(w * 0.03),
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
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(w * 0.03)),
                                  child: Image(
                                    image: kIsWeb
                                        ? MemoryImage(ad['images'][0] as Uint8List)
                                        : FileImage(File(ad['images'][0] as String)) as ImageProvider,
                                    width: double.infinity,
                                    height: w * 0.4,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Image.asset(
                                      'Assets/fallback_image.png',
                                      width: double.infinity,
                                      height: w * 0.4,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(w * 0.025),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ad['name'],
                                        style: TextStyle(fontSize: w * 0.035, fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: h * 0.005),
                                      Text(
                                        ad['description'],
                                        style: TextStyle(fontSize: w * 0.03, color: Colors.grey[700]),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: h * 0.005),
                                      Text(
                                        "${ad['price']} ${ad['currency']}",
                                        style: TextStyle(
                                          fontSize: w * 0.035,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xffFF580E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
