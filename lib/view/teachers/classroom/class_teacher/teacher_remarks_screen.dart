import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/teachers/teacher_classroom_controller.dart';
import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/model/common/poeple_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TeacherRemarksScreen extends StatefulWidget {
  const TeacherRemarksScreen({Key? key}) : super(key: key);

  @override
  State<TeacherRemarksScreen> createState() => _TeacherRemarksScreenState();
}

class _TeacherRemarksScreenState extends State<TeacherRemarksScreen> {
  final TeacherClassroomController controller = Get.find();
  final RxBool isLoading = true.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasNext = false.obs;
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  final RxList<PeopleModel> peopleList = <PeopleModel>[].obs;
  final RxList<PeopleModel> filteredPeopleList = <PeopleModel>[].obs;
  Rx<TeacherModel?> teacher = Rx<TeacherModel?>(null);

  String teacherName = '';

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.arguments != null) {
        teacherName = Get.arguments['teacherName'] ?? '';
      }
      loadStudents();
    });
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadStudents() async {
    isLoading.value = true;
    try {
      final result = await controller.getPeopleList(
        pageNumber: currentPage.value,
      );

      if (result != null) {
        final students = result[ApiParameter.students] as List<PeopleModel>;

        if (currentPage.value == 1) {
          peopleList.value = students;
        } else {
          peopleList.addAll(students);
        }

        // Also update the filtered list
        filteredPeopleList.value = List.from(peopleList);

        teacher.value = result[ApiParameter.teacherProfile] as TeacherModel?;
        hasNext.value = result[ApiParameter.hasNext] ?? false;
      }
    } catch (e) {
      log('Error loading student data: $e');
      commonSnackBar(
        message: "Failed to load students data. Please try again.",
        color: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void scrollListener() {
    if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent &&
        hasNext.value) {
      currentPage.value++;
      loadStudents();
    }
  }

  void refreshData() {
    currentPage.value = 1;
    searchController.clear();
    loadStudents();
  }

  void filterStudents(String query) {
    if (query.isEmpty) {
      filteredPeopleList.value = List.from(peopleList);
    } else {
      filteredPeopleList.value =
          peopleList
              .where(
                (student) =>
                    student.name != null &&
                    student.name!.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    }
  }

  void navigateToStudentRemarks(PeopleModel student) {
    Get.toNamed(
      RouteNames.teacherStudentRemarks,
      arguments: {'student': student, 'teacherName': teacherName},
    );
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      resizeToAvoidBottomInset: true,
      appBar: commonAppBar(
        context: context,
        isBack: true,
        title: "Student Remarks",
        actions: [
          IconButton(
            onPressed: refreshData,
            icon: Icon(Icons.refresh, color: AppColors.blueColor),
          ).paddingOnly(right: getWidth(8)),
        ],
      ),
      body: SafeArea(
        child: Obx(
          () =>
              isLoading.value
                  ? Center(child: commonLoader())
                  // Wrap the main column with SingleChildScrollView to make it scrollable when keyboard appears
                  : SingleChildScrollView(
                    // Enable physics for better scrolling experience
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search field
                        Padding(
                          padding: EdgeInsets.all(getWidth(16)),
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: 'Search students...',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  getWidth(12),
                                ),
                                borderSide: BorderSide(
                                  color: AppColors.grey.withOpacity(0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  getWidth(12),
                                ),
                                borderSide: BorderSide(
                                  color: AppColors.blueColor,
                                  width: 2,
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: getWidth(16),
                                vertical: getHeight(12),
                              ),
                              filled: true,
                              fillColor: AppColors.white,
                            ),
                            onChanged: filterStudents,
                          ),
                        ),

                        // Information text
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: getWidth(16),
                          ),
                          child: Text(
                            "Select a student to view or add remarks",
                            style: TextStyle(
                              fontSize: getWidth(14),
                              fontStyle: FontStyle.italic,
                              color: AppColors.textColor.withOpacity(0.7),
                            ),
                          ),
                        ),

                        SizedBox(height: getHeight(16)),

                        // Students list - Use a fixed height container to ensure it doesn't overflow
                        Container(
                          height:
                              MediaQuery.of(context).size.height -
                              MediaQuery.of(context).padding.top -
                              AppBar().preferredSize.height -
                              getHeight(
                                130,
                              ), // Subtract height of search field + info text + padding
                          child: Obx(
                            () =>
                                filteredPeopleList.isEmpty
                                    ? _buildEmptyState()
                                    : RefreshIndicator(
                                      onRefresh: () async {
                                        refreshData();
                                      },
                                      child: ListView.builder(
                                        controller: scrollController,
                                        padding: EdgeInsets.only(
                                          bottom: getHeight(16),
                                        ),
                                        itemCount:
                                            filteredPeopleList.length +
                                            (hasNext.value &&
                                                    searchController
                                                        .text
                                                        .isEmpty
                                                ? 1
                                                : 0),
                                        itemBuilder: (context, index) {
                                          if (index ==
                                              filteredPeopleList.length) {
                                            // Show loader at the end if more items are loading
                                            return Center(
                                              child: Padding(
                                                padding: EdgeInsets.all(
                                                  getWidth(16),
                                                ),
                                                child: commonLoader(),
                                              ),
                                            );
                                          }

                                          return _buildStudentTile(
                                            filteredPeopleList[index],
                                          );
                                        },
                                      ),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildStudentTile(PeopleModel student) {
    return InkWell(
      onTap: () => navigateToStudentRemarks(student),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: getWidth(16),
          vertical: getHeight(12),
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: getWidth(48),
              height: getWidth(48),
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
                        size: getWidth(32),
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
                      fontSize: getWidth(16),
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
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.blueColor.withOpacity(0.5),
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
            searchController.text.isEmpty
                ? "No Students Found"
                : "No matching students",
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
              searchController.text.isEmpty
                  ? "There are no students assigned to this class yet."
                  : "Try a different search term.",
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
