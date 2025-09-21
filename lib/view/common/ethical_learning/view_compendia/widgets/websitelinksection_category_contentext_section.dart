import 'package:Vadai/common_imports.dart';
import 'package:Vadai/model/students/compendia_model.dart';
import 'package:flutter/services.dart';

class ContentTextSection extends StatelessWidget {
  final TextEditingController contentController;

  const ContentTextSection({Key? key, required this.contentController})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.grey,
                spreadRadius: getWidth(4),
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: commonTextFiled(
            controller: contentController,
            contentPadding: EdgeInsets.only(
              left: getWidth(16),
              right: getWidth(16),
              top: getHeight(16),
              bottom: getHeight(16),
            ),
            hintText: "Copy & paste the textual part of your compendium here.",
            readOnly: true,
            borderRadius: getWidth(10),
            maxLines: null,
          ),
        ).paddingOnly(top: getHeight(8)),

        Align(
          alignment: Alignment.centerRight,
          child: materialButtonWithChild(
            color: AppColors.color949494,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: contentController.text));
              commonSnackBar(message: AppStrings.copiedToClipBoard);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.copy_outlined, size: getWidth(18)),
                Text(
                  AppStrings.copyContents,
                  style: TextStyle(
                    fontSize: getWidth(12),
                    fontWeight: FontWeight.bold,
                  ),
                ).paddingOnly(left: getWidth(4)),
              ],
            ).paddingOnly(left: getWidth(8), right: getWidth(8)),
          ),
        ).paddingOnly(top: getHeight(16)),

        commonDivider(),
      ],
    );
  }
}

class CategoryInfoSection extends StatelessWidget {
  final CompendiaDetailModel? compendiaDetail;

  const CategoryInfoSection({Key? key, required this.compendiaDetail})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CategoryTextItem(
          title: AppStrings.category,
          content: compendiaDetail?.compendium?.category ?? '',
        ).paddingOnly(top: getHeight(6)),

        CategoryTextItem(
          title: AppStrings.subCategory,
          content: compendiaDetail?.compendium?.subcategory ?? '',
        ).paddingOnly(top: getHeight(6)),
      ],
    );
  }
}

class CategoryTextItem extends StatelessWidget {
  final String title;
  final String content;

  const CategoryTextItem({Key? key, required this.title, required this.content})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textWid(
          title,
          style: TextStyle(
            color: AppColors.textColor,
            fontWeight: FontWeight.bold,
            fontSize: getWidth(13),
          ),
        ).paddingOnly(right: getWidth(8)),

        Expanded(
          child: textWid(
            content,
            style: TextStyle(
              color: AppColors.textColor,
              fontSize: getWidth(12),
            ),
          ),
        ),
      ],
    );
  }
}

class WebsiteLinksSection extends StatelessWidget {
  final List<String>? links;

  const WebsiteLinksSection({Key? key, this.links}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (links == null || links!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            textWid(
              AppStrings.websiteLink,
              style: TextStyle(
                color: AppColors.textColor,
                fontWeight: FontWeight.bold,
                fontSize: getWidth(13),
              ),
            ).paddingOnly(right: getWidth(8)),

            Expanded(
              child: Wrap(
                spacing: getWidth(5),
                runSpacing: getHeight(0),
                children:
                    links!
                        .map(
                          (link) => GestureDetector(
                            onTap: () => launchUrl(link),
                            child: textWid(
                              link,
                              style: TextStyle(
                                color: AppColors.blueColor,
                                fontSize: getWidth(12),
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ],
        ).paddingOnly(top: getHeight(6)),

        commonDivider(),
      ],
    );
  }
}
