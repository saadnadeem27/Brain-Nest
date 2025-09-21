import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/common/ethical_learning_controller.dart';
import 'package:Vadai/model/students/compendia_model.dart';
import 'package:Vadai/view/common/ethical_learning/view_compendia/screens/view_compendia.dart';
import 'package:Vadai/view/common/ethical_learning/view_compendia/widgets/continued_continuation_createcontinuatino.dart';
import 'package:Vadai/view/common/ethical_learning/view_compendia/widgets/image_actionbutton.dart';
import 'package:Vadai/view/common/ethical_learning/view_compendia/widgets/websitelinksection_category_contentext_section.dart';

class CompendiaContentView extends StatelessWidget {
  final CompendiaDetailModel? compendiaDetail;
  final TextEditingController contentController;
  final EthicalLearningController ethicalCtr;
  final Function(String) onRefreshData;

  const CompendiaContentView({
    Key? key,
    required this.compendiaDetail,
    required this.contentController,
    required this.ethicalCtr,
    required this.onRefreshData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ContentTextSection(contentController: contentController),

          // Category and subcategory
          CategoryInfoSection(compendiaDetail: compendiaDetail),

          // Website links if available
          WebsiteLinksSection(links: compendiaDetail?.compendium?.websiteLinks),

          // Images section if available
          ImagesSection(images: compendiaDetail?.compendium?.images),

          // Action buttons (Pin, Review, Comments)
          ActionButtonsSection(
            compendiaDetail: compendiaDetail,
            ethicalCtr: ethicalCtr,
          ),

          // Continued from section
          if (compendiaDetail?.continuedFrom != null &&
              compendiaDetail?.continuedFrom?.sId != null)
            ContinuedFromSection(
              continuedFrom: compendiaDetail?.continuedFrom,
              onRefresh: onRefreshData,
            ),

          // Continuations section
          if (compendiaDetail?.continuations != null &&
              compendiaDetail?.continuations?.isEmpty == false)
            ContinuationsSection(
              continuations: compendiaDetail?.continuations,
              onRefresh: onRefreshData,
            ),

          // Create continuation button
          CreateContinuationButton(
            compendiaId: compendiaDetail?.compendium?.sId,
          ),

          // Author info section
          AuthorInfoSection(compendiaDetail: compendiaDetail),
          BottomActionButtons(compendiaDetail: compendiaDetail),
        ],
      ).paddingOnly(
        left: getWidth(16),
        right: getWidth(16),
        bottom: getHeight(28),
      ),
    );
  }
}
