import '../../../../common_imports.dart';

class TeachingAssignmentCard extends StatelessWidget {
  final Map<String, dynamic> assignment;
  final int index;
  final Function(int) onRemove;
  final Function(Map<String, dynamic>) onEditSubject;

  const TeachingAssignmentCard({
    required this.assignment,
    required this.index,
    required this.onRemove,
    required this.onEditSubject,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMainClass = assignment['isMainClass'] == true;
    final bool hasSubject =
        assignment['subjectName'] != null &&
        assignment['subjectName'].isNotEmpty;

    return Container(
      margin: EdgeInsets.only(bottom: getHeight(12)),
      padding: EdgeInsets.all(getWidth(12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color:
              isMainClass ? AppColors.blueColor : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isMainClass),
          Divider(height: getHeight(16)),
          _buildSubjectSection(hasSubject),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isMainClass) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (isMainClass)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: getWidth(8),
                        vertical: getHeight(2),
                      ),
                      margin: EdgeInsets.only(right: getWidth(8)),
                      decoration: BoxDecoration(
                        color: AppColors.blueColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "Main Class",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: getWidth(10),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      "${assignment['className']} - ${assignment['sectionName']}",
                      style: AppTextStyles.textStyle(
                        fontSize: getWidth(16),
                        fontWeight: FontWeight.w600,
                        txtColor: AppColors.textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Show delete button for non-main classes
        if (!isMainClass)
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: Colors.red,
              size: getWidth(20),
            ),
            onPressed: () => onRemove(index),
          ),
      ],
    );
  }

  Widget _buildSubjectSection(bool hasSubject) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.book_outlined,
              color: AppColors.blueColor,
              size: getWidth(16),
            ),
            SizedBox(width: getWidth(8)),
            Text(
              "Subject:",
              style: AppTextStyles.textStyle(
                fontSize: getWidth(14),
                fontWeight: FontWeight.w500,
                txtColor: AppColors.textColor,
              ),
            ),
          ],
        ),
        SizedBox(height: getHeight(8)),
        if (!hasSubject) _buildNoSubjectView() else _buildSubjectView(),
      ],
    );
  }

  Widget _buildNoSubjectView() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: getHeight(8)),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              "No subject selected yet",
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ),
          Expanded(
            flex: 3,
            child: materialButtonWithChild(
              onPressed: () => onEditSubject(assignment),
              color: AppColors.blueColor.withOpacity(0.1),
              borderColor: AppColors.blueColor,
              borderRadius: 8,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add,
                    color: AppColors.blueColor,
                    size: getWidth(16),
                  ),
                  SizedBox(width: getWidth(4)),
                  Text(
                    "Select Subject",
                    style: TextStyle(
                      color: AppColors.blueColor,
                      fontSize: getWidth(12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectView() {
    return Container(
      margin: EdgeInsets.only(top: getHeight(4)),
      padding: EdgeInsets.symmetric(
        horizontal: getWidth(12),
        vertical: getHeight(8),
      ),
      decoration: BoxDecoration(
        color: AppColors.blueColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.blueColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              assignment['subjectName'] ?? '',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.blueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
