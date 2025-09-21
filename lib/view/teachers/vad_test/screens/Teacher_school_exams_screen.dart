import 'package:Vadai/common/widgets/common_dropdown.dart';
import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/teachers/teacher_progress_tracking_controller.dart';
import 'package:Vadai/controller/teachers/teacher_vadtest_controller.dart';
import 'package:Vadai/model/teachers/teacher_classes_data.dart';
import 'package:Vadai/model/teachers/teacher_schoolexam_model.dart';
import 'package:Vadai/view/teachers/vad_test/screens/teacher_subject_details_screen.dart';

class TeacherSchoolExamsScreen extends StatefulWidget {
  const TeacherSchoolExamsScreen({Key? key}) : super(key: key);

  @override
  State<TeacherSchoolExamsScreen> createState() =>
      _TeacherSchoolExamsScreenState();
}

class _TeacherSchoolExamsScreenState extends State<TeacherSchoolExamsScreen> {
  final TeacherVadTestController controller =
      Get.find<TeacherVadTestController>();

  // Add the progress tracking controller to access teaching classes/subjects
  final TeacherProgressTrackingController progressController = Get.put(
    TeacherProgressTrackingController(),
  );

  final RxBool isLoading = true.obs;
  final RxList<TeacherSchoolExamModel> exams = <TeacherSchoolExamModel>[].obs;

  // Selection state for filters
  final RxString selectedClassId = "".obs;
  final RxString selectedSectionId = "".obs;
  final RxString selectedSubjectId = "".obs;
  final RxString selectedSubjectName = "".obs;

  @override
  void initState() {
    super.initState();
    loadTeachingData();
  }

