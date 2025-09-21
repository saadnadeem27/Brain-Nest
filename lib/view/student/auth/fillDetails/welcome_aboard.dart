import 'package:Vadai/common_imports.dart';

class WelcomeAboard extends StatefulWidget {
  const WelcomeAboard({super.key});

  @override
  State<WelcomeAboard> createState() => _WelcomeAboardState();
}

class _WelcomeAboardState extends State<WelcomeAboard> {
  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      bottomNavigationBar: textWid(
        AppStrings.stringByUsingVADAIYouAgreeToTheTermsAndPrivacyPolicy,
        maxlines: 2,
        textAlign: TextAlign.center,
        style: AppTextStyles.textStyle(
          fontSize: getWidth(14),
          fontWeight: FontWeight.w400,
        ),
      ).paddingOnly(bottom: getHeight(16)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: getWidth(100),
            height: getWidth(100),
            decoration: BoxDecoration(
              color: AppColors.blueColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              color: AppColors.blueColor,
              size: getWidth(60),
            ),
          ),
          SizedBox(height: getHeight(24)),
          // App logo
          Center(child: Image.asset(AppAssets.logo, width: getWidth(180))),
          Text(
            "🎉 Account Created Successfully! Welcome aboard!",
            maxLines: 3,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.blueColor,
              fontSize: getWidth(14),
            ),
          ),
          SizedBox(height: getHeight(16)),

          // Message about school approval
          Text(
            "⏳ Your profile is under review by your school admin. You’ll be able to log in once it’s verified!",
            maxLines: 5,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textColor.withOpacity(0.7),
              fontSize: getWidth(14),
            ),
          ),
          SizedBox(height: getHeight(8)),

          // Done button
          materialButtonWithChild(
            width: double.infinity,
            onPressed: () => Get.offAllNamed(RouteNames.loginScreen),
            child: textWid(
              "Return to Login",
              style: AppTextStyles.textStyle(
                fontSize: getWidth(16),
                fontWeight: FontWeight.w500,
                txtColor: AppColors.white,
              ),
            ),
            color: AppColors.blueColor,
            padding: EdgeInsets.symmetric(vertical: getHeight(18)),
            borderRadius: 12,
          ).paddingOnly(top: getHeight(24)),

          // What's next? Section
          SizedBox(height: getHeight(24)),
          Text(
            "What happens next?",
            textAlign: TextAlign.center,
            style: AppTextStyles.textStyle(
              fontSize: getWidth(18),
              fontWeight: FontWeight.w600,
              txtColor: AppColors.textColor,
            ),
          ),
          SizedBox(height: getHeight(16)),

          // Steps list
          _buildStep(
            number: "1",
            text: "📋 Your school will review the info you submitted",
          ),
          _buildStep(
            number: "2",
            text: "✅ Once approved, you'll get access to your account",
          ),
          _buildStep(
            number: "3",
            text: "🔐 Log in using your registered email and password",
          ),
        ],
      ).paddingOnly(
        left: getWidth(16),
        right: getWidth(16),
        bottom: getHeight(24),
      ),
    );
  }

  Widget _buildStep({required String number, required String text}) {
    return Padding(
      padding: EdgeInsets.only(bottom: getHeight(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: getWidth(28),
            height: getWidth(28),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.blueColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: getWidth(14),
              ),
            ),
          ),
          SizedBox(width: getWidth(12)),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: getHeight(4)),
              child: Text(
                text,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: getWidth(14),
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
