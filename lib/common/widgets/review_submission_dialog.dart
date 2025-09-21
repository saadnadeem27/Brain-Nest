import 'package:Vadai/common_imports.dart';

class ReviewSubmissionDialog extends StatelessWidget {
  final TextEditingController reviewController = TextEditingController();
  final Function(String) onSubmit;

  ReviewSubmissionDialog({Key? key, required this.onSubmit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: getWidth(20),
          vertical: getHeight(20),
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            textWid(
              "Submit for VAD Squad Review",
              style: TextStyle(
                fontSize: getWidth(18),
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            SizedBox(height: getHeight(10)),
            commonTextFiled(
              controller: reviewController,
              hintText: "Kindly review the content and suggest changes",
              borderRadius: getWidth(10),
              maxLines: 6,
            ),
            SizedBox(height: getHeight(10)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: textWid(
                    "Cancel",
                    style: TextStyle(
                      fontSize: getWidth(16),
                      color: AppColors.textColor,
                    ),
                  ),
                ),
                SizedBox(width: getWidth(6)),
                MaterialButton(
                  color: AppColors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onPressed: () {
                    if (reviewController.text.trim().isNotEmpty) {
                      onSubmit(reviewController.text.trim());
                      Get.back();
                    } else {
                      commonSnackBar(message: 'Please enter review details');
                    }
                  },
                  child: textWid(
                    "Submit",
                    style: TextStyle(
                      fontSize: getWidth(16),
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void showReviewSubmissionDialog(
  BuildContext context,
  Function(String) onSubmit,
) {
  showDialog(
    context: context,
    builder:
        (BuildContext context) => ReviewSubmissionDialog(onSubmit: onSubmit),
  );
}
