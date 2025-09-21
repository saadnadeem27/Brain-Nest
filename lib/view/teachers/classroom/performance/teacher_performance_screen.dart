import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/teachers/teacher_classroom_controller.dart';
import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/model/common/poeple_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TeacherPerformanceScreen extends StatefulWidget {
  const TeacherPerformanceScreen({Key? key}) : super(key: key);

  @override
  State<TeacherPerformanceScreen> createState() =>
      _TeacherPerformanceScreenState();
}

class _TeacherPerformanceScreenState extends State<TeacherPerformanceScreen> {
  final TeacherClassroomController controller = Get.find();
  final RxBool isLoading = true.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasNext = false.obs;
  final ScrollController scrollController = ScrollController();

  final RxList<PeopleModel> studentsList = <PeopleModel>[].obs;

  String className = '';
  String sectionName = '';
  String subjectName = '';
  String classId = '';
  String sectionId = '';
  String subjectId = '';

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initData();
    });
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  void initData() async {
    isLoading.value = true;

    try {
      // Extract arguments if available
      if (Get.arguments != null) {
        className = Get.arguments['className'] ?? '';
        sectionName = Get.arguments['sectionName'] ?? '';
        subjectName = Get.arguments['subjectName'] ?? '';
        classId = Get.arguments['classId'] ?? '';
        sectionId = Get.arguments['sectionId'] ?? '';
        subjectId = Get.arguments['subjectId'] ?? '';
      }

      await loadStudents();
    } catch (e) {
      log('Error in initData of TeacherPerformanceScreen: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadStudents() async {
    try {
      final result = await controller.getPeopleList(
        classId: classId.isEmpty ? null : classId,
        sectionId: sectionId.isEmpty ? null : sectionId,
        subjectId: subjectId.isEmpty ? null : subjectId,
        pageNumber: currentPage.value,
      );

      if (result != null) {
        final students = result[ApiParameter.students] as List<PeopleModel>;

        if (currentPage.value == 1) {
          // First page - replace current list
          studentsList.value = students;
        } else {
          // Subsequent pages - append to list
          studentsList.addAll(students);
        }

        // Update pagination status
        hasNext.value = result[ApiParameter.hasNext] ?? false;
      }
    } catch (e) {
      log('Error loading students data: $e');
      commonSnackBar(
        message: "Failed to load students data. Please try again.",
        color: Colors.red,
      );
    }
  }

  void scrollListener() {
    if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent &&
        hasNext.value) {
      // Load more data when scrolled to bottom
      currentPage.value++;
      loadStudents();
    }
  }

  void refreshData() {
    currentPage.value = 1;
    loadStudents();
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      appBar: commonAppBar(
        context: context,
        isBack: true,
        title: "Student Performance",
        actions: [
          IconButton(
            onPressed: refreshData,
            icon: Icon(Icons.refresh, color: AppColors.blueColor),
          ).paddingOnly(right: getWidth(8)),
        ],
      ),
      body: Obx(
        () =>
            isLoading.value
                ? Center(child: commonLoader())
                : RefreshIndicator(
                  onRefresh: () async {
                    refreshData();
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Class and subject info card
                      _buildHeaderCard(),

                      // Instruction text
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          getWidth(16),
                          getHeight(16),
                          getWidth(16),
                          getHeight(8),
                        ),
                        child: Text(
                          "Select a student to view their performance report:",
                          style: TextStyle(
                            fontSize: getWidth(14),
                            fontStyle: FontStyle.italic,
                            color: AppColors.textColor.withOpacity(0.7),
                          ),
                        ),
                      ),

                      // Students list
                      Expanded(
                        child:
                            studentsList.isEmpty
                                ? _buildEmptyState()
                                : ListView.builder(
                                  controller: scrollController,
                                  padding: EdgeInsets.all(getWidth(16)),
                                  itemCount:
                                      studentsList.length +
                                      (hasNext.value ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == studentsList.length) {
                                      // Show loader at the end if more items are loading
                                      return Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(getWidth(16)),
                                          child: commonLoader(),
                                        ),
                                      );
                                    }

                                    return _buildStudentTile(
                                      studentsList[index],
                                      index + 1,
                                    );
                                  },
                                ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(getWidth(16)),
      margin: EdgeInsets.all(getWidth(16)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.blueColor.withOpacity(0.1),
            AppColors.blueColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(getWidth(12)),
        border: Border.all(color: AppColors.blueColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subjectName.isNotEmpty)
            Row(
              children: [
                Icon(
                  Icons.book_rounded,
                  color: AppColors.blueColor,
                  size: getWidth(20),
                ),
                SizedBox(width: getWidth(8)),
                Expanded(
                  child: Text(
                    subjectName,
                    style: TextStyle(
                      fontSize: getWidth(16),
                      fontWeight: FontWeight.w600,
                      color: AppColors.blueColor,
                    ),
                  ),
                ),
              ],
            ),
          if (subjectName.isNotEmpty && className.isNotEmpty)
            SizedBox(height: getHeight(8)),
          if (className.isNotEmpty)
            Row(
              children: [
                Icon(
                  Icons.school_rounded,
                  color: AppColors.textColor.withOpacity(0.6),
                  size: getWidth(20),
                ),
                SizedBox(width: getWidth(8)),
                Text(
                  "Class $className${sectionName.isNotEmpty ? ' - Section $sectionName' : ''}",
                  style: TextStyle(
                    fontSize: getWidth(15),
                    fontWeight: FontWeight.w500,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
          SizedBox(height: getHeight(8)),
          Row(
            children: [
              Icon(
                Icons.people_alt_rounded,
                color: AppColors.textColor.withOpacity(0.6),
                size: getWidth(20),
              ),
              SizedBox(width: getWidth(8)),
              Text(
                "${studentsList.length} students",
                style: TextStyle(
                  fontSize: getWidth(15),
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudentTile(PeopleModel student, int serialNumber) {
    return GestureDetector(
      onTap: () {
        if (student.sId != null) {
          Get.toNamed(
            RouteNames.teacherStudentPerformance,
            arguments: {
              'studentId': student.sId!,
              'studentName': student.name ?? 'Student',
              'studentImage': student.profileImage,
              'className': className,
              'sectionName': sectionName,
              'subjectName': subjectName,
            },
          );
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: getHeight(12)),
        padding: EdgeInsets.all(getWidth(12)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(getWidth(12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Serial number
            Container(
              width: getWidth(28),
              height: getWidth(28),
              decoration: BoxDecoration(
                color: AppColors.blueColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  serialNumber.toString(),
                  style: TextStyle(
                    fontSize: getWidth(14),
                    fontWeight: FontWeight.bold,
                    color: AppColors.blueColor,
                  ),
                ),
              ),
            ),
            SizedBox(width: getWidth(12)),

            // Student profile image
            Container(
              width: getWidth(40),
              height: getWidth(40),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.grey.withOpacity(0.1),
                border: Border.all(
                  color: AppColors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child:
                  student.profileImage != null &&
                          student.profileImage!.isNotEmpty
                      ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: student.profileImage!,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => Container(
                                color: AppColors.grey.withOpacity(0.3),
                                child: Icon(
                                  Icons.person_rounded,
                                  color: AppColors.blueColor,
                                  size: getWidth(32),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                color: AppColors.blueColor.withOpacity(0.15),
                                child: Icon(
                                  Icons.person_rounded,
                                  color: AppColors.blueColor,
                                  size: getWidth(32),
                                ),
                              ),
                        ),
                      )
                      : Icon(
                        Icons.person,
                        color: AppColors.grey,
                        size: getWidth(24),
                      ),
            ),
            SizedBox(width: getWidth(12)),

            // Student name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name ?? 'Unknown Student',
                    style: TextStyle(
                      fontSize: getWidth(15),
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColor,
                    ),
                  ),
                  if (student.email != null && student.email!.isNotEmpty) ...[
                    SizedBox(height: getHeight(2)),
                    Text(
                      student.email!,
                      style: TextStyle(
                        fontSize: getWidth(12),
                        color: AppColors.textColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Arrow icon
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.blueColor,
              size: getWidth(16),
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
            Icons.people_alt_outlined,
            size: getWidth(64),
            color: AppColors.grey.withOpacity(0.5),
          ),
          SizedBox(height: getHeight(16)),
          Text(
            "No Students Found",
            style: TextStyle(
              fontSize: getWidth(18),
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          SizedBox(height: getHeight(8)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: getWidth(32)),
            child: Text(
              "There are no students assigned to this class yet.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: getWidth(14),
                color: AppColors.textColor.withOpacity(0.7),
              ),
            ),
          ),
          SizedBox(height: getHeight(24)),
          materialButtonOnlyText(text: "Refresh", onTap: refreshData),
        ],
      ),
    );
  }
}
