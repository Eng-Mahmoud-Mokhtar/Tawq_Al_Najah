import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../../Seller/Home/presentation/view_model/views/widgets/ConvexNotchedShape.dart';
import '../../../../More/presentation/view_model/views/MorePage.dart';
import '../../../../Explore/presentation/view_model/views/Explore.dart';
import '../../../../MyPosts/presentation/view_model/views/Widgets/AddPostBuyer.dart';
import '../../../../cart/presentation/view_model/views/Cart.dart';
import 'HomeBody.dart';


class BottomNavBCubit extends Cubit<int> {
  BottomNavBCubit() : super(0);
  void setIndex(int index) => emit(index);
}

class HomeStructure extends StatelessWidget {
  const HomeStructure({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final List<Widget> pages = [
      const HomePage(),
      const Explore(),
      CartPage(),
      const ProfilePage(),
    ];

    return BlocProvider(
      create: (_) => BottomNavBCubit(),
      child: BlocBuilder<BottomNavBCubit, int>(
        builder: (context, selectedIndex) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: IndexedStack(
              index: selectedIndex,
              children: pages,
            ),
            floatingActionButton: GestureDetector(
              onTap: () => handleAddPostBuyer(context),
              child: Container(
                width: screenWidth * 0.13,
                height: screenWidth * 0.13,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: KprimaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: ThirdColor.withOpacity(0.5),
                      spreadRadius: 4,
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: screenWidth * 0.07,
                  ),
                ),
              ),
            ),
            floatingActionButtonLocation:
            FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: SafeArea(
              minimum: EdgeInsets.zero,
              child: SizedBox(
                height: screenWidth * 0.175,
                child: BottomAppBar(
                  color: Colors.white,
                  shape: const ConvexNotchedShape(),
                  notchMargin: 1.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildNavItem(
                        context: context,
                        image: "Assets/home-2.png",
                        selectedImage: "Assets/home-2.png",
                        label: S.of(context).Home,
                        index: 0,
                        screenWidth: screenWidth,
                      ),
                      _buildNavItem(
                        context: context,
                        image: "Assets/search.png",
                        selectedImage: "Assets/search.png",
                        label: S.of(context).explore,
                        index: 1,
                        screenWidth: screenWidth,
                      ),
                      SizedBox(width: screenWidth * 0.13),
                      _buildNavItem(
                        context: context,
                        image: "Assets/bag.png",
                        selectedImage: "Assets/bag.png",
                        label: S.of(context).Cart,
                        index: 2,
                        screenWidth: screenWidth,
                      ),
                      _buildNavItem(
                        context: context,
                        image: "Assets/icons8-more-24.png",
                        selectedImage: "Assets/icons8-more-24.png",
                        label: S.of(context).more,
                        index: 3,
                        screenWidth: screenWidth,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required String image,
    required String selectedImage,
    required String label,
    required int index,
    required double screenWidth,
  }) {
    final bool isSelected = context.watch<BottomNavBCubit>().state == index;
    return InkResponse(
      onTap: () {
        context.read<BottomNavBCubit>().setIndex(index);
      },
      radius: screenWidth * 0.1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            isSelected ? selectedImage : image,
            width: screenWidth * 0.05,
            height: screenWidth * 0.05,
            color: isSelected ? KprimaryColor : Colors.grey.shade400,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? KprimaryColor : Colors.grey.shade400,
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.02,
            ),
          ),
        ],
      ),
    );
  }
}
