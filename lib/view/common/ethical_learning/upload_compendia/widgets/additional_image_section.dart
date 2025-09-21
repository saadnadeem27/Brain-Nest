import 'dart:io';

import 'package:Vadai/common_imports.dart';

class AdditionalImagesSection extends StatelessWidget {
  final RxList<File?> imageList;
  final VoidCallback onPickImages;

  const AdditionalImagesSection({
    Key? key,
    required this.imageList,
    required this.onPickImages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.imageString,
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
          onPressed: onPickImages,
          color: AppColors.transparent,
          borderColor: AppColors.textColor,
          borderRadius: getWidth(5),
          borderWidth: getWidth(1),
        ).paddingOnly(top: getHeight(8)),
        Obx(
          () =>
              imageList.isNotEmpty
                  ? SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imageList.length,
                      itemBuilder:
                          (context, index) => Stack(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(getWidth(4)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.file(
                                    File(imageList[index]?.path ?? ''),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    imageList.removeAt(index);
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
                          ),
                    ),
                  ).paddingOnly(top: 8)
                  : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
