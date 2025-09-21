import 'package:Vadai/common_imports.dart';

class PromptCopiedDialog extends StatelessWidget {
  final VoidCallback onUnderstood;
  const PromptCopiedDialog({Key? key, required this.onUnderstood})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      // backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: getWidth(20),
          vertical: getHeight(20),
        ),
        decoration: BoxDecoration(
          color: AppColors.blueColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            textWid(
              "Your Content and the command prompt has been copied. Please paste it in the desired AI Chatbot to continue the conversation.",
              textAlign: TextAlign.center,
              maxlines: 4,
              style: TextStyle(
                fontSize: getWidth(16),
                fontWeight: FontWeight.w500,
                color: AppColors.white,
              ),
            ),
            SizedBox(height: getHeight(20)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: textWid(
                    "Cancel",
                    style: TextStyle(
                      fontSize: getWidth(16),
                      color: AppColors.white,
                    ),
                  ),
                ),
                MaterialButton(
                  color: AppColors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onPressed: () => onUnderstood(),
                  child: textWid(
                    "Understood",
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

void showPromptCopiedDialog(BuildContext context, VoidCallback onUnderstood) {
  showDialog(
    context: context,
    builder:
        (BuildContext context) =>
            PromptCopiedDialog(onUnderstood: onUnderstood),
  );
}
