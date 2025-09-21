import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/student/school_controller.dart';
import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/model/students/school_details_model.dart';
import 'package:Vadai/model/students/subject_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileReviewScreen extends StatefulWidget {
  const ProfileReviewScreen({super.key});

  @override
  State<ProfileReviewScreen> createState() => _ProfileReviewScreenState();
}

class _ProfileReviewScreenState extends State<ProfileReviewScreen> {
  SchoolController schoolCtr = Get.find<SchoolController>();
  RxBool isLoading = false.obs;

  // Student Profile Data
  String? profileImageUrl;
  String? studentName;
  String? rollNumber;
  String? phoneNumber;
  String? parentWhatsappNumber;
  String? studentWhatsappNumber;

  // School Data
  SchoolDetailModel? schoolData;
  String? schoolId;
  String? classId;
  String? sectionId;
  String? className;
  String? sectionName;
  String? schoolName;

  // Subject Data
  List<String> selectedSubjectIds = [];
  List<String> selectedSubjectNames = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    if (Get.arguments != null && Get.arguments is Map) {
      final Map<String, dynamic> args = Get.arguments;

      // Personal details
      profileImageUrl = args['profileImageUrl'];
      studentName = args['name'];
      rollNumber = args['rollNumber'];
      phoneNumber = args['phoneNumber'];
      parentWhatsappNumber = args['parentWhatsapp'];
      studentWhatsappNumber = args['studentWhatsapp'];

      // School details
      schoolData = args['school'];
      schoolId = args['schoolId'];
      classId = args['classId'];
      sectionId = args['sectionId'];
      schoolName = schoolData?.schoolName;

      // Find class and section names
      if (schoolData != null && classId != null) {
        final selectedClass = schoolData?.classes?.firstWhere(
          (element) => element.sId == classId,
          orElse: () => Classes(),
        );

        className = selectedClass?.name;

        if (selectedClass != null && sectionId != null) {
          final selectedSection = selectedClass.sections?.firstWhere(
            (element) => element.sId == sectionId,
            orElse: () => Sections(),
          );

          sectionName = selectedSection?.section;
        }
      }

      // Subjects
      selectedSubjectIds = args['subjects'] ?? [];
      selectedSubjectNames = args['subjectNames'] ?? [];
    }
  }

  Future<void> _submitProfile() async {
    try {
      isLoading.value = true;

      final success = await schoolCtr.completeProfile(
        schoolId: schoolId ?? '',
        classId: classId ?? '',
        sectionId: sectionId ?? '',
        name: studentName ?? '',
        subjects: selectedSubjectIds,
        rollNumber: rollNumber,
        phoneNumber: phoneNumber,
        parentWhatsapp: parentWhatsappNumber,
        studentWhatsapp: studentWhatsappNumber,
        profileImageUrl: profileImageUrl,
      );

      if (success) {
        Get.offAllNamed(RouteNames.welcomeAboard);
      } else {
        commonSnackBar(
          message: "Failed to submit profile. Please try again.",
          color: AppColors.errorColor,
        );
      }
    } catch (e) {
      log('Error submitting profile: $e');
      commonSnackBar(
        message: "An error occurred. Please try again.",
        color: AppColors.errorColor,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => commonScaffold(
        context: context,
        appBar: commonAppBar(context: context, isBack: true, title: ""),
        body:
            isLoading.value
                ? Center(child: commonLoader())
                : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header section
                      Center(
                        child: Column(
                          children: [
                            Image.asset(AppAssets.logo, width: getWidth(150)),
                            SizedBox(height: getHeight(16)),
                            Text(
                              "Almost there! Review your details",
                              style: AppTextStyles.textStyle(
                                fontSize: getWidth(18),
                                fontWeight: FontWeight.w600,
                                txtColor: AppColors.blueColor,
                              ),
                            ),
                            SizedBox(height: getHeight(8)),
                            Text(
                              "Please verify all information before submitting",
                              style: TextStyle(
                                color: AppColors.textColor.withOpacity(0.7),
                                fontSize: getWidth(14),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: getHeight(24)),

                      // Profile image and basic info card
                      _buildProfileCard(),

                      // School information card
                      _buildSectionHeader("School Information"),
                      _buildInfoCard(
                        children: [
                          _buildInfoRow(
                            icon: Icons.school,
                            label: "School",
                            value: schoolName ?? "Not specified",
                          ),
                          _buildInfoRow(
                            icon: Icons.class_,
                            label: "Class",
                            value: className ?? "Not specified",
                          ),
                          _buildInfoRow(
                            icon: Icons.group,
                            label: "Section",
                            value: sectionName ?? "Not specified",
                          ),
                          _buildInfoRow(
                            icon: Icons.numbers,
                            label: "Roll Number",
                            value:
                                rollNumber?.isNotEmpty == true
                                    ? rollNumber!
                                    : "Not specified",
                          ),
                        ],
                      ),

                      // Contact information card
                      _buildSectionHeader("Contact Information"),
                      _buildInfoCard(
                        children: [
                          _buildInfoRow(
                            icon: Icons.phone,
                            label: "Phone Number",
                            value:
                                phoneNumber?.isNotEmpty == true
                                    ? phoneNumber!
                                    : "Not specified",
                          ),
                          _buildInfoRow(
                            icon: Icons.people,
                            //! icon: Icons.whatsapp,
                            label: "Parent's WhatsApp",
                            value:
                                parentWhatsappNumber?.isNotEmpty == true
                                    ? parentWhatsappNumber!
                                    : "Not specified",
                          ),
                          _buildInfoRow(
                            //! icon: Icons.whatsapp,
                            icon: Icons.people,
                            label: "Student's WhatsApp",
                            value:
                                studentWhatsappNumber?.isNotEmpty == true
                                    ? studentWhatsappNumber!
                                    : "Not specified",
                          ),
                        ],
                      ),

                      // Subject information card
                      _buildSectionHeader("Selected Subjects"),
                      _buildInfoCard(
                        children: [
                          if (selectedSubjectNames.isEmpty)
                            Padding(
                              padding: EdgeInsets.all(getWidth(16)),
                              child: Text(
                                "No subjects selected",
                                style: AppTextStyles.textStyle(
                                  fontSize: getWidth(14),
                                  txtColor: AppColors.textColor,
                                ),
                              ),
                            )
                          else
                            ...selectedSubjectNames.map(
                              (subject) => _buildSubjectItem(subject),
                            ),
                        ],
                      ),

                      // Submit button
                      SizedBox(height: getHeight(32)),
                      materialButtonWithChild(
                        width: double.infinity,
                        onPressed: _submitProfile,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: getHeight(16),
                          ),
                          child: Text(
                            "Submit Profile",
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

                      // Edit details button
                      SizedBox(height: getHeight(16)),
                      materialButtonWithChild(
                        width: double.infinity,
                        onPressed: () => Get.back(),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: getHeight(16),
                          ),
                          child: Text(
                            "Edit Details",
                            style: AppTextStyles.textStyle(
                              fontSize: getWidth(16),
                              fontWeight: FontWeight.w600,
                              txtColor: AppColors.blueColor,
                            ),
                          ),
                        ),
                        color: AppColors.white,
                        borderColor: AppColors.blueColor,
                        borderWidth: 2,
                        borderRadius: 12,
                      ),

                      SizedBox(height: getHeight(24)),
                    ],
                  ).paddingSymmetric(horizontal: getWidth(16)),
                ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      margin: EdgeInsets.only(bottom: getHeight(8)),
      padding: EdgeInsets.all(getWidth(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: getHeight(80),
            height: getHeight(80),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.blueColor, width: 2),
            ),
            child: ClipOval(
              child:
                  profileImageUrl != null
                      ? CachedNetworkImage(
                        imageUrl: profileImageUrl!,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                        errorWidget:
                            (context, url, error) => Icon(
                              Icons.account_circle,
                              size: getWidth(40),
                              color: AppColors.grey,
                            ),
                      )
                      : Icon(
                        Icons.account_circle,
                        size: getWidth(40),
                        color: AppColors.grey,
                      ),
            ),
          ),
          SizedBox(width: getWidth(16)),

          // Student Name and ID
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName ?? "Student Name",
                  style: AppTextStyles.textStyle(
                    fontSize: getWidth(18),
                    fontWeight: FontWeight.w600,
                    txtColor: AppColors.textColor,
                  ),
                ),
                if (rollNumber?.isNotEmpty == true)
                  Text(
                    "Roll No: $rollNumber",
                    style: TextStyle(
                      color: AppColors.textColor.withOpacity(0.7),
                      fontSize: getWidth(14),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(top: getHeight(16), bottom: getHeight(8)),
      child: Text(
        title,
        style: AppTextStyles.textStyle(
          fontSize: getWidth(16),
          fontWeight: FontWeight.w600,
          txtColor: AppColors.blueColor,
        ),
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: getHeight(8)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: getWidth(16),
        vertical: getHeight(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: getWidth(20), color: AppColors.blueColor),
          SizedBox(width: getWidth(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textColor.withOpacity(0.7),
                    fontSize: getWidth(12),
                  ),
                ),
                SizedBox(height: getHeight(4)),
                Text(
                  value,
                  style: AppTextStyles.textStyle(
                    fontSize: getWidth(14),
                    fontWeight: FontWeight.w500,
                    txtColor: AppColors.textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectItem(String subject) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: getWidth(16),
        vertical: getHeight(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: getWidth(20),
            color: AppColors.blueColor,
          ),
          SizedBox(width: getWidth(12)),
          Expanded(
            child: Text(
              subject,
              style: AppTextStyles.textStyle(
                fontSize: getWidth(14),
                txtColor: AppColors.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
