import 'package:Vadai/common_imports.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/svg.dart';

class VADTestSubjectContainer extends StatefulWidget {
  final String subjectName;
  final String date;
  final String subjectIntro;
  final VoidCallback? onContinue;
  final bool isNetwork;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? dateBackgroundColor;
  final Color? continueBtnColor;
  final Color? continueBtnTextColor;
  final String? continueText;
  final double? height;
  final Widget? customSubjectImage;

  const VADTestSubjectContainer({
    super.key,
    required this.subjectName,
    required this.date,
    required this.subjectIntro,
    this.onContinue,
    this.isNetwork = false,
    this.backgroundColor,
    this.textColor,
    this.dateBackgroundColor,
    this.continueBtnColor,
    this.continueBtnTextColor,
    this.continueText,
    this.height,
    this.customSubjectImage,
  });

  @override
  State<VADTestSubjectContainer> createState() =>
      _VADTestSubjectContainerState();
}

class _VADTestSubjectContainerState extends State<VADTestSubjectContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: widget.height ?? getHeight(173),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppColors.blueColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Stack(
        children: [
          Positioned(
            left: getWidth(22),
            top: getHeight(22),
            child: textWid(
              widget.subjectName,
              style: AppTextStyles.textStyle(
                txtColor: widget.textColor ?? AppColors.white,
                fontSize: getWidth(18),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Positioned(
            right: getWidth(10),
            top: getHeight(18),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: getWidth(12),
                vertical: getHeight(4),
              ),
              decoration: BoxDecoration(
                color:
                    widget.dateBackgroundColor ??
                    AppColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: textWid(
                widget.date,
                style: AppTextStyles.textStyle(
                  txtColor: widget.textColor ?? AppColors.white,
                  fontSize: getWidth(12),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: getWidth(18),
            child: assetImage(
              customHeight: 90,
              image: AppAssets.boxShadow,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            right: getWidth(45),
            bottom: getHeight(40),
            child:
                widget.customSubjectImage ??
                (widget.isNetwork
                    ? (widget.subjectIntro.toLowerCase().endsWith('.svg')
                        ? SvgPicture.network(
                          widget.subjectIntro,
                          width: getWidth(100),
                          fit: BoxFit.contain,
                          placeholderBuilder:
                              (BuildContext context) => Center(
                                child: SizedBox(
                                  width: getWidth(30),
                                  height: getWidth(30),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: widget.textColor ?? AppColors.white,
                                  ),
                                ),
                              ),
                        )
                        : CachedNetworkImage(
                          imageUrl: widget.subjectIntro,
                          width: getWidth(100),
                          fit: BoxFit.contain,
                          placeholder:
                              (context, url) => Center(
                                child: SizedBox(
                                  width: getWidth(30),
                                  height: getWidth(30),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: widget.textColor ?? AppColors.white,
                                  ),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Icon(
                                Icons.error_outline,
                                size: getWidth(30),
                                color: widget.textColor ?? AppColors.white,
                              ),
                        ))
                    : assetImage(
                      customWidth: getWidth(100),
                      image: widget.subjectIntro,
                      fit: BoxFit.contain,
                    )),
          ),
          Positioned(
            left: getWidth(22),
            bottom: getHeight(33),
            child: GestureDetector(
              onTap: widget.onContinue,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.continueBtnColor ?? AppColors.white,
                  borderRadius: BorderRadius.circular(getWidth(42)),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: getWidth(16),
                  vertical: getHeight(5),
                ),
                child: textWid(
                  widget.continueText ?? AppStrings.continueString,
                  style: AppTextStyles.textStyle(
                    txtColor:
                        widget.continueBtnTextColor ?? AppColors.textColor,
                    fontSize: getWidth(15),
                    fontWeight: FontWeight.w600,
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
