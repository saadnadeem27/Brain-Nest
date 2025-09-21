import 'package:Vadai/common_imports.dart';
import 'package:Vadai/model/students/subject_model.dart';

class SubjectSelectItem extends StatelessWidget {
  final SubjectModel? subject;
  final bool isSelected;
  final VoidCallback onSelect;

  const SubjectSelectItem({
    required this.subject,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: getHeight(8)),
        padding: EdgeInsets.all(getWidth(12)),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.blueColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isSelected ? AppColors.blueColor : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: getWidth(24),
              height: getWidth(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.blueColor : Colors.white,
                border: Border.all(
                  color: isSelected ? AppColors.blueColor : Colors.grey,
                  width: 2,
                ),
              ),
              child:
                  isSelected
                      ? Icon(
                        Icons.check,
                        size: getWidth(16),
                        color: Colors.white,
                      )
                      : null,
            ),
            SizedBox(width: getWidth(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject?.subjectName ?? '',
                    style: TextStyle(
                      fontSize: getWidth(14),
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColor,
                    ),
                  ),
                  if (subject?.subjectId != null)
                    Text(
                      "Code: ${subject?.subjectId}",
                      style: TextStyle(
                        fontSize: getWidth(12),
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
