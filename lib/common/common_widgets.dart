import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/student/student_profile_controller.dart';
import 'package:Vadai/controller/teachers/teacher_profile_controller.dart';
import 'package:Vadai/helper/local_storage_helper.dart';
import 'package:Vadai/main.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

bool isAuth() {
  bool isAuth = false;
  if (LocalStorage.read(key: LocalStorageKeys.token) != null) {
    isAuth = true;
  }
  return isAuth;
}

Widget commonNoDataFound() {
  return Center(
    child: textWid(
      AppStrings.nothingHereTryAgain,
      style: AppTextStyles.textStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        txtColor: AppColors.black.withOpacity(0.7),
      ),
    ),
  );
}

String timeAgoMethod(String? dateString) {
  if (dateString == null || dateString.isEmpty) return '';

  try {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(date).abs();

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 7) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else if (difference.inSeconds > 30) {
      return '${difference.inSeconds} second${difference.inSeconds > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  } catch (e) {
    return '';
  }
}

String formatDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) return '';
  DateTime? date = DateTime.tryParse(dateString);
  if (date == null) {
    return '';
  }
  return DateFormat('dd/MM/yyyy').format(date.toLocal());
}

String getWeekday(String? dateString) {
  if (dateString == null || dateString.isEmpty) return '';

  DateTime? dateTime = DateTime.tryParse(dateString);
  if (dateTime == null) {
    return '';
  }
  DateTime localDateTime = dateTime.toLocal();
  return DateFormat('EEEE').format(localDateTime);
}

String getTime(String? dateString) {
  if (dateString == null || dateString.isEmpty) return '';

  DateTime? dateTime = DateTime.tryParse(dateString);
  if (dateTime == null) {
    return '';
  }
  DateTime localDateTime = dateTime.toLocal();
  return DateFormat('h:mm a').format(localDateTime);
}

String formatDouble(double? value) {
  if (value == null) return '';
  if (value == value.floor()) {
    return value.toInt().toString();
  }
  String formatted = value.toStringAsFixed(2);
  while (formatted.endsWith('0')) {
    formatted = formatted.substring(0, formatted.length - 1);
  }
  if (formatted.endsWith('.')) {
    formatted = formatted.substring(0, formatted.length - 1);
  }
  return formatted;
}

Widget commonScaffold({
  required BuildContext context,
  Widget? body,
  Key? key,
  Color? backgroundColor,
  bool? resizeToAvoidBottomInset,
  Widget? bottomNavigationBar,
  PreferredSizeWidget? appBar,
  Widget? drawer,
  Widget? endDrawer,
  Function()? onTap,
  Widget? floatingActionButton,
  FloatingActionButtonLocation? floatingActionButtonLocation,
  Function(dynamic val)? onEndDrawerChanged,
}) {
  return GestureDetector(
    onTap: onTap ?? () => FocusManager.instance.primaryFocus?.unfocus(),
    child: Scaffold(
      onEndDrawerChanged: onEndDrawerChanged,
      endDrawer: endDrawer,
      appBar:
          appBar != null
              ? PreferredSize(
                preferredSize: Size.fromHeight(getWidth(55)),
                child: appBar,
              )
              : null,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      key: key,
      backgroundColor: backgroundColor ?? AppColors.white,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset ?? true,
      bottomNavigationBar: bottomNavigationBar,
      body: body,
      drawer: drawer,
    ),
  );
}

