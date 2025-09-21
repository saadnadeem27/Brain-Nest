import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/student/auth_controller.dart';
import 'package:Vadai/view/student/profile/widgets/plan_card.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});
  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      appBar: commonAppBar(
        context: context,
        titleWidget: SizedBox(
          height: getHeight(235),
          width: getWidth(70),
          child: Image.asset(AppAssets.logo),
        ),
        isBack: true,
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: getWidth(16),
            right: getWidth(16),
            bottom: getHeight(20),
          ),
          child: Column(
            children: [
              Text(
                "Choose the access level that best supports your learning journey and future goals:",
                style: TextStyle(
                  fontSize: getWidth(12),
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: getHeight(12)),
              const PlanCardSection(),
              SizedBox(height: getHeight(20)),
              Text(
                "You can modify your VADAI access at any time through your account settings.",
                style: TextStyle(
                  fontSize: getWidth(12),
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlanCardSection extends StatefulWidget {
  const PlanCardSection({Key? key}) : super(key: key);

  @override
  State<PlanCardSection> createState() => _PlanCardSectionState();
}

class _PlanCardSectionState extends State<PlanCardSection> {
  AuthController authController = Get.put(AuthController());
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [Expanded(child: _buildFullPotentialPlan(context))],
        ),
        SizedBox(height: getHeight(20)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [Expanded(child: _buildBasicPlan(context))],
        ),
      ],
    );
  }

  Widget _buildBasicPlan(BuildContext context) {
    return PlanCard(
      title: "Basic Access",
      price: "(₹250 per month)",
      backgroundColor: Colors.black,
      textColor: Colors.white,
      features: const [
        "Academics",
        "Ethical Learning",
        "Career Game",
        "VAD Test",
        "Bi-monthly webinars (Free registrations)",
        "No VAD Squad Reviews",
      ],
      onConfirm: () async {
        final confirmed = await Get.dialog<bool>(
          AlertDialog(
            title: Text('Change to Basic Plan'),
            content: Text(
              'Are you sure you want to switch to the Basic plan (₹250/month)?',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: Text('Confirm'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          // Request change to Basic plan
          final result = await authController.requestAccessLevelChange(
            fullPotentialAccess: false,
          );

          if (result['success']) {
            Get.back(); // Return to previous screen
            commonSnackBar(
              message:
                  'Your plan change request has been submitted successfully',
            );
          }
        }
      },
    );
  }

  Widget _buildFullPotentialPlan(BuildContext context) {
    return PlanCard(
      title: "Full Potential",
      price: "(₹400 per month)",
      backgroundColor: const Color(0xFF4A6DB5), // Blue color from the image
      textColor: Colors.white,
      features: const [
        "Academics",
        "Ethical Learning",
        "Career Game",
        "VAD Test",
        "Bi-monthly webinars (Including Premium)",
        "Instant VAD Squad Reviews for Career Roadmap and Ethical Learning.",
      ],
      onConfirm: () async {
        // Show confirmation dialog
        final confirmed = await Get.dialog<bool>(
          AlertDialog(
            title: Text('Change to Premium Plan'),
            content: Text(
              'Are you sure you want to switch to the Full Potential plan (₹400/month)?',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: Text('Confirm'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          // Request change to Premium plan
          final result = await authController.requestAccessLevelChange(
            fullPotentialAccess: true,
          );

          if (result['success']) {
            Get.back(); // Return to previous screen
            commonSnackBar(
              message:
                  'Your plan change request has been submitted successfully',
            );
          }
        }
      },
      hasPremiumFeatures: true,
    );
  }
}
