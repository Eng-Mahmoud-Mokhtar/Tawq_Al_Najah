import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'Core/Widgets/code.dart';
import 'Core/utiles/LocaleCubit.dart';
import 'Feature/Auth/presentation/view_model/CountryCubit.dart';
import 'Feature/Seller/Search/presentation/view_model/filter_cubit.dart';
import 'Feature/Seller/Home/presentation/view_model/views/HomeStructure.dart';
import 'Feature/Seller/More/presentation/view_model/favorites_cubit.dart';
import 'Feature/Seller/cart/presentation/view_model/cart_cubit.dart';
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
      enabled: true,
      builder: (context) => ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        builder: (context, child) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => BottomNavCubit()),
              BlocProvider(create: (_) =>  FilterCubit()),
              BlocProvider(create: (_) => LocaleCubit()),
              BlocProvider(create: (_) => CodeCubit()),
              BlocProvider(create: (_) => CountryCubit()),
              BlocProvider(create: (_) => FavoritesCubit()),
              BlocProvider(create: (_) => CartCubit()),
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