AppBar commonAppBar({
  required BuildContext context,
  Key? key,
  String? title,
  Widget? titleWidget,
  List<Widget>? actions = const [],
  bool shadow = false,
  Widget? leading,
  bool isBack = false,
  bool automaticallyImplyLeading = true,
  bool centerTitle = true,
  double? elevation,
  PreferredSizeWidget? bottom,
  IconThemeData? iconTheme,
  IconThemeData? actionsIconTheme,
  TextTheme? textTheme,
  bool primary = true,
  double titleSpacing = NavigationToolbar.kMiddleSpacing,
  double toolbarOpacity = 1.0,
  double bottomOpacity = 1.0,
  double? toolbarHeight,
  double? leadingWidth,
  bool excludeHeaderSemantics = false,
  Color titleColor = AppColors.blueColor,
}) {
  return AppBar(
    key: key,
    title:
        titleWidget ??
        (title != null
            ? textWid(
              title,
              style: TextStyle(
                fontSize: getWidth(24),
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            )
            : assetImage(image: AppAssets.logo, customHeight: 40)),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(getWidth(30)),
        bottomRight: Radius.circular(getWidth(30)),
      ),
    ),
    actions: actions,
    leading:
        isBack
            ? IconButton(onPressed: Get.back, icon: Icon(Icons.arrow_back))
            : Padding(
              padding: EdgeInsets.only(left: getWidth(16)),
              child: leading,
            ),
    automaticallyImplyLeading: automaticallyImplyLeading,
    centerTitle: centerTitle,
    backgroundColor: AppColors.white,
    elevation: elevation ?? getWidth(10),
    surfaceTintColor: Colors.transparent,
    shadowColor: shadow ? AppColors.black.withOpacity(0.8) : null,
    bottom: bottom,
    iconTheme: iconTheme,
    actionsIconTheme: actionsIconTheme,
    primary: primary,
    titleSpacing: titleSpacing,
    toolbarOpacity: toolbarOpacity,
    bottomOpacity: bottomOpacity,
    toolbarHeight: toolbarHeight,
    leadingWidth: leadingWidth,
    excludeHeaderSemantics: excludeHeaderSemantics,
  );
}

Widget commonLoader({
  double customHeight = double.infinity,
  double? customWidth = double.infinity,
}) {
  return Container(
    width: customWidth,
    height: customHeight,
    child: const Center(
      child: CircularProgressIndicator(color: AppColors.blueColor),
    ),
  );
}

Text textWid(
  String text, {
  TextStyle? style,
  TextOverflow? textOverflow = TextOverflow.ellipsis,
  TextAlign textAlign = TextAlign.left,
  int? maxlines = 1,
}) {
  return Text(
    text,
    style: style ?? AppTextStyles.textStyle(),
    maxLines: maxlines,
    textAlign: textAlign,
    overflow: textOverflow,
  );
}

Image assetImage({
  required String image,
  double? customHeight,
  double? customWidth,
  Color? color,
  BoxFit fit = BoxFit.contain,
}) {
  return Image.asset(
    image,
    color: color,
    height: customHeight != null ? getHeight(customHeight) : null,
    width: customWidth != null ? getWidth(customWidth) : null,
    fit: fit,
  );
}

Widget commonPadding({required Widget child, EdgeInsets? padding}) {
  return Padding(
    padding:
        padding ?? EdgeInsets.only(left: getWidth(16), right: getWidth(16)),
    child: child,
  );
}

Widget commonSearchField({String? hint, String image = AppAssets.search}) {
  return commonTextFiled(
    hintText: hint ?? AppStrings.searchCompendia,
    hintStyle: AppTextStyles.textStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
    ),
    contentPadding: EdgeInsets.only(left: getWidth(16)),
    suffixWidget: Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.blueColor,
      ),
      child: assetImage(image: image, customWidth: 35, customHeight: 35),
    ),
  );
}

Widget commonCard({
  double? height,
  double? width,
  required double radius,
  Widget? child,
  Border? border,
}) {
  return Container(
    height: height != null ? getHeight(height) : null,
    width: width != null ? getHeight(width) : null,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.white, AppColors.white, AppColors.colorE3E3E3],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0, 0.5, 1],
      ),
      border: border ?? Border.all(color: AppColors.white, width: 1),
      boxShadow: [
        BoxShadow(
          offset: const Offset(0, 3),
          blurRadius: 12,
          spreadRadius: 0,
          color: AppColors.black.withOpacity(0.16),
        ),
      ],
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
    ),
    child: child,
  );
}