  Future<void> loadTeachingData() async {
    isLoading.value = true;
    try {
      // Load teaching subjects data
      await progressController.getTeachingSubjects();

      // Auto-select first class, section, and subject if available
      if (progressController.teacherClassesData.value != null &&
          progressController
              .teacherClassesData
              .value!
              .classesAndSubjects
              .isNotEmpty) {
        final firstClass =
            progressController
                .teacherClassesData
                .value!
                .classesAndSubjects
                .first;
        selectedClassId.value = firstClass.classId;

        if (firstClass.sections.isNotEmpty) {
          final firstSection = firstClass.sections.first;
          selectedSectionId.value = firstSection.sectionId;

          if (firstSection.subjects.isNotEmpty) {
            final firstSubject = firstSection.subjects.first;
            selectedSubjectId.value = firstSubject.subjectId;
            selectedSubjectName.value = firstSubject.subjectName;
          }
        }
      }

      // Load exams with the selected filters
      await loadExams();
    } catch (e) {
      log('Error loading teaching data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadExams() async {
    if (selectedClassId.value.isEmpty ||
        selectedSectionId.value.isEmpty ||
        selectedSubjectId.value.isEmpty) {
      isLoading.value = false;
      exams.clear();
      return;
    }

    isLoading.value = true;
    try {
      final List<TeacherSchoolExamModel>? examsList = await controller
          .getSchoolExams(
            classId: selectedClassId.value,
            sectionId: selectedSectionId.value,
            subjectId: selectedSubjectId.value,
          );

      exams.clear();
      if (examsList != null) {
        exams.addAll(examsList);
      } else {
        commonSnackBar(
          message: "Failed to load school exams",
          color: Colors.red,
        );
      }
    } catch (e) {
      log("Error loading school exams: $e");
      commonSnackBar(
        message: "An error occurred while loading school exams",
        color: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      appBar: commonAppBar(
        context: context,
        title: "School Exams",
        isBack: true,
      ),
      body: Column(
        children: [
          // Filter selection header
          _buildSelectionHeader(),

          // Exams list
          Expanded(
            child: Obx(() {
              if (isLoading.value) {
                return Center(child: commonLoader());
              }

              if (exams.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: getWidth(60),
                        color: AppColors.grey.withOpacity(0.5),
                      ),
                      SizedBox(height: getHeight(16)),
                      Text(
                        "No school exams available for this selection",
                        style: TextStyle(
                          fontSize: getWidth(16),
                          color: AppColors.textColor.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: getHeight(16)),
                      materialButtonOnlyText(text: "Refresh", onTap: loadExams),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: loadExams,
                child: ListView.builder(
                  padding: EdgeInsets.all(getWidth(16)),
                  itemCount: exams.length,
                  itemBuilder: (context, index) {
                    final exam = exams[index];
                    return _buildExamCard(exam);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionHeader() {
    return Container(
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
      child: Obx(() {
        if (progressController.isLoading.value) {
          return Center(
            child: SizedBox(height: getHeight(100), child: commonLoader()),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Class",
                        style: TextStyle(
                          fontSize: getWidth(12),
                          color: AppColors.textColor,
                        ),
                      ),
                      CommonDropdown<ClassWithSubjects>(
                        hint: "Select Class",
                        value: progressController
                            .teacherClassesData
                            .value
                            ?.classesAndSubjects
                            .firstWhereOrNull(
                              (c) => c.classId == selectedClassId.value,
                            ),
                        items:
                            progressController
                                .teacherClassesData
                                .value
                                ?.classesAndSubjects ??
                            [],
                        itemToString: (item) => item.className,
                        onChanged: (value) {
                          if (value != null) {
                            selectedClassId.value = value.classId;
                            selectedSectionId.value = "";
                            selectedSubjectId.value = "";
                            selectedSubjectName.value = "";
                          }
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(width: getWidth(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Section",
                        style: TextStyle(
                          fontSize: getWidth(12),
                          color: AppColors.textColor,
                        ),
                      ),
                      CommonDropdown<SectionWithSubjects>(
                        hint: "Select Section",
                        value:
                            selectedClassId.value.isNotEmpty
                                ? progressController
                                    .teacherClassesData
                                    .value
                                    ?.classesAndSubjects
                                    .firstWhereOrNull(
                                      (c) => c.classId == selectedClassId.value,
                                    )
                                    ?.sections
                                    .firstWhereOrNull(
                                      (s) =>
                                          s.sectionId ==
                                          selectedSectionId.value,
                                    )
                                : null,
                        items:
                            selectedClassId.value.isNotEmpty
                                ? (progressController
                                        .teacherClassesData
                                        .value
                                        ?.classesAndSubjects
                                        .firstWhereOrNull(
                                          (c) =>
                                              c.classId ==
                                              selectedClassId.value,
                                        )
                                        ?.sections ??
                                    [])
                                : [],
                        itemToString: (item) => item.section,
                        onChanged: (value) {
                          if (value != null) {
                            selectedSectionId.value = value.sectionId;
                            selectedSubjectId.value = "";
                            selectedSubjectName.value = "";
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: getHeight(8)),
            // Subject selection
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Subject",
                  style: TextStyle(
                    fontSize: getWidth(12),
                    color: AppColors.textColor,
                  ),
                ),
                CommonDropdown<Subject>(
                  hint: "Select Subject",
                  value:
                      (selectedClassId.value.isNotEmpty &&
                              selectedSectionId.value.isNotEmpty)
                          ? progressController
                              .teacherClassesData
                              .value
                              ?.classesAndSubjects
                              .firstWhereOrNull(
                                (c) => c.classId == selectedClassId.value,
                              )
                              ?.sections
                              .firstWhereOrNull(
                                (s) => s.sectionId == selectedSectionId.value,
                              )
                              ?.subjects
                              .firstWhereOrNull(
                                (s) => s.subjectId == selectedSubjectId.value,
                              )
                          : null,
                  items:
                      (selectedClassId.value.isNotEmpty &&
                              selectedSectionId.value.isNotEmpty)
                          ? (progressController
                                  .teacherClassesData
                                  .value
                                  ?.classesAndSubjects
                                  .firstWhereOrNull(
                                    (c) => c.classId == selectedClassId.value,
                                  )
                                  ?.sections
                                  .firstWhereOrNull(
                                    (s) =>
                                        s.sectionId == selectedSectionId.value,
                                  )
                                  ?.subjects ??
                              [])
                          : [],
                  itemToString: (item) => item.subjectName,
                  onChanged: (value) {
                    if (value != null) {
                      selectedSubjectId.value = value.subjectId;
                      selectedSubjectName.value = value.subjectName;
                      loadExams();
                    }
                  },
                  selectedItemStyle: TextStyle(
                    fontSize: getWidth(14),
                    color: AppColors.blueColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: getHeight(8)),

            // Apply Filter Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (selectedClassId.value.isNotEmpty &&
                            selectedSectionId.value.isNotEmpty &&
                            selectedSubjectId.value.isNotEmpty)
                        ? loadExams
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blueColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.grey.withOpacity(0.3),
                  disabledForegroundColor: AppColors.grey,
                  padding: EdgeInsets.symmetric(vertical: getHeight(10)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Apply Filters",
                  style: TextStyle(
                    fontSize: getWidth(14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildExamCard(TeacherSchoolExamModel exam) {
    return Card(
      margin: EdgeInsets.only(bottom: getHeight(16)),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(getWidth(12)),
      ),
      child: InkWell(
        onTap: () => _navigateToSubjects(exam),
        borderRadius: BorderRadius.circular(getWidth(12)),
        child: Padding(
          padding: EdgeInsets.all(getWidth(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      exam.name ?? "Unnamed Exam",
                      style: TextStyle(
                        fontSize: getWidth(18),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Show selected subject as a chip/badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: getWidth(10),
                      vertical: getHeight(5),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.blueColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(getWidth(8)),
                    ),
                    child: Text(
                      selectedSubjectName.value,
                      style: TextStyle(
                        color: AppColors.blueColor,
                        fontWeight: FontWeight.w600,
                        fontSize: getWidth(12),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: getHeight(8)),
              if (exam.message != null && exam.message!.isNotEmpty) ...[
                Text(
                  exam.message!,
                  style: TextStyle(
                    fontSize: getWidth(14),
                    color: AppColors.textColor.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: getHeight(8)),
              ],
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: getWidth(16),
                    color: AppColors.blueColor,
                  ),
                  SizedBox(width: getWidth(6)),
                  Text(
                    exam.getFormattedDate(),
                    style: TextStyle(
                      fontSize: getWidth(14),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  // View details action indicator
                  Row(
                    children: [
                      Text(
                        "View details",
                        style: TextStyle(
                          fontSize: getWidth(12),
                          color: AppColors.blueColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: getWidth(4)),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: getWidth(12),
                        color: AppColors.blueColor,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToSubjects(TeacherSchoolExamModel exam) {
    if (exam.id == null || exam.id!.isEmpty) {
      commonSnackBar(message: "Exam ID not available");
      return;
    }

    Get.to(
      () => TeacherSubjectDetailsScreen(
        examId: exam.id!,
        classId: selectedClassId.value,
        sectionId: selectedSectionId.value,
        subjectId: selectedSubjectId.value,
        subjectName: selectedSubjectName.value,
      ),
    );
  }
}
