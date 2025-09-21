import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/teachers/teacher_vadtest_controller.dart';
import 'package:Vadai/model/teachers/teacher_schoolexam_subject_details_model.dart';
import 'package:Vadai/view/teachers/vad_test/screens/Teacher_exam_marksentry_screen.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class TeacherSubjectDetailsScreen extends StatefulWidget {
  final String examId;
  final String classId;
  final String sectionId;
  final String subjectId;
  final String subjectName;

  const TeacherSubjectDetailsScreen({
    Key? key,
    required this.examId,
    required this.classId,
    required this.sectionId,
    required this.subjectId,
    required this.subjectName,
  }) : super(key: key);

  @override
  State<TeacherSubjectDetailsScreen> createState() =>
      _TeacherSubjectDetailsScreenState();
}

class _TeacherSubjectDetailsScreenState
    extends State<TeacherSubjectDetailsScreen>
    with SingleTickerProviderStateMixin {
  final TeacherVadTestController controller =
      Get.find<TeacherVadTestController>();
  final RxBool isLoading = true.obs;
  final Rx<TeacherSchoolExamSubjectDetailsModel?> subjectDetails =
      Rx<TeacherSchoolExamSubjectDetailsModel?>(null);
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadSubjectDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> loadSubjectDetails() async {
    isLoading.value = true;
    try {
      subjectDetails.value = await controller.getSchoolExamSubjectDetails(
        examId: widget.examId,
        subjectId: widget.subjectId,
        classId: widget.classId,
        sectionId: widget.sectionId,
      );
    } catch (e) {
      log('Error loading subject details: $e');
      commonSnackBar(message: 'Failed to load subject details');
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
        title: widget.subjectName,
        isBack: true,
      ),
      body: Obx(() {
        if (isLoading.value) {
          return Center(child: commonLoader());
        }

        if (subjectDetails.value == null) {
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
                  "Subject details not available",
                  style: TextStyle(
                    fontSize: getWidth(16),
                    color: AppColors.textColor.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: getHeight(16)),
                materialButtonOnlyText(
                  text: "Refresh",
                  onTap: loadSubjectDetails,
                ),
              ],
            ),
          );
        }

        final bool hasEmptySubjectData = subjectDetails.value?.subject == null;

        return Column(
          children: [
            _buildHeader(),

            if (!hasEmptySubjectData)
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

            if (!hasEmptySubjectData)
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
    final examSubject = subjectDetails.value!;
    final subject = examSubject.subject ?? SubjectDetailsModel();

    // Check if subject data is empty or missing
    final bool hasEmptyData = examSubject.subject == null;

    if (hasEmptyData) {
      // Return a nicer empty state instead of showing placeholder values
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(getWidth(20)),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Subject name
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(getWidth(16)),
              decoration: BoxDecoration(
                color: AppColors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(getWidth(8)),
                border: Border.all(color: AppColors.grey.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: getWidth(30),
                    color: AppColors.blueColor.withOpacity(0.7),
                  ),
                  SizedBox(height: getHeight(12)),
                  Text(
                    "No details available for ${widget.subjectName}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: getWidth(16),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
                  ),
                  SizedBox(height: getHeight(8)),
                  Text(
                    "The content for this subject hasn't been uploaded yet.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: getWidth(14),
                      color: AppColors.textColor.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: getHeight(12)),
                  ElevatedButton.icon(
                    onPressed: loadSubjectDetails,
                    icon: Icon(Icons.refresh, size: getWidth(16)),
                    label: Text("Refresh"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blueColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: getWidth(16),
                        vertical: getHeight(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

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
          // Subject name and marks
          Row(
            children: [
              Expanded(
                child: Text(
                  subject.subject ?? widget.subjectName,
                  style: TextStyle(
                    fontSize: getWidth(20),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: getWidth(12),
                  vertical: getHeight(6),
                ),
                decoration: BoxDecoration(
                  color: AppColors.blueColor,
                  borderRadius: BorderRadius.circular(getWidth(8)),
                ),
                child: Text(
                  "${subject.totalMark ?? 0} marks",
                  style: TextStyle(
                    fontSize: getWidth(12),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: getHeight(8)),

          // Topic and document count
          Row(
            children: [
              Icon(
                Icons.library_books,
                size: getWidth(18),
                color: AppColors.blueColor,
              ),
              SizedBox(width: getWidth(8)),
              Text(
                "${subject.largerTopics?.length ?? 0} main topics",
                style: TextStyle(
                  fontSize: getWidth(14),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: getWidth(16)),
              Icon(
                Icons.description_outlined,
                size: getWidth(18),
                color: AppColors.blueColor,
              ),
              SizedBox(width: getWidth(8)),
              Text(
                "${subject.documents?.length ?? 0} documents",
                style: TextStyle(
                  fontSize: getWidth(14),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // Chapters and details if available
          if (subject.chaptersAndDetails != null &&
              subject.chaptersAndDetails!.isNotEmpty) ...[
            SizedBox(height: getHeight(16)),
            Text(
              "Chapters & Details:",
              style: TextStyle(
                fontSize: getWidth(16),
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            SizedBox(height: getHeight(4)),
            Text(
              subject.chaptersAndDetails!,
              style: TextStyle(
                fontSize: getWidth(14),
                color: AppColors.textColor,
              ),
            ),
          ],
          if (examSubject.startDate != null &&
              examSubject.startDate!.isBefore(DateTime.now())) ...[
            SizedBox(height: getHeight(16)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToMarksEntry(),
                icon: Icon(Icons.assignment_turned_in, size: getWidth(18)),
                label: Text(
                  "Fill Report",
                  style: TextStyle(fontSize: getWidth(14)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blueColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: getHeight(12)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(getWidth(8)),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTopicsTab() {
    final examSubject = subjectDetails.value!;

    // Check if subject is null
    if (examSubject.subject == null) {
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
              "No subject data available",
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

    final subject = examSubject.subject!;
    final largerTopics = subject.largerTopics;

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
                "${topic.subtopics?.length ?? 0} subtopics",
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
    final examSubject = subjectDetails.value!;

    // Check if subject is null
    if (examSubject.subject == null) {
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
              "No subject data available",
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

    final subject = examSubject.subject!;
    final documents = subject.documents;

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

  void _navigateToMarksEntry() {
    Get.to(
      () => TeacherExamMarksEntryScreen(
        examId: widget.examId,
        examName: subjectDetails.value?.name ?? "School Exam",
        subjectId: widget.subjectId,
        subjectName: widget.subjectName,
        classId: widget.classId,
        sectionId: widget.sectionId,
        totalMarks: subjectDetails.value?.subject?.totalMark ?? 100,
      ),
    );
  }
}
