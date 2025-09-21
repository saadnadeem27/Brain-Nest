import 'package:Vadai/common_imports.dart';

class CommonDropdown<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<T> items;
  final String Function(T) itemToString;
  final Function(T?) onChanged;
  final bool isExpanded;
  final String? labelText;
  final bool isEnabled;
  final double borderRadius;
  final Color borderColor;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? hintStyle;
  final TextStyle? selectedItemStyle;
  final TextStyle? dropdownItemStyle;
  final Icon? icon;

  const CommonDropdown({
    Key? key,
    required this.hint,
    required this.value,
    required this.items,
    required this.itemToString,
    required this.onChanged,
    this.isExpanded = true,
    this.labelText,
    this.isEnabled = true,
    this.borderRadius = 8.0,
    this.borderColor = AppColors.grey,
    this.fillColor,
    this.contentPadding,
    this.hintStyle,
    this.selectedItemStyle,
    this.dropdownItemStyle,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: isExpanded,
      decoration: InputDecoration(
        labelText: labelText,
        enabled: isEnabled,
        hintText: hint,
        hintStyle:
            hintStyle ??
            TextStyle(fontSize: getWidth(14), color: AppColors.textColor),
        filled: fillColor != null,
        fillColor: fillColor,
        contentPadding:
            contentPadding ??
            EdgeInsets.symmetric(
              horizontal: getWidth(12),
              vertical: getHeight(4),
            ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: borderColor ?? AppColors.black.withOpacity(1),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(getWidth(borderRadius)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: borderColor ?? AppColors.black.withOpacity(0.6),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(getWidth(borderRadius)),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: borderColor ?? AppColors.black.withOpacity(0.6),
            width: 1,
          ),
        ),
      ),
      icon: icon ?? Icon(Icons.arrow_drop_down, color: AppColors.textColor),
      style:
          selectedItemStyle ??
          TextStyle(
            fontSize: getWidth(14),
            color: AppColors.textColor,
            fontWeight: FontWeight.w500,
          ),
      hint: Text(
        hint,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style:
            hintStyle ??
            TextStyle(fontSize: getWidth(14), color: AppColors.textColor),
      ),
      items:
          items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemToString(item),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    dropdownItemStyle ??
                    TextStyle(
                      fontSize: getWidth(14),
                      color: AppColors.textColor,
                    ),
              ),
            );
          }).toList(),
      onChanged: isEnabled ? onChanged : null,
    );
  }
}
