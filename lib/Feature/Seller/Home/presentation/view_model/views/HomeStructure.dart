import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../More/presentation/view_model/views/MorePage.dart';
import '../../../../Search/presentation/view_model/views/SearchPage.dart';
import '../../../../cart/presentation/view_model/views/Cart.dart';
import 'HomeBody.dart';

class BottomNavCubit extends Cubit<int> {
  BottomNavCubit() : super(0);
  void setIndex(int index) => emit(index);
}

class HomeStructure extends StatelessWidget {
  const HomeStructure({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final List<Widget> pages = [
      const HomePage(),
      const SearchPage(),
      CartPage(),
      const ProfilePage(),
    ];

    return BlocBuilder<BottomNavCubit, int>(
      builder: (context, selectedIndex) {
        final iconList = [
          "Assets/home-2.png",
          "Assets/search.png",
          "Assets/bag.png",
          "Assets/icons8-more-24.png"
        ];

        final labelList = [
          S.of(context).Home,
          S.of(context).search,
          S.of(context).Cart,
          S.of(context).more
        ];

        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: IndexedStack(
            index: selectedIndex,
            children: pages,
          ),
          bottomNavigationBar: SafeArea(
            minimum: EdgeInsets.zero,
            child: SizedBox(
              height: screenWidth * 0.18,
              child: BottomAppBar(
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(pages.length, (index) {
                    final bool isSelected = selectedIndex == index;
                    final iconColor =
                    isSelected ? KprimaryColor : Colors.grey.shade400;

                    return InkResponse(
                      onTap: () {
                        context.read<BottomNavCubit>().setIndex(index);
                      },
                      radius: screenWidth * 0.1,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            iconList[index],
                            width: screenWidth * 0.05,
                            height: screenWidth * 0.05,
                            color: iconColor,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            labelList[index],
                            style: TextStyle(
                              color: iconColor,
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.025,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
