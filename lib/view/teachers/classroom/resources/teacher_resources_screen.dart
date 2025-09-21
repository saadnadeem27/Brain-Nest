import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/teachers/teacher_classroom_controller.dart';
import 'package:Vadai/model/common/chapter_model.dart';

class TeacherResourcesScreen extends StatefulWidget {
  const TeacherResourcesScreen({Key? key}) : super(key: key);

  @override
  State<TeacherResourcesScreen> createState() => _TeacherResourcesScreenState();
}

class _TeacherResourcesScreenState extends State<TeacherResourcesScreen> {
  final TeacherClassroomController controller = Get.find();
  final TextEditingController chapterNameController = TextEditingController();
  final RxBool isLoading = true.obs;
  final RxList<ChapterModel> chapters = <ChapterModel>[].obs;

  String className = '';
  String sectionName = '';
  String subjectName = '';
  String classId = '';
  String sectionId = '';
  String subjectId = '';

  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  void dispose() {
    chapterNameController.dispose();
    super.dispose();
  }

  Future<void> initData() async {
    isLoading.value = true;

    try {
      if (Get.arguments != null) {
        // Extract arguments
        className = Get.arguments['className'] ?? '';
        sectionName = Get.arguments['sectionName'] ?? '';
        subjectName = Get.arguments['subjectName'] ?? '';
        classId = Get.arguments['classId'] ?? '';
        sectionId = Get.arguments['sectionId'] ?? '';
        subjectId = Get.arguments['subjectId'] ?? '';
      }

      // Load chapters
      await loadChapters();
    } catch (e) {
      log('Error in initData of TeacherResourcesScreen: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadChapters() async {
    isLoading.value = true;
    try {
      final List<ChapterModel>? chaptersList = await controller
          .getResourceChapterList(subjectId: subjectId);

      if (chaptersList != null) {
        chapters.value = chaptersList;
      } else {
        chapters.clear();
      }
    } catch (e) {
      log('Error loading chapters: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void showAddChapterDialog() {
    chapterNameController.clear();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(getWidth(16)),
        ),
        child: Container(
          padding: EdgeInsets.all(getWidth(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Add New Chapter",
                style: TextStyle(
                  fontSize: getWidth(18),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              SizedBox(height: getHeight(20)),

              commonTextFiled(
                controller: chapterNameController,
                hintText: "Enter chapter name",
              ),

              SizedBox(height: getHeight(24)),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontSize: getWidth(16),
                      ),
                    ),
                  ),
                  SizedBox(width: getWidth(12)),
                  ElevatedButton(
                    onPressed: () async {
                      if (chapterNameController.text.trim().isEmpty) {
                        commonSnackBar(
                          message: "Please enter a chapter name",
                          color: Colors.red,
                        );
                        return;
                      }

                      Get.back(); // Close dialog

                      // Show loading indicator
                      Get.dialog(
                        Center(child: commonLoader()),
                        barrierDismissible: false,
                      );

                      final success = await controller.addChapter(
                        chapterName: chapterNameController.text.trim(),
                        subjectId: subjectId,
                        classId: classId.isEmpty ? null : classId,
                        sectionId: sectionId.isEmpty ? null : sectionId,
                      );

                      Get.back(); // Close loading dialog

                      if (success) {
                        await loadChapters(); // Refresh chapters list
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blueColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: getWidth(16),
                        vertical: getHeight(12),
                      ),
                    ),
                    child: Text(
                      "Add Chapter",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: getWidth(16),
                      ),
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

  void showDeleteConfirmation(ChapterModel chapter) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(getWidth(16)),
        ),
        child: Container(
          padding: EdgeInsets.all(getWidth(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: getWidth(48),
              ),
              SizedBox(height: getHeight(16)),

              Text(
                "Delete Chapter?",
                style: TextStyle(
                  fontSize: getWidth(18),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              SizedBox(height: getHeight(8)),

              Text(
                "Are you sure you want to delete this chapter? This will also delete all modules and resources within this chapter. This action cannot be undone.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: getWidth(14),
                  color: AppColors.textColor.withOpacity(0.7),
                ),
              ),

              SizedBox(height: getHeight(24)),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.grey),
                        padding: EdgeInsets.symmetric(vertical: getHeight(12)),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontSize: getWidth(14),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: getWidth(12)),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        Get.dialog(
                          Center(child: commonLoader()),
                          barrierDismissible: false,
                        );

                        final success = await controller.deleteChapter(
                          chapterId: chapter.sId ?? '',
                        );

                        Get.back(); // Close loading dialog

                        if (success) {
                          await loadChapters(); // Refresh chapters list
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: getHeight(12)),
                      ),
                      child: Text(
                        "Delete",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: getWidth(14),
                        ),
                      ),
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

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      appBar: commonAppBar(
        context: context,
        title: "Resources",
        isBack: true,
        actions: [
          IconButton(
            onPressed: loadChapters,
            icon: Icon(Icons.refresh, color: AppColors.blueColor),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddChapterDialog,
        backgroundColor: AppColors.blueColor,
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: Obx(() {
        if (isLoading.value) {
          return Center(child: commonLoader());
        } else if (chapters.isEmpty) {
          return _buildEmptyState();
        } else {
          return _buildChaptersList();
        }
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: getWidth(80),
            color: AppColors.grey.withOpacity(0.5),
          ),
          SizedBox(height: getHeight(24)),
          Text(
            "No Chapters Yet",
            style: TextStyle(
              fontSize: getWidth(20),
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          SizedBox(height: getHeight(12)),
          Text(
            "Add your first chapter to organize your teaching resources",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: getWidth(16),
              color: AppColors.textColor.withOpacity(0.7),
            ),
          ),
          SizedBox(height: getHeight(32)),
          ElevatedButton.icon(
            onPressed: showAddChapterDialog,
            icon: Icon(Icons.add_circle_outline, color: Colors.white),
            label: Text(
              "Add New Chapter",
              style: TextStyle(color: Colors.white, fontSize: getWidth(16)),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueColor,
              padding: EdgeInsets.symmetric(
                horizontal: getWidth(24),
                vertical: getHeight(12),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(getWidth(30)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChaptersList() {
    return ListView(
      padding: EdgeInsets.all(getWidth(16)),
      children: [
        // Subject and class info card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(getWidth(16)),
          margin: EdgeInsets.only(bottom: getHeight(24)),
          decoration: BoxDecoration(
            color: AppColors.blueColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(getWidth(12)),
            border: Border.all(color: AppColors.blueColor.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.book_rounded,
                    color: AppColors.blueColor,
                    size: getWidth(24),
                  ),
                  SizedBox(width: getWidth(12)),
                  Expanded(
                    child: Text(
                      subjectName,
                      style: TextStyle(
                        fontSize: getWidth(18),
                        fontWeight: FontWeight.bold,
                        color: AppColors.blueColor,
                      ),
                    ),
                  ),
                ],
              ),
              if (className.isNotEmpty) ...[
                SizedBox(height: getHeight(12)),
                Row(
                  children: [
                    Icon(
                      Icons.school_rounded,
                      color: AppColors.textColor.withOpacity(0.6),
                      size: getWidth(16),
                    ),
                    SizedBox(width: getWidth(12)),
                    Text(
                      "Class $className ${sectionName.isNotEmpty ? '- Section $sectionName' : ''}",
                      style: TextStyle(
                        fontSize: getWidth(14),
                        color: AppColors.textColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // Chapters count
        Padding(
          padding: EdgeInsets.only(
            left: getWidth(8),
            bottom: getHeight(16),
            top: getHeight(8),
          ),
          child: Text(
            "${chapters.length} ${chapters.length == 1 ? 'Chapter' : 'Chapters'}",
            style: TextStyle(
              fontSize: getWidth(16),
              fontWeight: FontWeight.w600,
              color: AppColors.textColor.withOpacity(0.7),
            ),
          ),
        ),

        // Chapters list
        ...chapters.map((chapter) => _buildChapterItem(chapter)).toList(),
      ],
    );
  }

  Widget _buildChapterItem(ChapterModel chapter) {
    return Container(
      margin: EdgeInsets.only(bottom: getHeight(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(getWidth(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.toNamed(
              RouteNames.teacherResourceModules,
              arguments: {
                'chapter': chapter,
                'subjectName': subjectName,
                'className': className,
                'sectionName': sectionName,
              },
            )?.then((_) => loadChapters());
          },
          borderRadius: BorderRadius.circular(getWidth(12)),
          child: Padding(
            padding: EdgeInsets.all(getWidth(16)),
            child: Row(
              children: [
                Container(
                  width: getWidth(48),
                  height: getWidth(48),
                  decoration: BoxDecoration(
                    color: AppColors.blueColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(getWidth(12)),
                  ),
                  child: Icon(
                    Icons.folder_rounded,
                    color: AppColors.blueColor,
                    size: getWidth(24),
                  ),
                ),
                SizedBox(width: getWidth(16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chapter.chapterName ?? 'Unnamed Chapter',
                        style: TextStyle(
                          fontSize: getWidth(16),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                        ),
                      ),
                      SizedBox(height: getHeight(4)),
                      Text(
                        "Created: ${timeAgoMethod(chapter.createdAt ?? '')}",
                        style: TextStyle(
                          fontSize: getWidth(12),
                          color: AppColors.textColor.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => showDeleteConfirmation(chapter),
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red.withOpacity(0.7),
                    size: getWidth(20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
