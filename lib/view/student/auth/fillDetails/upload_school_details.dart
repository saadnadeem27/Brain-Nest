import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/student/school_controller.dart';
import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/model/students/school_details_model.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';

class UploadSchoolDetails extends StatefulWidget {
  const UploadSchoolDetails({super.key});

  @override
  State<UploadSchoolDetails> createState() => _UploadSchoolDetailsState();
}

class _UploadSchoolDetailsState extends State<UploadSchoolDetails> {
  SchoolController schoolCtr = Get.put(SchoolController());
  TextEditingController studentNameController = TextEditingController();
  TextEditingController rollNumberController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController parentWhatsappController = TextEditingController();
  TextEditingController studentWhatsappController = TextEditingController();
  List<SchoolDetailModel> schoolList = [];
  SchoolDetailModel? selectedSchool;
  Classes? selectedClass;
  Sections? selectedSection;
  String? profileImageUrl;

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
    if (studentNameController.text.isEmpty) {
      commonSnackBar(message: AppStrings.pleaseEnterStudentName);
      return false;
    }
    if (rollNumberController.text.isEmpty) {
      commonSnackBar(message: 'Please enter roll number');
      return false;
    }

    if (schoolController.dropDownValue == null) {
      commonSnackBar(message: AppStrings.selectSchool);
      return false;
    }

    if (classController.dropDownValue == null) {
      commonSnackBar(message: AppStrings.selectClass);
      return false;
    }

    if (sectionController.dropDownValue == null) {
      commonSnackBar(message: AppStrings.pleaseSelectASection);
      return false;
    }

    if (phoneNumberController.text.isNotEmpty &&
        phoneNumberController.text.length < 10) {
      commonSnackBar(message: "Please enter a valid phone number");
      return false;
    }

    if (parentWhatsappController.text.isNotEmpty &&
        parentWhatsappController.text.length < 10) {
      commonSnackBar(message: "Please enter a valid parent WhatsApp number");
      return false;
    }

    if (studentWhatsappController.text.isNotEmpty &&
        studentWhatsappController.text.length < 10) {
      commonSnackBar(message: "Please enter a valid student WhatsApp number");
      return false;
    }

