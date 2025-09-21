import 'package:Vadai/common_imports.dart';

class ContentSection extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onImageTap;

  const ContentSection({
    Key? key,
    required this.controller,
    required this.onImageTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.content,
              style: TextStyle(
                fontSize: getWidth(18),
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: onImageTap,
              child: const Icon(
                Icons.image_outlined,
                color: AppColors.textColor,
              ).paddingOnly(left: getWidth(8)),
            ),
          ],
        ),
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
            controller: controller,
            hintText: "Copy & paste the textual part of your compendium here.",
            borderRadius: getWidth(10),
            maxLines: 25,
            keyBoardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
          ),
        ).paddingOnly(top: getHeight(8)),
      ],
    );
  }
}
