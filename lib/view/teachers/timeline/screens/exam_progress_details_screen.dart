import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/teachers/teacher_progress_tracking_controller.dart';
import 'package:Vadai/model/teachers/teacher_schoolexam_progress_model.dart';
import 'package:Vadai/model/teachers/teacher_vadtest_progress_model.dart';
import 'package:Vadai/view/teachers/timeline/screens/subtopics_screen.dart';
import 'package:intl/intl.dart';

class ExamProgressDetailsScreen extends StatefulWidget {
  const ExamProgressDetailsScreen({Key? key}) : super(key: key);

  @override
  State<ExamProgressDetailsScreen> createState() =>
      _ExamProgressDetailsScreenState();
}

class _ExamProgressDetailsScreenState extends State<ExamProgressDetailsScreen> {
  final TeacherProgressTrackingController controller =
      Get.find<TeacherProgressTrackingController>();
  final RxBool isRefreshing = false.obs;

  late bool isVadTest;
  late TeacherVadTestProgressModel? vadTestData;
  late TeacherSchoolExamProgressModel? schoolExamData;
  late String classId;
  late String sectionId;
  late String className;
  late String sectionName;
  late String subjectName;
  late List<LargerTopic> topics;

  @override
  void initState() {
    super.initState();

    initData();
    ever(controller.hasDataChanged, (hasChanged) {
      if (hasChanged) {
        // refreshData();
        controller.hasDataChanged.value = false;
      }
    });
  }

  initData() {
    if (Get.arguments == null) {
      commonSnackBar(message: "Invalid arguments passed.");
      Get.back();
      return;
    }
    isVadTest = Get.arguments['isVadTest'];
    vadTestData = isVadTest ? Get.arguments['vadTestData'] : null;
    schoolExamData = !isVadTest ? Get.arguments['schoolExamData'] : null;
    classId = Get.arguments['classId'];
    sectionId = Get.arguments['sectionId'];
    className = Get.arguments['className'];
    sectionName = Get.arguments['sectionName'];
    subjectName = Get.arguments['subjectName'];

    topics =
        isVadTest
            ? vadTestData!.subjectDetails?.largerTopics ?? []
            : schoolExamData!.subjectDetails?.largerTopics ?? [];
  }

  @override
  Widget build(BuildContext context) {
    String title =
        isVadTest
            ? (vadTestData?.name?.capitalizeFirst ?? "VAD Test")
            : (schoolExamData?.name?.capitalizeFirst ?? "School Exam");

    return commonScaffold(
      context: context,
      appBar: commonAppBar(context: context, isBack: true, title: title),
      body: Column(
        children: [
          // Exam info
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
                  "${className} - ${sectionName.capitalizeFirst}",
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
                if (!isVadTest && schoolExamData?.startDate != null) ...[
                  SizedBox(height: getHeight(4)),
                  Text(
                    "Date: ${schoolExamData?.getStartDateTime() != null ? DateFormat('dd MMM yyyy').format(schoolExamData!.getStartDateTime()!) : 'N/A'}",
                    style: TextStyle(
                      fontSize: getWidth(14),
                      color: AppColors.textColor,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Topics list
          Expanded(
            child: Obx(() {
              if (isRefreshing.value) {
                return Center(child: commonLoader());
              }

              if (topics.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "No topics found",
                        style: TextStyle(
                          fontSize: getWidth(16),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: getHeight(16)),
                      materialButtonOnlyText(
                        text: "Return",
                        onTap: () {
                          Get.back();
                        },
                        width: getWidth(120),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(getWidth(16)),
                itemCount: topics.length,
                itemBuilder: (context, index) {
                  final topic = topics[index];
                  final subtopicsCount = topic.subtopics?.length ?? 0;
                  final completedSubtopics =
                      topic.subtopics
                          ?.where((subtopic) => subtopic.isCompletedRx.value)
                          .length ??
                      0;

                  return InkWell(
                    onTap: () {
                      Get.to(
                        () => const SubtopicsScreen(),
                        arguments: {
                          'topicName': topic.name ?? "Untitled Topic",
                          'subtopics': topic.subtopics ?? [],
                          'classId': classId,
                          'sectionId': sectionId,
                          'className': className,
                          'sectionName': sectionName,
                          'subjectName': subjectName,
                        },
                      )?.then((_) {
                        if (controller.hasDataChanged.value) {
                          controller.hasDataChanged.value = false;
                        }
                      });
                    },
                    child: Card(
                      margin: EdgeInsets.only(bottom: getHeight(12)),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              topic.name?.capitalizeFirst ?? "Untitled Topic",
                              style: TextStyle(
                                fontSize: getWidth(16),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle:
                                subtopicsCount > 0
                                    ? Text(
                                      "$completedSubtopics of $subtopicsCount subtopics completed",
                                    )
                                    : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Obx(
                                  () => Switch(
                                    value: topic.isCompletedRx.value,
                                    onChanged: (value) async {
                                      final topicId = topic.id ?? "";
                                      final success = await controller
                                          .markProgress(
                                            topicId: topicId,
                                            classId: classId,
                                            sectionId: sectionId,
                                          );
                                      if (success) {
                                        topic.isCompletedRx.value = value;
                                        controller.hasDataChanged.value = true;
                                      }
                                    },
                                    activeColor: Colors.white,
                                    activeTrackColor: AppColors.blueColor,
                                    inactiveThumbColor: Colors.black,
                                    inactiveTrackColor: AppColors.grey,
                                  ),
                                ),
                                if (subtopicsCount > 0)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                    ),
                                    onPressed: () {
                                      Get.to(
                                        () => const SubtopicsScreen(),
                                        arguments: {
                                          'topicName':
                                              topic.name ?? "Untitled Topic",
                                          'subtopics': topic.subtopics ?? [],
                                          'classId': classId,
                                          'sectionId': sectionId,
                                          'className': className,
                                          'sectionName': sectionName,
                                          'subjectName': subjectName,
                                        },
                                      )?.then((_) {
                                        if (controller.hasDataChanged.value) {
                                          // refreshData();
                                          controller.hasDataChanged.value =
                                              false;
                                        }
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ),
                          // Progress indicator
                          if (subtopicsCount > 0)
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                getWidth(16),
                                0,
                                getWidth(16),
                                getHeight(16),
                              ),
                              child: LinearProgressIndicator(
                                value:
                                    subtopicsCount > 0
                                        ? completedSubtopics / subtopicsCount
                                        : 0.0,
                                backgroundColor: AppColors.grey,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.blueColor,
                                ),
                                minHeight: getHeight(8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
