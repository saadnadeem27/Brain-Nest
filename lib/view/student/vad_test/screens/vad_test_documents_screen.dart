import 'package:Vadai/model/students/vad_test_model.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import '../../../../common_imports.dart';

class VadTestDocumentsScreen extends StatelessWidget {
  final String testName;
  final List<Documents>? documents;

  const VadTestDocumentsScreen({
    Key? key,
    required this.testName,
    this.documents,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      appBar: commonAppBar(
        context: context,
        isBack: true,
        title: 'Syllabus & Documents',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Test name header
          Container(
            padding: EdgeInsets.all(getWidth(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  testName,
                  style: TextStyle(
                    fontSize: getWidth(20),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                SizedBox(height: getHeight(4)),
                Text(
                  'Course Materials & Documents',
                  style: TextStyle(
                    fontSize: getWidth(14),
                    color: AppColors.textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                documents == null || documents!.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                      padding: EdgeInsets.all(getWidth(16)),
                      itemCount: documents!.length,
                      separatorBuilder: (context, index) => Divider(),
                      itemBuilder: (context, index) {
                        final document = documents![index];
                        return _buildDocumentItem(document);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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

  Widget _buildDocumentItem(Documents document) {
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

  void _downloadDocument(Documents document) async {
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

  void _openDocument(Documents document) async {
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
