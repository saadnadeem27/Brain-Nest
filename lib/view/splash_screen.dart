import 'package:flutter/material.dart';import 'package:brain_nest/common/app_colors.dart';

import 'package:get/get.dart';import 'package:brain_nest/routes.dart';

import 'package:google_fonts/google_fonts.dart';import 'package:flutter/material.dart';

import '../common/app_colors.dart';import 'package:get/get.dart';

import '../app_selection_screen.dart';import 'package:google_fonts/google_fonts.dart';



class SplashScreen extends StatefulWidget {class SplashScreen extends StatefulWidget {

  const SplashScreen({Key? key}) : super(key: key);  const SplashScreen({super.key});



  @override  @override

  State<SplashScreen> createState() => _SplashScreenState();  State<SplashScreen> createState() => _SplashScreenState();

}}



class _SplashScreenState extends State<SplashScreen>class _SplashScreenState extends State<SplashScreen>

    with TickerProviderStateMixin {    with TickerProviderStateMixin {

  late AnimationController _fadeController;  late final AnimationController _controller = AnimationController(

  late AnimationController _scaleController;      duration: const Duration(milliseconds: 2000),

  late Animation<double> _fadeAnimation;      vsync: this,

  late Animation<double> _scaleAnimation;    )

    ..forward().then((_) async {

  @override      WidgetsBinding.instance.addPostFrameCallback((_) async {

  void initState() {        // Skip auth for demo purposes - go directly to app selection

    super.initState();        Get.offAllNamed(AppRoutes.appSelection);

          });

    _fadeController = AnimationController(    });

      duration: const Duration(milliseconds: 1500),

      vsync: this,  late final Animation<double> _fadeAnimation = Tween<double>(

    );    begin: 0,

        end: 1.0,

    _scaleController = AnimationController(  ).animate(CurvedAnimation(

      duration: const Duration(milliseconds: 1200),    parent: _controller, 

      vsync: this,    curve: Interval(0.0, 0.6, curve: Curves.easeInOut)

    );  ));



    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(  late final Animation<double> _scaleAnimation = Tween<double>(

      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),    begin: 0.5,

    );    end: 1.0,

  ).animate(CurvedAnimation(

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(    parent: _controller, 

      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),    curve: Interval(0.2, 0.8, curve: Curves.elasticOut)

    );  ));



    _startAnimations();  late final Animation<Offset> _slideAnimation = Tween<Offset>(

  }    begin: Offset(0, 0.3),

    end: Offset.zero,

  void _startAnimations() async {  ).animate(CurvedAnimation(

    await Future.delayed(const Duration(milliseconds: 300));    parent: _controller, 

    _scaleController.forward();    curve: Interval(0.4, 1.0, curve: Curves.easeOutBack)

    _fadeController.forward();  ));

    

    await Future.delayed(const Duration(milliseconds: 2500));  @override

    if (mounted) {  void dispose() {

      Get.off(() => const AppSelectionScreen());    _controller.dispose();

    }    super.dispose();

  }  }



  @override  @override

  void dispose() {  Widget build(BuildContext context) {

    _fadeController.dispose();    return Scaffold(

    _scaleController.dispose();      body: Container(

    super.dispose();        decoration: BoxDecoration(

  }          gradient: AppColors.primaryGradient,

        ),

  @override        child: Center(

  Widget build(BuildContext context) {          child: Column(

    return Scaffold(            mainAxisAlignment: MainAxisAlignment.center,

      body: Container(            children: [

        decoration: const BoxDecoration(              // Animated Logo

          gradient: LinearGradient(              AnimatedBuilder(

            begin: Alignment.topLeft,                animation: _scaleAnimation,

            end: Alignment.bottomRight,                child: Container(

            colors: [                  width: 120,

              Color(0xFF667eea),                  height: 120,

              Color(0xFF764ba2),                  decoration: BoxDecoration(

              Color(0xFFf093fb),                    color: AppColors.white,

            ],                    shape: BoxShape.circle,

          ),                    boxShadow: [

        ),                      BoxShadow(

        child: Center(                        color: Colors.black.withOpacity(0.2),

          child: AnimatedBuilder(                        blurRadius: 20,

            animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),                        offset: Offset(0, 10),

            builder: (context, child) {                      ),

              return FadeTransition(                    ],

                opacity: _fadeAnimation,                  ),

                child: ScaleTransition(                  child: Icon(

                  scale: _scaleAnimation,                    Icons.psychology_rounded,

                  child: Column(                    size: 60,

                    mainAxisAlignment: MainAxisAlignment.center,                    color: AppColors.primaryPurple,

                    children: [                  ),

                      // Logo                ),

                      Container(                builder: (context, child) {

                        width: 120,                  return Transform.scale(

                        height: 120,                    scale: _scaleAnimation.value,

                        decoration: BoxDecoration(                    child: child,

                          color: Colors.white,                  );

                          borderRadius: BorderRadius.circular(30),                },

                          boxShadow: [              ),

                            BoxShadow(              

                              color: Colors.black.withOpacity(0.3),              SizedBox(height: 40),

                              blurRadius: 20,              

                              offset: const Offset(0, 10),              // Animated Title

                            ),              SlideTransition(

                          ],                position: _slideAnimation,

                        ),                child: FadeTransition(

                        child: const Icon(                  opacity: _fadeAnimation,

                          Icons.psychology,                  child: Column(

                          size: 60,                    children: [

                          color: Color(0xFF667eea),                      Text(

                        ),                        'Brain Nest',

                      ),                        style: GoogleFonts.inter(

                      const SizedBox(height: 30),                          fontSize: 32,

                                                fontWeight: FontWeight.bold,

                      // App Name                          color: AppColors.white,

                      Text(                          letterSpacing: 1.2,

                        'Brain Nest',                        ),

                        style: GoogleFonts.poppins(                      ),

                          fontSize: 36,                      SizedBox(height: 8),

                          fontWeight: FontWeight.bold,                      Text(

                          color: Colors.white,                        'Premium Learning Platform',

                          shadows: [                        style: GoogleFonts.inter(

                            Shadow(                          fontSize: 16,

                              color: Colors.black.withOpacity(0.3),                          fontWeight: FontWeight.w400,

                              offset: const Offset(0, 2),                          color: AppColors.white.withOpacity(0.9),

                              blurRadius: 4,                          letterSpacing: 0.5,

                            ),                        ),

                          ],                      ),

                        ),                    ],

                      ),                  ),

                      const SizedBox(height: 8),                ),

                                    ),

                      // Tagline              

                      Text(              SizedBox(height: 60),

                        'Nurturing Minds, Building Futures',              

                        style: GoogleFonts.inter(              // Loading indicator

                          fontSize: 16,              FadeTransition(

                          color: Colors.white.withOpacity(0.9),                opacity: _fadeAnimation,

                          fontWeight: FontWeight.w400,                child: CircularProgressIndicator(

                        ),                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),

                      ),                  strokeWidth: 2,

                                      ),

                      const SizedBox(height: 60),              ),

                                  ],

                      // Loading indicator          ),

                      SizedBox(        ),

                        width: 40,      ),

                        height: 40,    );

                        child: CircularProgressIndicator(  }

                          strokeWidth: 3,}

                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}