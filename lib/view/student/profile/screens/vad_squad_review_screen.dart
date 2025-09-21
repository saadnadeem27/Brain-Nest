import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/student/student_profile_controller.dart';
import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/model/students/vad_squad_review_model.dart';

class VADSquadReviewScreen extends StatefulWidget {
  const VADSquadReviewScreen({super.key});

  @override
  State<VADSquadReviewScreen> createState() => _VADSquadReviewScreenState();
}

class _VADSquadReviewScreenState extends State<VADSquadReviewScreen> {
  final StudentProfileController profileCtr = Get.find();
  final ScrollController scrollController = ScrollController();
  RxBool isLoading = true.obs;
  RxBool isLoadingMorePage = false.obs;
  RxList<VADSquadReviewModel> reviewList = <VADSquadReviewModel>[].obs;
  RxBool hasNext = false.obs;
  RxInt pageNumber = 2.obs;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollListener);
    loadReviews();
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  Future<void> loadReviews() async {
    isLoading.value = true;
    try {
      final result = await profileCtr.getVadSquadReviewList();
      if (result != null) {
        reviewList.value = result[ApiParameter.list];
        hasNext.value = result[ApiParameter.hasNext] ?? false;
      }
    } catch (e) {
      log('Error loading VAD Squad reviews: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      loadMoreReviews();
    }
  }

  Future<void> loadMoreReviews() async {
    if (isLoadingMorePage.value || !hasNext.value) return;

    isLoadingMorePage.value = true;
    try {
      final result = await profileCtr.getVadSquadReviewList(
        pageKey: pageNumber.value,
      );
      if (result != null) {
        final newReviews =
            result[ApiParameter.list] as List<VADSquadReviewModel>;
        reviewList.addAll(newReviews);
        hasNext.value = result[ApiParameter.hasNext] ?? false;
        pageNumber.value++;
      }
    } catch (e) {
      log('Error loading more VAD Squad reviews: $e');
    } finally {
      isLoadingMorePage.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      appBar: commonAppBar(
        context: context,
        titleWidget: Text(
          "VAD Squad Reviews",
          style: AppTextStyles.textStyle(
            fontSize: getWidth(20),
            fontWeight: FontWeight.w600,
            txtColor: AppColors.black,
          ),
        ),
        centerTitle: true,
        isBack: true,
      ),
      body: Obx(
        () =>
            isLoading.value
                ? Center(child: commonLoader())
                : reviewList.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.reviews_outlined,
                        size: getWidth(50),
                        color: AppColors.grey01,
                      ),
                      SizedBox(height: getHeight(16)),
                      Text(
                        "No reviews available",
                        style: TextStyle(
                          fontSize: getWidth(16),
                          fontWeight: FontWeight.w500,
                          color: AppColors.textColor,
                        ),
                      ),
                    ],
                  ),
                )
                : Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: loadReviews,
                      child: ListView.builder(
                        controller: scrollController,
                        padding: EdgeInsets.all(getWidth(16)),
                        itemCount: reviewList.length,
                        itemBuilder: (context, index) {
                          return _buildReviewCard(reviewList[index]);
                        },
                      ),
                    ),
                    if (isLoadingMorePage.value)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                            vertical: getHeight(10),
                          ),
                          child: commonLoader(
                            customHeight: getHeight(50),
                            customWidth: getWidth(50),
                          ),
                        ),
                      ),
                  ],
                ),
      ),
    );
  }

  Widget _buildReviewCard(VADSquadReviewModel review) {
    return Container(
      margin: EdgeInsets.only(bottom: getHeight(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(getWidth(10)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 6,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: AppColors.blueColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(getWidth(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Icon(
                    Icons.format_quote,
                    color: AppColors.blueColor.withOpacity(0.3),
                    size: getWidth(24),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: getWidth(8),
                    vertical: getHeight(4),
                  ),
                  child: Text(
                    review.review ?? "Review content not available",
                    style: AppTextStyles.textStyle(
                      fontSize: getWidth(14),
                      txtColor: AppColors.textColor,
                      height: 1.5,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(
                    Icons.format_quote,
                    color: AppColors.blueColor.withOpacity(0.3),
                    size: getWidth(24),
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
