import 'package:Vadai/model/students/subject_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:Vadai/common/App_strings.dart';
import 'package:Vadai/common/app_colors.dart';
import 'package:Vadai/common/assets.dart';
import 'package:Vadai/common/common_widgets.dart';
import 'package:Vadai/common/size_config.dart';
import 'package:Vadai/routes.dart';

class CurriculumScreen extends StatefulWidget {
  const CurriculumScreen({super.key});

  @override
  State<CurriculumScreen> createState() => _CurriculumScreenState();
}

class _CurriculumScreenState extends State<CurriculumScreen> {
  SubjectModel? currentSubject;
  String? comingFrom;

  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    var data = Get.arguments;
    if (data != null) {
      currentSubject = data?[AppStrings.subjects];
      comingFrom = data?[AppStrings.comingFrom];
    }
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      appBar: commonAppBar(
        context: context,
        title: AppStrings.vadaiCurriculum,
        isBack: true,
        actions: [],
      ),
      body: commonPadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row(
            SizedBox(height: getHeight(32)),
            _buildCurriculum(
              text: 'Learn Hub',
              onTap: () {
                Get.toNamed(
                  RouteNames.chaptersScreen,
                  arguments: {
                    AppStrings.comingFrom: AppStrings.curriculum,
                    AppStrings.subjects: currentSubject,
                  },
                );
              },
              des:
                  'Study the VAD AI General Curriculum and stay aligned with what students everywhere are learning.',
            ),
            SizedBox(height: getHeight(36)),
            _buildCurriculum(
              text: 'Test Hub',
              onTap: () {
                Get.toNamed(
                  RouteNames.chaptersScreen,
                  arguments: {
                    'isTest': true,
                    AppStrings.comingFrom: AppStrings.curriculum,
                    AppStrings.subjects: currentSubject,
                  },
                );
              },
              des:
                  'Challenge yourself with tests aligned to the VAD AI General Curriculum which you learnt from the Learn Hub.',
              color: AppColors.red.withOpacity(0.9),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurriculum({
    Color? color = AppColors.blueColor,
    required String text,
    required String des,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(
          top: getHeight(18),
          bottom: getHeight(32),
          left: getWidth(32),
          right: getWidth(32),
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(getWidth(16)),
        ),
        child: Column(
          children: [
            SizedBox(height: getHeight(8)),
            Container(
              padding: EdgeInsets.only(top: getHeight(8), bottom: getHeight(8)),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: getWidth(1)),
                borderRadius: BorderRadius.circular(getWidth(16)),
              ),
              child: Center(
                child: textWid(
                  text,
                  style: TextStyle(
                    fontSize: getWidth(16),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: getHeight(16)),
            commonPadding(
              child: textWid(
                des,
                style: TextStyle(
                  fontSize: getWidth(11),
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
                maxlines: 2,
                textOverflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
