import 'package:Vadai/common_imports.dart';
import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/model/students/compendia_model.dart';
import 'package:Vadai/view/common/ethical_learning/view_compendia/screens/view_compendia.dart';
import 'package:Vadai/view/common/ethical_learning/view_compendia/widgets/compendia_card_widget.dart';

class ContinuedFromSection extends StatelessWidget {
  final ContinuedFrom? continuedFrom;
  final Function(String) onRefresh;

  const ContinuedFromSection({
    Key? key,
    required this.continuedFrom,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (continuedFrom == null || continuedFrom!.sId == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textWid(
          AppStrings.continuedFrom,
          style: TextStyle(
            color: AppColors.textColor,
            fontWeight: FontWeight.bold,
            fontSize: getWidth(13),
          ),
        ).paddingOnly(top: getHeight(18)),

        GestureDetector(
          onTap: () => onRefresh(continuedFrom!.sId!),
          child: CompendiaCardWidget(
            item: continuedFrom,
            onTap: () => onRefresh(continuedFrom!.sId!),
          ),
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

class ContinuationsSection extends StatelessWidget {
  final List<Continuations?>? continuations;
  final Function(String) onRefresh;

  const ContinuationsSection({
    Key? key,
    required this.continuations,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (continuations == null || continuations!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textWid(
          AppStrings.continuations,
          style: TextStyle(
            color: AppColors.textColor,
            fontWeight: FontWeight.bold,
            fontSize: getWidth(13),
          ),
        ).paddingOnly(top: getHeight(18)),

        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: getWidth(16),
            mainAxisSpacing: getHeight(16),
            childAspectRatio: 0.71,
          ),
          itemCount: continuations!.length,
          itemBuilder: (context, index) {
            return CompendiaCardWidget(
              item: continuations![index],
              onTap: () => onRefresh(continuations![index]?.sId ?? ''),
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

class CreateContinuationButton extends StatelessWidget {
  final String? compendiaId;

  const CreateContinuationButton({Key? key, this.compendiaId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: materialButtonWithChild(
        width: double.infinity,
        color: AppColors.transparent,
        borderColor: AppColors.textColor,
        borderWidth: getWidth(1),
        borderRadius: getWidth(10),
        onPressed:
            () => Get.toNamed(
              RouteNames.uploadCompendia,
              arguments: {ApiParameter.continuedFrom: compendiaId},
            )?.then((value) {
              if (value != null) {
                Get.back(result: true);
              }
            }),
        child: textWid(
          AppStrings.createContinuationCompendium,
          style: TextStyle(
            color: AppColors.textColor,
            fontWeight: FontWeight.bold,
            fontSize: getWidth(16),
          ),
        ).paddingOnly(top: getHeight(8), bottom: getHeight(8)),
      ).paddingOnly(left: getWidth(16), right: getWidth(16), top: getHeight(8)),
    );
  }
}
