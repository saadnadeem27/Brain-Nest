import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/teachers/teacher_classroom_controller.dart';
import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/model/common/poeple_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TeacherPeoplesScreen extends StatefulWidget {
  const TeacherPeoplesScreen({Key? key}) : super(key: key);

  @override
  State<TeacherPeoplesScreen> createState() => _TeacherPeoplesScreenState();
}

class _TeacherPeoplesScreenState extends State<TeacherPeoplesScreen> {
  final TeacherClassroomController controller = Get.find();
  final RxBool isLoading = true.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasNext = false.obs;
  final ScrollController scrollController = ScrollController();

  final RxList<PeopleModel> peopleList = <PeopleModel>[].obs;
  Rx<TeacherModel?> teacher = Rx<TeacherModel?>(null);

  String className = '';
  String sectionName = '';
  String subjectName = '';
  String classId = '';
  String sectionId = '';
  String subjectId = '';
  String pageTitle = 'Students';

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

      // Set the page title
      if (subjectName.isNotEmpty) {
        pageTitle = '$subjectName Students';
      } else if (className.isNotEmpty) {
        pageTitle =
            'Class $className${sectionName.isNotEmpty ? '-$sectionName' : ''} Students';
      }

      await loadPeople();
    } catch (e) {
      log('Error in initData of TeacherPeoplesScreen: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadPeople() async {
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
          peopleList.value = students;
        } else {
          // Subsequent pages - append to list
          peopleList.addAll(students);
        }

        // Update teacher info
        teacher.value = result[ApiParameter.teacherProfile] as TeacherModel?;

        // Update pagination status
        hasNext.value = result[ApiParameter.hasNext] ?? false;
      }
    } catch (e) {
      log('Error loading people data: $e');
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
      loadPeople();
    }
  }

  void refreshData() {
    currentPage.value = 1;
    loadPeople();
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      appBar: commonAppBar(
        context: context,
        isBack: true,
        title: pageTitle,
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
                      // Header info card
                      if (className.isNotEmpty || subjectName.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(getWidth(16)),
                          margin: EdgeInsets.fromLTRB(
                            getWidth(16),
                            getHeight(16),
                            getWidth(16),
                            getHeight(8),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.blueColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(getWidth(12)),
                            border: Border.all(
                              color: AppColors.blueColor.withOpacity(0.2),
                            ),
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
                              if (subjectName.isNotEmpty &&
                                  className.isNotEmpty)
                                SizedBox(height: getHeight(8)),
                              if (className.isNotEmpty)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.school_rounded,
                                      color: AppColors.textColor.withOpacity(
                                        0.6,
                                      ),
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
                                    "${peopleList.length} students",
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
                        ),

                      // "Teacher" header with divider
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          getWidth(16),
                          getHeight(16),
                          getWidth(16),
                          getHeight(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Teacher",
                              style: TextStyle(
                                fontSize: getWidth(16),
                                fontWeight: FontWeight.w600,
                                color: AppColors.blueColor,
                              ),
                            ),
                            SizedBox(height: getHeight(2)),
                            Divider(
                              color: AppColors.blueColor.withOpacity(0.2),
                              thickness: 1,
                            ),
                          ],
                        ),
                      ),

                      // Teacher profile
                      Obx(() => _buildTeacherTile(teacher.value)),

                      // "Students" header with divider
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          getWidth(16),
                          getHeight(16),
                          getWidth(16),
                          getHeight(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Students",
                              style: TextStyle(
                                fontSize: getWidth(16),
                                fontWeight: FontWeight.w600,
                                color: AppColors.blueColor,
                              ),
                            ),
                            SizedBox(height: getHeight(2)),
                            Divider(
                              color: AppColors.blueColor.withOpacity(0.2),
                              thickness: 1,
                            ),
                          ],
                        ),
                      ),

                      // Students list
                      Expanded(
                        child:
                            peopleList.isEmpty
                                ? _buildEmptyState()
                                : ListView.builder(
                                  controller: scrollController,
                                  padding: EdgeInsets.only(
                                    bottom: getHeight(16),
                                  ),
                                  itemCount:
                                      peopleList.length +
                                      (hasNext.value ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == peopleList.length) {
                                      // Show loader at the end if more items are loading
                                      return Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(getWidth(16)),
                                          child: commonLoader(),
                                        ),
                                      );
                                    }

                                    return _buildStudentTile(peopleList[index]);
                                  },
                                ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildTeacherTile(TeacherModel? teacherModel) {
    if (teacherModel == null) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: getWidth(16),
        vertical: getHeight(8),
      ),
      child: Row(
        children: [
          Container(
            width: getWidth(40),
            height: getWidth(40),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.blueColor.withOpacity(0.1),
              border: Border.all(
                color: AppColors.blueColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child:
                teacherModel.profileImage != null &&
                        teacherModel.profileImage!.isNotEmpty
                    ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: teacherModel.profileImage ?? '',
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
                      color: AppColors.blueColor,
                      size: getWidth(24),
                    ),
          ),
          SizedBox(width: getWidth(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teacherModel.name ?? 'Unknown Teacher',
                  style: TextStyle(
                    fontSize: getWidth(15),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
                SizedBox(height: getHeight(2)),
                Text(
                  'Class Teacher',
                  style: TextStyle(
                    fontSize: getWidth(12),
                    color: AppColors.textColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentTile(PeopleModel student) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: getWidth(16),
        vertical: getHeight(8),
      ),
      child: Row(
        children: [
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
                student.profileImage != null && student.profileImage!.isNotEmpty
                    ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: student.profileImage ?? '',
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
        ],
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
        ],
      ),
    );
  }
}
