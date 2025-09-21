import 'package:Vadai/common_imports.dart';

class CompendiaCardWidget extends StatelessWidget {
  final dynamic item;
  final VoidCallback onTap;

  const CompendiaCardWidget({Key? key, required this.item, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (item == null || item.sId == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
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
        children: [
          // Title and rating section
          Row(
            children: [
              // Rating star if applicable
              Align(
                alignment: Alignment.topLeft,
                child: Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: getWidth(16),
                ),
              ).paddingOnly(right: getWidth(8)),

              // Title
              Expanded(
                child: AutoScrollTitle(
                  text: item.title ?? '',
                  style: TextStyle(
                    fontSize: getWidth(12),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ).paddingOnly(top: getHeight(4), right: getWidth(4)),
              ),
            ],
          ),

          // Cover image section
          SizedBox(
            child: Stack(
              children: [
                // Cover image
                item.coverImage != null
                    ? networkImage(
                      image: item.coverImage ?? '',
                      errorImage: AppAssets.ethicalImg,
                      fit: BoxFit.fitWidth,
                    ).paddingOnly(top: getHeight(4))
                    : assetImage(
                      image: AppAssets.ethicalImg,
                      fit: BoxFit.fitWidth,
                    ).paddingOnly(top: getHeight(4)),

                // Pin count indicator
                if ((item.pinnedCount ?? 0) > 0)
                  Positioned(
                    top: getHeight(8),
                    right: getWidth(0),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: getWidth(8)),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.push_pin,
                            color: AppColors.white,
                            size: getWidth(16),
                          ),
                          SizedBox(width: getWidth(2)),
                          Text(
                            item.pinnedCount.toString(),
                            style: TextStyle(
                              fontSize: getWidth(12),
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ).paddingOnly(left: getWidth(4), right: getWidth(4)),

          // Author section
          Container(
            color: AppColors.textColor2.withOpacity(0.7),
            width: double.infinity,
            child: Text(
              'By Rahul', // Replace with actual author when available
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
          ),

          // Start button
          materialButtonWithChild(
            onPressed: onTap,
            borderRadiusOnly: const BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: getWidth(16),
                vertical: getHeight(8),
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
          ),
        ],
      ),
    );
  }
}
