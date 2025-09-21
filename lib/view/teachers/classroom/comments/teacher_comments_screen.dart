import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/teachers/teacher_classroom_controller.dart';
import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/model/common/comments_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TeacherCommentsScreen extends StatefulWidget {
  const TeacherCommentsScreen({Key? key}) : super(key: key);

  @override
  State<TeacherCommentsScreen> createState() => _TeacherCommentsScreenState();
}

class _TeacherCommentsScreenState extends State<TeacherCommentsScreen> {
  final TeacherClassroomController controller = Get.find();
  final TextEditingController commentController = TextEditingController();
  final RxBool isLoading = true.obs;
  final RxList<CommentsModel> comments = <CommentsModel>[].obs;
  final RxBool hasMore = false.obs;
  final RxInt currentPage = 1.obs;
  final ScrollController scrollController = ScrollController();
  String? parentId;
  String? announcementTitle;

  @override
  void initState() {
    super.initState();
    _getDataFromArguments();
    _loadComments();
    scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    commentController.dispose();
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  void _getDataFromArguments() {
    final args = Get.arguments;
    if (args != null) {
      parentId = args['parentId'];
      announcementTitle = args['announcementTitle'];
    }
  }

  Future<void> _loadComments() async {
    if (parentId == null) {
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    try {
      final result = await controller.getComments(
        parentId: parentId!,
        pageNumber: currentPage.value,
      );

      if (result != null) {
        final List<CommentsModel> loadedComments =
            result[ApiParameter.comments];
        if (currentPage.value == 1) {
          comments.clear();
        }
        comments.addAll(loadedComments);
        hasMore.value = result[ApiParameter.hasNext] ?? false;
      }
    } catch (e) {
      log('Error loading comments: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (hasMore.value && !isLoading.value) {
        currentPage.value++;
        _loadComments();
      }
    }
  }

  Future<void> _postComment() async {
    final comment = commentController.text.trim();
    if (comment.isEmpty || parentId == null) return;

    // Disable input while posting
    FocusScope.of(context).unfocus();
    commentController.clear();

    try {
      final success = await controller.addComment(
        parentId: parentId!,
        comment: comment,
      );

      if (success) {
        // Reload comments to show the newly added one
        currentPage.value = 1;
        await _loadComments();
        commonSnackBar(message: 'Comment added successfully');
      } else {
        commonSnackBar(message: 'Failed to add comment');
      }
    } catch (e) {
      log('Error posting comment: $e');
      commonSnackBar(message: 'An error occurred');
    }
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      appBar: commonAppBar(
        context: context,
        title: 'Comments',
        isBack: true,
        actions: [
          IconButton(
            onPressed: () async {
              currentPage.value = 1;
              await _loadComments();
            },
            icon: Icon(Icons.refresh, color: AppColors.blueColor),
          ),
        ],
      ),
      body: Column(
        children: [
          // Announcement title reference
          if (announcementTitle != null && announcementTitle!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: getHeight(12),
                horizontal: getWidth(16),
              ),
              decoration: BoxDecoration(
                color: AppColors.blueColor.withOpacity(0.05),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.announcement_rounded,
                    color: AppColors.blueColor.withOpacity(0.7),
                    size: getWidth(16),
                  ),
                  SizedBox(width: getWidth(8)),
                  Expanded(
                    child: Text(
                      'Announcement: $announcementTitle',
                      style: TextStyle(
                        fontSize: getWidth(12),
                        fontWeight: FontWeight.w500,
                        color: AppColors.textColor.withOpacity(0.8),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),

          // Comments list
          Expanded(
            child: Obx(() {
              if (isLoading.value && comments.isEmpty) {
                return Center(child: commonLoader());
              } else if (comments.isEmpty) {
                return _buildEmptyState();
              } else {
                return RefreshIndicator(
                  onRefresh: () async {
                    currentPage.value = 1;
                    await _loadComments();
                  },
                  child: ListView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.symmetric(
                      horizontal: getWidth(16),
                      vertical: getHeight(16),
                    ),
                    itemCount: comments.length + (hasMore.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Show loader at the end when loading more
                      if (index == comments.length) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: getHeight(16),
                            ),
                            child: commonLoader(),
                          ),
                        );
                      }

                      // Render comment item
                      return _buildCommentItem(comments[index]);
                    },
                  ),
                );
              }
            }),
          ),

          // Input field for new comment
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: getWidth(120),
            height: getWidth(120),
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: getWidth(60),
              color: AppColors.grey.withOpacity(0.5),
            ),
          ),
          SizedBox(height: getHeight(24)),
          Text(
            "No comments yet",
            style: TextStyle(
              fontSize: getWidth(18),
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          SizedBox(height: getHeight(8)),
          Text(
            "Start the conversation with your students!",
            style: TextStyle(
              fontSize: getWidth(14),
              color: AppColors.textColor.withOpacity(0.7),
            ),
          ),
          SizedBox(height: getHeight(32)),
          materialButtonWithChild(
            color: AppColors.blueColor,
            onPressed: () {
              // Focus on the comment input
              FocusScope.of(context).requestFocus(FocusNode());
              Future.delayed(Duration(milliseconds: 100), () {
                FocusScope.of(context).requestFocus(FocusNode());
              });
            },
            padding: EdgeInsets.symmetric(
              horizontal: getWidth(24),
              vertical: getHeight(12),
            ),
            borderRadius: 25,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_comment_outlined, color: Colors.white),
                SizedBox(width: getWidth(8)),
                Text(
                  'Add Comment',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: getWidth(16),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: getWidth(16),
        vertical: getHeight(12),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // User avatar
          Container(
            width: getWidth(36),
            height: getWidth(36),
            decoration: BoxDecoration(
              color: AppColors.blueColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.blueColor.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.person,
              color: AppColors.blueColor,
              size: getWidth(20),
            ),
          ),
          SizedBox(width: getWidth(12)),

          // Input field
          Expanded(
            child: Container(
              constraints: BoxConstraints(
                minHeight: getHeight(40),
                maxHeight: getHeight(100),
              ),
              decoration: BoxDecoration(
                color: AppColors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(getWidth(20)),
                border: Border.all(
                  color: AppColors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: commonTextFiled(
                controller: commentController,
                hintText: 'Write a comment...',
                hintStyle: TextStyle(
                  color: AppColors.textColor.withOpacity(0.6),
                  fontSize: getWidth(14),
                ),
                maxLines: null,
              ),
            ),
          ),
          SizedBox(width: getWidth(12)),

          // Send button
          Container(
            width: getWidth(40),
            height: getWidth(40),
            decoration: BoxDecoration(
              color: AppColors.blueColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.blueColor.withOpacity(0.3),
                  blurRadius: 8.0,
                  offset: Offset(0, 2),
                  spreadRadius: 0.0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _postComment,
                borderRadius: BorderRadius.circular(getWidth(50)),
                child: Center(
                  child: Icon(
                    Icons.send,
                    color: Colors.white,
                    size: getWidth(18),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(CommentsModel comment) {
    final formattedDate = timeAgoMethod(comment.commentedOn ?? '');

    return Container(
      margin: EdgeInsets.only(bottom: getHeight(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(getWidth(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comment header
          Container(
            padding: EdgeInsets.all(getWidth(12)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.grey.withOpacity(0.05),
                  Colors.white.withOpacity(0.01),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(getWidth(12)),
                topRight: Radius.circular(getWidth(12)),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // User avatar
                Container(
                  width: getWidth(40),
                  height: getWidth(40),
                  decoration: BoxDecoration(
                    color: AppColors.blueColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child:
                        comment.commentedBy?.profileImageUrl != null &&
                                comment.commentedBy!.profileImageUrl!.isNotEmpty
                            ? CachedNetworkImage(
                              imageUrl: comment.commentedBy!.profileImageUrl!,
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => Container(
                                    color: AppColors.grey.withOpacity(0.2),
                                    child: Icon(
                                      Icons.person,
                                      color: AppColors.blueColor.withOpacity(
                                        0.5,
                                      ),
                                      size: getWidth(20),
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) => Container(
                                    color: AppColors.blueColor.withOpacity(0.1),
                                    child: Icon(
                                      Icons.person,
                                      color: AppColors.blueColor,
                                      size: getWidth(20),
                                    ),
                                  ),
                            )
                            : Center(
                              child: Text(
                                (comment.commentedBy?.name?.isNotEmpty ?? false)
                                    ? comment.commentedBy!.name![0]
                                        .toUpperCase()
                                    : "?",
                                style: TextStyle(
                                  color: AppColors.blueColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: getWidth(16),
                                ),
                              ),
                            ),
                  ),
                ),
                SizedBox(width: getWidth(12)),

                // User name and time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.commentedBy?.name ?? 'Unknown',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: getWidth(14),
                          color: AppColors.textColor,
                        ),
                      ),
                      SizedBox(height: getHeight(2)),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: getWidth(12),
                          color: AppColors.textColor.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Comment content
          Padding(
            padding: EdgeInsets.fromLTRB(
              getWidth(64),
              getHeight(4),
              getWidth(16),
              getHeight(12),
            ),
            child: Text(
              comment.comment ?? '',
              style: TextStyle(
                fontSize: getWidth(15),
                color: AppColors.textColor,
                height: 1.4,
                letterSpacing: 0.2,
              ),
            ),
          ),

          // Reply button
          Container(
            padding: EdgeInsets.only(
              left: getWidth(16),
              right: getWidth(16),
              bottom: getHeight(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Replies button with counter badge
                InkWell(
                  onTap: () {
                    Get.toNamed(
                      RouteNames.teacherCommentReplies,
                      arguments: {'comment': comment},
                    )?.then((result) async {
                      currentPage.value = 1;
                      await _loadComments();
                    });
                  },
                  borderRadius: BorderRadius.circular(getWidth(20)),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: getWidth(12),
                      vertical: getHeight(6),
                    ),
                    decoration: BoxDecoration(
                      color:
                          (comment.replyCount ?? 0) > 0
                              ? AppColors.blueColor.withOpacity(0.1)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(getWidth(16)),
                      border: Border.all(
                        color:
                            (comment.replyCount ?? 0) > 0
                                ? Colors.transparent
                                : AppColors.grey.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          (comment.replyCount ?? 0) > 0
                              ? Icons.comment
                              : Icons.comment_outlined,
                          size: getWidth(16),
                          color:
                              (comment.replyCount ?? 0) > 0
                                  ? AppColors.blueColor
                                  : AppColors.textColor.withOpacity(0.6),
                        ),
                        SizedBox(width: getWidth(4)),
                        Text(
                          (comment.replyCount ?? 0) > 0
                              ? '${comment.replyCount} ${(comment.replyCount ?? 0) == 1 ? 'Reply' : 'Replies'}'
                              : 'Reply',
                          style: TextStyle(
                            fontSize: getWidth(12),
                            fontWeight: FontWeight.w500,
                            color:
                                (comment.replyCount ?? 0) > 0
                                    ? AppColors.blueColor
                                    : AppColors.textColor.withOpacity(0.6),
                          ),
                        ),
                      ],
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
}
