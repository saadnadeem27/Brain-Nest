import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/student/classroom_controller.dart';
import 'package:Vadai/controller/student/student_profile_controller.dart';
import 'package:Vadai/controller/teachers/teacher_profile_controller.dart';
import 'package:Vadai/helper/local_storage_helper.dart';
import 'package:Vadai/model/common/comment_reply_model.dart';
import 'package:Vadai/model/common/comments_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';

class CommentRepliesScreen extends StatefulWidget {
  const CommentRepliesScreen({Key? key}) : super(key: key);

  @override
  State<CommentRepliesScreen> createState() => _CommentRepliesScreenState();
}

class _CommentRepliesScreenState extends State<CommentRepliesScreen> {
  final ClassRoomController controller = Get.put(ClassRoomController());
  final RxString userRole = ''.obs;
  StudentProfileController? studentProfileController;
  TeacherProfileController? teacherProfileController;
  final TextEditingController replyController = TextEditingController();
  final RxBool isLoading = true.obs;
  final RxList<CommentsReplyModel> replies = <CommentsReplyModel>[].obs;
  CommentsModel? comment;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _getDataFromArguments();
    _loadReplies();
  }

  @override
  void dispose() {
    replyController.dispose();
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
    if (args != null && args['comment'] != null) {
      comment = args['comment'];
    }
  }

  Future<void> _loadReplies() async {
    if (comment?.sId == null) {
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    try {
      final result = await controller.getCommentReplies(
        commentId: comment!.sId!,
      );

      if (result != null) {
        replies.value = result;
      }
    } catch (e) {
      log('Error loading replies: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _postReply() async {
    final reply = replyController.text.trim();
    if (reply.isEmpty || comment?.sId == null) return;

    // Disable input while posting
    FocusScope.of(context).unfocus();
    replyController.clear();

    try {
      final success = await controller.addReply(
        commentId: comment?.sId ?? '',
        reply: reply,
      );

      if (success) {
        await _loadReplies();
      } else {
        commonSnackBar(message: 'Failed to add reply');
      }
    } catch (e) {
      log('Error posting reply: $e');
      commonSnackBar(message: 'An error occurred');
    }
  }

  bool isCurrentUser(String? userId) {
    if (userRole.value == 'student') {
      return userId == studentProfileController?.studentProfile.value?.sId;
    } else if (userRole.value == 'teacher') {
      return userId == teacherProfileController?.teacherProfile.value?.sId;
    }
    return false;
  }

  String? getUserProfileImage() {
    if (userRole.value == 'student') {
      return studentProfileController?.studentProfile.value?.profileImage;
    } else if (userRole.value == 'teacher') {
      return teacherProfileController?.teacherProfile.value?.profileImage;
    }
    return null;
  }

  String? getUserName() {
    if (userRole.value == 'student') {
      return studentProfileController?.studentProfile.value?.name;
    } else if (userRole.value == 'teacher') {
      return teacherProfileController?.teacherProfile.value?.name;
    }
    return 'User';
  }

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
      resizeToAvoidBottomInset: true,
      appBar: commonAppBar(
        context: context,
        title: 'Replies',
        isBack: true,
        actions: [
          IconButton(
            onPressed: _loadReplies,
            icon: Icon(Icons.refresh, color: AppColors.blueColor),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Original comment
            if (comment != null) _buildOriginalComment(),

            // Divider
            Divider(
              height: 1,
              thickness: 1,
              color: AppColors.grey.withOpacity(0.2),
            ),

            // Replies list
            Expanded(
              child: Obx(() {
                if (isLoading.value) {
                  return Center(child: commonLoader());
                } else if (replies.isEmpty) {
                  return _buildEmptyState();
                } else {
                  return RefreshIndicator(
                    onRefresh: _loadReplies,
                    child: ListView.builder(
                      padding: EdgeInsets.all(getWidth(16)),
                      itemCount: replies.length,
                      itemBuilder: (context, index) {
                        return _buildReplyItem(replies[index]);
                      },
                    ),
                  );
                }
              }),
            ),

            KeyboardVisibilityBuilder(
              builder: (context, isKeyboardVisible) {
                return _buildReplyInput();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: getWidth(100),
            height: getWidth(100),
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.forum_outlined,
              size: getWidth(50),
              color: AppColors.grey.withOpacity(0.5),
            ),
          ),
          SizedBox(height: getHeight(24)),
          Text(
            "No replies yet",
            style: TextStyle(
              fontSize: getWidth(18),
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          SizedBox(height: getHeight(8)),
          Text(
            "Be the first to reply to this comment!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: getWidth(14),
              color: AppColors.textColor.withOpacity(0.7),
            ),
          ),
          SizedBox(height: getHeight(24)),
          materialButtonWithChild(
            color: AppColors.blueColor,
            onPressed: () {
              // Focus on the reply input
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
                Icon(Icons.reply, color: Colors.white),
                SizedBox(width: getWidth(8)),
                Text(
                  'Add Reply',
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

  Widget _buildOriginalComment() {
    final formattedDate = timeAgoMethod(comment?.commentedOn ?? '');
    final isCurrentUserComment = isCurrentUser(comment?.commentedBy?.sId);

    return Container(
      margin: EdgeInsets.all(getWidth(16)),
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
          // Header with gradient
          Container(
            padding: EdgeInsets.all(getWidth(16)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  isCurrentUserComment
                      ? AppColors.blueColor.withOpacity(0.1)
                      : AppColors.grey.withOpacity(0.05),
                  Colors.white.withOpacity(0.01),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
                  width: getWidth(44),
                  height: getWidth(44),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          isCurrentUserComment
                              ? AppColors.blueColor.withOpacity(0.3)
                              : Colors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child:
                        comment?.commentedBy?.profileImageUrl != null &&
                                comment!
                                    .commentedBy!
                                    .profileImageUrl!
                                    .isNotEmpty
                            ? CachedNetworkImage(
                              imageUrl: comment!.commentedBy!.profileImageUrl!,
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => Container(
                                    color: AppColors.grey.withOpacity(0.2),
                                    child: Icon(
                                      Icons.person,
                                      color: AppColors.blueColor.withOpacity(
                                        0.5,
                                      ),
                                      size: getWidth(22),
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) => Container(
                                    color: AppColors.blueColor.withOpacity(0.1),
                                    child: Icon(
                                      Icons.person,
                                      color: AppColors.blueColor,
                                      size: getWidth(22),
                                    ),
                                  ),
                            )
                            : Center(
                              child: Text(
                                (comment?.commentedBy?.name?.isNotEmpty ??
                                        false)
                                    ? comment!.commentedBy!.name![0]
                                        .toUpperCase()
                                    : "?",
                                style: TextStyle(
                                  color: AppColors.blueColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: getWidth(18),
                                ),
                              ),
                            ),
                  ),
                ),
                SizedBox(width: getWidth(14)),

                // User name and time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            comment?.commentedBy?.name ?? 'Unknown',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: getWidth(16),
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
                      SizedBox(height: getHeight(4)),
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

          // Comment content with improved styling
          Container(
            padding: EdgeInsets.all(getWidth(16)),
            child: Text(
              comment?.comment ?? '',
              style: TextStyle(
                fontSize: getWidth(16),
                color: AppColors.textColor,
                height: 1.4,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyItem(CommentsReplyModel reply) {
    final isCurrentUserReply = isCurrentUser(reply.repliedBy?.sId);

    return Container(
      margin: EdgeInsets.only(bottom: getHeight(12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(getWidth(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
        border:
            isCurrentUserReply
                ? Border.all(color: AppColors.blueColor.withOpacity(0.1))
                : null,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: getWidth(4),
              decoration: BoxDecoration(
                color:
                    isCurrentUserReply
                        ? AppColors.blueColor.withOpacity(0.3)
                        : AppColors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(getWidth(12)),
                  bottomLeft: Radius.circular(getWidth(12)),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: EdgeInsets.all(getWidth(12)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: getWidth(36),
                      height: getWidth(36),
                      decoration: BoxDecoration(
                        color: AppColors.blueColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              isCurrentUserReply
                                  ? AppColors.blueColor.withOpacity(0.2)
                                  : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: ClipOval(
                        child:
                            reply.repliedBy?.profileImage != null &&
                                    reply.repliedBy!.profileImage!.isNotEmpty
                                ? CachedNetworkImage(
                                  imageUrl: reply.repliedBy!.profileImage!,
                                  fit: BoxFit.cover,
                                  placeholder:
                                      (context, url) => Container(
                                        color: AppColors.grey.withOpacity(0.2),
                                        child: Icon(
                                          Icons.person,
                                          color: AppColors.blueColor
                                              .withOpacity(0.5),
                                          size: getWidth(16),
                                        ),
                                      ),
                                  errorWidget:
                                      (context, url, error) => Container(
                                        color: AppColors.blueColor.withOpacity(
                                          0.1,
                                        ),
                                        child: Icon(
                                          Icons.person,
                                          color: AppColors.blueColor,
                                          size: getWidth(16),
                                        ),
                                      ),
                                )
                                : Center(
                                  child: Text(
                                    (reply.repliedBy?.name?.isNotEmpty ?? false)
                                        ? reply.repliedBy!.name![0]
                                            .toUpperCase()
                                        : "?",
                                    style: TextStyle(
                                      color: AppColors.blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: getWidth(14),
                                    ),
                                  ),
                                ),
                      ),
                    ),
                    SizedBox(width: getWidth(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                reply.repliedBy?.name ?? 'Unknown',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: getWidth(14),
                                  color: AppColors.textColor,
                                ),
                              ),
                              if (isCurrentUserReply)
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
                          SizedBox(height: getHeight(4)),
                          Text(
                            reply.reply ?? '',
                            style: TextStyle(
                              fontSize: getWidth(14),
                              color: AppColors.textColor,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyInput() {
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
          // Current user avatar
          Container(
            width: getWidth(36),
            height: getWidth(36),
            decoration: BoxDecoration(
              color: AppColors.blueColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.blueColor.withOpacity(0.2),
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

          // Input field with reply context
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
                controller: replyController,
                hintText: 'Write your reply...',
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
                onTap: _postReply,
                borderRadius: BorderRadius.circular(getWidth(50)),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 200),
                    child: Icon(
                      Icons.send,
                      key: ValueKey(replyController.text.trim().isNotEmpty),
                      color: Colors.white,
                      size: getWidth(18),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
