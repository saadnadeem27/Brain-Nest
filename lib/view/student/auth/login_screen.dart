import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/student/auth_controller.dart';
import 'package:Vadai/helper/validation_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  AuthController authController = Get.put(AuthController());
  final TextEditingController emailController = TextEditingController();
  RxBool isLoading = false.obs;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          bottom: getHeight(24),
          left: getWidth(24),
          right: getWidth(24),
        ),
        child: textWid(
          AppStrings.stringByUsingVADAIYouAgreeToTheTermsAndPrivacyPolicy,
          maxlines: 2,
          textAlign: TextAlign.center,
          style: AppTextStyles.textStyle(
            fontSize: getWidth(13),
            fontWeight: FontWeight.w400,
            txtColor: AppColors.textColor2,
          ),
        ),
      ),
      appBar: commonAppBar(context: context, isBack: true, title: ""),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: getWidth(24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: getHeight(60)),
                Image.asset(AppAssets.logo, width: getWidth(220)),
                Text(
                  "👋 You're now using VAD AI – let’s get started! ✨",
                  maxLines: 3,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.textStyle(
                    fontSize: getWidth(16),
                    fontWeight: FontWeight.w400,
                    txtColor: AppColors.textColor,
                  ),
                ),
                SizedBox(height: getHeight(40)),

                Obx(
                  () =>
                      isLoading.value
                          ? Container(
                            height: getHeight(200),
                            child: commonLoader(
                              customHeight: getHeight(100),
                              customWidth: getWidth(100),
                            ),
                          )
                          : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.email,
                                style: AppTextStyles.textStyle(
                                  fontSize: getWidth(18),
                                  fontWeight: FontWeight.w500,
                                  txtColor: AppColors.textColor,
                                ),
                              ),
                              SizedBox(height: getHeight(8)),
                              commonTextFiled(
                                controller: emailController,
                                hintText: "john@gmail.com",
                                maxLines: 1,
                                borderRadius: getWidth(12),
                                keyBoardType: TextInputType.emailAddress,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: getWidth(16),
                                  vertical: getHeight(16),
                                ),
                              ),
                              Text(
                                "We'll send a verification code to this email",
                                style: AppTextStyles.textStyle(
                                  fontSize: getWidth(14),
                                  fontWeight: FontWeight.w400,
                                  txtColor: AppColors.textColor,
                                ),
                              ).paddingOnly(top: getHeight(8)),
                              SizedBox(height: getHeight(40)),
                              materialButtonWithChild(
                                width: double.infinity,
                                onPressed: () async {
                                  String? validationError =
                                      ValidationHelper.validateEmail(
                                        emailController.text.trim(),
                                      );
                                  if (validationError != null) {
                                    commonSnackBar(message: validationError);
                                    return;
                                  }

                                  isLoading.value = true;
                                  try {
                                    await authController
                                        .sendOtp(
                                          email: emailController.text.trim(),
                                        )
                                        .then((value) {
                                          if (value) {
                                            Get.toNamed(
                                              RouteNames.otpScreen,
                                              arguments: {
                                                "email":
                                                    emailController.text.trim(),
                                              },
                                            );
                                          }
                                        });
                                  } finally {
                                    isLoading.value = false;
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: getHeight(16),
                                  ),
                                  child: Text(
                                    "Continue",
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
                            ],
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
