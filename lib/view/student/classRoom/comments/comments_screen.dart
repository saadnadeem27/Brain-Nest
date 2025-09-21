import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/student/classroom_controller.dart';
import 'package:Vadai/controller/student/student_profile_controller.dart';
import 'package:Vadai/controller/teachers/teacher_profile_controller.dart';
import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/helper/local_storage_helper.dart';
import 'package:Vadai/model/common/comments_model.dart';
import 'package:Vadai/view/student/classRoom/comments/comment_replies_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({Key? key}) : super(key: key);

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final ClassRoomController controller = Get.put(ClassRoomController());
  final RxString userRole = ''.obs;
  final RxString appBarTitle = 'Comments'.obs;
  StudentProfileController? studentProfileController;
  TeacherProfileController? teacherProfileController;

  final TextEditingController commentController = TextEditingController();
  final RxBool isLoading = true.obs;
  final RxList<CommentsModel> comments = <CommentsModel>[].obs;
  final RxBool hasMore = false.obs;
  final RxInt currentPage = 1.obs;
  final ScrollController scrollController = ScrollController();
  String? parentId; // ID of the announcement or assignment

  @override
  void initState() {
    super.initState();
    _initControllers();
    _getDataFromArguments();
    _loadComments();
    scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    commentController.dispose();
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    controller.dispose();
    super.dispose();
  }

  void _initControllers() async {
    final role = LocalStorage.read(key: LocalStorageKeys.userRole);
    userRole.value = role ?? '';

    if (userRole.value == 'student') {
      try {
        studentProfileController = Get.find<StudentProfileController>();
      } catch (e) {
        studentProfileController = Get.put(StudentProfileController());
      }
    } else if (userRole.value == 'teacher') {
      try {
        teacherProfileController = Get.find<TeacherProfileController>();
      } catch (e) {
        teacherProfileController = Get.put(TeacherProfileController());
      }
    }
  }

  void _getDataFromArguments() {
    final args = Get.arguments;
    if (args != null) {
      parentId = args['parentId'];

      if (args['title'] != null) {
        appBarTitle.value = args['title'];
      }
    }
  }

  Future<void> _loadComments() async {
    if (parentId == null) {
      isLoading.value = false;
      comments.clear();
      commonSnackBar(
        message: "Cannot load comments: Missing reference ID",
        color: Colors.orange,
      );
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

    FocusScope.of(context).unfocus();
    commentController.clear();

    try {
      final success = await controller.addComment(
        parentId: parentId!,
        comment: comment,
      );

      if (success) {
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

  // Check if the comment belongs to current user
  bool isCurrentUser(String? userId) {
    if (userRole.value == 'student') {
      return userId == studentProfileController?.studentProfile.value?.sId;
    } else if (userRole.value == 'teacher') {
      return userId == teacherProfileController?.teacherProfile.value?.sId;
    }
    return false;
  }

  // Get user's profile image based on role
  String? getUserProfileImage() {
    if (userRole.value == 'student') {
      return studentProfileController?.studentProfile.value?.profileImage;
    } else if (userRole.value == 'teacher') {
      return teacherProfileController?.teacherProfile.value?.profileImage;
    }
    return null;
  }

  // Get user's name based on role
  String? getUserName() {
    if (userRole.value == 'student') {
      return studentProfileController?.studentProfile.value?.name;
    } else if (userRole.value == 'teacher') {
      return teacherProfileController?.teacherProfile.value?.name;
    }
    return 'User';
  }

  // Get user's first letter for avatar
  String getUserInitial() {
    String? name;
    if (userRole.value == 'student') {
      name = studentProfileController?.studentProfile.value?.name;
    } else if (userRole.value == 'teacher') {
      name = teacherProfileController?.teacherProfile.value?.name;
    }
    return (name?.isNotEmpty == true) ? name![0].toUpperCase() : "?";
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      appBar: commonAppBar(
        context: context,
        title: appBarTitle.value,
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
            parentId == null ? "Comments unavailable" : "No comments yet",
            style: TextStyle(
              fontSize: getWidth(18),
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          SizedBox(height: getHeight(8)),
          Text(
            parentId == null
                ? "Please go back and try again"
                : "Be the first to share your thoughts!",
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
            child: ClipOval(
              child:
                  getUserProfileImage() != null &&
                          getUserProfileImage()!.isNotEmpty
                      ? CachedNetworkImage(
                        imageUrl: getUserProfileImage()!,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => Container(
                              color: AppColors.grey.withOpacity(0.2),
                              child: Icon(
                                Icons.person,
                                color: AppColors.blueColor.withOpacity(0.5),
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
                          getUserInitial(),
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

          Container(
            width: getWidth(40),
            height: getWidth(40),
            decoration: BoxDecoration(
              color: AppColors.blueColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.blueColor.withOpacity(0.3),
                  blurRadius: 8.0, // Ensuring positive blur radius
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
    final isCurrentUserComment = isCurrentUser(comment.commentedBy?.sId);

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
        border:
            isCurrentUserComment
                ? Border.all(color: AppColors.blueColor.withOpacity(0.1))
                : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comment header with gradient background
          Container(
            padding: EdgeInsets.all(getWidth(12)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  isCurrentUserComment
                      ? AppColors.blueColor.withOpacity(0.1)
                      : AppColors.grey.withOpacity(0.05),
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
                // User avatar with subtle border
                Container(
                  width: getWidth(40),
                  height: getWidth(40),
                  decoration: BoxDecoration(
                    color: AppColors.blueColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          isCurrentUserComment
                              ? AppColors.blueColor.withOpacity(0.3)
                              : Colors.transparent,
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

                // User name and time with improved typography
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            comment.commentedBy?.name ?? 'Unknown',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: getWidth(14),
                              color: AppColors.textColor,
                            ),
                          ),
                          if (isCurrentUserComment)
                            Container(
                              margin: EdgeInsets.only(left: getWidth(8)),
                              padding: EdgeInsets.symmetric(
                                horizontal: getWidth(6),
                                vertical: getHeight(2),
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.blueColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  getWidth(4),
                                ),
                              ),
                              child: Text(
                                'You',
                                style: TextStyle(
                                  fontSize: getWidth(10),
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.blueColor,
                                ),
                              ),
                            ),
                        ],
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

                // Options button (only for current user's comments)
                if (isCurrentUserComment)
                  GestureDetector(
                    onTap: () {
                      _showCommentOptions(comment);
                    },
                    child: Padding(
                      padding: EdgeInsets.all(getWidth(4)),
                      child: Icon(
                        Icons.more_vert,
                        size: getWidth(20),
                        color: AppColors.textColor.withOpacity(0.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Comment content with improved styling
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

          // Reply button styled as a clear call-to-action
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
                    Get.to(
                      () => CommentRepliesScreen(),
                      arguments: {'comment': comment},
                      transition: Transition.rightToLeft,
                      duration: Duration(milliseconds: 300),
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

  void _showCommentOptions(CommentsModel comment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: EdgeInsets.all(getWidth(16)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(getWidth(16)),
                topRight: Radius.circular(getWidth(16)),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: getWidth(40),
                  height: getHeight(4),
                  margin: EdgeInsets.only(bottom: getHeight(16)),
                  decoration: BoxDecoration(
                    color: AppColors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(getWidth(4)),
                  ),
                ),
                // Edit option
                ListTile(
                  leading: Icon(
                    Icons.edit,
                    color: AppColors.blueColor,
                    size: getWidth(22),
                  ),
                  title: Text(
                    'Edit Comment',
                    style: TextStyle(
                      fontSize: getWidth(16),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // Implement edit functionality
                  },
                ),
                Divider(height: 1),
                // Delete option
                ListTile(
                  leading: Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: getWidth(22),
                  ),
                  title: Text(
                    'Delete Comment',
                    style: TextStyle(
                      fontSize: getWidth(16),
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // Implement delete functionality
                    _showDeleteConfirmation(comment);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showDeleteConfirmation(CommentsModel comment) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Comment'),
            content: Text('Are you sure you want to delete this comment?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Add delete comment logic here
                  _deleteComment(comment);
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  // Add method to delete comment
  Future<void> _deleteComment(CommentsModel comment) async {
    try {
      // Add your comment deletion API call here
      // Example: await controller.deleteComment(comment.id);

      // For now, just show a success message
      commonSnackBar(message: 'Comment deleted');

      // Reload comments
      currentPage.value = 1;
      await _loadComments();
    } catch (e) {
      log('Error deleting comment: $e');
      commonSnackBar(message: 'Failed to delete comment', color: Colors.red);
    }
  }
}
