import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../Core/utiles/Colors.dart';
import '../../Feature/Buyer/Home/presentation/view_model/views/HomeStructure.dart' hide BottomNavSCubit;
import '../../Feature/Seller/Home/presentation/view_model/views/HomeStructure.dart';
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Text(
        title,
        style: TextStyle(
          fontSize: screenWidth * 0.035,
          fontWeight: FontWeight.bold,
          color: KprimaryText,
        ),
      ),
      iconTheme: IconThemeData(
        color: Colors.black,
        size: screenWidth * 0.05,
      ),
    );
  }
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}


class AppBarWithBottomB extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const AppBarWithBottomB({
    super.key,
    required this.title,
  });


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text(
        title,
        style: TextStyle(
          fontSize: screenWidth * 0.035,
          fontWeight: FontWeight.bold,
          color: KprimaryText,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color:KprimaryText,
          size: screenWidth * 0.05,
        ),
        onPressed: () {
          context.read<BottomNavBCubit>().setIndex(0);
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
class AppBarWithBottomS extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const AppBarWithBottomS({
    super.key,
    required this.title,
  });


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text(
        title,
        style: TextStyle(
          fontSize: screenWidth * 0.035,
          fontWeight: FontWeight.bold,
          color: KprimaryText,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color:KprimaryText,
          size: screenWidth * 0.05,
        ),
        onPressed: () {
          context.read<BottomNavSCubit>().setIndex(0);
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}


