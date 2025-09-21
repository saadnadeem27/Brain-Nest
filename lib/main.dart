import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/services.dart';
import 'package:brain_nest/common/app_colors.dart';
import 'package:brain_nest/routes.dart';
import 'package:google_fonts/google_fonts.dart';

GlobalKey<ScaffoldMessengerState> scaffoldKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  // LocalStorage.write(
  //   key: LocalStorageKeys.token,
  //   data:
  //       "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2N2RjMGViZGI4YzAyZWJkZjkwYWE1ZGUiLCJyb2xlIjoic3R1ZGVudCIsImlhdCI6MTc0NTM3OTg5NCwiZXhwIjoxNzc2OTE1ODk0LCJ0eXBlIjoiYWNjZXNzIn0.Ux4ZzuisOAknkmRyVSNTP4pjz7FmrSar5euu4gDphxQ",
  // );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarColor: AppColors.white,
      systemNavigationBarColor: AppColors.black,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(1.0)),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Brain Nest",
        scaffoldMessengerKey: scaffoldKey,
        getPages: AppRoutes.routes,
        initialRoute: AppRoutes.initial,
        transitionDuration: const Duration(milliseconds: 300),
        defaultTransition: Transition.rightToLeft,
        theme: ThemeData(
          useMaterial3: true,
          dividerTheme: const DividerThemeData(),
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryPurple,
            brightness: Brightness.light,
            primary: AppColors.primaryPurple,
            secondary: AppColors.accentTeal,
            surface: AppColors.surfaceLight,
            background: AppColors.backgroundPrimary,
            error: AppColors.errorRed,
          ),
          dialogBackgroundColor: AppColors.surfaceLight,
          inputDecorationTheme: InputDecorationTheme(
            errorStyle: TextStyle(
              color: AppColors.errorRed,
              fontSize: (14 / 852.0) * MediaQuery.of(context).size.height,
              fontWeight: FontWeight.w400,
              fontFamily: GoogleFonts.inter().fontFamily,
            ),
          ),
          scaffoldBackgroundColor: AppColors.backgroundPrimary,
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.surfaceLight,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
          textTheme: GoogleFonts.interTextTheme(
            Theme.of(context).textTheme.copyWith(
              headlineLarge: TextStyle(color: AppColors.textPrimary),
              headlineMedium: TextStyle(color: AppColors.textPrimary),
              headlineSmall: TextStyle(color: AppColors.textPrimary),
              bodyLarge: TextStyle(color: AppColors.textPrimary),
              bodyMedium: TextStyle(color: AppColors.textSecondary),
              bodySmall: TextStyle(color: AppColors.textTertiary),
            ),
          ),
        ),
        // home: const PeoplesScreen(),
      ),
    );
  }
}
