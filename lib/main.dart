import 'package:device_preview/device_preview.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tawqalnajah/Feature/Buyer/Product/presentation/view_model/cart_cubit.dart';
import 'Core/Widgets/CountryCubit.dart';
import 'Core/utiles/LocaleCubit.dart';
import 'Feature/Auth/presentation/SocialPartnership.dart';
import 'Feature/Buyer/Home/presentation/view_model/views/HomeStructure.dart';
import 'Feature/Buyer/MyPosts/presentation/view_model/MyPosts_Cubit.dart';
import 'Feature/Buyer/Product/presentation/view_model/favorite_cubit.dart';
import 'Feature/Seller/Home/presentation/view_model/views/HomeStructure.dart';
import 'Feature/Seller/Orders/presentation/view_model/views/SellerActiveOrdersPage.dart';
import 'Feature/Seller/Orders/presentation/view_model/views/SellerNewOrdersPage.dart';
import 'Feature/Seller/RelatedProuducts/presentation/view_model/FilterRelated_cubit.dart';
import 'Feature/Splash/presentation/view_model/views/SplashScreen.dart';
import 'generated/l10n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    DevicePreview(
      enabled: false,
      builder: (context) => ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        builder: (context, child) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => BottomNavBCubit()),
              BlocProvider(create: (_) => BottomNavSCubit()),
              BlocProvider(create: (_) => FilterRelatedCubit()),
              BlocProvider(create: (_) => LocaleCubit()),
              BlocProvider(create: (_) => CountryCubit()),
              BlocProvider(create: (_) => MyPostsCubit()),
              BlocProvider(create: (context) => FavoriteCubit()),
              BlocProvider(create: (context) => CartCubit()),
              BlocProvider(create: (context) => NewOrdersCubit(NewOrdersApi())),
              BlocProvider(create: (context) => ActiveOrdersCubit(ActiveOrdersApi())),
              BlocProvider(create: (context) => SocialPartnershipCubit(dio: Dio())),
            ],
            child: const MyApp(),
          );
        },
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: locale,
          supportedLocales: S.delegate.supportedLocales,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(fontFamily: 'Tajawal'),
          home: SplashScreen(),
        );
      },
    );
  }
}