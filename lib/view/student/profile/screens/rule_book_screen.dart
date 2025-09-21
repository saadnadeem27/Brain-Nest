import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/student/student_profile_controller.dart';
import 'package:Vadai/model/students/rule_book_model.dart';

class RuleBookScreen extends StatefulWidget {
  const RuleBookScreen({super.key});

  @override
  State<RuleBookScreen> createState() => _RuleBookScreenState();
}

class _RuleBookScreenState extends State<RuleBookScreen> {
  final StudentProfileController profileCtr = Get.find();
  List<RuleBookModel> ruleBooks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRuleBooks();
  }

  Future<void> _loadRuleBooks() async {
    setState(() {
      isLoading = true;
    });

    try {
      final rules = await profileCtr.getRuleBookList();
      if (rules != null) {
        setState(() {
          ruleBooks = rules;
        });
      }
    } catch (e) {
      log('Error loading rule books: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showRulesPopup(RuleBookModel ruleBook) {
    showDialog(
      context: context,
      builder:
          (BuildContext context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: getWidth(20),
                vertical: getHeight(20),
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ruleBook.title ?? 'Rules',
                    style: TextStyle(
                      fontSize: getWidth(18),
                      fontWeight: FontWeight.w600,
                      color: AppColors.blueColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: getHeight(16)),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            (ruleBook.rules ?? []).map((rule) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: getHeight(8)),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "- ",
                                      style: TextStyle(
                                        fontSize: getWidth(14),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        rule,
                                        style: TextStyle(
                                          fontSize: getWidth(14),
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: getHeight(16)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MaterialButton(
                        color: AppColors.blueColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        onPressed: () => Get.back(),
                        child: Text(
                          "Close",
                          style: TextStyle(
                            fontSize: getWidth(16),
                            fontWeight: FontWeight.w500,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      appBar: AppBar(
        title: Text(
          "Rule Book",
          style: AppTextStyles.textStyle(
            fontSize: getWidth(20),
            fontWeight: FontWeight.w600,
            txtColor: AppColors.black,
          ),
        ),
        centerTitle: true,
      ),
      body:
          isLoading
              ? Center(child: commonLoader())
              : ruleBooks.isEmpty
              ? Center(
                child: Text(
                  "No rules found",
                  style: TextStyle(
                    fontSize: getWidth(16),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
              : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(getWidth(16)),
                  child: Column(
                    children:
                        ruleBooks
                            .map((ruleBook) => _buildRuleButton(ruleBook))
                            .toList(),
                  ),
                ),
              ),
    );
  }

  Widget _buildRuleButton(RuleBookModel ruleBook) {
    return Container(
      margin: EdgeInsets.only(bottom: getHeight(16)),
      width: double.infinity,
      child: MaterialButton(
        onPressed: () => _showRulesPopup(ruleBook),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(vertical: getHeight(16)),
        color: AppColors.blueColor,
        child: Text(
          ruleBook.title ?? 'Rules',
          style: TextStyle(
            fontSize: getWidth(18),
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}
