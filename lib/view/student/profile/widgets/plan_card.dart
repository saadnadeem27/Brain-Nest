import 'package:Vadai/common_imports.dart';

class PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final List<String> features;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onConfirm;
  final bool hasPremiumFeatures;

  const PlanCard({
    Key? key,
    required this.title,
    required this.price,
    required this.features,
    required this.backgroundColor,
    required this.textColor,
    required this.onConfirm,
    this.hasPremiumFeatures = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: getWidth(300),
      padding: EdgeInsets.all(getWidth(20)),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlanHeader(),
          SizedBox(height: getHeight(20)),
          _buildFeaturesList(),
          SizedBox(height: getHeight(20)),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildPlanHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: getWidth(24),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: getHeight(5)),
        Text(price, style: TextStyle(color: textColor, fontSize: getWidth(14))),
      ],
    );
  }

  Widget _buildFeaturesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          features.map((feature) {
            return Padding(
              padding: EdgeInsets.only(bottom: getHeight(10)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "• ",
                    style: TextStyle(
                      color: textColor,
                      fontSize: getWidth(16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      feature,
                      style: TextStyle(
                        color: textColor,
                        fontSize: getWidth(16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildConfirmButton() {
    return Center(
      child: MaterialButton(
        onPressed: onConfirm,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        minWidth: getWidth(200),
        height: getHeight(45),
        child: Text(
          "Confirm",
          style: TextStyle(
            color: Colors.black,
            fontSize: getWidth(18),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
