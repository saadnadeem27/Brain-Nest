import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/student/school_controller.dart';
import 'package:Vadai/controller/teachers/teacher_auth_controller.dart';
import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/model/students/school_details_model.dart';
import 'package:Vadai/model/students/subject_model.dart';
import 'package:Vadai/view/teachers/auth/widgets/SubjectSelectItem.dart';
import 'package:Vadai/view/teachers/auth/widgets/TeachingAssignmentCard.dart';

class TeacherUploadSubject extends StatefulWidget {
  const TeacherUploadSubject({super.key});

  @override
  State<TeacherUploadSubject> createState() => _TeacherUploadSubjectState();
}

class _TeacherUploadSubjectState extends State<TeacherUploadSubject> {
  final ScrollController scrollController = ScrollController();
  SchoolController schoolCtr = Get.put(SchoolController());
  TeacherAuthController teacherAuthCtr = Get.find<TeacherAuthController>();

  // School data
  SchoolDetailModel? schoolData;
  String? schoolId;
  String? classId;
  String? sectionId;
  bool isClassTeacher = false;
  List<Classes> availableClasses = [];

  // Teacher data
  String? teacherName;
  String? whatsappNumber;
  String? profileImageUrl;

  // Subject data
  List<SubjectModel?> subjectList = [];

  // Reactive state with more granular loading states
  RxBool isLoading = false.obs;
  RxBool isLoadingSections = false.obs;
  RxBool isLoadingSubjects = false.obs;
  RxList<Map<String, dynamic>> teachingAssignments =
      <Map<String, dynamic>>[].obs;

  // Current selection state
  RxString selectedClassId = "".obs;
  RxString selectedClassName = "".obs;
  RxString selectedSectionId = "".obs;
  RxString selectedSectionName = "".obs;
  RxString selectedSubjectId = "".obs;
  RxString selectedSubjectName = "".obs;
  Rx<Classes?> selectedClassData = Rx<Classes?>(null);

  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  // MARK: - Initialization Methods

