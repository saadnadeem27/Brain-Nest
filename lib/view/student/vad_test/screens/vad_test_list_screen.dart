import 'package:Vadai/controller/student/vad_test_controller.dart';
import 'package:Vadai/model/students/vad_test_model.dart';
import 'package:Vadai/view/student/vad_test/widgets/vad_test_item_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../common_imports.dart';

class VadTestListScreen extends StatefulWidget {
  final String subjectId;
  final String subjectName;
  final String? subjectIcon;

  const VadTestListScreen({
    Key? key,
    required this.subjectId,
    required this.subjectName,
    this.subjectIcon,
  }) : super(key: key);

  @override
  State<VadTestListScreen> createState() => _VadTestListScreenState();
}

class _VadTestListScreenState extends State<VadTestListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final VadTestController vadTestCtr = Get.find();

  RxBool isLoading = true.obs;
  RxMap<String, List<VadTestModel>> testData =
      <String, List<VadTestModel>>{'upcoming': [], 'live': [], 'past': []}.obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    fetchVadTests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchVadTests() async {
    isLoading.value = true;
    try {
      final result = await vadTestCtr.getVadTest(subjectId: widget.subjectId);
      if (result != null) {
        testData['upcoming'] = result['upcoming'] ?? [];
        testData['live'] = result['live'] ?? [];
        testData['past'] = result['past'] ?? [];
      }
    } catch (e) {
      log('Error fetching VAD tests: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      appBar: commonAppBar(
        context: context,
        isBack: true,
        title: widget.subjectName,
      ),
      body: Column(
        children: [
          // Subject header with icon
          _buildSubjectHeader(),

          // Tab bar
          Container(
            color: AppColors.blueColor,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.white,
              indicatorWeight: 3,
              labelColor: AppColors.white,
              unselectedLabelColor: AppColors.white.withOpacity(0.7),
              tabs: const [
                Tab(text: 'Upcoming'),
                Tab(text: 'Live'),
                Tab(text: 'Past'),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: Obx(() {
              if (isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              return TabBarView(
                controller: _tabController,
                children: [
                  // Upcoming tests tab
                  _buildTestList(testData['upcoming'] ?? [], TestType.upcoming),

                  // Live tests tab
                  _buildTestList(testData['live'] ?? [], TestType.live),

                  // Past tests tab
                  _buildTestList(testData['past'] ?? [], TestType.past),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: getHeight(10),
        horizontal: getWidth(16),
      ),
      color: AppColors.blueColor,
      child: Row(
        children: [
          // Subject icon - made smaller and more compact
          Container(
            width: getWidth(46),
            height: getWidth(46),
            padding: EdgeInsets.all(getWidth(6)),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(getWidth(6)),
            ),
            child:
                widget.subjectIcon != null && widget.subjectIcon!.isNotEmpty
                    ? (widget.subjectIcon!.toLowerCase().endsWith('.svg')
                        ? SvgPicture.network(
                          widget.subjectIcon!,
                          placeholderBuilder:
                              (context) => Center(
                                child: SizedBox(
                                  width: getWidth(16),
                                  height: getWidth(16),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.blueColor,
                                  ),
                                ),
                              ),
                        )
                        : CachedNetworkImage(
                          imageUrl: widget.subjectIcon!,
                          placeholder:
                              (context, url) => Center(
                                child: SizedBox(
                                  width: getWidth(16),
                                  height: getWidth(16),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.blueColor,
                                  ),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Icon(
                                Icons.book,
                                size: getWidth(24),
                                color: AppColors.blueColor,
                              ),
                        ))
                    : Icon(
                      Icons.book,
                      size: getWidth(24),
                      color: AppColors.blueColor,
                    ),
          ),
          SizedBox(width: getWidth(12)),

          // Test count only - removed redundant subject name
          Expanded(
            child: Obx(() {
              final tabTypes = ['upcoming', 'live', 'past'];
              final currentTabType = tabTypes[_tabController.index];
              final currentTabCount = testData[currentTabType]?.length ?? 0;
              final currentTabName = TestType.values[_tabController.index].name;

              return Text(
                '$currentTabCount ${currentTabName} Tests Available',
                style: TextStyle(
                  fontSize: getWidth(15),
                  fontWeight: FontWeight.w500,
                  color: AppColors.white,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTestList(List<VadTestModel> tests, TestType type) {
    if (tests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == TestType.upcoming
                  ? Icons.event_busy
                  : type == TestType.live
                  ? Icons.live_tv
                  : Icons.history,
              size: getWidth(50),
              color: AppColors.grey.withOpacity(0.5),
            ),
            SizedBox(height: getHeight(12)),
            Text(
              "No ${type.name} tests available",
              style: TextStyle(
                fontSize: getWidth(15),
                color: AppColors.textColor.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchVadTests,
      child: ListView.builder(
        itemCount: tests.length,
        padding: EdgeInsets.symmetric(
          horizontal: getWidth(16),
          vertical: getHeight(12),
        ),
        itemBuilder: (context, index) {
          final test = tests[index];
          return Padding(
            padding: EdgeInsets.only(bottom: getHeight(12)),
            child: VadTestItemCard(
              test: test,
              testType: type,
              onSyllabus: () => _navigateToSyllabus(test),
              onAttempt:
                  type == TestType.live ? () => _attemptTest(test) : null,
              onReport: type == TestType.past ? () => _viewReport(test) : null,
            ),
          );
        },
      ),
    );
  }

  void _navigateToSyllabus(VadTestModel test) {
    // Navigate to documents screen
    Get.toNamed(
      RouteNames.vadTestDocuments,
      arguments: {'testName': test.name, 'documents': test.documents},
    );
  }

  void _attemptTest(VadTestModel test) {
    commonSnackBar(
      title: 'Coming Soon',
      message: 'Test attempt feature will be available soon',
    );
  }

  void _viewReport(VadTestModel test) {
    commonSnackBar(
      title: 'Coming Soon',
      message: 'Test reports will be available soon',
    );
  }
}

enum TestType { upcoming, live, past }

extension TestTypeExtension on TestType {
  String get name {
    switch (this) {
      case TestType.upcoming:
        return 'Upcoming';
      case TestType.live:
        return 'Live';
      case TestType.past:
        return 'Past';
    }
  }
}
