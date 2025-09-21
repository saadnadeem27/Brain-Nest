import 'dart:io';

import 'package:Vadai/common_imports.dart';

class CoverImageSection extends StatelessWidget {
  final Rx<File?> coverImage;
  final VoidCallback onSelectImage;

  const CoverImageSection({
    Key? key,
    required this.coverImage,
    required this.onSelectImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.coverImage,
          style: TextStyle(fontSize: getWidth(18), fontWeight: FontWeight.bold),
        ),
        materialButtonWithChild(
          child: Text(
            AppStrings.addImage,
            style: TextStyle(
              color: AppColors.textColor,
              fontSize: getWidth(16),
            ),
          ).paddingOnly(left: getWidth(16), right: getWidth(16)),
          onPressed: onSelectImage,
          color: AppColors.transparent,
          borderColor: AppColors.textColor,
          borderRadius: getWidth(5),
          borderWidth: getWidth(1),
        ).paddingOnly(top: getHeight(8)),
        Obx(
          () =>
              coverImage.value != null
                  ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.file(
                          File(coverImage.value?.path ?? ''),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            coverImage.value = null;
                          },
                          child: CircleAvatar(
                            radius: getWidth(12),
                            backgroundColor: AppColors.red,
                            child: Icon(
                              Icons.close,
                              size: getWidth(18),
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ).paddingOnly(top: 8)
                  : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
