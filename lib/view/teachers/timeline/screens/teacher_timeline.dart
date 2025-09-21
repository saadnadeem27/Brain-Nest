import 'package:Vadai/common/widgets/common_dropdown.dart';
import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/teachers/teacher_progress_tracking_controller.dart';
import 'package:Vadai/model/teachers/teacher_classes_data.dart';
import 'package:Vadai/model/teachers/teacher_schoolexam_progress_model.dart';
import 'package:Vadai/model/teachers/teacher_vadtest_progress_model.dart';
import 'package:Vadai/view/teachers/timeline/screens/exam_progress_details_screen.dart';
import 'package:intl/intl.dart';

class TeacherTimeline extends StatefulWidget {
  const TeacherTimeline({Key? key}) : super(key: key);

  @override
  State<TeacherTimeline> createState() => _TeacherTimelineState();
}

class _TeacherTimelineState extends State<TeacherTimeline>
    with TickerProviderStateMixin {
  final TeacherProgressTrackingController controller =
      Get.find<TeacherProgressTrackingController>();

  // Selection state
  final RxString selectedClassId = "".obs;
  final RxString selectedSectionId = "".obs;
  final RxString selectedSubjectId = "".obs;
  final RxString selectedSubjectName = "".obs;

  // Progress data
  final RxBool isLoadingVadTests = false.obs;
  final RxBool isLoadingSchoolExams = false.obs;
  final RxList<TeacherVadTestProgressModel> vadTests =
      <TeacherVadTestProgressModel>[].obs;
  final RxList<TeacherSchoolExamProgressModel> schoolExams =
      <TeacherSchoolExamProgressModel>[].obs;

  // Tab controller
  late TabController _tabController;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _tabsAnimation;

  // Track if animations have been played
  final RxBool _animationsInitialized = false.obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Create animations for different elements
    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _tabsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    // Initialize data if already available (without triggering new API calls)
    initializeViewData();

    // Initialize animations if data is already loaded
    ever(controller.isLoading, (isLoading) {
      if (!isLoading && !_animationsInitialized.value && mounted) {
        _initializeAnimations();
      }
    });

    // Handle case where data is already loaded
    if (!controller.isLoading.value && !_animationsInitialized.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeAnimations();
      });
    }

    ever(controller.hasDataChanged, (hasChanged) {
      if (hasChanged) {
        loadProgressData();
        controller.hasDataChanged.value = false;
      }
    });
  }

  void _initializeAnimations() {
    _animationsInitialized.value = true;
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Only initialize view data from already loaded controller data
  void initializeViewData() {
    if (controller.teacherClassesData.value != null &&
        controller.teacherClassesData.value!.classesAndSubjects.isNotEmpty) {
      // Auto-select first class and section
      final firstClass =
          controller.teacherClassesData.value!.classesAndSubjects.first;
      selectedClassId.value = firstClass.classId;

      if (firstClass.sections.isNotEmpty) {
        final firstSection = firstClass.sections.first;
        selectedSectionId.value = firstSection.sectionId;

        if (firstSection.subjects.isNotEmpty) {
          final firstSubject = firstSection.subjects.first;
          selectedSubjectId.value = firstSubject.subjectId;
          selectedSubjectName.value = firstSubject.subjectName;

          // Load the progress data for the auto-selected subject
          loadProgressData();
        }
      }
    }
  }

  Future<void> loadProgressData() async {
    if (selectedClassId.value.isEmpty ||
        selectedSectionId.value.isEmpty ||
        selectedSubjectId.value.isEmpty) {
      return;
    }

    loadVadTests();
    loadSchoolExams();
  }

  Future<void> loadVadTests() async {
    isLoadingVadTests.value = true;
    try {
      final data = await controller.getVadTestProgress(
        classId: selectedClassId.value,
        sectionId: selectedSectionId.value,
        subjectId: selectedSubjectId.value,
      );

      vadTests.clear();
      if (data != null) {
        vadTests.addAll(data);
      }
    } catch (e) {
      log('Error loading VAD Tests: $e');
    } finally {
      isLoadingVadTests.value = false;
    }
  }

  Future<void> loadSchoolExams() async {
    isLoadingSchoolExams.value = true;
    try {
      final data = await controller.getSchoolExamProgress(
        classId: selectedClassId.value,
        sectionId: selectedSectionId.value,
        subjectId: selectedSubjectId.value,
      );

      schoolExams.clear();
      if (data != null) {
        schoolExams.addAll(data);
      }
    } catch (e) {
      log('Error loading School Exams: $e');
    } finally {
      isLoadingSchoolExams.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: commonScaffold(
        context: context,
        body: Stack(
          children: [
            Positioned(
              top: getHeight(130),
              bottom: getHeight(30),
              right: getWidth(-130),
              child: Image.asset(
                AppAssets.tabBackGround,
                fit: BoxFit.cover,
                opacity: const AlwaysStoppedAnimation(0.6),
              ),
            ),
            Column(
              children: [
                teachersTabAppBar(
                  title: "Progress Tracking",
                ).paddingOnly(bottom: getHeight(10)),

                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return Center(child: commonLoader());
                    }

                    if (controller.teacherClassesData.value == null) {
                      return _buildEmptyState();
                    }

                    return Column(
                      children: [
                        // Selection header with animation
                        ScaleTransition(
                          scale: _headerAnimation,
                          child: _buildSelectionHeader(),
                        ),

                        // Tabs and progress content
                        if (selectedSubjectId.value.isNotEmpty) ...[
                          // Tabs with animation
                          ScaleTransition(
                            scale: _tabsAnimation,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TabBar(
                                controller: _tabController,
                                labelColor: AppColors.blueColor,
                                unselectedLabelColor: AppColors.textColor,
                                indicatorColor: AppColors.blueColor,
                                tabs: const [
                                  Tab(text: "VAD Tests"),
                                  Tab(text: "School Exams"),
                                ],
                              ),
                            ),
                          ),

                          // Tab content
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                // VAD Tests Tab
                                _buildVadTestsTab(),
                                // School Exams Tab
                                _buildSchoolExamsTab(),
                              ],
                            ),
                          ),
                        ],

                        // If no subject is selected, show class/section/subject list
                        if (selectedSubjectId.value.isEmpty)
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: () async {
                                controller.isLoading.value = true;
                                try {
                                  await controller.getTeachingSubjects();
                                  initializeViewData();
                                } finally {
                                  controller.isLoading.value = false;
                                }
                              },
                              child: _buildClassList(),
                            ),
                          ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: getWidth(60),
            color: AppColors.blueColor.withOpacity(0.7),
          ),
          SizedBox(height: getHeight(16)),
          Text(
            "No classes found",
            style: TextStyle(
              fontSize: getWidth(16),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: getHeight(8)),
          Text(
            "You don't have any classes assigned yet",
            style: TextStyle(
              fontSize: getWidth(14),
              color: AppColors.textColor,
            ),
          ),
          SizedBox(height: getHeight(16)),
          materialButtonOnlyText(
            text: "Refresh",
            onTap: () => loadProgressData(),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionHeader() {
    // Find class and section names for display
    String className = "";
    String sectionName = "";

    if (controller.teacherClassesData.value != null) {
      final classData = controller.teacherClassesData.value!.classesAndSubjects
          .firstWhere(
            (c) => c.classId == selectedClassId.value,
            orElse:
                () =>
                    ClassWithSubjects(classId: "", className: "", sections: []),
          );

      className = classData.className;

      if (classData.sections.isNotEmpty) {
        final sectionData = classData.sections.firstWhere(
          (s) => s.sectionId == selectedSectionId.value,
          orElse:
              () =>
                  SectionWithSubjects(sectionId: "", section: "", subjects: []),
        );

        sectionName = sectionData.section;
      }
    }

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
      child: Column(
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
                      value: controller
                          .teacherClassesData
                          .value
                          ?.classesAndSubjects
                          .firstWhereOrNull(
                            (c) => c.classId == selectedClassId.value,
                          ),
                      items:
                          controller
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
                              ? controller
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
                              : null,
                      items:
                          selectedClassId.value.isNotEmpty
                              ? (controller
                                      .teacherClassesData
                                      .value
                                      ?.classesAndSubjects
                                      .firstWhereOrNull(
                                        (c) =>
                                            c.classId == selectedClassId.value,
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
                        ? controller
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
                        ? (controller
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
                                ?.subjects ??
                            [])
                        : [],
                itemToString: (item) => item.subjectName,
                onChanged: (value) {
                  if (value != null &&
                      value.subjectId != selectedSubjectId.value) {
                    selectedSubjectId.value = value.subjectId;
                    selectedSubjectName.value = value.subjectName;
                    loadProgressData();
                  }
                },
                selectedItemStyle: TextStyle(
                  fontSize: getWidth(14),
                  color: AppColors.blueColor,
                  fontWeight: FontWeight.w600,
                  overflow: TextOverflow.ellipsis,
                ),
                dropdownItemStyle: TextStyle(
                  fontSize: getWidth(14),
                  color: AppColors.textColor,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVadTestsTab() {
    return Obx(() {
      if (isLoadingVadTests.value) {
        return Center(child: commonLoader());
      }

      if (vadTests.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "No VAD Tests found",
                style: TextStyle(
                  fontSize: getWidth(16),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: getHeight(16)),
              materialButtonOnlyText(
                text: "Refresh",
                onTap: loadVadTests,
                width: getWidth(120),
              ),
            ],
          ),
        );
      }
      String className = "";
      String sectionName = "";

      if (controller.teacherClassesData.value != null) {
        final classData = controller
            .teacherClassesData
            .value!
            .classesAndSubjects
            .firstWhere(
              (c) => c.classId == selectedClassId.value,
              orElse:
                  () => ClassWithSubjects(
                    classId: "",
                    className: "",
                    sections: [],
                  ),
            );

        className = classData.className;

        if (classData.sections.isNotEmpty) {
          final sectionData = classData.sections.firstWhere(
            (s) => s.sectionId == selectedSectionId.value,
            orElse:
                () => SectionWithSubjects(
                  sectionId: "",
                  section: "",
                  subjects: [],
                ),
          );

          sectionName = sectionData.section;
        }
      }

      return RefreshIndicator(
        onRefresh: loadVadTests,
        child: ListView.builder(
          padding: EdgeInsets.all(getWidth(16)),
          itemCount: vadTests.length,
          itemBuilder: (context, index) {
            final test = vadTests[index];
            final progress = _calculateVadTestProgress(test);

            return _buildProgressCard(
              title: test.name ?? "Untitled Test",
              progressPercent: progress,
              onTap: () {
                Get.to(
                  () => const ExamProgressDetailsScreen(),
                  arguments: {
                    'isVadTest': true,
                    'vadTestData': test,
                    'classId': selectedClassId.value,
                    'sectionId': selectedSectionId.value,
                    'className': className,
                    'sectionName': sectionName,
                    'subjectName': selectedSubjectName.value,
                  },
                );
              },
            );
          },
        ),
      );
    });
  }

  Widget _buildSchoolExamsTab() {
    return Obx(() {
      if (isLoadingSchoolExams.value) {
        return Center(child: commonLoader());
      }

      if (schoolExams.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "No School Exams found",
                style: TextStyle(
                  fontSize: getWidth(16),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: getHeight(16)),
              materialButtonOnlyText(
                text: "Refresh",
                onTap: loadSchoolExams,
                width: getWidth(120),
              ),
            ],
          ),
        );
      }

      String className = "";
      String sectionName = "";

      if (controller.teacherClassesData.value != null) {
        final classData = controller
            .teacherClassesData
            .value!
            .classesAndSubjects
            .firstWhere(
              (c) => c.classId == selectedClassId.value,
              orElse:
                  () => ClassWithSubjects(
                    classId: "",
                    className: "",
                    sections: [],
                  ),
            );

        className = classData.className;

        if (classData.sections.isNotEmpty) {
          final sectionData = classData.sections.firstWhere(
            (s) => s.sectionId == selectedSectionId.value,
            orElse:
                () => SectionWithSubjects(
                  sectionId: "",
                  section: "",
                  subjects: [],
                ),
          );

          sectionName = sectionData.section;
        }
      }

      return RefreshIndicator(
        onRefresh: loadSchoolExams,
        child: ListView.builder(
          padding: EdgeInsets.all(getWidth(16)),
          itemCount: schoolExams.length,
          itemBuilder: (context, index) {
            final exam = schoolExams[index];
            final progress = _calculateSchoolExamProgress(exam);
            final formattedDate =
                exam.getStartDateTime() != null
                    ? DateFormat('dd MMM yyyy').format(exam.getStartDateTime()!)
                    : "No date";

            return _buildProgressCard(
              title: exam.name ?? "Untitled Exam",
              subtitle: "Date: $formattedDate",
              progressPercent: progress,
              onTap: () {
                Get.to(
                  () => const ExamProgressDetailsScreen(),
                  arguments: {
                    'isVadTest': false,
                    'schoolExamData': exam,
                    'classId': selectedClassId.value,
                    'sectionId': selectedSectionId.value,
                    'className': className,
                    'sectionName': sectionName,
                    'subjectName': selectedSubjectName.value,
                  },
                );
              },
            );
          },
        ),
      );
    });
  }

  Widget _buildProgressCard({
    required String title,
    String? subtitle,
    required double progressPercent,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: getHeight(16)),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(getWidth(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: getWidth(16),
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: getHeight(4)),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: getWidth(14),
                    color: AppColors.textColor,
                  ),
                ),
              ],
              SizedBox(height: getHeight(16)),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: progressPercent,
                      backgroundColor: AppColors.grey.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.blueColor,
                      ),
                      minHeight: getHeight(8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(width: getWidth(16)),
                  Text(
                    "${(progressPercent * 100).toInt()}%",
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
      ),
    );
  }

  double _calculateVadTestProgress(TeacherVadTestProgressModel test) {
    if (test.subjectDetails?.largerTopics == null ||
        test.subjectDetails!.largerTopics!.isEmpty) {
      return 0.0;
    }

    int totalItems = 0;
    int completedItems = 0;

    for (final topic in test.subjectDetails!.largerTopics!) {
      if (topic.isCompleted == true) {
        completedItems++;
      }
      totalItems++;

      if (topic.subtopics != null) {
        for (final subtopic in topic.subtopics!) {
          if (subtopic.isCompleted == true) {
            completedItems++;
          }
          totalItems++;
        }
      }
    }

    return totalItems > 0 ? completedItems / totalItems : 0.0;
  }

  double _calculateSchoolExamProgress(TeacherSchoolExamProgressModel exam) {
    if (exam.subjectDetails?.largerTopics == null ||
        exam.subjectDetails!.largerTopics!.isEmpty) {
      return 0.0;
    }

    int totalItems = 0;
    int completedItems = 0;

    for (final topic in exam.subjectDetails!.largerTopics!) {
      if (topic.isCompleted == true) {
        completedItems++;
      }
      totalItems++;

      if (topic.subtopics != null) {
        for (final subtopic in topic.subtopics!) {
          if (subtopic.isCompleted == true) {
            completedItems++;
          }
          totalItems++;
        }
      }
    }

    return totalItems > 0 ? completedItems / totalItems : 0.0;
  }

  // Class list for hierarchical selection
  Widget _buildClassList() {
    // Create a flat list of all items
    List<Widget> listItems = [];

    for (var classData
        in controller.teacherClassesData.value!.classesAndSubjects) {
      // Add class header
      listItems.add(_buildClassItem(classData));

      // If this class is selected, show its sections
      if (selectedClassId.value == classData.classId) {
        for (var section in classData.sections) {
          // Add section chip
          listItems.add(_buildSectionItem(section));

          // If this section is selected, show its subjects
          if (selectedSectionId.value == section.sectionId) {
            for (var subject in section.subjects) {
              listItems.add(_buildSubjectItem(subject));
            }
          }
        }
      }
    }

    return ListView(
      padding: EdgeInsets.symmetric(
        vertical: getHeight(8),
        horizontal: getWidth(16),
      ),
      children: listItems,
    );
  }

  Widget _buildClassItem(ClassWithSubjects classData) {
    final bool isSelected = selectedClassId.value == classData.classId;

    return GestureDetector(
      onTap: () {
        if (isSelected) {
          // If already selected, deselect it
          selectedClassId.value = "";
          selectedSectionId.value = "";
          selectedSubjectId.value = "";
          selectedSubjectName.value = "";
        } else {
          // Select this class, deselect any section and subject
          selectedClassId.value = classData.classId;
          selectedSectionId.value = "";
          selectedSubjectId.value = "";
          selectedSubjectName.value = "";
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: getHeight(8)),
        padding: EdgeInsets.symmetric(
          horizontal: getWidth(16),
          vertical: getHeight(12),
        ),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.blueColor
                  : AppColors.blueColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(getWidth(10)),
          border: Border.all(color: AppColors.blueColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "Class ${classData.className}",
                style: TextStyle(
                  fontSize: getWidth(16),
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.white : AppColors.blueColor,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: isSelected ? AppColors.white : AppColors.blueColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionItem(SectionWithSubjects section) {
    final bool isSelected = selectedSectionId.value == section.sectionId;

    return GestureDetector(
      onTap: () {
        if (isSelected) {
          // If already selected, deselect it
          selectedSectionId.value = "";
          selectedSubjectId.value = "";
          selectedSubjectName.value = "";
        } else {
          // Select this section, deselect any subject
          selectedSectionId.value = section.sectionId;
          selectedSubjectId.value = "";
          selectedSubjectName.value = "";
        }
      },
      child: Container(
        margin: EdgeInsets.only(
          left: getWidth(24),
          top: getHeight(6),
          bottom: getHeight(6),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: getWidth(16),
          vertical: getHeight(8),
        ),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.blueColor.withOpacity(0.2)
                  : AppColors.grey.withOpacity(0.15),
          borderRadius: BorderRadius.circular(getWidth(8)),
          border: isSelected ? Border.all(color: AppColors.blueColor) : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "Section ${section.section}",
                style: TextStyle(
                  fontSize: getWidth(14),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.blueColor : AppColors.textColor,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: isSelected ? AppColors.blueColor : AppColors.textColor,
              size: getWidth(20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectItem(Subject subject) {
    final bool isSelected = selectedSubjectId.value == subject.subjectId;

    return GestureDetector(
      onTap: () {
        if (isSelected) {
          // If already selected, deselect it
          selectedSubjectId.value = "";
          selectedSubjectName.value = "";
        } else {
          // Select this subject and load progress data
          selectedSubjectId.value = subject.subjectId;
          selectedSubjectName.value = subject.subjectName;
          loadProgressData();
        }
      },
      child: Container(
        margin: EdgeInsets.only(
          left: getWidth(48),
          top: getHeight(6),
          bottom: getHeight(6),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: getWidth(16),
          vertical: getHeight(10),
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(getWidth(8)),
          border:
              isSelected
                  ? Border.all(color: AppColors.blueColor, width: 2)
                  : Border.all(color: AppColors.grey.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                subject.subjectName,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: getWidth(14),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppColors.blueColor : AppColors.textColor,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.blueColor,
                size: getWidth(20),
              ),
          ],
        ),
      ),
    );
  }
}
