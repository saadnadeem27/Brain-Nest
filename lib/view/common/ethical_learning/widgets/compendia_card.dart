import 'package:Vadai/common_imports.dart';
import 'package:Vadai/model/students/compendia_model.dart';
import 'package:Vadai/controller/common/ethical_learning_controller.dart';
import 'package:Vadai/helper/api_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CompendiaCard extends StatelessWidget {
  final CompendiaOverviewModel? item;
  final EthicalLearningController ethicalCtr;
  final VoidCallback? onRefresh;

  const CompendiaCard({
    Key? key,
    required this.item,
    required this.ethicalCtr,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [_buildCardHeader(), _buildCardBody(context)],
    );
  }

  Widget _buildCardHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [_buildRatingBadge(), _buildPinButton()],
    );
  }

  Widget _buildRatingBadge() {
    return (item?.rating != null && (item?.rating ?? 0) > 0)
        ? Container(
          padding: EdgeInsets.symmetric(
            horizontal: getWidth(8),
            vertical: getHeight(1),
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(Icons.star, color: Colors.amber, size: getWidth(16)),
        )
        : const SizedBox.shrink();
  }

  Widget _buildPinButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final index = ethicalCtr.compendia.indexOf(item);
        if (index == -1) {
          return;
        } else {
          if (ethicalCtr.compendia[index]?.isPinned?.value == true) {
            ethicalCtr.compendia[index]?.isPinned?.value = false;
            ethicalCtr.compendia[index]?.pinnedCount.value =
                (ethicalCtr.compendia[index]?.pinnedCount.value ?? 0) - 1;
            await ethicalCtr
                .removePinCompendia(compendiaId: item?.sId ?? '')
                .then((value) {
                  if (value == null || value == false) {
                    ethicalCtr.compendia[index]?.isPinned?.value = true;
                    ethicalCtr.compendia[index]?.pinnedCount.value =
                        (ethicalCtr.compendia[index]?.pinnedCount.value ?? 0) +
                        1;
                  }
                });
          } else {
            ethicalCtr.compendia[index]?.isPinned?.value = true;
            ethicalCtr.compendia[index]?.pinnedCount.value =
                (ethicalCtr.compendia[index]?.pinnedCount.value ?? 0) + 1;
            await ethicalCtr.pinCompendia(compendiaId: item?.sId ?? '').then((
              value,
            ) {
              if (value == null || value == false) {
                ethicalCtr.compendia[index]?.isPinned?.value = false;
                ethicalCtr.compendia[index]?.pinnedCount.value =
                    (ethicalCtr.compendia[index]?.pinnedCount.value ?? 0) - 1;
              }
            });
          }
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: getWidth(8),
          vertical: getHeight(1),
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child:
            (item?.pinnedCount.value ?? 0) > 0
                ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.push_pin,
                      color:
                          item?.isPinned?.value == true
                              ? AppColors.blueColor
                              : AppColors.textColor,
                      size: getWidth(16),
                    ),
                    SizedBox(width: getWidth(2)),
                    Text(
                      (item?.pinnedCount.value ?? '').toString(),
                      style: TextStyle(
                        fontSize: getWidth(12),
                        fontWeight: FontWeight.w600,
                        color:
                            item?.isPinned?.value == true
                                ? AppColors.blueColor
                                : AppColors.textColor,
                      ),
                    ),
                  ],
                )
                : Icon(
                  Icons.push_pin,
                  color: AppColors.textColor,
                  size: getWidth(16),
                ),
      ),
    );
  }

  Widget _buildCardBody(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(),
          _buildImage(),
          _buildAuthorBar(),
          _buildStartButton(context),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return AutoScrollTitle(
      text: item?.title ?? '',
      style: TextStyle(
        fontSize: getWidth(12),
        fontWeight: FontWeight.w600,
        color: AppColors.textColor,
      ),
    ).paddingOnly(top: getHeight(4), right: getWidth(4), left: getWidth(4));
  }

  Widget _buildImage() {
    return item?.coverImage != null && item!.coverImage!.isNotEmpty
        ? SizedBox(
          height: getHeight(120),
          width: double.infinity,
          child: CachedNetworkImage(
            imageUrl: item!.coverImage!,
            fit: BoxFit.cover,
            placeholder:
                (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
            errorWidget:
                (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.error_outline,
                    size: getWidth(40),
                    color: Colors.red,
                  ),
                ),
            memCacheWidth: 800,
            memCacheHeight: 400,
          ),
        ).paddingOnly(top: getHeight(4))
        : assetImage(
          image: AppAssets.ethicalImg,
          fit: BoxFit.fitWidth,
        ).paddingOnly(top: getHeight(4));
  }

  Widget _buildAuthorBar() {
    return Container(
      color: AppColors.textColor2.withOpacity(0.7),
      width: double.infinity,
      child: Text(
        item?.createdBy ?? '',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: getWidth(10),
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
      ).paddingOnly(
        top: getHeight(4),
        right: getWidth(4),
        left: getWidth(4),
        bottom: getHeight(4),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return materialButtonWithChild(
      onPressed:
          () => Get.toNamed(
            RouteNames.viewCompendia,
            arguments: {ApiParameter.compendiaId: item?.sId},
          )?.then((value) async {
            if (value != null && onRefresh != null) {
              onRefresh!();
            }
          }),
      borderRadiusOnly: const BorderRadius.only(
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(10),
      ),
      child: Container(
        padding: EdgeInsets.only(
          left: getWidth(16),
          right: getWidth(16),
          top: getHeight(8),
          bottom: getHeight(8),
        ),
        child: Center(
          child: textWid(
            AppStrings.start,
            style: AppTextStyles.textStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              txtColor: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}
