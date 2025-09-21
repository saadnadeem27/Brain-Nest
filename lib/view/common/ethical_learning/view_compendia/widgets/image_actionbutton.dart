import 'package:Vadai/common/widgets/review_submission_dialog.dart';
import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/common/ethical_learning_controller.dart';
import 'package:Vadai/model/students/compendia_model.dart';

class ImagesSection extends StatelessWidget {
  final List<String>? images;

  const ImagesSection({Key? key, this.images}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (images == null || images!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textWid(
          AppStrings.imageString,
          style: TextStyle(
            color: AppColors.textColor,
            fontWeight: FontWeight.bold,
            fontSize: getWidth(13),
          ),
        ).paddingOnly(top: getHeight(6)),

        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: getWidth(6),
            mainAxisSpacing: getHeight(6),
            childAspectRatio: 1.2,
          ),
          itemCount: images!.length,
          itemBuilder: (context, index) {
            return networkImage(
              image: images![index],
              errorImage: AppAssets.ethicalImg,
            );
          },
        ).paddingOnly(
          top: getHeight(8),
          left: getWidth(16),
          right: getWidth(16),
        ),

        commonDivider(),
      ],
    );
  }
}

class ActionButtonsSection extends StatelessWidget {
  final CompendiaDetailModel? compendiaDetail;
  final EthicalLearningController ethicalCtr;

  const ActionButtonsSection({
    Key? key,
    required this.compendiaDetail,
    required this.ethicalCtr,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPinned =
        (compendiaDetail?.compendium?.isPinned?.value ?? false).obs;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Pin button
            Obx(
              () => materialButtonWithChild(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.push_pin,
                      size: getWidth(16),
                      color:
                          (compendiaDetail?.compendium?.isPinned?.value ??
                                  false)
                              ? AppColors.white
                              : AppColors.textColor,
                    ),
                    Text(
                      AppStrings.pin,
                      style: TextStyle(
                        color:
                            (compendiaDetail?.compendium?.isPinned?.value ??
                                    false)
                                ? AppColors.white
                                : AppColors.textColor,
                        fontSize: getWidth(12),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ).paddingOnly(left: getWidth(6), right: getWidth(6)),
                onPressed: () async {
                  if (compendiaDetail?.compendium?.sId == null) return;

                  if (isPinned.value) {
                    // Update UI first for responsiveness
                    isPinned.value = false;

                    // Then update backend
                    if (compendiaDetail?.compendium?.isPinned != null) {
                      compendiaDetail!.compendium!.isPinned!.value = false;
                    }
                    await ethicalCtr.removePinCompendia(
                      compendiaId: compendiaDetail!.compendium!.sId!,
                    );
                  } else {
                    // Update UI first for responsiveness
                    isPinned.value = true;

                    // Then update backend
                    if (compendiaDetail?.compendium?.isPinned != null) {
                      compendiaDetail!.compendium!.isPinned!.value = true;
                    }
                    await ethicalCtr.pinCompendia(
                      compendiaId: compendiaDetail!.compendium!.sId!,
                    );
                  }
                },
                color:
                    (compendiaDetail?.compendium?.isPinned?.value ?? false)
                        ? AppColors.blueColor
                        : AppColors.transparent,
                borderColor:
                    (compendiaDetail?.compendium?.isPinned?.value ?? false)
                        ? AppColors.blueColor
                        : AppColors.textColor,
                borderRadius: getWidth(10),
                borderWidth: getWidth(1),
              ),
            ),

            // Review button
            materialButtonWithChild(
              child: Text(
                AppStrings.vadSquadReview,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: getWidth(12),
                  fontWeight: FontWeight.w800,
                ),
              ).paddingOnly(left: getWidth(6), right: getWidth(6)),
              onPressed: () {
                if (compendiaDetail?.compendium?.sId != null) {
                  showReviewSubmissionDialog(context, (
                    String reviewText,
                  ) async {
                    await ethicalCtr.submitCompendiaForReview(
                      compendiaId: compendiaDetail?.compendium?.sId ?? '',
                      partToReview: reviewText,
                    );
                  });
                }
              },
              color: AppColors.colorFFE734.withOpacity(0.7),
              borderColor: AppColors.textColor,
              borderRadius: getWidth(10),
              borderWidth: getWidth(1),
            ),

            // Comments button
            materialButtonWithChild(
              child: Text(
                AppStrings.comments,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: getWidth(12),
                  fontWeight: FontWeight.w800,
                ),
              ).paddingOnly(left: getWidth(6), right: getWidth(6)),
              onPressed:
                  () => Get.toNamed(
                    RouteNames.comments,
                    arguments: {
                      'parentId': compendiaDetail?.compendium?.sId,
                      'title': compendiaDetail?.compendium?.title ?? 'Comments',
                    },
                  ),
              color: AppColors.transparent,
              borderColor: AppColors.textColor,
              borderRadius: getWidth(10),
              borderWidth: getWidth(1),
            ),
          ],
        ).paddingOnly(top: getHeight(16), bottom: getHeight(8)),

        commonDivider(),
      ],
    );
  }
}
