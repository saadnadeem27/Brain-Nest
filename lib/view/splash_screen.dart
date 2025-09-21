import 'package:Vadai/common/app_colors.dart';
import 'package:Vadai/common/assets.dart';
import 'package:Vadai/common/common_widgets.dart';
import 'package:Vadai/common/size_config.dart';
import 'package:Vadai/helper/local_storage_helper.dart';
import 'package:Vadai/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )
    ..forward().then((_) async {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (LocalStorage.read(key: LocalStorageKeys.token) == null) {
          Get.offAllNamed(RouteNames.appSelection);
        } else {
          final userRole = LocalStorage.read(key: LocalStorageKeys.userRole);

          if (userRole == "teacher") {
            Get.offAllNamed(RouteNames.teachersDashboard);
          } else if (userRole == "student") {
            Get.offAllNamed(RouteNames.userDashboard);
          }
        }
      });
    });

  late final Animation<double> _animation = Tween<double>(
    begin: 0,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      backgroundColor: AppColors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          child: SizedBox(
            height: getHeight(75),
            width: getWidth(200),
            child: Image.asset(AppAssets.logo, fit: BoxFit.fill),
          ),
          builder: (BuildContext context, Widget? child) {
            return Transform.scale(scale: _animation.value, child: child);
          },
        ),
      ),
    );
  }
}
