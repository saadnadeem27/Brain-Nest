// Brain Nest - Common Imports
// This file contains all commonly used imports across the application

// Flutter Core
export 'package:flutter/material.dart';
export 'package:flutter/services.dart';

// State Management
export 'package:get/get.dart';

// UI & Fonts
export 'package:google_fonts/google_fonts.dart';

// Utilities
export 'dart:async';
export 'dart:convert';
export 'dart:io' hide HeaderValue;
export 'dart:developer' show log;

// App Common Files
export 'common/app_colors.dart';
export 'services/static_data_service.dart';

// App Screens
export 'screens/learner/learner_dashboard.dart';
export 'screens/educator/educator_dashboard.dart';

// Controllers
export 'controllers/learner/learner_home_controller.dart';
export 'controllers/educator/educator_home_controller.dart';

// Components
export 'components/ui_components.dart';
