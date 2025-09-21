import 'package:Vadai/common_imports.dart';
import 'package:flutter/services.dart';

class QuestionCountDialog extends StatefulWidget {
  final Function(int) onGenerate;

  const QuestionCountDialog({Key? key, required this.onGenerate})
    : super(key: key);

  @override
  State<QuestionCountDialog> createState() => _QuestionCountDialogState();
}

class _QuestionCountDialogState extends State<QuestionCountDialog> {
  final TextEditingController _countController = TextEditingController(
    text: "3",
  );
  String? _validationError;
  bool _isValidating = false;

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    setState(() => _isValidating = true);

    // Parse the input and validate
    int? count = int.tryParse(_countController.text.trim());

    if (count == null || count <= 0) {
      setState(() {
        _validationError = "Please enter a valid number greater than 0";
        _isValidating = false;
      });
    } else if (count > 20) {
      setState(() {
        _validationError = "Maximum 20 questions allowed";
        _isValidating = false;
      });
    } else {
      // Call the callback with the valid count
      widget.onGenerate(count);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Generate Questions'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How many questions would you like to generate?'),
          SizedBox(height: getHeight(16)),
          commonTextFiled(
            controller: _countController,
            hintText: "Enter number (1-50)",
            borderRadius: 8,
            keyBoardType: TextInputType.number,
            inputFormatter: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
          ),
          if (_validationError != null) ...[
            SizedBox(height: getHeight(8)),
            Text(
              _validationError!,
              style: TextStyle(color: AppColors.red, fontSize: getWidth(12)),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isValidating ? null : () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: _isValidating ? null : _validateAndSubmit,
          child: Text('Generate'),
          style: TextButton.styleFrom(foregroundColor: AppColors.blueColor),
        ),
      ],
    );
  }
}