Widget commonTextFiled({
  Color textColor = AppColors.black,
  double? fontSize,
  TextEditingController? controller,
  OutlineInputBorder? border,
  Color backgroundColor = AppColors.white,
  Color? borderColor,
  Widget? prefix,
  bool suffix = false,
  Widget? suffixWidget,
  FormFieldValidator? validator,
  bool autoFocus = false,
  Function(String)? onChanged,
  Function()? onEditingComplete,
  Function()? onTap,
  bool isEnable = true,
  List<TextInputFormatter>? inputFormatter,
  bool? autovalidate = true,
  TextInputType? keyBoardType = TextInputType.text,
  String hintText = '',
  double borderRadius = 20,
  TextAlign textAlign = TextAlign.left,
  Color? focusColor,
  double prefixMaxWidth = 34,
  double? suffixPadding,
  BoxConstraints? suffixBoxConstraints,
  BoxConstraints? prefixConstraints,
  FocusNode? focusNode,
  EdgeInsets? contentPadding,
  int? maxLines,
  bool maxLineNull = false,
  List<String>? autofillHints,
  int? maxLength,
  bool? readOnly,
  String? label,
  String? initialValue,
  TextStyle? hintStyle,
  obscureText = false,
  TextInputAction? textInputAction,
}) {
  borderColor = borderColor ?? AppColors.lightBorder;
  return TextFormField(
    readOnly: readOnly ?? false,
    autofillHints: autofillHints,
    cursorColor: borderColor,
    cursorWidth: getWidth(2),
    cursorHeight: getHeight(20),
    cursorErrorColor: AppColors.red,
    textInputAction: textInputAction,
    initialValue: initialValue,
    autovalidateMode: autovalidate! ? AutovalidateMode.onUserInteraction : null,
    controller: controller,
    focusNode: focusNode,
    validator: validator,
    enabled: isEnable,
    autofocus: autoFocus,
    textAlign: textAlign,
    textCapitalization: TextCapitalization.none,
    keyboardType: keyBoardType ?? TextInputType.visiblePassword,
    onChanged: onChanged,
    onEditingComplete: onEditingComplete,
    onTap: onTap,
    obscureText: obscureText,
    maxLines: maxLineNull ? null : maxLines ?? 1,
    maxLength: maxLength,
    inputFormatters: inputFormatter ?? [],
    autocorrect: true,
    enableSuggestions: true,
    decoration: InputDecoration(
      hintText: hintText,
      hintStyle:
          hintStyle ??
          AppTextStyles.textStyle(txtColor: AppColors.black.withOpacity(0.5)),
      labelText: label,
      labelStyle: AppTextStyles.textStyle(
        txtColor: AppColors.black,
        fontSize: fontSize ?? 14,
      ),
      filled: true,
      fillColor: backgroundColor,
      errorStyle: AppTextStyles.textStyle(
        txtColor: AppColors.errorColor,
        fontSize: getWidth(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(width: 1, color: AppColors.errorColor),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      disabledBorder:
          border ??
          OutlineInputBorder(
            borderSide: BorderSide(
              color: borderColor ?? AppColors.black.withOpacity(0.6),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
      enabledBorder:
          border ??
          OutlineInputBorder(
            borderSide: BorderSide(
              color: borderColor ?? AppColors.black.withOpacity(0.6),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(getWidth(borderRadius)),
          ),
      focusedBorder:
          border ??
          OutlineInputBorder(
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
        borderRadius: BorderRadius.circular(getWidth(borderRadius)),
      ),
      alignLabelWithHint: true,
      prefixIcon: prefix,
      prefixIconConstraints:
          prefixConstraints ??
          BoxConstraints(maxWidth: getWidth(prefixMaxWidth)),
      contentPadding: contentPadding ?? EdgeInsets.all(getHeight(10)),
      suffixIconConstraints:
          suffixBoxConstraints ??
          BoxConstraints(
            // maxHeight: getHeight(40),
            maxWidth: getWidth(40),
          ),
      suffixIcon: Padding(
        padding: EdgeInsets.only(
          left: getWidth(5),
          right: getWidth(suffixPadding ?? 10),
        ),
        child: suffixWidget,
      ),
    ),
    style: AppTextStyles.textStyle(
      txtColor: isEnable ? textColor : AppColors.black.withOpacity(0.5),
      fontSize: fontSize ?? 14,
    ),
  );
}

Widget loader({double customHeight = 60, double? customWidth, Color? color}) {
  // RxBool show = false.obs;
  return Container(
    color: color ?? AppColors.white,
    alignment: Alignment.center,
    child: assetImage(
      image: AppAssets.loader,
      customHeight: getHeight(customHeight),
      customWidth: customWidth != null ? getHeight(customWidth) : null,
    ),
  );
}

commonSnackBar({
  String? title,
  required String message,
  Color? color,
  double? width,
}) {
  scaffoldKey.currentState?.clearSnackBars();
  return message == ''
      ? null
      : scaffoldKey.currentState?.showSnackBar(
        SnackBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 30.0),
          content: Center(
            child: Container(
              margin: EdgeInsets.only(left: getWidth(16), right: getWidth(16)),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color ?? AppColors.textColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: textWid(
                message,
                maxlines: 4,
                style: AppTextStyles.textStyle(txtColor: AppColors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
}

Widget materialButtonWithChild({
  Widget? child,
  Color color = AppColors.blueColor,
  BorderRadius? borderRadiusOnly,
  double borderRadius = 7,
  Color borderColor = AppColors.transparent,
  double? borderWidth,
  double? height,
  double? width,
  double elevation = 0,
  Color splashColor = AppColors.transparent,
  Color? highlightColor = AppColors.transparent,
  double highlightElevation = 0,
  EdgeInsets padding = EdgeInsets.zero,
  void Function()? onPressed,
}) {
  return MaterialButton(
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    padding: padding,
    elevation: elevation,
    highlightElevation: highlightElevation,
    splashColor: splashColor,
    highlightColor: highlightColor,
    clipBehavior: Clip.hardEdge,
    shape: OutlineInputBorder(
      borderRadius:
          borderRadiusOnly ?? BorderRadius.circular(getWidth(borderRadius)),
      borderSide:
          borderWidth == null
              ? BorderSide.none
              : BorderSide(color: borderColor, width: borderWidth),
    ),
    height: height != null ? getHeight(height) : null,
    minWidth: width != null ? getWidth(width) : null,
    color: color,
    onPressed: onPressed ?? () {},
    child: child,
  );
}

Widget materialButtonOnlyText({
  String? text,
  double? height,
  Function()? onTap,
  double? width,
  double elevation = 0,
  Color color = AppColors.blueColor,
  TextStyle? style,
  double borderRadius = 7,
  EdgeInsets padding = EdgeInsets.zero,
}) {
  return materialButtonWithChild(
    onPressed: onTap,
    height: height,
    padding: padding,
    width: width,
    elevation: elevation,
    color: color,
    borderRadius: borderRadius,
    child: textWid(
      text ?? "",
      style:
          style ??
          AppTextStyles.textStyle(
            txtColor: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
    ),
  );
}

void showGetXDialog({
  required String title,
  String message = 'This feature will be available soon',
}) {
  Get.defaultDialog(
    title: title,
    middleText: message,
    textConfirm: "OK",
    confirmTextColor: Colors.white,
    buttonColor: AppColors.blueColor,
    titlePadding: EdgeInsets.all(getWidth(8)),
    onConfirm: () {
      Get.back();
    },
  );
}

void showDynamicMenuStatus({
  required BuildContext context,
  required int selectedStatusIndex,
  required List<String> list,
  required Function(int) onItemSelected,
  // required RelativeRect relativeRect,
}) {
  final RenderBox renderBox = context.findRenderObject() as RenderBox;
  final offset = renderBox.localToGlobal(Offset.zero);

  final left = offset.dx;
  final right =
      MediaQuery.of(context).size.width - offset.dx - renderBox.size.width;
  final top = (offset.dy + renderBox.size.height) + 4;
  showMenu<int>(
    context: context,
    position: RelativeRect.fromLTRB(left, top, right, 0.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(
        getWidth(10),
      ), // Adjust the radius as needed
    ),
    items: List<PopupMenuEntry<int>>.generate(list.length, (index) {
      return PopupMenuItem<int>(
        value: index,
        child: textWid(
          list[index]?.capitalizeFirst ?? '',
          style: AppTextStyles.textStyle(
            fontWeight:
                index == selectedStatusIndex
                    ? ui.FontWeight.w700
                    : ui.FontWeight.w400,
          ),
        ),
      );
    }),
    elevation: 8.0,
  ).then((selectedIndex) {
    if (selectedIndex != null) {
      onItemSelected(selectedIndex);
    }
  });
}

Widget buildCategoryText({
  required String title,
  required String content,
  Color? titleColor = AppColors.textColor,
  Color? contentColor = AppColors.blueColor,
  double titleSize = 13,
  double contentSize = 13,
}) {
  return RichText(
    text: TextSpan(
      children: [
        TextSpan(
          text: '$title: ',
          style: TextStyle(
            color: titleColor, // Or your desired color
            fontWeight: FontWeight.bold,
            fontSize: getWidth(titleSize),
          ),
        ),
        TextSpan(
          text: content,
          style: TextStyle(
            color: contentColor, // Or your desired color
            fontSize: getWidth(contentSize),
          ),
        ),
      ],
    ),
  );
}

Widget commonDivider({
  double? height = 16,
  double? thickness = 1,
  double? leftPadding = 0,
  double? rightPadding = 0,
}) {
  return Divider(
    color: AppColors.textColor2,
    height: getHeight(height ?? 16),
    thickness: getHeight(thickness ?? 1),
  ).paddingOnly(
    left: getWidth(leftPadding ?? 16),
    right: getWidth(rightPadding ?? 16),
  );
}

class AutoScrollTitle extends StatefulWidget {
  final String text;
  final TextStyle style;

  const AutoScrollTitle({Key? key, required this.text, required this.style})
    : super(key: key);

  @override
  State<AutoScrollTitle> createState() => _AutoScrollTitleState();
}

class _AutoScrollTitleState extends State<AutoScrollTitle>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  GlobalKey _keyText = GlobalKey();
  bool _hasOverflow = false;
  double _viewportWidth = 0;
  double _textWidth = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureText();
    });
  }

  void _measureText() {
    final RenderBox renderBox =
        _keyText.currentContext?.findRenderObject() as RenderBox;
    _textWidth = renderBox.size.width;
    _viewportWidth = context.size?.width ?? 0;
    _hasOverflow = _textWidth > _viewportWidth;

    if (_hasOverflow) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    Animation<double> _animation = Tween<double>(
      begin: 0.0,
      end: _textWidth - _viewportWidth,
    ).animate(_animationController);

    _animation.addListener(() {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_animation.value);
      }
    });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Add a small pause at the end before resetting
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            // Jump back to start instantly
            _scrollController.jumpTo(0);
            // Add a small pause before starting the next animation
            Future.delayed(Duration(seconds: 1), () {
              if (mounted) {
                _animationController.forward(from: 0);
              }
            });
          }
        });
      }
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _scrollController,
          physics: const NeverScrollableScrollPhysics(),
          child: Container(
            key: _keyText,
            child: Text(widget.text, style: widget.style),
          ),
        );
      },
    );
  }
}

