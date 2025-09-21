import 'package:Vadai/common_imports.dart';

class ProfileDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final double? fontSize;

  const ProfileDetailRow({
    Key? key,
    required this.label,
    required this.value,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.textStyle(
            txtColor: AppColors.textColor,
            fontSize: fontSize ?? getWidth(16),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTextStyles.textStyle(
              txtColor: AppColors.black,
              fontSize: fontSize ?? getWidth(16),
              fontWeight: FontWeight.w600,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
