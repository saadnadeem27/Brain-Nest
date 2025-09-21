import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/common/ethical_learning_controller.dart';
import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/model/students/compendia_model.dart';
import 'package:Vadai/view/common/ethical_learning/widgets/compendia_card.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MyCompendia extends StatefulWidget {
  const MyCompendia({super.key});

  @override
  State<MyCompendia> createState() => _MyCompendiaState();
}

class _MyCompendiaState extends State<MyCompendia> {
  final EthicalLearningController ethicalController = Get.find();
  final ScrollController _scrollController = ScrollController();
  RxList<CompendiaOverviewModel?> myCompendia = <CompendiaOverviewModel?>[].obs;
  RxBool isLoading = true.obs;
  RxBool hasMore = false.obs;
  RxInt currentPage = 1.obs;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    loadMyCompendia();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (hasMore.value) {
        loadMoreCompendia();
      }
    }
  }

  Future<void> loadMyCompendia() async {
    isLoading.value = true;
    try {
      final result = await ethicalController.getMyCompendia(pageNumber: 1);
      if (result != null) {
        myCompendia.value =
            result[ApiParameter.list] as List<CompendiaOverviewModel?>;
        hasMore.value = result[ApiParameter.hasNext] as bool;
        currentPage.value = 2;
        _prefetchCoverImages(myCompendia);
      }
    } catch (e) {
      log('Error loading my compendia: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreCompendia() async {
    if (!hasMore.value) return;

    try {
      final result = await ethicalController.getMyCompendia(
        pageNumber: currentPage.value,
      );
      if (result != null) {
        myCompendia.addAll(
          result[ApiParameter.list] as List<CompendiaOverviewModel?>,
        );
        hasMore.value = result[ApiParameter.hasNext] as bool;
        currentPage.value++;
      }
    } catch (e) {
      log('Error loading more compendia: $e');
    }
  }

  void _prefetchCoverImages(List<CompendiaOverviewModel?> compendia) {
    for (var compendium in compendia) {
      if (compendium?.coverImage != null &&
          compendium!.coverImage!.isNotEmpty) {
        precacheImage(
          CachedNetworkImageProvider(compendium.coverImage!),
          context,
        ).catchError((e) {
          // Silently handle any errors during precaching
          log('Error precaching my compendia image: $e');
        });
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
        title: AppStrings.myCompendium,
        actions: [],
      ),
      body: Obx(() {
        if (isLoading.value) {
          return Center(child: commonLoader());
        }

        if (myCompendia.isEmpty) {
          return Center(
            child: textWid(
              'No compendia found. Create your own!',
              style: AppTextStyles.textStyle(
                fontSize: getWidth(16),
                fontWeight: FontWeight.w700,
                txtColor: AppColors.textColor3,
              ),
            ),
          );
        }

        return SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              GridView.builder(
                padding: const EdgeInsets.all(8.0),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: getWidth(16),
                  mainAxisSpacing: getHeight(16),
                  childAspectRatio:
                      0.68, // Match the same aspect ratio as in EthicalLearning
                ),
                itemCount: myCompendia.length,
                itemBuilder: (context, index) {
                  return CompendiaCard(
                    item: myCompendia[index],
                    ethicalCtr: ethicalController,
                    onRefresh: loadMyCompendia,
                  );
                },
              ).paddingOnly(
                top: getHeight(8),
                left: getWidth(16),
                right: getWidth(16),
              ),

              // Loading more indicator
              if (hasMore.value)
                Center(
                  child: commonLoader(
                    customHeight: getHeight(50),
                    customWidth: getWidth(50),
                  ),
                ).paddingOnly(bottom: getHeight(16)),
            ],
          ),
        );
      }),
    );
  }
}