Future<bool> _checkImageUrl(String url) async {
  try {
    final response = await Dio().head(url);
    return response.statusCode == 200;
  } catch (e) {
    log('Error checking image URL: $e');
    return false;
  }
}

Widget networkImage({
  required String image,
  required String errorImage,
  double? customHeight,
  double? customWidth,
  Color? color,
  BoxFit fit = BoxFit.contain,
}) {
  return FutureBuilder<bool>(
    future: _checkImageUrl(image),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.hasError || !snapshot.data!) {
          return assetImage(
            image: errorImage,
            color: color,
            customHeight: customHeight != null ? getHeight(customHeight) : null,
            customWidth: customWidth != null ? getWidth(customWidth) : null,
            fit: fit,
          );
        } else {
          return Image.network(
            image,
            color: color,
            height: customHeight != null ? getHeight(customHeight) : null,
            width: customWidth != null ? getWidth(customWidth) : null,
            fit: fit,
          );
        }
      } else {
        return const Center(child: CircularProgressIndicator());
      }
    },
  );
}

Widget commonHeadingWithDivider({required String text}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Expanded(
        child: Divider(color: AppColors.textColor, thickness: 1.0),
      ),
      commonPadding(
        child: textWid(
          text,
          style: AppTextStyles.textStyle(fontWeight: FontWeight.w600),
        ),
      ),
      const Expanded(
        child: Divider(color: AppColors.textColor, thickness: 1.0),
      ),
    ],
  );
}