  Future<void> initData() async {
    isLoading.value = true;
    try {
      _extractArgumentData();
      _setupClassTeacherData();
      _loadAvailableClasses();

      if (selectedClassId.value.isNotEmpty) {
        // Load sections for this class first
        loadSectionsForClass(selectedClassId.value);
        // Then load subjects
        await loadSubjects(selectedClassId.value);
      }
    } catch (e) {
      log('Error initializing teacher subject selection: $e');
      commonSnackBar(
        message: "Failed to initialize data. Please try again.",
        color: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _extractArgumentData() {
    try {
      if (Get.arguments != null) {
        var data = Get.arguments;
        schoolData = data['school'];
        schoolId = data['schoolId'];
        teacherName = data['name'];
        whatsappNumber = data['whatsappNumber'];
        profileImageUrl = data['profileImageUrl'];
        isClassTeacher = data['isClassTeacher'] ?? false;

        if (isClassTeacher) {
          classId = data['classId'];
          sectionId = data['sectionId'];
        }

        log('School Data: ${schoolData?.toJson()}');
        log('School Data id: $schoolId');
      } else {
        log('No arguments provided to TeacherUploadSubject');
      }
    } catch (e) {
      log('Error extracting argument data: $e');
    }
  }

  void _setupClassTeacherData() {
    try {
      // If teacher is a class teacher, we already have a class/section
      // Commented out as in the original code, but kept for reference
      // if (isClassTeacher && classId != null && sectionId != null) {
      //   // Add this as the first teaching assignment
      //   Map<String, dynamic> mainClassAssignment = {
      //     'classId': classId,
      //     'className': _getClassName(classId),
      //     'sectionId': sectionId,
      //     'sectionName': _getSectionName(classId, sectionId),
      //     'isMainClass': true,
      //     'subjectId': '',
      //     'subjectName': '',
      //   };
      //
      //   teachingAssignments.add(mainClassAssignment);
      //
      //   // Set this as the current selection to load subjects
      //   selectedClassId.value = classId ?? '';
      //   selectedClassName.value = _getClassName(classId);
      //
      //   if (selectedClassId.value.isNotEmpty && schoolData?.classes != null) {
      //     final classData = schoolData!.classes!.firstWhere(
      //       (c) => c.sId == selectedClassId.value,
      //       orElse: () => Classes(),
      //     );
      //     selectedClassData.value = classData;
      //   }
      //
      //   selectedSectionId.value = sectionId ?? '';
      //   selectedSectionName.value = _getSectionName(classId, sectionId);
      // }
    } catch (e) {
      log('Error setting up class teacher data: $e');
    }
  }

  void _loadAvailableClasses() {
    try {
      // Get all available classes for selections
      if (schoolData != null && schoolData!.classes != null) {
        availableClasses = schoolData!.classes!;
        log('Loaded ${availableClasses.length} available classes');
      } else {
        log('No classes available in school data');
        availableClasses = [];
      }
    } catch (e) {
      log('Error loading available classes: $e');
      availableClasses = [];
    }
  }

  // MARK: - Helper Methods

  String _getClassName(String? id) {
    try {
      if (id == null || schoolData == null || schoolData!.classes == null)
        return "Unknown";

      final classData = schoolData!.classes!.firstWhere(
        (c) => c.sId == id,
        orElse: () => Classes(),
      );

      return classData.name ?? "Unknown";
    } catch (e) {
      log('Error getting class name: $e');
      return "Unknown";
    }
  }

  String _getSectionName(String? classId, String? sectionId) {
    try {
      if (classId == null ||
          sectionId == null ||
          schoolData == null ||
          schoolData!.classes == null)
        return "Unknown";

      final classData = schoolData!.classes!.firstWhere(
        (c) => c.sId == classId,
        orElse: () => Classes(),
      );

      if (classData.sections == null) return "Unknown";

      final sectionData = classData.sections!.firstWhere(
        (s) => s.sId == sectionId,
        orElse: () => Sections(),
      );

      return sectionData.section ?? "Unknown";
    } catch (e) {
      log('Error getting section name: $e');
      return "Unknown";
    }
  }

  // MARK: - Data Loading Methods

  void loadSectionsForClass(String classId) {
    isLoadingSections.value = true;
    try {
      // Validate school data
      if (schoolData == null || schoolData!.classes == null) {
        log('School data or classes is null');
        commonSnackBar(
          message: "School data not available, please try again",
          color: Colors.red,
        );
        return;
      }

      // Find the selected class and store it directly
      final classData = schoolData!.classes!.firstWhere(
        (c) => c.sId == classId,
        orElse: () => Classes(),
      );

      if (classData.sId == null) {
        log('Class not found with ID: $classId');
        commonSnackBar(message: "Selected class not found", color: Colors.red);
        return;
      }

      // Store the full class object including its sections
      selectedClassData.value = classData;
      log(
        'Selected class: ${classData.name}, with ${classData.sections?.length ?? 0} sections',
      );

      // Reset section selection when changing class
      selectedSectionId.value = '';
      selectedSectionName.value = '';
    } catch (e) {
      log('Error loading sections: $e');
      selectedClassData.value = null;
      commonSnackBar(
        message: "Error loading sections. Please try again.",
        color: Colors.red,
      );
    } finally {
      isLoadingSections.value = false;
    }
  }

  Future<void> loadSubjects(String classId) async {
    isLoadingSubjects.value = true;
    try {
      if (classId.isEmpty) {
        log('Cannot load subjects: classId is empty');
        return;
      }

      if (schoolId == null || schoolId!.isEmpty) {
        log('Cannot load subjects: schoolId is null or empty');
        return;
      }

      await schoolCtr
          .getSubjectList(schoolId: schoolId ?? '', classId: classId)
          .then((List<SubjectModel?>? value) {
            if (value != null) {
              subjectList = value;
              // Reset selected subject when changing class
              selectedSubjectId.value = '';
              selectedSubjectName.value = '';
            } else {
              // Handle empty or null list specifically
              subjectList = [];
              log('No subjects returned for class: $classId');
            }
          });
    } catch (e) {
      log('Error loading subjects: $e');
      subjectList = [];
      commonSnackBar(
        message: "Failed to load subjects. Please try again.",
        color: Colors.red,
      );
    } finally {
      isLoadingSubjects.value = false;
    }
  }

  // MARK: - Action Methods

  void addTeachingAssignment() {
    try {
      if (selectedClassId.value.isEmpty) {
        commonSnackBar(message: "Please select a class");
        return;
      }

      if (selectedSectionId.value.isEmpty) {
        commonSnackBar(message: "Please select a section");
        return;
      }

      if (selectedSubjectId.value.isEmpty) {
        commonSnackBar(message: "Please select a subject");
        return;
      }

      if (_isDuplicateAssignment()) {
        return;
      }

      if (_hasExistingSubjectForClassSection()) {
        return;
      }

      _createNewAssignment();
      _resetSelectionAfterAdd();
    } catch (e) {
      log('Error adding teaching assignment: $e');
      commonSnackBar(
        message: "Failed to add teaching assignment. Please try again.",
        color: Colors.red,
      );
    }
  }

  bool _isDuplicateAssignment() {
    try {
      for (var assignment in teachingAssignments) {
        if (assignment['classId'] == selectedClassId.value &&
            assignment['sectionId'] == selectedSectionId.value &&
            assignment['subjectId'] == selectedSubjectId.value) {
          commonSnackBar(
            message: "This class-section-subject combination is already added",
            color: Colors.red,
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      log('Error checking for duplicate assignment: $e');
      return false;
    }
  }

  bool _hasExistingSubjectForClassSection() {
    try {
      for (var assignment in teachingAssignments) {
        if (assignment['classId'] == selectedClassId.value &&
            assignment['sectionId'] == selectedSectionId.value &&
            assignment['subjectId'] != selectedSubjectId.value) {
          commonSnackBar(
            message:
                "You already teach another subject for this class-section. Please edit that entry instead.",
            color: Colors.red,
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      log('Error checking for existing subject: $e');
      return false;
    }
  }

  void _createNewAssignment() {
    try {
      Map<String, dynamic> newAssignment = {
        'classId': selectedClassId.value,
        'className': selectedClassName.value,
        'sectionId': selectedSectionId.value,
        'sectionName': selectedSectionName.value,
        'subjectId': selectedSubjectId.value,
        'subjectName': selectedSubjectName.value,
        'isMainClass':
            isClassTeacher &&
            selectedClassId.value == classId &&
            selectedSectionId.value == sectionId,
      };

      teachingAssignments.add(newAssignment);

      commonSnackBar(
        message:
            "Added ${selectedSubjectName.value} for ${selectedClassName.value} - ${selectedSectionName.value}",
        color: Colors.green,
      );
    } catch (e) {
      log('Error creating new assignment: $e');
      commonSnackBar(
        message: "Failed to create assignment. Please try again.",
        color: Colors.red,
      );
    }
  }

  void _resetSelectionAfterAdd() {
    try {
      // Reset selection except for class teachers' main class
      if (!isClassTeacher ||
          (selectedClassId.value != classId ||
              selectedSectionId.value != sectionId)) {
        selectedClassId.value = '';
        selectedClassName.value = '';
        selectedSectionId.value = '';
        selectedSectionName.value = '';
      }
      selectedSubjectId.value = '';
      selectedSubjectName.value = '';
    } catch (e) {
      log('Error resetting selection: $e');
    }
  }

  void removeTeachingAssignment(int index) {
    try {
      // Don't allow removing main class assignment for class teachers
      if (teachingAssignments[index]['isMainClass'] == true) {
        // But allow changing the subject
        commonSnackBar(
          message:
              "You cannot remove your main class as a class teacher, but you can change the subject",
          color: Colors.red,
        );
        return;
      }

      teachingAssignments.removeAt(index);
      commonSnackBar(message: "Assignment removed", color: Colors.green);
    } catch (e) {
      log('Error removing teaching assignment: $e');
      commonSnackBar(
        message: "Failed to remove assignment. Please try again.",
        color: Colors.red,
      );
    }
  }

  void selectSubject(String subjectId, String subjectName) {
    try {
      selectedSubjectId.value = subjectId;
      selectedSubjectName.value = subjectName;
    } catch (e) {
      log('Error selecting subject: $e');
    }
  }

  void editAssignmentSubject(Map<String, dynamic> assignment) {
    try {
      // Set this class-section as current selection to change subject
      selectedClassId.value = assignment['classId'] ?? '';
      selectedClassName.value = assignment['className'] ?? '';
      selectedSectionId.value = assignment['sectionId'] ?? '';
      selectedSectionName.value = assignment['sectionName'] ?? '';
      loadSectionsForClass(selectedClassId.value);
      loadSubjects(selectedClassId.value);
    } catch (e) {
      log('Error editing assignment subject: $e');
      commonSnackBar(
        message: "Failed to edit assignment. Please try again.",
        color: Colors.red,
      );
    }
  }

  // MARK: - Form Submission

  void submitData() async {
    try {
      if (!_validateSubmission()) {
        return;
      }

      List<Map<String, String>> apiClassesAndSubjects = _prepareApiData();

      if (apiClassesAndSubjects.isEmpty) {
        commonSnackBar(
          message: "Please assign at least one subject before proceeding",
          color: Colors.red,
        );
        return;
      }

      _navigateToReviewScreen(apiClassesAndSubjects);
    } catch (e) {
      log('Error during submission: $e');
      commonSnackBar(
        message: "An error occurred during submission. Please try again.",
        color: Colors.red,
      );
    }
  }

  bool _validateSubmission() {
    try {
      bool hasAnySubjects = false;
      for (var assignment in teachingAssignments) {
        if (assignment['subjectId'] != null &&
            assignment['subjectId'].isNotEmpty) {
          hasAnySubjects = true;
          break;
        }
      }

      if (teachingAssignments.isEmpty || !hasAnySubjects) {
        commonSnackBar(message: "Please select at least one subject you teach");
        return false;
      }
      return true;
    } catch (e) {
      log('Error validating submission: $e');
      commonSnackBar(
        message: "Error validating your data. Please try again.",
        color: Colors.red,
      );
      return false;
    }
  }

  List<Map<String, String>> _prepareApiData() {
    try {
      List<Map<String, String>> apiClassesAndSubjects = [];
      for (var assignment in teachingAssignments) {
        if (assignment['subjectId'] != null &&
            assignment['subjectId'].isNotEmpty) {
          apiClassesAndSubjects.add({
            "classId": assignment['classId'] ?? '',
            "sectionId": assignment['sectionId'] ?? '',
            "subjectId": assignment['subjectId'] ?? '',
          });
        }
      }
      return apiClassesAndSubjects;
    } catch (e) {
      log('Error preparing API data: $e');
      return [];
    }
  }

  void _navigateToReviewScreen(
    List<Map<String, String>> apiClassesAndSubjects,
  ) {
    try {
      Get.toNamed(
        RouteNames.teacherProfileReview,
        arguments: {
          'school': schoolData,
          'schoolId': schoolId,
          'name': teacherName,
          'whatsappNumber': whatsappNumber,
          'profileImageUrl': profileImageUrl,
          'isClassTeacher': isClassTeacher,
          'teachingAssignments': teachingAssignments.toList(),
          'apiClassesAndSubjects': apiClassesAndSubjects,
          // If class teacher, include the main class and section
          if (isClassTeacher) 'classId': classId,
          if (isClassTeacher) 'sectionId': sectionId,
        },
      );
    } catch (e) {
      log('Error navigating to review screen: $e');
      commonSnackBar(
        message: "Failed to proceed to review. Please try again.",
        color: Colors.red,
      );
    }
  }

  // MARK: - Build Methods

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => commonScaffold(
        context: context,
        appBar: commonAppBar(context: context, isBack: true, title: ""),
        bottomNavigationBar: _buildBottomNavigationBar(),
        body:
            isLoading.value
                ? Center(child: commonLoader())
                : Scrollbar(
                  controller: scrollController,
                  thickness: getWidth(10),
                  radius: Radius.circular(getWidth(8)),
                  scrollbarOrientation: ScrollbarOrientation.right,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        _buildCurrentAssignments(),
                        _buildNewAssignmentSection(),
                        _buildInfoBox(),
                      ],
                    ).paddingOnly(
                      left: getWidth(16),
                      right: getWidth(16),
                      bottom: getHeight(24),
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return isLoading.value
        ? const SizedBox.shrink()
        : materialButtonWithChild(
          width: double.infinity,
          onPressed: submitData,
          child: textWid(
            "Review and Finish",
            style: AppTextStyles.textStyle(
              fontSize: getWidth(16),
              fontWeight: FontWeight.w500,
              txtColor: AppColors.white,
            ),
          ),
          color: AppColors.blueColor,
          padding: EdgeInsets.symmetric(vertical: getHeight(18)),
        ).paddingOnly(
          bottom: getHeight(16),
          left: getWidth(16),
          right: getWidth(16),
        );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Center(child: Image.asset(AppAssets.logo, width: getWidth(220))),
        SizedBox(height: getHeight(16)),
        Center(
          child: Text(
            "✅ Final Step: Select Subjects You Teach 📚",
            maxLines: 3,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textColor.withOpacity(0.7),
              fontSize: getWidth(14),
            ),
          ),
        ),
        SizedBox(height: getHeight(8)),
        Center(
          child: Text(
            "You can teach one subject per class-section",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.blueColor,
              fontSize: getWidth(14),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentAssignments() {
    return Obx(
      () =>
          teachingAssignments.isNotEmpty
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    icon: Icons.school_outlined,
                    title: "Your Teaching Assignments",
                  ),
                  ...teachingAssignments
                      .asMap()
                      .entries
                      .map(
                        (entry) => TeachingAssignmentCard(
                          assignment: entry.value,
                          index: entry.key,
                          onRemove: removeTeachingAssignment,
                          onEditSubject: editAssignmentSubject,
                        ),
                      )
                      .toList(),
                ],
              )
              : SizedBox(),
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Padding(
      padding: EdgeInsets.only(top: getHeight(24), bottom: getHeight(8)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.blueColor, size: getWidth(20)),
          SizedBox(width: getWidth(8)),
          Text(
            title,
            style: AppTextStyles.textStyle(
              fontSize: getWidth(18),
              fontWeight: FontWeight.w600,
              txtColor: AppColors.blueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewAssignmentSection() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: getHeight(16)),
      padding: EdgeInsets.all(getWidth(16)),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.add_circle_outline,
            title: "Add New Teaching Assignment",
          ),
          SizedBox(height: getHeight(8)),
          _buildClassSelection(),
          SizedBox(height: getHeight(16)),
          _buildSectionSelection(),
          SizedBox(height: getHeight(16)),
          _buildSubjectSelection(),
          SizedBox(height: getHeight(16)),
          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildClassSelection() {
    if (availableClasses.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "1. Select Class",
            style: AppTextStyles.textStyle(
              fontSize: getWidth(14),
              fontWeight: FontWeight.w500,
              txtColor: AppColors.textColor,
            ),
          ),
          SizedBox(height: getHeight(8)),
          Container(
            padding: EdgeInsets.all(getWidth(16)),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.5), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: getWidth(20),
                    ),
                    SizedBox(width: getWidth(8)),
                    Text(
                      "No Classes Available",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: getWidth(14),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: getHeight(8)),
                Text(
                  "There are no classes available at this school. Please contact the school administrator.",
                  style: TextStyle(color: Colors.red[700]),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "1. Select Class",
          style: AppTextStyles.textStyle(
            fontSize: getWidth(14),
            fontWeight: FontWeight.w500,
            txtColor: AppColors.textColor,
          ),
        ),
        SizedBox(height: getHeight(8)),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: getWidth(12),
            vertical: getHeight(4),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.textColor, width: 1),
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            underline: SizedBox(),
            hint: Text("Select a class"),
            value: selectedClassId.value.isEmpty ? null : selectedClassId.value,
            items:
                availableClasses
                    .map(
                      (classItem) => DropdownMenuItem<String>(
                        value: classItem.sId,
                        child: Text(classItem.name ?? "Unknown"),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) {
                selectedClassId.value = value;
                selectedClassName.value = _getClassName(value);
                loadSectionsForClass(value);
                loadSubjects(value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionSelection() {
    return Obx(
      () =>
          selectedClassId.value.isNotEmpty
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "2. Select Section",
                    style: AppTextStyles.textStyle(
                      fontSize: getWidth(14),
                      fontWeight: FontWeight.w500,
                      txtColor: AppColors.textColor,
                    ),
                  ),
                  SizedBox(height: getHeight(8)),
                  isLoadingSections.value
                      ? Center(
                        child: SizedBox(
                          height: getHeight(48),
                          child: commonLoader(),
                        ),
                      )
                      : _buildSectionDropdown(),
                ],
              )
              : SizedBox(),
    );
  }

  Widget _buildSectionDropdown() {
    // Handle no sections case
    if (selectedClassData.value?.sections == null ||
        selectedClassData.value!.sections!.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: getWidth(12),
          vertical: getHeight(12),
        ),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.textColor, width: 1),
        ),
        child: Text(
          "No sections available for this class",
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: getWidth(12),
        vertical: getHeight(4),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.textColor, width: 1),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        underline: SizedBox(),
        hint: Text("Select a section"),
        value: selectedSectionId.value.isEmpty ? null : selectedSectionId.value,
        items:
            selectedClassData.value?.sections
                ?.map(
                  (section) => DropdownMenuItem<String>(
                    value: section.sId,
                    child: Text(section.section ?? "Unknown"),
                  ),
                )
                .toList() ??
            [],
        onChanged: (value) {
          if (value != null) {
            selectedSectionId.value = value;
            selectedSectionName.value = _getSectionName(
              selectedClassId.value,
              value,
            );
          }
        },
      ),
    );
  }

  Widget _buildSubjectSelection() {
    return Obx(
      () =>
          selectedClassId.value.isNotEmpty && selectedSectionId.value.isNotEmpty
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "3. Select Subject",
                    style: AppTextStyles.textStyle(
                      fontSize: getWidth(14),
                      fontWeight: FontWeight.w500,
                      txtColor: AppColors.textColor,
                    ),
                  ),
                  SizedBox(height: getHeight(8)),
                  isLoadingSubjects.value
                      ? Center(
                        child: SizedBox(
                          height: getHeight(200),
                          child: commonLoader(),
                        ),
                      )
                      : _buildSubjectList(),
                ],
              )
              : SizedBox(),
    );
  }

  Widget _buildSubjectList() {
    if (subjectList.isEmpty) {
      return Container(
        height: getHeight(100),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, color: Colors.grey, size: getWidth(24)),
              SizedBox(height: getHeight(8)),
              Text(
                "No subjects found for this class",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: getHeight(4)),
              Text(
                "Please select a different class",
                style: TextStyle(fontSize: getWidth(12), color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: getHeight(300),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Scrollbar(
        thickness: 6,
        radius: Radius.circular(4),
        thumbVisibility: true,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(getWidth(8)),
            child: Column(
              children:
                  subjectList.map((subject) {
                    return SubjectSelectItem(
                      subject: subject,
                      isSelected: selectedSubjectId.value == subject?.sId,
                      onSelect:
                          () => selectSubject(
                            subject?.sId ?? '',
                            subject?.subjectName ?? '',
                          ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Obx(
      () =>
          selectedClassId.value.isNotEmpty &&
                  selectedSectionId.value.isNotEmpty &&
                  selectedSubjectId.value.isNotEmpty
              ? materialButtonWithChild(
                width: double.infinity,
                onPressed: addTeachingAssignment,
                color: AppColors.blueColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.white),
                    SizedBox(width: getWidth(8)),
                    Text(
                      "Add Assignment",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: getWidth(16),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(vertical: getHeight(12)),
              )
              : SizedBox(),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: EdgeInsets.all(getWidth(12)),
      margin: EdgeInsets.only(bottom: getHeight(24)),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.amber[800],
            size: getWidth(18),
          ),
          SizedBox(width: getWidth(8)),
          Expanded(
            child: Text(
              "You must assign at least one subject to proceed. If you are a class teacher, you must assign a subject to your main class.",
              style: TextStyle(
                color: Colors.amber[800],
                fontSize: getWidth(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
