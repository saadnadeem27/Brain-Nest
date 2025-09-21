import 'package:brain_nest/common/common_widgets.dart';
import 'package:brain_nest/common/size_config.dart';
import 'package:brain_nest/common_imports.dart';
import 'package:image_picker/image_picker.dart';

class ImageSourceOption extends StatelessWidget {
  final ImageSource source;
  final String text;
  final IconData icon;
  final bool isContentImage;
  final VoidCallback onTap;

  const ImageSourceOption({
    Key? key,
    required this.source,
    required this.text,
    required this.icon,
    required this.isContentImage,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: getWidth(100),
        child: Column(
          children: [
            CircleAvatar(
              radius: getHeight(25),
              backgroundColor: AppColors.black,
              child: Icon(icon, color: AppColors.white),
            ),
            sizeBoxHeight(8),
            textWid(
              text,
              textAlign: TextAlign.center,
              maxlines: 2,
              textOverflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
