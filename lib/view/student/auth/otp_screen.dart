import 'dart:async';
import 'dart:developer';
import 'package:Vadai/common/App_strings.dart';
import 'package:Vadai/common/app_colors.dart';
import 'package:Vadai/common/assets.dart';
import 'package:Vadai/common/common_widgets.dart';
import 'package:Vadai/common/size_config.dart';
import 'package:Vadai/common/text_style.dart';
import 'package:Vadai/controller/student/auth_controller.dart';
import 'package:Vadai/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({super.key});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  AuthController ctr = Get.put((AuthController()));
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  RxBool isLoading = false.obs;
  Map<String, dynamic>? dataArgument = Get.arguments;
  String email = '';

  final PinTheme defaultPinTheme = PinTheme(
    width: getWidth(48),
    height: getHeight(48),
    textStyle: AppTextStyles.textStyle(
      fontSize: 24,
      txtColor: AppColors.textColor,
    ),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(7),
      border: Border.all(color: AppColors.color7D818A, width: 1),
    ),
  );

  final RxInt _requestAgain = 60.obs;
  Timer? _timer;

  initializeTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_requestAgain.value > 0) {
        _requestAgain.value--;
      }
    });
  }

  @override
  void initState() {
    initializeTimer();
    super.initState();
    if (dataArgument != null) {
      email = dataArgument?['email'];
    }
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      appBar: commonAppBar(context: context, isBack: true, title: ""),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: getWidth(24)),
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo and welcome section
                  SizedBox(height: getHeight(40)),
                  Image.asset(AppAssets.logo, width: getWidth(220)),
                  RichText(
                    textAlign: TextAlign.center,
                    maxLines: 5,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "📩 Enter the code sent to ",
                          style: AppTextStyles.textStyle(
                            txtColor: AppColors.textColor,
                            fontSize: getWidth(16),
                          ),
                        ),
                        TextSpan(
                          text: email,
                          style: AppTextStyles.textStyle(
                            txtColor: AppColors.blueColor,
                            fontWeight: FontWeight.w600,
                            fontSize: getWidth(16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: getHeight(40)),

                  // OTP input or loader
                  isLoading.value
                      ? Container(
                        height: getHeight(200),
                        child: commonLoader(
                          customHeight: getHeight(100),
                          customWidth: getWidth(100),
                        ),
                      )
                      : Column(
                        children: [
                          // OTP input
                          Center(
                            child: Form(
                              key: _formKey,
                              child: Pinput(
                                length: 5,
                                controller: _pinController,
                                focusNode: _focusNode,
                                autofillHints: const [
                                  AutofillHints.oneTimeCode,
                                ],
                                defaultPinTheme: defaultPinTheme,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (value) {
                                  return _pinController.text.length == 5
                                      ? null
                                      : 'Please enter all 5 digits';
                                },
                                hapticFeedbackType:
                                    HapticFeedbackType.lightImpact,
                                cursor: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 9),
                                      width: 22,
                                      height: 1,
                                      color: AppColors.transparent,
                                    ),
                                  ],
                                ),
                                focusedPinTheme: defaultPinTheme.copyWith(
                                  textStyle: defaultPinTheme.textStyle
                                      ?.copyWith(color: AppColors.white),
                                  decoration: defaultPinTheme.decoration!
                                      .copyWith(color: AppColors.blueColor),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: getHeight(40)),

                          // Submit button
                          materialButtonWithChild(
                            width: double.infinity,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                verify();
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: getHeight(16),
                              ),
                              child: Text(
                                "Verify & Continue",
                                style: AppTextStyles.textStyle(
                                  fontSize: getWidth(16),
                                  fontWeight: FontWeight.w600,
                                  txtColor: AppColors.white,
                                ),
                              ),
                            ),
                            color: AppColors.blueColor,
                            borderRadius: 12,
                          ),
                          SizedBox(height: getHeight(20)),

                          // Resend OTP section
                          Container(
                            padding: EdgeInsets.all(getWidth(16)),
                            decoration: BoxDecoration(
                              color: AppColors.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Obx(
                              () =>
                                  _requestAgain.value == 0
                                      ? GestureDetector(
                                        onTap: resetTimerRequestOTP,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.refresh_rounded,
                                              color: AppColors.blueColor,
                                              size: getWidth(20),
                                            ),
                                            SizedBox(width: getWidth(8)),
                                            Text(
                                              "Resend OTP",
                                              style: AppTextStyles.textStyle(
                                                fontSize: getWidth(16),
                                                fontWeight: FontWeight.w600,
                                                txtColor: AppColors.blueColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                      : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Resend OTP in ",
                                            style: AppTextStyles.textStyle(
                                              fontSize: getWidth(16),
                                              txtColor: AppColors.textColor,
                                            ),
                                          ),
                                          Text(
                                            "${_requestAgain.value} seconds",
                                            style: AppTextStyles.textStyle(
                                              fontSize: getWidth(16),
                                              fontWeight: FontWeight.w700,
                                              txtColor: AppColors.blueColor,
                                            ),
                                          ),
                                        ],
                                      ),
                            ),
                          ),
                        ],
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  verify() async {
    if (_pinController.text.length != 5) {
      commonSnackBar(message: 'Please enter a valid 5-digit OTP');
      return;
    }

    isLoading.value = true;
    try {
      final result = await ctr.verifyOtp(
        email: email,
        otp: _pinController.text,
      );
      if (result['success'] == true) {
        if (result['isRegistered'] == true) {
          Get.offAllNamed(RouteNames.userDashboard);
        } else {
          Get.toNamed(RouteNames.uploadProfile, arguments: {'email': email});
        }
      }
    } catch (e) {
      log('Error during OTP verification: ${e.toString()}');
      commonSnackBar(message: 'Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  resetTimerRequestOTP() async {
    _requestAgain.value = 60;
    _pinController.clear();
    try {
      await ctr.sendOtp(email: email).then((value) {
        if (value != true) {
          _requestAgain.value = 0;
        }
      });
    } catch (e) {
      log(e.toString());
    }
  }
}
