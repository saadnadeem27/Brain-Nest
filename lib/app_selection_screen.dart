import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/student/auth_controller.dart';
import 'package:Vadai/helper/local_storage_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSelectionScreen extends StatelessWidget {
  const AppSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: getHeight(60)),

              // App logo
              Center(child: Image.asset(AppAssets.logo, width: getWidth(180))),

              SizedBox(height: getHeight(40)),

              // Welcome text
              Text(
                "Welcome to VADAI",
                style: AppTextStyles.textStyle(
                  fontSize: getWidth(24),
                  fontWeight: FontWeight.bold,
                  txtColor: AppColors.textColor,
                ),
              ),

              SizedBox(height: getHeight(10)),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: getWidth(30)),
                child: Text(
                  "Choose how you want to use the app",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.textStyle(
                    fontSize: getWidth(16),
                    fontWeight: FontWeight.w400,
                    txtColor: AppColors.textColor.withOpacity(0.8),
                  ),
                ),
              ),

              SizedBox(height: getHeight(60)),

              // Student app selection
              _buildAppOptionCard(
                title: "Student App",
                description:
                    "Access your learning resources, assignments and track your progress",
                icon: Icons.school_rounded,
                color: AppColors.blueColor,
                onTap: () {
                  // Save role preference
                  LocalStorage.write(
                    key: LocalStorageKeys.userRole,
                    data: "student",
                  );
                  Get.toNamed(RouteNames.loginScreen);
                },
              ),

              SizedBox(height: getHeight(20)),

              // Teacher app selection
              _buildAppOptionCard(
                title: "Teacher App",
                description:
                    "Manage classes, assignments and monitor student progress",
                icon: Icons.cast_for_education,
                color: Colors.green,
                onTap: () {
                  // Save role preference
                  LocalStorage.write(
                    key: LocalStorageKeys.userRole,
                    data: "teacher",
                  );
                  Get.toNamed(RouteNames.teachersLoginScreen);
                },
              ),

              SizedBox(height: getHeight(40)),

              // Terms text
              Container(
                padding: EdgeInsets.only(
                  bottom: getHeight(24),
                  left: getWidth(24),
                  right: getWidth(24),
                ),
                child: textWid(
                  AppStrings
                      .stringByUsingVADAIYouAgreeToTheTermsAndPrivacyPolicy,
                  maxlines: 2,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.textStyle(
                    fontSize: getWidth(13),
                    fontWeight: FontWeight.w400,
                    txtColor: AppColors.textColor2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppOptionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required Function() onTap,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: getWidth(24)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(getWidth(20)),
            child: Row(
              children: [
                Container(
                  width: getWidth(60),
                  height: getWidth(60),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: getWidth(30)),
                ),
                SizedBox(width: getWidth(16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.textStyle(
                          fontSize: getWidth(18),
                          fontWeight: FontWeight.bold,
                          txtColor: AppColors.textColor,
                        ),
                      ),
                      SizedBox(height: getHeight(4)),
                      Text(
                        description,
                        style: AppTextStyles.textStyle(
                          fontSize: getWidth(14),
                          txtColor: AppColors.textColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: color, size: getWidth(16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
