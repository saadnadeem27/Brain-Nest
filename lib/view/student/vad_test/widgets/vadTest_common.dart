import 'package:Vadai/common_imports.dart';
import 'package:get/get_core/src/get_main.dart';

void VadTestRules() {
  Get.dialog(
    AlertDialog(
      title: const Text("VAD Test:"),
      content: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
              '• The respective teachers from each school must submit their syllabi for all subjects to form a unified curriculum.'),
          SizedBox(height: 8),
          Text(
              '• VADAI will create a general curriculum that is fair to all participating schools.'),
          SizedBox(height: 8),
          Text(
              '• The VAD Test will be conducted three times per academic year.'),
          SizedBox(height: 8),
          Text(
              '• Tests will be held on specific weekends, announced beforehand.'),
          SizedBox(height: 8),
          Text(
              '• All students must attend the test live at the same time, with parents acting as invigilators.'),
          SizedBox(height: 8),
          Text('• The curriculum for the tests will be provided in advance.'),
          SizedBox(height: 8),
          Text(
              '• Students will have access to preparatory files for each test through VADAI.'),
          SizedBox(height: 8),
          Text(
              '• Test results will determine the academic performance rankings.'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}
