import 'package:Vadai/controller/student/classroom_controller.dart';
import 'package:Vadai/controller/student/student_profile_controller.dart';
import 'package:Vadai/model/students/subject_model.dart';
import 'package:Vadai/common_imports.dart';

class ClassRoom extends StatefulWidget {
  const ClassRoom({super.key});

  @override
  State<ClassRoom> createState() => _ClassRoomState();
}

class _ClassRoomState extends State<ClassRoom> {
  ClassRoomController classRoomCtr = Get.find();
  StudentProfileController profileCtr = Get.find();

  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    try {
      await classRoomCtr.getSubjectList();
    } catch (e) {
      log('-------------->>>>>>>>>>>> Error in initData of UserDashboard: $e');
    }
  }

  refreshData() async {
    classRoomCtr.isLoading.value = true;
    try {
      await classRoomCtr.getSubjectList();
    } catch (e) {
      log('-------------->>>>>>>>>>>> Error in initData of UserDashboard: $e');
    } finally {
      classRoomCtr.isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: commonScaffold(
        context: context,
        backgroundColor: AppColors.white,
        body: Stack(
          children: [
            Positioned(
              top: getHeight(130),
              bottom: getHeight(30),
              right: getWidth(-130),
              child: Image.asset(
                AppAssets.tabBackGround,
                fit: BoxFit.cover,
                opacity: const AlwaysStoppedAnimation(0.6),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: getHeight(70)),
              child: Obx(
                () =>
                    classRoomCtr.isLoading.value
                        ? Center(child: commonLoader())
                        : RefreshIndicator(
                          onRefresh: () async => refreshData(),
                          child: SingleChildScrollView(
                            child: commonPadding(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(height: getHeight(16)),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            getWidth(25),
                                          ),
                                          border: Border.all(
                                            color: AppColors.black,
                                            width: getWidth(1),
                                          ),
                                        ),
                                        child: commonPadding(
                                          padding: EdgeInsets.only(
                                            left: getWidth(10),
                                            right: getWidth(10),
                                            top: getHeight(2),
                                            bottom: getHeight(2),
                                          ),
                                          child: textWid(
                                            'Class: ${profileCtr.studentProfile.value?.className ?? ''}',
                                            style: AppTextStyles.textStyle(
                                              fontSize: getWidth(12),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          textWid(
                                            AppStrings.subjects,
                                            style: AppTextStyles.textStyle(
                                              fontSize: getWidth(25),
                                              fontWeight: FontWeight.w700,
                                              txtColor: AppColors.black,
                                            ),
                                          ),
                                          assetImage(
                                            image: AppAssets.subjectDivider,
                                            customWidth: 130,
                                          ),
                                        ],
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            getWidth(25),
                                          ),
                                          border: Border.all(
                                            color: AppColors.black,
                                            width: getWidth(1),
                                          ),
                                        ),
                                        child: commonPadding(
                                          padding: EdgeInsets.only(
                                            left: getWidth(10),
                                            right: getWidth(10),
                                            top: getHeight(2),
                                            bottom: getHeight(2),
                                          ),
                                          child: textWid(
                                            'Sec: ${profileCtr.studentProfile.value?.section ?? ''}',
                                            style: AppTextStyles.textStyle(
                                              fontSize: getWidth(12),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: getHeight(35)),
                                  materialButtonWithChild(
                                    onPressed:
                                        () =>
                                            Get.toNamed(RouteNames.myClassroom),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: textWid(
                                        'My Classroom',
                                        style: AppTextStyles.textStyle(
                                          txtColor: AppColors.white,
                                          fontSize: 22,
                                          letterSpacing: 0.01,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ).paddingOnly(
                                        top: getHeight(21),
                                        bottom: getHeight(21),
                                        right: getWidth(15),
                                        left: getWidth(15),
                                      ),
                                    ),
                                    width: double.infinity,
                                  ).paddingOnly(
                                    bottom: getHeight(20),
                                    right: getWidth(10),
                                    left: getWidth(10),
                                  ),

                                  ...List.generate(
                                    classRoomCtr.subjectsList.length,
                                    (i) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          bottom: getHeight(20),
                                          right: getWidth(10),
                                          left: getWidth(10),
                                        ),
                                        child: Material(
                                          color: AppColors.white,
                                          child: InkWell(
                                            onTap: () {
                                              Get.toNamed(
                                                RouteNames.subjectDetail,
                                                arguments:
                                                    classRoomCtr
                                                        .subjectsList[i],
                                              );
                                            },
                                            child: _buildSubjectCards(
                                              item:
                                                  classRoomCtr.subjectsList[i],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: getHeight(5)),
                                  textWid(
                                    'Total Assignments completed by class: ${classRoomCtr.submittedAssignmentsCount.value}',
                                    maxlines: 1,
                                    textOverflow: TextOverflow.clip,
                                    style: AppTextStyles.textStyle(
                                      fontSize: getWidth(12),
                                      fontWeight: FontWeight.w600,
                                      txtColor: AppColors.black,
                                    ),
                                  ),
                                  SizedBox(height: getHeight(44)),
                                ],
                              ),
                            ),
                          ),
                        ),
              ),
            ),
            studentsTabAppBar(title: AppStrings.classroom),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCards({required SubjectModel? item}) {
    double greenPadding =
        item?.assignmentsCount == 0 ? getWidth(268) : getWidth(228);
    return item == null || item.sId == null
        ? const SizedBox.shrink()
        : Container(
          width: double.infinity,
          height: getHeight(65),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(getWidth(10)),
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 3),
                blurRadius: 12,
                spreadRadius: 2,
                color: AppColors.black.withOpacity(0.16),
              ),
            ],
            color: Colors.white.withOpacity(0.8),
          ),
          child: Stack(
            children: [
              (item.assignmentsCount ?? 0) > 0
                  ? Positioned(
                    left: getWidth(268),
                    child: Container(
                      width: getWidth(55),
                      height: getHeight(65),
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(getWidth(10)),
                          bottomRight: Radius.circular(getWidth(10)),
                        ),
                      ),
                      padding: EdgeInsets.only(
                        top: getHeight(16),
                        bottom: getHeight(16),
                      ),
                      child: Center(
                        child: textWid(
                          item.assignmentsCount.toString(),
                          style: AppTextStyles.textStyle(
                            txtColor: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  )
                  : const SizedBox(),
              (item.announcementsCount ?? 0) > 0
                  ? Positioned(
                    left: greenPadding,
                    child: Container(
                      width: getWidth(52),
                      height: getHeight(65),
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(getWidth(10)),
                          bottomRight: Radius.circular(getWidth(10)),
                        ),
                      ),
                      padding: EdgeInsets.only(
                        top: getHeight(16),
                        bottom: getHeight(16),
                      ),
                      child: Center(
                        child: textWid(
                          item.announcementsCount.toString(),
                          style: AppTextStyles.textStyle(
                            txtColor: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  )
                  : const SizedBox(),
              Container(
                width: getWidth(240),
                height: double.infinity,
                padding: EdgeInsets.only(
                  top: getHeight(15),
                  bottom: getHeight(15),
                  right: getWidth(15),
                  left: getWidth(15),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(getWidth(10)),
                    bottomRight: Radius.circular(getWidth(10)),
                  ),
                ),
                child: textWid(
                  item.subjectName ?? '',
                  maxlines: 1,
                  textOverflow: TextOverflow.ellipsis,
                  style: AppTextStyles.textStyle(
                    txtColor: AppColors.blueColor,
                    fontSize: 22,
                    letterSpacing: 0.01,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
  }
}
