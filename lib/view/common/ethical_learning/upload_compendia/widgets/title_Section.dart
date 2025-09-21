import 'package:Vadai/common_imports.dart';

class TitleSection extends StatelessWidget {
  final TextEditingController controller;

  const TitleSection({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.title,
          style: TextStyle(fontSize: getWidth(18), fontWeight: FontWeight.bold),
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
            hintText: "Please write the title of your compendium here.",
            maxLines: 2,
            borderRadius: getWidth(10),
          ),
        ).paddingOnly(top: getHeight(8)),
      ],
    );
  }
}
