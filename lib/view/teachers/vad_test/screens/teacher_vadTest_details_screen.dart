import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/teachers/teacher_vadtest_controller.dart';
import 'package:Vadai/model/teachers/teacher_vadtest_details_model.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class TeacherVadTestDetailsScreen extends StatefulWidget {
  final String vadTestId;

  const TeacherVadTestDetailsScreen({Key? key, required this.vadTestId})
    : super(key: key);

  @override
  State<TeacherVadTestDetailsScreen> createState() =>
      _TeacherVadTestDetailsScreenState();
}

class _TeacherVadTestDetailsScreenState
    extends State<TeacherVadTestDetailsScreen>
    with SingleTickerProviderStateMixin {
  final TeacherVadTestController controller = Get.find();
  final RxBool isLoading = true.obs;
  final Rx<TeacherVadTestDetailsModel?> testDetails =
      Rx<TeacherVadTestDetailsModel?>(null);
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadTestDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> loadTestDetails() async {
    isLoading.value = true;
    try {
      testDetails.value = await controller.getVadTestDetails(widget.vadTestId);
    } catch (e) {
      log('Error loading test details: $e');
      commonSnackBar(message: 'Failed to load test details');
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
        title: 'VAD Test Details',
        isBack: true,
      ),
      body: Obx(() {
        if (isLoading.value) {
          return Center(child: commonLoader());
        }

        if (testDetails.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: getWidth(60),
                  color: AppColors.grey.withOpacity(0.5),
                ),
                SizedBox(height: getHeight(16)),
                Text(
                  "Test details not available",
                  style: TextStyle(
                    fontSize: getWidth(16),
                    color: AppColors.textColor.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: getHeight(16)),
                materialButtonOnlyText(text: "Refresh", onTap: loadTestDetails),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Header info section
            _buildHeader(),

            // Tabs
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.blueColor,
                unselectedLabelColor: AppColors.textColor,
                indicatorColor: AppColors.blueColor,
                tabs: const [
                  Tab(text: "Syllabus & Topics"),
                  Tab(text: "Documents"),
                ],
              ),
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildTopicsTab(), _buildDocumentsTab()],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildHeader() {
    final test = testDetails.value!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(getWidth(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Test name and subject
          Text(
            test.name?.isNotEmpty == true
                ? test.name!
                : test.subject ?? "Untitled Test",
            style: TextStyle(
              fontSize: getWidth(20),
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          if (test.subject != null) ...[
            SizedBox(height: getHeight(4)),
            Text(
              test.subject!,
              style: TextStyle(
                fontSize: getWidth(16),
                color: AppColors.blueColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          SizedBox(height: getHeight(16)),

          // Test date and time info
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: getWidth(18),
                color: AppColors.blueColor,
              ),
              SizedBox(width: getWidth(8)),
              Text(
                test.getFormattedDate(),
                style: TextStyle(
                  fontSize: getWidth(14),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: getWidth(16)),
              Icon(
                Icons.access_time,
                size: getWidth(18),
                color: AppColors.blueColor,
              ),
              SizedBox(width: getWidth(8)),
              Text(
                "${test.getFormattedStartTime()} - ${test.getFormattedEndTime()}",
                style: TextStyle(
                  fontSize: getWidth(14),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          SizedBox(height: getHeight(8)),

          // Duration and report button
          Row(
            children: [
              Icon(Icons.timer, size: getWidth(18), color: AppColors.blueColor),
              SizedBox(width: getWidth(8)),
              Text(
                "Duration: ${test.getFormattedDuration()}",
                style: TextStyle(
                  fontSize: getWidth(14),
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(),
            ],
          ),

          // Additional info if available
          if (test.additionalInfo != null &&
              test.additionalInfo!.isNotEmpty) ...[
            SizedBox(height: getHeight(16)),
            Text(
              "Additional Information:",
              style: TextStyle(
                fontSize: getWidth(16),
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            SizedBox(height: getHeight(4)),
            Text(
              test.additionalInfo!,
              style: TextStyle(
                fontSize: getWidth(14),
                color: AppColors.textColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTopicsTab() {
    final test = testDetails.value!;
    final largerTopics = test.largerTopics;

    if (largerTopics == null || largerTopics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.subject,
              size: getWidth(60),
              color: AppColors.grey.withOpacity(0.5),
            ),
            SizedBox(height: getHeight(16)),
            Text(
              "No topics available",
              style: TextStyle(
                fontSize: getWidth(16),
                color: AppColors.textColor.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(getWidth(16)),
      itemCount: largerTopics.length,
      itemBuilder: (context, index) {
        final topic = largerTopics[index];
        return Card(
          margin: EdgeInsets.only(bottom: getHeight(16)),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(getWidth(12)),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.symmetric(
                horizontal: getWidth(16),
                vertical: getHeight(8),
              ),
              title: Text(
                topic.name?.capitalizeFirst ?? "Untitled Topic",
                style: TextStyle(
                  fontSize: getWidth(16),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              subtitle: Text(
                "${topic.getSubtopicCount()} subtopics",
                style: TextStyle(
                  fontSize: getWidth(14),
                  color: AppColors.textColor.withOpacity(0.7),
                ),
              ),
              children:
                  topic.subtopics
                      ?.map(
                        (subtopic) => ListTile(
                          leading: Icon(
                            Icons.circle,
                            size: getWidth(10),
                            color: AppColors.blueColor,
                          ),
                          title: Text(
                            subtopic.name?.capitalizeFirst ??
                                "Untitled Subtopic",
                            style: TextStyle(
                              fontSize: getWidth(14),
                              color: AppColors.textColor,
                            ),
                          ),
                          dense: true,
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList() ??
                  [],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDocumentsTab() {
    final test = testDetails.value!;
    final documents = test.documents;

    if (documents == null || documents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: getWidth(60),
              color: AppColors.grey.withOpacity(0.5),
            ),
            SizedBox(height: getHeight(16)),
            Text(
              "No documents available",
              style: TextStyle(
                fontSize: getWidth(16),
                color: AppColors.textColor.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(getWidth(16)),
      itemCount: documents.length,
      separatorBuilder: (context, index) => Divider(),
      itemBuilder: (context, index) {
        final document = documents[index];
        return _buildDocumentItem(document);
      },
    );
  }

  Widget _buildDocumentItem(DocumentModel document) {
    final String docType = document.type?.toLowerCase() ?? '';
    IconData iconData;
    Color iconColor;
    Color bgColor;

    // Determine icon and colors based on document type
    if (docType.contains('pdf')) {
      iconData = Icons.picture_as_pdf;
      iconColor = Colors.red;
      bgColor = Colors.red.withOpacity(0.1);
    } else if (docType.contains('doc') || docType.contains('word')) {
      iconData = Icons.article;
      iconColor = Colors.blue;
      bgColor = Colors.blue.withOpacity(0.1);
    } else if (docType.contains('xls') || docType.contains('excel')) {
      iconData = Icons.table_chart;
      iconColor = Colors.green;
      bgColor = Colors.green.withOpacity(0.1);
    } else if (docType.contains('ppt') || docType.contains('presentation')) {
      iconData = Icons.slideshow;
      iconColor = Colors.orange;
      bgColor = Colors.orange.withOpacity(0.1);
    } else if (docType.contains('image') ||
        docType.contains('jpg') ||
        docType.contains('png')) {
      iconData = Icons.image;
      iconColor = Colors.purple;
      bgColor = Colors.purple.withOpacity(0.1);
    } else if (docType.contains('link')) {
      iconData = Icons.link;
      iconColor = Colors.teal;
      bgColor = Colors.teal.withOpacity(0.1);
    } else if (docType.contains('text') || docType.contains('txt')) {
      iconData = Icons.text_snippet;
      iconColor = Colors.amber;
      bgColor = Colors.amber.withOpacity(0.1);
    } else {
      iconData = Icons.insert_drive_file;
      iconColor = Colors.grey;
      bgColor = Colors.grey.withOpacity(0.1);
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: getHeight(6)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(getWidth(12)),
        border: Border.all(color: AppColors.grey.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(getWidth(12)),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openDocument(document),
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: getHeight(12),
                horizontal: getWidth(16),
              ),
              child: Row(
                children: [
                  // Document icon with colored background
                  Container(
                    width: getWidth(50),
                    height: getWidth(50),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(getWidth(10)),
                    ),
                    child: Center(
                      child: Icon(
                        iconData,
                        color: iconColor,
                        size: getWidth(28),
                      ),
                    ),
                  ),
                  SizedBox(width: getWidth(16)),

                  // Document details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          document.name ?? 'Unnamed Document',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: getWidth(16),
                            color: AppColors.textColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: getHeight(4)),
                        Text(
                          document.type ?? 'Unknown Type',
                          style: TextStyle(
                            fontSize: getWidth(13),
                            color: AppColors.textColor.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Download button
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.blueColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(getWidth(8)),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.download_rounded,
                        color: AppColors.blueColor,
                        size: getWidth(24),
                      ),
                      onPressed: () => _downloadDocument(document),
                      tooltip: 'Download Document',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _downloadDocument(DocumentModel document) async {
    if (document.link == null || document.link!.isEmpty) {
      commonSnackBar(message: 'Document link is not available');
      return;
    }

    try {
      final Uri url = Uri.parse(document.link!);
      if (!await url_launcher.canLaunchUrl(url)) {
        commonSnackBar(message: "Could not launch document URL");
        return;
      }
      await url_launcher.launchUrl(
        url,
        mode: url_launcher.LaunchMode.externalApplication,
      );
    } catch (e) {
      log('Error downloading document: $e');
      commonSnackBar(message: "Failed to download document");
    }
  }

  void _openDocument(DocumentModel document) async {
    if (document.link == null || document.link!.isEmpty) {
      commonSnackBar(message: 'Document link is not available');
      return;
    }

    try {
      final Uri url = Uri.parse(document.link!);
      if (!await url_launcher.canLaunchUrl(url)) {
        commonSnackBar(message: "Could not open document URL");
        return;
      }
      await url_launcher.launchUrl(
        url,
        mode: url_launcher.LaunchMode.externalApplication,
      );
    } catch (e) {
      log('Error opening document: $e');
      commonSnackBar(message: "Failed to open document");
    }
  }
}
