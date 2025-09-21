import 'package:Vadai/common/widgets/prompt_copied_dialog.dart';
import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/common/ethical_learning_controller.dart';
import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/helper/local_storage_helper.dart';
import 'package:Vadai/model/students/compendia_model.dart';
import 'package:Vadai/view/common/ethical_learning/view_compendia/screens/compendia_quiz.dart';
import 'package:Vadai/view/common/ethical_learning/view_compendia/widgets/compendia_content_view.dart';
import 'package:flutter/services.dart';

class ViewCompendia extends StatefulWidget {
  const ViewCompendia({super.key});

  @override
  State<ViewCompendia> createState() => _ViewCompendiaState();
}

class _ViewCompendiaState extends State<ViewCompendia> {
  EthicalLearningController ethicalCtr = Get.find();
  String? compendiaId;
  RxBool isLoading = false.obs;
  CompendiaDetailModel? compendiaDetail;
  RxString compendiumTitle = ''.obs;
  TextEditingController contentController = TextEditingController(
    text: AppStrings.compendiaContent,
  );

  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  void dispose() {
    super.dispose();
    contentController.dispose();
  }

  void initData() async {
    isLoading.value = true;
    if (Get.arguments != null &&
        Get.arguments[ApiParameter.compendiaId] != null) {
      compendiaId = Get.arguments[ApiParameter.compendiaId];
    }
    try {
      await ethicalCtr.getCompendia(compendiaId: compendiaId ?? '').then((
        CompendiaDetailModel? value,
      ) {
        if (value != null) {
          compendiaDetail = value;
          compendiumTitle.value = compendiaDetail?.compendium?.title ?? '';
          contentController.text = compendiaDetail?.compendium?.contents ?? '';
        }
      });
    } finally {
      isLoading.value = false;
    }
  }

  void refreshData(String id) async {
    isLoading.value = true;
    try {
      await ethicalCtr.getCompendia(compendiaId: id).then((
        CompendiaDetailModel? value,
      ) {
        if (value != null) {
          compendiaDetail = value;
          compendiumTitle.value = compendiaDetail?.compendium?.title ?? '';
          contentController.text = compendiaDetail?.compendium?.contents ?? '';
        }
      });
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => commonScaffold(
        context: context,
        appBar: commonAppBar(
          context: context,
          isBack: true,
          title: compendiumTitle.value,
          actions: [],
        ),
        body:
            isLoading.value
                ? commonLoader()
                : CompendiaContentView(
                  compendiaDetail: compendiaDetail,
                  contentController: contentController,
                  ethicalCtr: ethicalCtr,
                  onRefreshData: refreshData,
                ),
      ),
    );
  }
}

class AuthorInfoSection extends StatelessWidget {
  final CompendiaDetailModel? compendiaDetail;

  const AuthorInfoSection({Key? key, required this.compendiaDetail})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        commonDivider().paddingOnly(top: getHeight(18), bottom: getHeight(6)),

        textWid(
          '${AppStrings.nameOfTheCourseCreator}: ${compendiaDetail?.compendium?.createdBy ?? ''}',
          style: TextStyle(
            color: AppColors.textColor,
            fontWeight: FontWeight.w400,
            fontSize: getWidth(13),
          ),
        ),

        if (compendiaDetail?.compendium?.className != null)
          textWid(
            '${AppStrings.className}: ${compendiaDetail?.compendium?.className ?? ''}',
            style: TextStyle(
              color: AppColors.textColor,
              fontWeight: FontWeight.w400,
              fontSize: getWidth(13),
            ),
          ).paddingOnly(top: getHeight(6)),

        if (compendiaDetail?.compendium?.createdAt != null)
          textWid(
            "${AppStrings.dateOfUpload}: ${formatDate(compendiaDetail?.compendium?.createdAt ?? '')}",
            style: TextStyle(
              color: AppColors.textColor,
              fontWeight: FontWeight.w400,
              fontSize: getWidth(13),
            ),
          ).paddingOnly(top: getHeight(6)),

        commonDivider(),
      ],
    );
  }
}

class BottomActionButtons extends StatelessWidget {
  final CompendiaDetailModel? compendiaDetail;

  const BottomActionButtons({Key? key, required this.compendiaDetail})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: materialButtonWithChild(
            width: double.infinity,
            onPressed:
                compendiaDetail?.compendium?.sId != null
                    ? () async {
                      final ethicalCtr = Get.find<EthicalLearningController>();
                      final prompt = await ethicalCtr.generateCompendiaPrompt(
                        compendiaId: compendiaDetail!.compendium!.sId!,
                      );

                      if (prompt != null) {
                        await Clipboard.setData(ClipboardData(text: prompt));
                        showPromptCopiedDialog(context, () {
                          Get.back();
                          Get.toNamed(RouteNames.aiScreen);
                        });
                      } else {}
                    }
                    : null,
            child: textWid(
              AppStrings.aIMagic,
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: getWidth(16),
              ),
            ).paddingOnly(top: getHeight(8), bottom: getHeight(8)),
          ).paddingOnly(
            top: getHeight(24),
            left: getWidth(16),
            right: getWidth(16),
          ),
        ),
        if (compendiaDetail?.compendium?.mCQs?.isNotEmpty ?? false)
          Center(
            child: materialButtonWithChild(
              width: double.infinity,
              color: AppColors.textColor,
              onPressed:
                  (compendiaDetail?.compendium?.mCQs != null &&
                          (compendiaDetail?.compendium?.mCQs?.isNotEmpty ??
                              false))
                      ? () {
                        Get.to(
                          () => const CompendiaQuiz(),
                          arguments: {
                            'mcqs': compendiaDetail?.compendium?.mCQs,
                            'title': compendiaDetail?.compendium?.title,
                            'compendiaId': compendiaDetail?.compendium?.sId,
                          },
                        );
                      }
                      : null,
              child: textWid(
                AppStrings.takeTheQuiz,
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: getWidth(16),
                ),
              ).paddingOnly(top: getHeight(8), bottom: getHeight(8)),
            ).paddingOnly(
              top: getHeight(12),
              left: getWidth(16),
              right: getWidth(16),
            ),
          ),
      ],
    );
  }
}
