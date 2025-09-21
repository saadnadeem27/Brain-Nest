import 'dart:async';
import 'dart:developer';
import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/teachers/teacher_auth_controller.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

class TeacherOTPVerificationScreen extends StatefulWidget {
  const TeacherOTPVerificationScreen({super.key});

  @override
  State<TeacherOTPVerificationScreen> createState() =>
      _TeacherOTPVerificationScreenState();
}

class _TeacherOTPVerificationScreenState
    extends State<TeacherOTPVerificationScreen> {
  TeacherAuthController ctr = Get.put((TeacherAuthController()));
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
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: getWidth(12),
                      vertical: getHeight(6),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      borderRadius: BorderRadius.circular(getWidth(20)),
                    ),
                    child: Text(
                      "Teacher Portal",
                      style: AppTextStyles.textStyle(
                        fontSize: getWidth(14),
                        fontWeight: FontWeight.w600,
                        txtColor: AppColors.greenDark,
                      ),
                    ),
                  ),
                  SizedBox(height: getHeight(12)),
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
                            txtColor: AppColors.greenDark,
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
                                      .copyWith(color: AppColors.greenDark),
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
                            color: AppColors.greenDark,
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
                                              color: AppColors.greenDark,
                                              size: getWidth(20),
                                            ),
                                            SizedBox(width: getWidth(8)),
                                            Text(
                                              "Resend OTP",
                                              style: AppTextStyles.textStyle(
                                                fontSize: getWidth(16),
                                                fontWeight: FontWeight.w600,
                                                txtColor: AppColors.greenDark,
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
                                              txtColor: AppColors.greenDark,
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
      log('---------------->>>>>>>>>>>>>>>>>>>>> Teacher OTP Result: $result');
      if (result['success'] == true) {
        if (result['isRegistered'] == true) {
          Get.offAllNamed(RouteNames.teachersDashboard);
          log(
            '---------->>>>>>>>>>>>>>>>>>>>>>> going to teacher dashboard <<<<<<<<<<<<<<<<<<<<-----------------',
          );
        } else {
          Get.toNamed(
            RouteNames.teacherUploadProfile,
            arguments: {'email': email},
          );
          log(
            '---------->>>>>>>>>>>>>>>>>>>>>>> going to teacher profile setup <<<<<<<<<<<<<<<<<<<<-----------------',
          );
        }
      }
    } catch (e) {
      log('Error during teacher OTP verification: ${e.toString()}');
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
