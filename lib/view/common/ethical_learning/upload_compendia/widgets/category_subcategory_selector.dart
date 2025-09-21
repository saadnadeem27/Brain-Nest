import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/common/ethical_learning_controller.dart';
import 'package:Vadai/model/students/compendia_model.dart';
import 'package:flutter/services.dart';

class CategorySelector extends StatelessWidget {
  final EthicalLearningController ethicalCtr;
  final Rx<CompendiaCategoryModel?> selectedCategory;
  final Function(int) onCategorySelected;

  const CategorySelector({
    Key? key,
    required this.ethicalCtr,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        textWid(
          'Category: \t',
          style: AppTextStyles.textStyle(
            fontSize: getWidth(21),
            fontWeight: FontWeight.w700,
            txtColor: AppColors.textColor3,
          ),
        ),
        Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () {
                showDynamicMenuStatus(
                  context: context,
                  selectedStatusIndex: ethicalCtr.categories.indexOf(
                    selectedCategory.value,
                  ),
                  list:
                      ethicalCtr.categories
                          .map((category) => category?.name ?? '')
                          .toList(),
                  onItemSelected: onCategorySelected,
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: getWidth(16),
                  vertical: getHeight(8),
                ),
                decoration: BoxDecoration(
                  color: AppColors.color7D818A,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Obx(
                  () => Row(
                    children: [
                      textWid(
                        (selectedCategory.value?.name ?? '').capitalizeFirst ??
                            '',
                        style: AppTextStyles.textStyle(
                          txtColor: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ).paddingOnly(right: getWidth(4)),
                      const Icon(
                        Icons.keyboard_arrow_down_outlined,
                        color: AppColors.white,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class SubcategorySelector extends StatefulWidget {
  final EthicalLearningController ethicalCtr;
  final Rx<CompendiaSubCategoryModel?> selectedSubcategory;
  final Function(CompendiaSubCategoryModel?) onSubcategorySelected;

  const SubcategorySelector({
    Key? key,
    required this.ethicalCtr,
    required this.selectedSubcategory,
    required this.onSubcategorySelected,
  }) : super(key: key);

  @override
  State<SubcategorySelector> createState() => _SubcategorySelectorState();
}

class _SubcategorySelectorState extends State<SubcategorySelector> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add a label to make it clear
        Text(
          'Subcategory:',
          style: TextStyle(
            fontSize: getWidth(16),
            fontWeight: FontWeight.w600,
            color: AppColors.textColor3,
          ),
        ).paddingOnly(bottom: getHeight(8), left: getWidth(4)),

        // The subcategories list
        Obx(
          () =>
              widget.ethicalCtr.subCategories.isEmpty
                  ? Center(
                    child: Text(
                      "No subcategories available",
                      style: TextStyle(
                        color: AppColors.textColor.withOpacity(0.7),
                        fontSize: getWidth(14),
                      ),
                    ),
                  )
                  : SizedBox(
                    height: getHeight(40),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.ethicalCtr.subCategories.length,
                      itemBuilder: (context, index) {
                        final subCategory =
                            widget.ethicalCtr.subCategories[index];

                        // Compare by ID for reliable equality check
                        final isSelected =
                            subCategory?.sId ==
                            widget.selectedSubcategory.value?.sId;

                        return InkWell(
                          onTap: () {
                            widget.onSubcategorySelected(subCategory);

                            HapticFeedback.lightImpact();
                            if (mounted) {
                              setState(() {});
                            }
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: EdgeInsets.only(right: getWidth(10)),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: getWidth(12),
                                vertical: getHeight(8),
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? AppColors.blueColor
                                        : AppColors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? AppColors.blueColor
                                          : AppColors.grey.withOpacity(0.5),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  if (isSelected)
                                    BoxShadow(
                                      color: AppColors.blueColor.withOpacity(
                                        0.3,
                                      ),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  widget
                                          .ethicalCtr
                                          .subCategories[index]
                                          ?.name ??
                                      '',
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? AppColors.white
                                            : AppColors.textColor,
                                    fontSize: getWidth(14),
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
        ),
      ],
    );
  }
}
