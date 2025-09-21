import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Get the proportionate height as per screen size
double getHeight(double inputHeight) {
  // 812 is the layout height that designer used
  return (inputHeight / 812.0) * Get.height;
}

// Get the proportionate height as per screen size
double getWidth(double inputWidth) {
  // 375 is the layout width that designer used
  return (inputWidth / 375.0) * Get.width;
}

sizeBoxHeight(double value) {
  return SizedBox(
    height: getHeight(value),
  );
}

sizeBoxWidth(double value) {
  return SizedBox(
    width: getHeight(value),
  );
}

double defaultPaddingH() {
  return (24 / 375.0) * Get.width;
}