Future<void> launchUrl(String? urlString) async {
  if (urlString == null || urlString.isEmpty) {
    commonSnackBar(message: 'Invalid document URL');
    return;
  }

  final Uri url = Uri.parse(urlString);
  if (!await canLaunchUrl(url)) {
    commonSnackBar(
      message: "Could not launch $urlString, it's not a valid URL",
    );
    return;
  }
  await launchUrl(urlString);
}

Widget studentsTabAppBar({required String title}) {
  final StudentProfileController profileController =
      Get.find<StudentProfileController>();
  return Container(
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(getWidth(30)),
        bottomRight: Radius.circular(getWidth(30)),
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.black.withOpacity(0.08),
          offset: const Offset(0, 5),
          blurRadius: 10,
        ),
      ],
    ),
    child: Obx(
      () =>
          profileController.isLoading.value
              ? const SizedBox.shrink()
              : Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: getWidth(16),
                      right: getWidth(16),
                      top: getHeight(8),
                      bottom: getHeight(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Get.toNamed(RouteNames.accountScreen),
                          child: Container(
                            width: getWidth(40),
                            height: getWidth(40),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.grey01,
                              border: Border.all(
                                color: AppColors.blueColor,
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(getWidth(20)),
                              child:
                                  profileController
                                              .studentProfile
                                              .value
                                              ?.profileImage !=
                                          null
                                      ? CachedNetworkImage(
                                        imageUrl:
                                            profileController
                                                .studentProfile
                                                .value
                                                ?.profileImage ??
                                            '',
                                        fit: BoxFit.cover,
                                        placeholder:
                                            (context, url) => const Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.blueColor,
                                              ),
                                            ),
                                        errorWidget:
                                            (context, url, error) => Icon(
                                              Icons.person,
                                              color: AppColors.blueColor,
                                              size: getWidth(24),
                                            ),
                                      )
                                      : Icon(
                                        Icons.person,
                                        color: AppColors.blueColor,
                                        size: getWidth(24),
                                      ),
                            ),
                          ),
                        ),
                        assetImage(image: AppAssets.logo, customHeight: 40),
                        GestureDetector(
                          onTap:
                              () => Get.toNamed(
                                RouteNames.notificationScreen,
                              )?.then((_) {
                                profileController.getNotificationCount();
                              }),
                          child: Icon(
                            profileController.unReadNotification.value
                                ? Icons.notification_add
                                : Icons.notifications,
                            color: AppColors.blueColor,
                            size: getWidth(28),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: getHeight(-12),
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: getWidth(20),
                          vertical: getHeight(3),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.blueColor,
                          borderRadius: BorderRadius.circular(getWidth(30)),
                        ),
                        child: textWid(
                          title,
                          style: AppTextStyles.textStyle(
                            fontSize: getWidth(18),
                            fontWeight: FontWeight.w700,
                            txtColor: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    ),
  );
}

