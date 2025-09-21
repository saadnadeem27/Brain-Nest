import 'package:Vadai/model/students/vad_test_model.dart';
import 'package:Vadai/view/student/vad_test/screens/vad_test_list_screen.dart';
import '../../../../common_imports.dart';

class VadTestItemCard extends StatelessWidget {
  final VadTestModel test;
  final TestType testType;
  final VoidCallback? onSyllabus;
  final VoidCallback? onAttempt;
  final VoidCallback? onReport;

  const VadTestItemCard({
    Key? key,
    required this.test,
    required this.testType,
    this.onSyllabus,
    this.onAttempt,
    this.onReport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(getWidth(12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Test header with date and status
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: getWidth(16),
              vertical: getHeight(12),
            ),
            decoration: BoxDecoration(
              color: _getHeaderColor(),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(getWidth(12)),
                topRight: Radius.circular(getWidth(12)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: getWidth(12),
                    vertical: getHeight(4),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(getWidth(16)),
                  ),
                  child: Text(
                    _formatDate(test.date),
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: getWidth(12),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Test content
          Padding(
            padding: EdgeInsets.all(getWidth(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Test topics
                if (test.topics != null && test.topics!.isNotEmpty)
                  _buildInfoRow('Topics', test.topics!, Icons.topic),

                // Number of topics
                if (test.numberOfTopics != null)
                  _buildInfoRow(
                    'Number of Topics',
                    test.numberOfTopics.toString(),
                    Icons.format_list_numbered,
                  ),

                // Additional info if available
                if (test.additionalInfo != null &&
                    test.additionalInfo!.isNotEmpty)
                  _buildInfoRow(
                    'Additional Info',
                    test.additionalInfo!,
                    Icons.info_outline,
                  ),

                SizedBox(height: getHeight(16)),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (testType != TestType.past) ...[
                      _buildButton(
                        'Syllabus',
                        Icons.menu_book,
                        AppColors.blueColor,
                        onSyllabus,
                      ),
                      SizedBox(width: getWidth(12)),
                    ],

                    if (testType == TestType.live)
                      _buildButton(
                        'Attempt',
                        Icons.play_arrow,
                        AppColors.green,
                        onAttempt,
                      ),

                    if (testType == TestType.past)
                      _buildButton(
                        'View Report',
                        Icons.assessment,
                        AppColors.blueColor,
                        onReport,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: getHeight(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: getWidth(18), color: AppColors.blueColor),
          SizedBox(width: getWidth(8)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: getWidth(12),
                    color: AppColors.textColor.withOpacity(0.8),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: getWidth(14),
                    fontWeight: FontWeight.w500,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: getWidth(16)),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: getWidth(12),
          vertical: getHeight(8),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(getWidth(20)),
        ),
      ),
    );
  }

  Color _getHeaderColor() {
    switch (testType) {
      case TestType.upcoming:
        return AppColors.blueColor;
      case TestType.live:
        return AppColors.green;
      case TestType.past:
        return AppColors.blueColor;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return "No date";
    }

    try {
      final date = DateTime.parse(dateString);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      return dateString;
    }
  }
}
