import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/teachers/teacher_progress_tracking_controller.dart';
import 'package:Vadai/model/teachers/teacher_schoolexam_progress_model.dart';

class SubtopicsScreen extends StatefulWidget {
  const SubtopicsScreen({Key? key}) : super(key: key);

  @override
  State<SubtopicsScreen> createState() => _SubtopicsScreenState();
}

class _SubtopicsScreenState extends State<SubtopicsScreen> {
  final TeacherProgressTrackingController controller =
      Get.find<TeacherProgressTrackingController>();

  String topicName = "";
  List<Subtopic> subtopics = [];
  String classId = "";
  String sectionId = "";
  String className = "";
  String sectionName = "";
  String subjectName = "";

  @override
  void initState() {
    super.initState();

    initData();
  }

  initData() {
    if (Get.arguments == null) {
      commonSnackBar(message: "Invalid arguments");
      return;
    }
    final args = Get.arguments;
    topicName = args['topicName'];
    subtopics = args['subtopics'];
    classId = args['classId'];
    sectionId = args['sectionId'];
    className = args['className'];
    sectionName = args['sectionName'];
    subjectName = args['subjectName'];
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      appBar: commonAppBar(
        context: context,
        isBack: true,
        title: topicName.capitalizeFirst,
      ),
      body: Column(
        children: [
          // Class, Subject info
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(
              horizontal: getWidth(16),
              vertical: getHeight(8),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: getWidth(16),
              vertical: getHeight(12),
            ),
            decoration: BoxDecoration(
              color: AppColors.blueColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                Text(
                  "${className} - ${sectionName}",
                  style: TextStyle(
                    fontSize: getWidth(14),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: getHeight(4)),
                Text(
                  "Subject: ${subjectName.capitalizeFirst}",
                  style: TextStyle(
                    fontSize: getWidth(14),
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
          ),

          // Progress summary
          Padding(
            padding: EdgeInsets.all(getWidth(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Subtopics Progress",
                  style: TextStyle(
                    fontSize: getWidth(16),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: getHeight(8)),
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => LinearProgressIndicator(
                          value: _calculateProgress(),
                          backgroundColor: AppColors.grey,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.blueColor,
                          ),
                          minHeight: getHeight(10),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    SizedBox(width: getWidth(16)),
                    Text(
                      "${(_calculateProgress() * 100).toInt()}%",
                      style: TextStyle(
                        fontSize: getWidth(14),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Subtopics list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(getWidth(16)),
              itemCount: subtopics.length,
              itemBuilder: (context, index) {
                final subtopic = subtopics[index];

                return Card(
                  margin: EdgeInsets.only(bottom: getHeight(12)),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: getWidth(16),
                      vertical: getHeight(8),
                    ),
                    title: Text(
                      subtopic.name?.capitalizeFirst ?? "Untitled Subtopic",
                      style: TextStyle(fontSize: getWidth(15)),
                    ),
                    trailing: Obx(
                      () => Switch(
                        value: subtopic.isCompletedRx.value,
                        onChanged: (value) async {
                          final success = await controller.markProgress(
                            topicId: subtopic.id ?? "",
                            classId: classId,
                            sectionId: sectionId,
                          );

                          if (success) {
                            subtopic.isCompleted = value;
                            controller.hasDataChanged.value = true;
                          }
                        },
                        activeColor: Colors.white,
                        activeTrackColor: AppColors.blueColor,
                        inactiveThumbColor: Colors.black,
                        inactiveTrackColor: AppColors.grey,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  double _calculateProgress() {
    final completedCount = subtopics.where((s) => s.isCompletedRx.value).length;
    return subtopics.isNotEmpty ? completedCount / subtopics.length : 0.0;
  }
}
