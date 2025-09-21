import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/student/school_controller.dart';
import 'package:Vadai/controller/teachers/teacher_auth_controller.dart';
import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/model/students/school_details_model.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';

class TeacherUploadSchoolDetails extends StatefulWidget {
  const TeacherUploadSchoolDetails({super.key});

  @override
  State<TeacherUploadSchoolDetails> createState() =>
      _TeacherUploadSchoolDetailsState();
}

class _TeacherUploadSchoolDetailsState
    extends State<TeacherUploadSchoolDetails> {
  SchoolController schoolCtr = Get.put(SchoolController());
  TeacherAuthController teacherAuthCtr = Get.find<TeacherAuthController>();
  TextEditingController teacherNameController = TextEditingController();
  TextEditingController whatsappController = TextEditingController();
  List<SchoolDetailModel> schoolList = [];
  SchoolDetailModel? selectedSchool;
  Classes? selectedClass;
  Sections? selectedSection;
  String? profileImageUrl;
  RxBool isClassTeacher = false.obs; // Track if teacher is a class teacher

  SingleValueDropDownController schoolController =
      SingleValueDropDownController();
  SingleValueDropDownController classController =
      SingleValueDropDownController();
  SingleValueDropDownController sectionController =
      SingleValueDropDownController();
  FocusNode searchSchoolFocusNode = FocusNode();
  FocusNode searchClassFocusNode = FocusNode();
  FocusNode searchSectionFocusNode = FocusNode();
  FocusNode textFieldSchoolFocusNode = FocusNode();
  FocusNode textFieldClassFocusNode = FocusNode();
  FocusNode textFieldSectionFocusNode = FocusNode();
  RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null && Get.arguments is Map) {
      profileImageUrl = Get.arguments['profileImageUrl'];
    }
    initSchoolList();
  }

  initSchoolList() async {
    isLoading.value = true;
    try {
      await schoolCtr.getSchoolList().then((List<SchoolDetailModel>? value) {
        if (value != null) {
          schoolList = value;
          if (schoolList.isNotEmpty) {
            selectedSchool = schoolList.first;
            schoolController.dropDownValue = DropDownValueModel(
              name: selectedSchool?.schoolName ?? '',
              value: selectedSchool?.sId,
            );
            if (selectedSchool?.classes != null &&
                (selectedSchool?.classes?.isNotEmpty ?? false)) {
              selectedClass = selectedSchool?.classes?.first;
              classController.dropDownValue = DropDownValueModel(
                name: selectedClass?.name ?? '',
                value: selectedClass?.sId,
              );
              if (selectedClass?.sections != null &&
                  (selectedClass?.sections?.isNotEmpty ?? false)) {
                selectedSection = selectedClass!.sections!.first;
                sectionController.dropDownValue = DropDownValueModel(
                  name: selectedSection!.section ?? '',
                  value: selectedSection!.sId,
                );
              }
            }
          }
        }
      });
    } finally {
      isLoading.value = false;
    }
  }

  bool validateForm() {
    if (teacherNameController.text.isEmpty) {
      commonSnackBar(message: 'Please enter teacher name');
      return false;
    }

    if (schoolController.dropDownValue == null) {
      commonSnackBar(message: 'Please select school');
      return false;
    }

    // Only validate class and section if the user is a class teacher
    if (isClassTeacher.value) {
      if (classController.dropDownValue == null) {
        commonSnackBar(message: 'Please select class');
        return false;
      }

      if (sectionController.dropDownValue == null) {
        commonSnackBar(message: 'Please select section');
        return false;
      }
    }

    if (whatsappController.text.isNotEmpty &&
        whatsappController.text.length < 10) {
      commonSnackBar(message: "Please enter a valid WhatsApp number");
      return false;
    }

    return true;
  }

  submitData() {
    if (!validateForm()) return;

    // Create arguments map with base data
    Map<String, dynamic> args = {
      'school': schoolList.firstWhere(
        (element) => element.sId == schoolController.dropDownValue?.value,
      ),
      'schoolId': schoolController.dropDownValue?.value,
      'name': teacherNameController.text,
      'isClassTeacher': isClassTeacher.value,
      'whatsappNumber': whatsappController.text,
    };

    // Only add class and section details if teacher is a class teacher
    if (isClassTeacher.value) {
      args['classId'] = classController.dropDownValue?.value;
      args['sectionId'] = sectionController.dropDownValue?.value;
    }

    // Add profile image URL if available
    if (profileImageUrl != null) {
      args['profileImageUrl'] = profileImageUrl;
    }

    Get.toNamed(RouteNames.teacherUploadSubject, arguments: args);
  }

  @override
  void dispose() {
    schoolController.dispose();
    classController.dispose();
    sectionController.dispose();
    teacherNameController.dispose();
    whatsappController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      appBar: commonAppBar(context: context, isBack: true, title: ""),
      body: Obx(
        () =>
            isLoading.value
                ? Center(child: commonLoader())
                : SingleChildScrollView(
                  child: Form(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Image.asset(
                            AppAssets.logo,
                            width: getWidth(220),
                          ),
                        ),
                        Center(
                          child: Text(
                            "✏️ Let's build your teacher profile – just a few quick steps!",
                            maxLines: 3,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textColor.withOpacity(0.7),
                              fontSize: getWidth(14),
                            ),
                          ),
                        ),

                        // Teacher Name
                        _buildFieldLabel("Teacher Name"),
                        commonTextFiled(
                          hintText: "Enter your full name",
                          controller: teacherNameController,
                          borderRadius: getWidth(12),
                          borderColor: AppColors.textColor,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter teacher name";
                            }
                            return null;
                          },
                        ),

                        // School Selection
                        _buildFieldLabel("School"),
                        DropDownTextField(
                          controller: schoolController,
                          textFieldFocusNode: textFieldSchoolFocusNode,
                          searchFocusNode: searchSchoolFocusNode,
                          clearOption: true,
                          readOnly: true,
                          searchAutofocus: true,
                          textFieldDecoration: _getDropdownDecoration(
                            "Select School",
                          ),
                          searchDecoration: InputDecoration(
                            hintText: "Search here",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please select school";
                            }
                            return null;
                          },
                          dropDownList:
                              schoolList
                                  .map(
                                    (e) => DropDownValueModel(
                                      name: e.schoolName ?? '',
                                      value: e.sId,
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) {
                            schoolController.dropDownValue = val;
                            selectedSchool = schoolList.firstWhere(
                              (element) => element.sId == val.value,
                            );
                            if (selectedSchool?.classes != null &&
                                (selectedSchool?.classes?.isNotEmpty ??
                                    false)) {
                              selectedClass = selectedSchool?.classes?.first;
                              classController
                                  .dropDownValue = DropDownValueModel(
                                name: selectedClass?.name ?? '',
                                value: selectedClass?.sId,
                              );
                              if (selectedClass?.sections != null &&
                                  (selectedClass?.sections?.isNotEmpty ??
                                      false)) {
                                selectedSection =
                                    selectedClass?.sections?.first;
                                sectionController
                                    .dropDownValue = DropDownValueModel(
                                  name: selectedSection?.section ?? '',
                                  value: selectedSection?.sId,
                                );
                              }
                            }
                          },
                        ),

                        // Class Teacher Selection
                        _buildFieldLabel("Teacher Role"),
                        Obx(
                          () => Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => isClassTeacher.value = true,
                                  child: Container(
                                    padding: EdgeInsets.all(getWidth(12)),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color:
                                            isClassTeacher.value
                                                ? AppColors.blueColor
                                                : AppColors.textColor,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        getWidth(12),
                                      ),
                                      color:
                                          isClassTeacher.value
                                              ? AppColors.blueColor.withOpacity(
                                                0.1,
                                              )
                                              : AppColors.transparent,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isClassTeacher.value
                                              ? Icons.radio_button_checked
                                              : Icons.radio_button_unchecked,
                                          color:
                                              isClassTeacher.value
                                                  ? AppColors.blueColor
                                                  : AppColors.textColor,
                                          size: getWidth(20),
                                        ),
                                        SizedBox(width: getWidth(8)),
                                        Expanded(
                                          child: Text(
                                            "I am a Class Teacher",
                                            style: AppTextStyles.textStyle(
                                              txtColor: AppColors.textColor,
                                              fontSize: getWidth(14),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: getWidth(8)),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => isClassTeacher.value = false,
                                  child: Container(
                                    padding: EdgeInsets.all(getWidth(12)),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color:
                                            !isClassTeacher.value
                                                ? AppColors.blueColor
                                                : AppColors.textColor,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        getWidth(12),
                                      ),
                                      color:
                                          !isClassTeacher.value
                                              ? AppColors.blueColor.withOpacity(
                                                0.1,
                                              )
                                              : AppColors.transparent,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          !isClassTeacher.value
                                              ? Icons.radio_button_checked
                                              : Icons.radio_button_unchecked,
                                          color:
                                              !isClassTeacher.value
                                                  ? AppColors.blueColor
                                                  : AppColors.textColor,
                                          size: getWidth(20),
                                        ),
                                        SizedBox(width: getWidth(8)),
                                        Expanded(
                                          child: Text(
                                            "I am a Subject Teacher",
                                            style: AppTextStyles.textStyle(
                                              txtColor: AppColors.textColor,
                                              fontSize: getWidth(14),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Class Selection - Only show if isClassTeacher is true
                        Obx(
                          () =>
                              isClassTeacher.value
                                  ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildFieldLabel("Class You Teach"),
                                      DropDownTextField(
                                        controller: classController,
                                        textFieldFocusNode:
                                            textFieldClassFocusNode,
                                        searchFocusNode: searchClassFocusNode,
                                        clearOption: true,
                                        readOnly: true,
                                        searchAutofocus: true,
                                        textFieldDecoration:
                                            _getDropdownDecoration(
                                              "Select Class",
                                            ),
                                        searchDecoration: InputDecoration(
                                          hintText: "Search here",
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Please select class";
                                          }
                                          return null;
                                        },
                                        dropDownList:
                                            (selectedSchool?.classes ?? [])
                                                .map(
                                                  (e) => DropDownValueModel(
                                                    name: e.name ?? '',
                                                    value: e.sId,
                                                  ),
                                                )
                                                .toList(),
                                        onChanged: (val) {
                                          classController.dropDownValue = val;
                                          selectedClass = (selectedSchool
                                                      ?.classes ??
                                                  [])
                                              .firstWhere(
                                                (element) =>
                                                    element.sId == val.value,
                                              );
                                          selectedSection =
                                              selectedClass?.sections?.first;
                                          sectionController.dropDownValue =
                                              DropDownValueModel(
                                                name:
                                                    selectedSection?.section ??
                                                    '',
                                                value: selectedSection?.sId,
                                              );
                                        },
                                      ),
                                    ],
                                  )
                                  : SizedBox(),
                        ),

                        // Section Selection - Only show if isClassTeacher is true
                        Obx(
                          () =>
                              isClassTeacher.value
                                  ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildFieldLabel("Section You Teach"),
                                      DropDownTextField(
                                        controller: sectionController,
                                        textFieldFocusNode:
                                            textFieldSectionFocusNode,
                                        searchFocusNode: searchSectionFocusNode,
                                        clearOption: true,
                                        readOnly: true,
                                        searchAutofocus: true,
                                        textFieldDecoration:
                                            _getDropdownDecoration(
                                              "Select Section",
                                            ),
                                        searchDecoration: InputDecoration(
                                          hintText: "Search here",
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Please select a section";
                                          }
                                          return null;
                                        },
                                        dropDownList:
                                            (selectedClass?.sections ?? [])
                                                .map(
                                                  (e) => DropDownValueModel(
                                                    name: e.section ?? '',
                                                    value: e.sId,
                                                  ),
                                                )
                                                .toList(),
                                        onChanged: (val) {
                                          sectionController.dropDownValue = val;
                                        },
                                      ),
                                    ],
                                  )
                                  : SizedBox(),
                        ),

                        // Optional instruction text for subject teachers
                        Obx(
                          () =>
                              !isClassTeacher.value
                                  ? Padding(
                                    padding: EdgeInsets.only(top: getHeight(8)),
                                    child: Text(
                                      "As a subject teacher, you'll select your teaching subjects in the next step.",
                                      style: TextStyle(
                                        fontSize: getWidth(12),
                                        fontStyle: FontStyle.italic,
                                        color: AppColors.textColor.withOpacity(
                                          0.7,
                                        ),
                                      ),
                                    ),
                                  )
                                  : SizedBox(),
                        ),

                        // WhatsApp Number
                        _buildFieldLabel("WhatsApp Number"),
                        commonTextFiled(
                          hintText: "Enter your WhatsApp number",
                          controller: whatsappController,
                          borderRadius: getWidth(12),
                          borderColor: AppColors.textColor,
                          keyBoardType: TextInputType.phone,
                          maxLength: 10,
                        ),

                        // Submit Button
                        SizedBox(height: getHeight(32)),
                        materialButtonWithChild(
                          width: double.infinity,
                          onPressed: () => submitData(),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: getHeight(16),
                            ),
                            child: Text(
                              "Continue",
                              style: AppTextStyles.textStyle(
                                fontSize: getWidth(16),
                                fontWeight: FontWeight.w600,
                                txtColor: AppColors.white,
                              ),
                            ),
                          ),
                          color: AppColors.blueColor,
                          borderRadius: 12,
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

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: getHeight(8), top: getHeight(16)),
      child: Text(
        label,
        style: AppTextStyles.textStyle(
          txtColor: AppColors.textColor,
          fontSize: getWidth(14),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  InputDecoration _getDropdownDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppTextStyles.textStyle(
        txtColor: AppColors.textColor.withOpacity(0.5),
      ),
      filled: true,
      fillColor: AppColors.transparent,
      errorStyle: AppTextStyles.textStyle(
        txtColor: AppColors.errorColor,
        fontSize: getWidth(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(width: 1, color: AppColors.errorColor),
        borderRadius: BorderRadius.circular(getWidth(12)),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.textColor, width: 1),
        borderRadius: BorderRadius.circular(getWidth(12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.textColor, width: 1),
        borderRadius: BorderRadius.circular(getWidth(12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.textColor, width: 1),
        borderRadius: BorderRadius.circular(getWidth(12)),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(getWidth(12)),
        borderSide: const BorderSide(color: AppColors.textColor, width: 1),
      ),
    );
  }
}
