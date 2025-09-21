import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/student/classroom_controller.dart';
import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/model/common/poeple_model.dart';
import 'package:Vadai/model/students/subject_model.dart';

class PeoplesScreen extends StatefulWidget {
  const PeoplesScreen({super.key});

  @override
  State<PeoplesScreen> createState() => _PeoplesScreenState();
}

class _PeoplesScreenState extends State<PeoplesScreen> {
  ClassRoomController classRoomCtr = Get.find();
  RxBool isLoading = false.obs;
  RxInt currentPage = 2.obs;
  RxBool hasNext = false.obs;
  final ScrollController scrollController = ScrollController();
  SubjectModel? currentSubject;
  List<PeopleModel> peopleList = [];
  TeacherModel? teacher;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollListener);
    initData();
  }

  void initData() async {
    isLoading.value = true;
    var data = Get.arguments;
    if (data != null) {
      currentSubject = data?[AppStrings.subjects];
    }
    try {
      await classRoomCtr
          .getSubjectPeopleList(subjectId: currentSubject?.sId ?? '')
          .then((value) {
            if (value != null) {
              peopleList = value[ApiParameter.students];
              teacher = value[ApiParameter.teacherProfile];
              hasNext.value = value[ApiParameter.hasNext];
            }
          });
    } catch (e) {
      log(
        '------------------>>>>>>>>>>>>>> error in initData of module screen $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      loadMoreAnnouncements();
    }
  }

  void loadMoreAnnouncements() async {
    if (hasNext.value) {
      try {
        await classRoomCtr
            .getSubjectPeopleList(subjectId: currentSubject?.sId ?? '')
            .then((value) {
              if (value != null) {
                peopleList.addAll(value[ApiParameter.students]);
                if (value[ApiParameter.teacherProfile] != null) {
                  teacher = value[ApiParameter.teacherProfile];
                }
                hasNext.value = value[ApiParameter.hasNext];
                currentPage++;
              }
            });
      } catch (e) {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in people: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      appBar: commonAppBar(
        context: context,
        isBack: true,
        title: 'Peoples',
        actions: [],
      ),
      body: Obx(
        () =>
            isLoading.value
                ? commonLoader()
                : commonPadding(
                  padding: EdgeInsets.only(
                    left: getWidth(38),
                    right: getWidth(38),
                    top: getWidth(20),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          (teacher?.profileImage != null)
                              ? Container(
                                height: getWidth(25),
                                width: getWidth(25),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: ClipOval(
                                  child: networkImage(
                                    image: teacher?.profileImage ?? '',
                                    errorImage: AppAssets.accountImageIcon,
                                    customWidth: getWidth(150),
                                    customHeight: getHeight(150),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                              : CircleAvatar(
                                child: assetImage(image: AppAssets.peopleImg),
                              ),
                          SizedBox(width: getWidth(10)),
                          textWid(
                            teacher?.name ?? '',
                            maxlines: 1,
                            textOverflow: TextOverflow.ellipsis,
                            style: AppTextStyles.textStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: getHeight(10)),
                      commonPadding(
                        child: Divider(
                          color: AppColors.black.withOpacity(0.3),
                          thickness: getWidth(1.5),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: peopleList.length,
                          itemBuilder: (context, index) {
                            return _buildPeople(peopleList[index]);
                          },
                        ),
                      ),
                      // if (hasNext.value) commonLoader()
                    ],
                  ),
                ),
      ),
    );
  }

  _buildPeople(PeopleModel item) {
    return Padding(
      padding: EdgeInsets.only(top: getWidth(15)),
      child: Row(
        children: [
          (item.profileImage != null)
              ? Container(
                height: getWidth(25),
                width: getWidth(25),
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: ClipOval(
                  child: networkImage(
                    image: item.profileImage ?? '',
                    errorImage: AppAssets.accountImageIcon,
                    customWidth: getWidth(150),
                    customHeight: getHeight(150),
                    fit: BoxFit.cover,
                  ),
                ),
              )
              : assetImage(
                image: AppAssets.accountImageIcon,
                fit: BoxFit.contain,
              ),
          SizedBox(width: getWidth(10)),
          textWid(
            item.name ?? '',
            maxlines: 1,
            textOverflow: TextOverflow.ellipsis,
            style: AppTextStyles.textStyle(fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