    return true;
  }

  submitData() {
    if (!validateForm()) return;

    Get.toNamed(
      RouteNames.uploadSubject,
      arguments: {
        ApiParameter.school: schoolList.firstWhere(
          (element) => element.sId == schoolController.dropDownValue?.value,
        ),
        ApiParameter.schoolId: schoolController.dropDownValue?.value,
        ApiParameter.classId: classController.dropDownValue?.value,
        ApiParameter.sectionId: sectionController.dropDownValue?.value,
        ApiParameter.name: studentNameController.text,
        'rollNumber': rollNumberController.text,
        'phoneNumber': phoneNumberController.text,
        'parentWhatsapp': parentWhatsappController.text,
        'studentWhatsapp': studentWhatsappController.text,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      },
    );
  }

  @override
  void dispose() {
    schoolController.dispose();
    classController.dispose();
    sectionController.dispose();
    studentNameController.dispose();
    rollNumberController.dispose();
    phoneNumberController.dispose();
    parentWhatsappController.dispose();
    studentWhatsappController.dispose();
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
                            "✏️ Let’s build your school profile – just a few quick steps!",
                            maxLines: 3,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textColor.withOpacity(0.7),
                              fontSize: getWidth(14),
                            ),
                          ),
                        ),

                        // Student Name
                        _buildFieldLabel(AppStrings.studentName),
                        commonTextFiled(
                          hintText: "Enter your full name",
                          controller: studentNameController,
                          borderRadius: getWidth(12),
                          borderColor: AppColors.textColor,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter student name";
                            }
                            return null;
                          },
                        ),

                        // Roll Number
                        _buildFieldLabel("Roll Number"),
                        commonTextFiled(
                          hintText: "Enter your roll number",
                          controller: rollNumberController,
                          borderRadius: getWidth(12),
                          borderColor: AppColors.textColor,
                          keyBoardType: TextInputType.number,
                        ),

                        // School Selection
                        _buildFieldLabel(AppStrings.school),
                        DropDownTextField(
                          controller: schoolController,
                          textFieldFocusNode: textFieldSchoolFocusNode,
                          searchFocusNode: searchSchoolFocusNode,
                          clearOption: true,
                          readOnly: true,
                          searchAutofocus: true,
                          textFieldDecoration: _getDropdownDecoration(
                            AppStrings.selectSchool,
                          ),
                          searchDecoration: InputDecoration(
                            hintText: AppStrings.searchHere,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.selectSchool;
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

                        // Class Selection
                        _buildFieldLabel(AppStrings.classString),
                        DropDownTextField(
                          controller: classController,
                          textFieldFocusNode: textFieldClassFocusNode,
                          searchFocusNode: searchClassFocusNode,
                          clearOption: true,
                          readOnly: true,
                          searchAutofocus: true,
                          textFieldDecoration: _getDropdownDecoration(
                            AppStrings.selectClass,
                          ),
                          searchDecoration: InputDecoration(
                            hintText: AppStrings.searchHere,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.selectClass;
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
                            selectedClass = (selectedSchool?.classes ?? [])
                                .firstWhere(
                                  (element) => element.sId == val.value,
                                );
                            selectedSection = selectedClass?.sections?.first;
                            sectionController
                                .dropDownValue = DropDownValueModel(
                              name: selectedSection?.section ?? '',
                              value: selectedSection?.sId,
                            );
                          },
                        ),

                        // Section Selection
                        _buildFieldLabel(AppStrings.section),
                        DropDownTextField(
                          controller: sectionController,
                          textFieldFocusNode: textFieldSectionFocusNode,
                          searchFocusNode: searchSectionFocusNode,
                          clearOption: true,
                          readOnly: true,
                          searchAutofocus: true,
                          textFieldDecoration: _getDropdownDecoration(
                            AppStrings.selectSection,
                          ),
                          searchDecoration: InputDecoration(
                            hintText: AppStrings.searchHere,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.pleaseSelectASection;
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

                        // Phone Number
                        _buildFieldLabel("Phone Number"),
                        commonTextFiled(
                          hintText: "Enter phone number",
                          controller: phoneNumberController,
                          borderRadius: getWidth(12),
                          borderColor: AppColors.textColor,
                          keyBoardType: TextInputType.phone,
                          maxLength: 10,
                        ),

                        // Parent WhatsApp
                        _buildFieldLabel("Parent's WhatsApp"),
                        commonTextFiled(
                          hintText: "Enter parent's WhatsApp number",
                          controller: parentWhatsappController,
                          borderRadius: getWidth(12),
                          borderColor: AppColors.textColor,
                          keyBoardType: TextInputType.phone,
                          maxLength: 10,
                        ),

                        // Student WhatsApp
                        _buildFieldLabel("Student's WhatsApp"),
                        commonTextFiled(
                          hintText: "Enter your WhatsApp number",
                          controller: studentWhatsappController,
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

  // Widget _buildSectionHeader(String title) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       SizedBox(height: getHeight(24)),
  //       Container(
  //         padding: EdgeInsets.symmetric(
  //           horizontal: getWidth(12),
  //           vertical: getHeight(8),
  //         ),
  //         decoration: BoxDecoration(
  //           color: AppColors.blueColor.withOpacity(0.1),
  //           borderRadius: BorderRadius.circular(8),
  //         ),
  //         child: Text(
  //           title,
  //           style: AppTextStyles.textStyle(
  //             txtColor: AppColors.blueColor,
  //             fontSize: getWidth(16),
  //             fontWeight: FontWeight.w600,
  //           ),
  //         ),
  //       ),
  //       SizedBox(height: getHeight(12)),
  //     ],
  //   );
  // }

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