Widget teachersTabAppBar({required String title}) {
  final TeacherProfileController profileController =
      Get.find<TeacherProfileController>();
  return Container(
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(getWidth(30)),
        bottomRight: Radius.circular(getWidth(30)),
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.black.withOpacity(0.08),
          offset: const Offset(0, 5),
          blurRadius: 10,
        ),
      ],
    ),
    child: Obx(
      () =>
          profileController.isLoading.value
              ? const SizedBox.shrink()
              : Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: getWidth(16),
                      right: getWidth(16),
                      top: getHeight(8),
                      bottom: getHeight(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap:
                              () =>
                                  Get.toNamed(RouteNames.teacherAccountScreen),
                          child: Container(
                            width: getWidth(40),
                            height: getWidth(40),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.grey01,
                              border: Border.all(
                                color: AppColors.blueColor,
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(getWidth(20)),
                              child:
                                  profileController
                                              .teacherProfile
                                              .value
                                              ?.profileImage !=
                                          null
                                      ? CachedNetworkImage(
                                        imageUrl:
                                            profileController
                                                .teacherProfile
                                                .value
                                                ?.profileImage ??
                                            '',
                                        fit: BoxFit.cover,
                                        placeholder:
                                            (context, url) => const Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.blueColor,
                                              ),
                                            ),
                                        errorWidget:
                                            (context, url, error) => Icon(
                                              Icons.person,
                                              color: AppColors.blueColor,
                                              size: getWidth(24),
                                            ),
                                      )
                                      : Icon(
                                        Icons.person,
                                        color: AppColors.blueColor,
                                        size: getWidth(24),
                                      ),
                            ),
                          ),
                        ),
                        assetImage(image: AppAssets.logo, customHeight: 40),
                        GestureDetector(
                          onTap:
                              () => Get.toNamed(
                                RouteNames.teacherNotificationScreen,
                              )?.then((_) {
                                profileController.getNotificationCount();
                              }),
                          child: Icon(
                            profileController.unReadNotification.value
                                ? Icons.notification_add
                                : Icons.notifications,
                            color: AppColors.blueColor,
                            size: getWidth(28),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: getHeight(-12),
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: getWidth(20),
                          vertical: getHeight(3),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.blueColor,
                          borderRadius: BorderRadius.circular(getWidth(30)),
                        ),
                        child: textWid(
                          title,
                          style: AppTextStyles.textStyle(
                            fontSize: getWidth(18),
                            fontWeight: FontWeight.w700,
                            txtColor: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    ),
  );
}
