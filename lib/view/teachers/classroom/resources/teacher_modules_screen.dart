import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/teachers/teacher_classroom_controller.dart';
import 'package:Vadai/model/common/chapter_model.dart';
import 'package:Vadai/model/common/module_model.dart';
import 'package:dio/dio.dart' as dio;

class TeacherModulesScreen extends StatefulWidget {
  const TeacherModulesScreen({Key? key}) : super(key: key);

  @override
  State<TeacherModulesScreen> createState() => _TeacherModulesScreenState();
}

class _TeacherModulesScreenState extends State<TeacherModulesScreen> {
  final TeacherClassroomController controller = Get.find();
  final TextEditingController moduleNameController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final RxBool isLoading = true.obs;
  final RxBool isSearching = false.obs;
  final RxList<ModuleModel> modules = <ModuleModel>[].obs;

  ChapterModel? chapter;
  String subjectName = '';
  String className = '';
  String sectionName = '';
  dio.CancelToken? _cancelToken;

  @override
  void initState() {
    super.initState();
    _cancelToken = dio.CancelToken();
    initData();
  }

  @override
  void dispose() {
    moduleNameController.dispose();
    searchController.dispose();
    _cancelToken?.cancel();
    super.dispose();
  }

  Future<void> initData() async {
    isLoading.value = true;

    try {
      if (Get.arguments != null) {
        // Extract arguments
        chapter = Get.arguments['chapter'];
        subjectName = Get.arguments['subjectName'] ?? '';
        className = Get.arguments['className'] ?? '';
        sectionName = Get.arguments['sectionName'] ?? '';
      }

      if (chapter == null) {
        Get.back();
        return;
      }

      // Load modules
      await loadModules();
    } catch (e) {
      log('Error in initData of TeacherModulesScreen: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadModules() async {
    try {
      final List<ModuleModel>? modulesList = await controller
          .getTeachersResourceModuleList(
            chapterId: chapter?.sId ?? '',
            cancelToken: _cancelToken,
          );

      if (modulesList != null) {
        modules.value = modulesList;
      } else {
        modules.clear();
      }
    } catch (e) {
      log('Error loading modules: $e');
    }
  }

  Future<void> searchModules(String searchText) async {
    if (_cancelToken != null && !_cancelToken!.isCancelled) {
      _cancelToken!.cancel();
    }
    _cancelToken = dio.CancelToken();

    if (searchText.isEmpty) {
      await loadModules();
      return;
    }

    isSearching.value = true;

    try {
      final List<ModuleModel>? searchResults = await controller
          .getTeachersResourceModuleList(
            chapterId: chapter?.sId ?? '',
            searchTag: searchText,
            cancelToken: _cancelToken,
          );

      if (searchResults != null) {
        modules.value = searchResults;
      }
    } catch (e) {
      if (e is dio.DioException && e.type == dio.DioExceptionType.cancel) {
        // Request was cancelled, which is expected during rapid typing
        log('Search cancelled');
      } else {
        log('Error searching modules: $e');
      }
    } finally {
      isSearching.value = false;
    }
  }

  void showAddModuleDialog() {
    moduleNameController.clear();

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
                "Add New Module",
                style: TextStyle(
                  fontSize: getWidth(18),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              SizedBox(height: getHeight(20)),

              commonTextFiled(
                controller: moduleNameController,
                hintText: "Enter module name",
              ),

              SizedBox(height: getHeight(24)),

              Text(
                "Note: You can add documents to this module after it has been created.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: getWidth(12),
                  color: AppColors.textColor.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
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
                      if (moduleNameController.text.trim().isEmpty) {
                        commonSnackBar(
                          message: "Please enter a module name",
                          color: Colors.red,
                        );
                        return;
                      }

                      Get.back(); // Close dialog

                      // Create an empty module first
                      Get.dialog(
                        Center(child: commonLoader()),
                        barrierDismissible: false,
                      );

                      final success = await controller.addModule(
                        moduleName: moduleNameController.text.trim(),
                        chapterId: chapter?.sId ?? '',
                        documents: [], // Start with empty document list
                      );

                      Get.back(); // Close loading dialog

                      if (success) {
                        await loadModules(); // Refresh modules list

                        // Now prompt to add documents
                        commonSnackBar(
                          message:
                              "Module created successfully! You can now add documents.",
                          color: AppColors.green,
                        );

                        // TODO: Navigate to add documents screen or show document upload dialog
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
                      "Add Module",
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

  void showDeleteConfirmation(ModuleModel module) {
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
                "Delete Module?",
                style: TextStyle(
                  fontSize: getWidth(18),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              SizedBox(height: getHeight(8)),

              Text(
                "Are you sure you want to delete this module? All documents within this module will also be deleted. This action cannot be undone.",
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
                        Get.back(); // Close dialog

                        // Show loading indicator
                        Get.dialog(
                          Center(child: commonLoader()),
                          barrierDismissible: false,
                        );

                        final success = await controller.deleteModule(
                          moduleId: module.sId ?? '',
                        );

                        Get.back(); // Close loading dialog

                        if (success) {
                          await loadModules(); // Refresh modules list
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
        title: "Modules",
        isBack: true,
        actions: [
          IconButton(
            onPressed: () {
              searchController.clear();
              loadModules();
            },
            icon: Icon(Icons.refresh, color: AppColors.blueColor),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddModuleDialog,
        backgroundColor: AppColors.blueColor,
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Chapter info card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(getWidth(16)),
            margin: EdgeInsets.all(getWidth(16)),
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
                      Icons.folder_rounded,
                      color: AppColors.blueColor,
                      size: getWidth(24),
                    ),
                    SizedBox(width: getWidth(12)),
                    Expanded(
                      child: Text(
                        chapter?.chapterName ?? 'Unnamed Chapter',
                        style: TextStyle(
                          fontSize: getWidth(18),
                          fontWeight: FontWeight.bold,
                          color: AppColors.blueColor,
                        ),
                      ),
                    ),
                  ],
                ),
                if (subjectName.isNotEmpty) ...[
                  SizedBox(height: getHeight(12)),
                  Row(
                    children: [
                      Icon(
                        Icons.book_rounded,
                        color: AppColors.textColor.withOpacity(0.6),
                        size: getWidth(16),
                      ),
                      SizedBox(width: getWidth(12)),
                      Text(
                        subjectName,
                        style: TextStyle(
                          fontSize: getWidth(14),
                          color: AppColors.textColor.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
                if (className.isNotEmpty) ...[
                  SizedBox(height: getHeight(6)),
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

          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: getWidth(16)),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search modules...",
                prefixIcon: Icon(Icons.search, color: AppColors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(getWidth(30)),
                  borderSide: BorderSide(
                    color: AppColors.grey.withOpacity(0.3),
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: getHeight(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: searchModules,
            ),
          ),

          // Module count

          // Modules list
          Expanded(
            child: Obx(() {
              if (isLoading.value) {
                return Center(child: commonLoader());
              } else if (modules.isEmpty) {
                return _buildEmptyState();
              } else {
                return ListView.builder(
                  padding: EdgeInsets.all(getWidth(16)),
                  itemCount: modules.length,
                  itemBuilder:
                      (context, index) => _buildModuleItem(modules[index]),
                );
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: getHeight(20)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.folder_open_outlined,
                size: getWidth(80),
                color: AppColors.grey.withOpacity(0.5),
              ),
              SizedBox(height: getHeight(24)),
              Text(
                "No Modules Yet",
                style: TextStyle(
                  fontSize: getWidth(20),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              SizedBox(height: getHeight(12)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: getWidth(20)),
                child: Text(
                  "Add your first module to organize your teaching materials",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: getWidth(16),
                    color: AppColors.textColor.withOpacity(0.7),
                  ),
                ),
              ),
              SizedBox(height: getHeight(32)),
              ElevatedButton.icon(
                onPressed: showAddModuleDialog,
                icon: Icon(Icons.add_circle_outline, color: Colors.white),
                label: Text(
                  "Add New Module",
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
        ),
      ),
    );
  }

  Widget _buildModuleItem(ModuleModel module) {
    final documentCount = module.documents?.length ?? 0;

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
              RouteNames.teacherModuleDetails,
              arguments: {
                'module': module,
                'chapterName': chapter?.chapterName,
              },
            )?.then((_) => loadModules());
          },
          borderRadius: BorderRadius.circular(getWidth(12)),
          child: Padding(
            padding: EdgeInsets.all(getWidth(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: getWidth(48),
                      height: getWidth(48),
                      decoration: BoxDecoration(
                        color: AppColors.blueColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(getWidth(8)),
                      ),
                      child: Icon(
                        Icons.article_rounded,
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
                            module.moduleName ?? 'Unnamed Module',
                            style: TextStyle(
                              fontSize: getWidth(16),
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                          ),
                          SizedBox(height: getHeight(4)),
                          Text(
                            "Created: ${timeAgoMethod(module.createdAt ?? '')}",
                            style: TextStyle(
                              fontSize: getWidth(12),
                              color: AppColors.textColor.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => showDeleteConfirmation(module),
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red.withOpacity(0.7),
                        size: getWidth(20),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: getHeight(12)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: getWidth(12),
                    vertical: getHeight(6),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.blueColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(getWidth(16)),
                  ),
                  child: Text(
                    "$documentCount ${documentCount == 1 ? 'Document' : 'Documents'}",
                    style: TextStyle(
                      fontSize: getWidth(12),
                      fontWeight: FontWeight.w500,
                      color: AppColors.blueColor,
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
}
