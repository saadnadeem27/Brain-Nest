import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/student/school_controller.dart';
import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/model/students/school_details_model.dart';
import 'package:Vadai/model/students/subject_model.dart';

class UploadSubject extends StatefulWidget {
  const UploadSubject({super.key});

  @override
  State<UploadSubject> createState() => _UploadSubjectState();
}

class _UploadSubjectState extends State<UploadSubject> {
  final ScrollController scrollController = ScrollController();
  SchoolController schoolCtr = Get.put(SchoolController());
  SchoolDetailModel? schoolList;
  List<SubjectModel?> subjectList = [];
  RxBool isLoading = false.obs;
  String? schoolId;
  String? classId;
  String? sectionId;
  String? studentName;
  String? rollNumber;
  String? phoneNumber;
  String? parentWhatsappNumber;
  String? studentWhatsappNumber;
  String? profileImageUrl;
  RxList<String> selectedSubjectIds = <String>[].obs;

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

  initData() async {
    isLoading.value = true;
    try {
      if (Get.arguments != null) {
        var data = Get.arguments;
        schoolList = data[ApiParameter.school];
        schoolId = data[ApiParameter.schoolId];
        classId = data[ApiParameter.classId];
        sectionId = data[ApiParameter.sectionId];
        studentName = data[ApiParameter.name];
        rollNumber = data['rollNumber'];
        phoneNumber = data['phoneNumber'];
        parentWhatsappNumber = data['parentWhatsapp'];
        studentWhatsappNumber = data['studentWhatsapp'];
        profileImageUrl = data['profileImageUrl'];
      }
      await schoolCtr
          .getSubjectList(schoolId: schoolId ?? '', classId: classId ?? '')
          .then((List<SubjectModel?>? value) {
            if (value != null) {
              subjectList = value;
            }
          });
    } catch (e) {
      log(
        '----------------------------->>>>>>>>>>>>>>>>>>> error is $e and  get arguments is ${Get.arguments} and its type is ${Get.arguments.runtimeType}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  submitData() async {
    // if (selectedSubjectIds.isEmpty) {
    //   commonSnackBar(message: AppStrings.pleaseSelectASubject);
    //   return;
    // }
    // try {
    //   isLoading.value = true;
    //   await schoolCtr.completeProfile(
    //     schoolId: schoolId ?? '',
    //     classId: classId ?? '',
    //     sectionId: sectionId ?? '',
    //     name: studentName ?? '',
    //     subjects: selectedSubjectIds,
    //   );
    // } catch (e) {
    //   log('----------------------------->>>>>>>>>>>>>>>>>>> error is $e');
    // } finally {
    //   isLoading.value = false;
    // }
    if (selectedSubjectIds.isEmpty) {
      commonSnackBar(message: AppStrings.pleaseSelectASubject);
      return;
    }

    // Retrieve subject names for display in review screen
    List<String> subjectNames = [];
    for (String id in selectedSubjectIds) {
      final subject = subjectList.firstWhere(
        (element) => element?.sId == id,
        orElse: () => null,
      );
      if (subject != null) {
        subjectNames.add(subject.subjectName ?? '');
      }
    }

    // Navigate to review screen with all collected data
    Get.toNamed(
      RouteNames.profileReview,
      arguments: {
        'school': schoolList,
        'schoolId': schoolId,
        'classId': classId,
        'sectionId': sectionId,
        'name': studentName,
        'rollNumber': rollNumber,
        'phoneNumber': phoneNumber,
        'parentWhatsapp': parentWhatsappNumber,
        'studentWhatsapp': studentWhatsappNumber,
        'profileImageUrl': profileImageUrl,
        'subjects': selectedSubjectIds,
        'subjectNames': subjectNames,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => commonScaffold(
        context: context,
        appBar: commonAppBar(context: context, isBack: true, title: ""),
        bottomNavigationBar:
            isLoading.value
                ? const SizedBox.shrink()
                : materialButtonWithChild(
                  width: double.infinity,
                  onPressed: () => submitData(),
                  child: textWid(
                    AppStrings.saveAndFinish,
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
                ),
        body: Scrollbar(
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
                Center(
                  child: Image.asset(AppAssets.logo, width: getWidth(220)),
                ),
                Center(
                  child: Text(
                    "✅ Final Step: Choose Your Subjects 📚",
                    maxLines: 3,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textColor.withOpacity(0.7),
                      fontSize: getWidth(14),
                    ),
                  ),
                ),

                // Loader or content based on state
                isLoading.value
                    ? Container(
                      height: getHeight(300),
                      alignment: Alignment.center,
                      child: commonLoader(),
                    )
                    : subjectList.isEmpty
                    ? Container(
                      height: getHeight(200),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.book_outlined,
                            size: 64,
                            color: AppColors.grey,
                          ),
                          SizedBox(height: getHeight(16)),
                          textWid(
                            AppStrings.nothingHereTryAgain,
                            style: AppTextStyles.textStyle(
                              fontSize: getWidth(16),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: getHeight(16)),
                          materialButtonWithChild(
                            onPressed: initData,
                            child: Text(
                              "Reload Subjects",
                              style: AppTextStyles.textStyle(
                                fontSize: getWidth(14),
                                fontWeight: FontWeight.w500,
                                txtColor: AppColors.white,
                              ),
                            ),
                            color: AppColors.blueColor,
                          ),
                        ],
                      ),
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: textWid(
                            AppStrings.selectSubjects,
                            style: AppTextStyles.textStyle(
                              fontSize: getWidth(20),
                              txtColor: AppColors.textColor,
                            ),
                          ),
                        ).paddingOnly(top: getHeight(28)),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: textWid(
                            "${AppStrings.className}: ${(schoolList?.classes != null && classId != null) ? (schoolList!.classes!.any((e) => e.sId == classId) ? schoolList!.classes!.firstWhere((e) => e.sId == classId).name : 'Unknown') : 'Unknown'}",
                            maxlines: 1,
                            textOverflow: TextOverflow.ellipsis,
                            style: AppTextStyles.textStyle(
                              txtColor: AppColors.textColor,
                              fontSize: getWidth(18),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ).paddingOnly(top: getHeight(18), bottom: getHeight(8)),

                        Container(
                          margin: EdgeInsets.only(top: getHeight(16)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:
                                subjectList.map((subject) {
                                  final isSelected = selectedSubjectIds
                                      .contains(subject?.sId);
                                  return GestureDetector(
                                    onTap: () {
                                      if (isSelected) {
                                        selectedSubjectIds.remove(
                                          subject?.sId ?? '',
                                        );
                                      } else {
                                        selectedSubjectIds.add(
                                          subject?.sId ?? "",
                                        );
                                      }
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      margin: EdgeInsets.only(
                                        bottom: getHeight(10),
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.05,
                                            ),
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                        border: Border.all(
                                          color:
                                              isSelected
                                                  ? AppColors.blueColor
                                                  : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: getWidth(16),
                                          vertical: getHeight(14),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: getWidth(24),
                                              height: getWidth(24),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color:
                                                    isSelected
                                                        ? AppColors.blueColor
                                                        : Colors.white,
                                                border: Border.all(
                                                  color:
                                                      isSelected
                                                          ? AppColors.blueColor
                                                          : AppColors.textColor
                                                              .withOpacity(0.5),
                                                  width: 2,
                                                ),
                                              ),
                                              child:
                                                  isSelected
                                                      ? Icon(
                                                        Icons.check,
                                                        size: getWidth(16),
                                                        color: Colors.white,
                                                      )
                                                      : null,
                                            ),
                                            SizedBox(width: getWidth(16)),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    subject?.subjectName ?? '',
                                                    style:
                                                        AppTextStyles.textStyle(
                                                          fontSize: getWidth(
                                                            16,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          txtColor:
                                                              AppColors
                                                                  .textColor,
                                                        ),
                                                  ),
                                                  if (subject?.sId != null)
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                        top: getHeight(4),
                                                      ),
                                                      child: Text(
                                                        "Code: ${subject?.subjectId}",
                                                        style: TextStyle(
                                                          fontSize: getWidth(
                                                            12,
                                                          ),
                                                          color: AppColors
                                                              .textColor
                                                              .withOpacity(0.6),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.all(
                                                getWidth(8),
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                    isSelected
                                                        ? AppColors.blueColor
                                                            .withOpacity(0.1)
                                                        : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                isSelected
                                                    ? Icons.done
                                                    : Icons.add,
                                                color:
                                                    isSelected
                                                        ? AppColors.blueColor
                                                        : AppColors.textColor
                                                            .withOpacity(0.5),
                                                size: getWidth(20),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),

                        // Selection summary
                        Obx(
                          () =>
                              selectedSubjectIds.isNotEmpty
                                  ? Container(
                                    margin: EdgeInsets.only(top: getHeight(16)),
                                    padding: EdgeInsets.all(getWidth(12)),
                                    decoration: BoxDecoration(
                                      color: AppColors.grey.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: AppColors.blueColor,
                                          size: getWidth(20),
                                        ),
                                        SizedBox(width: getWidth(8)),
                                        Expanded(
                                          child: Text(
                                            "You've selected ${selectedSubjectIds.length} subject${selectedSubjectIds.length > 1 ? 's' : ''}",
                                            style: AppTextStyles.textStyle(
                                              fontSize: getWidth(14),
                                              txtColor: AppColors.textColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  : SizedBox(),
                        ),
                      ],
                    ),
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
}
