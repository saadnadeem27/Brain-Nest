import 'package:brain_nest/common/assets.dart';
import 'package:brain_nest/common/common_widgets.dart';
import 'package:brain_nest/common/size_config.dart';
import 'package:brain_nest/common/text_style.dart';
import 'package:brain_nest/common_imports.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';

class Webview extends StatefulWidget {
  const Webview({Key? key}) : super(key: key);

  @override
  State<Webview> createState() => _WebviewState();
}

class _WebviewState extends State<Webview> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  double progress = 0;
  String currentUrl = '';
  bool isLoading = true;
  RxInt selectedWebsiteIndex = 0.obs;

  final List<Map<String, String>> websites = [
    {'name': 'Bard AI', 'url': 'https://bard.google.com/'},
    {'name': 'ChatGPT', 'url': 'https://chat.openai.com/'},
    {'name': 'Perplexity AI', 'url': 'https://www.perplexity.ai/'},
    {
      'name': 'Bing AI',
      'url': 'https://www.bing.com/search?q=Bing+AI&showconv=1',
    },
  ];

  String get initialUrl {
    return websites[0]['url'] ?? 'https://www.google.com/';
  }

  void navigateToWebsite(int index) {
    if (index >= 0 && index < websites.length) {
      final selectedUrl = websites[index]['url'] ?? 'https://www.google.co.in/';
      webViewController?.loadUrl(
        urlRequest: URLRequest(url: WebUri(selectedUrl)),
      );
    }
  }

  // Add this method to enable clipboard access via JavaScript
  Future<void> _enableClipboardFeatures(
    InAppWebViewController controller,
  ) async {
    // JavaScript to enable clipboard paste
    await controller.evaluateJavascript(
      source: '''
      // This helps with clipboard access in some browsers
      document.addEventListener('click', function() {
        // Add focus listeners to input elements
        var inputs = document.querySelectorAll('input, textarea');
        inputs.forEach(function(input) {
          if (!input.hasAttribute('data-clipboard-handler')) {
            input.setAttribute('data-clipboard-handler', 'true');
            
            // Add context menu event listener
            input.addEventListener('contextmenu', function(e) {
              // This helps trigger the native paste menu on some platforms
              console.log('Context menu opened on input');
            });
            
            // Add focus listener
            input.addEventListener('focus', function() {
              console.log('Input focused');
            });
          }
        });
      });
    ''',
    );
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(top: getHeight(70)),
              child: Column(
                children: [
                  progress < 1.0
                      ? LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.blueColor,
                        ),
                      )
                      : const SizedBox(),

                  Expanded(
                    child: InAppWebView(
                      key: webViewKey,

                      initialUrlRequest: URLRequest(url: WebUri(initialUrl)),
                      gestureRecognizers: {
                        Factory<LongPressGestureRecognizer>(
                          () => LongPressGestureRecognizer(),
                        ),
                        Factory<TapGestureRecognizer>(
                          () => TapGestureRecognizer(),
                        ),
                        Factory<VerticalDragGestureRecognizer>(
                          () => VerticalDragGestureRecognizer(),
                        ),
                      },
                      initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                          useShouldOverrideUrlLoading: true,
                          mediaPlaybackRequiresUserGesture: false,
                          // Add these settings for clipboard functionality
                          javaScriptEnabled: true,
                          javaScriptCanOpenWindowsAutomatically: true,
                          supportZoom:
                              false, // Prevent zoom to improve text selection
                          transparentBackground: true,
                          disableContextMenu:
                              false, // Allow context menu for paste
                          // supportMultipleWindows: true,
                          verticalScrollBarEnabled: true,
                          horizontalScrollBarEnabled: true,
                          disableHorizontalScroll: false,
                          disableVerticalScroll: false,
                          applicationNameForUserAgent:
                              "VADAI App WebView", // Custom User-Agent
                        ),
                        android: AndroidInAppWebViewOptions(
                          useHybridComposition: true,
                          supportMultipleWindows: true,
                          builtInZoomControls: false,
                          displayZoomControls: false,
                          // forceDark: AndroidForceDark.OFF,
                          // Enable clipboard in Android webview
                          allowContentAccess: true,
                          allowFileAccess: true,
                        ),
                        ios: IOSInAppWebViewOptions(
                          allowsBackForwardNavigationGestures: true,
                          allowsLinkPreview: true,
                          // Enable clipboard in iOS webview
                          isFraudulentWebsiteWarningEnabled: false,
                          allowsInlineMediaPlayback: true,
                        ),
                      ),
                      onWebViewCreated: (controller) {
                        webViewController = controller;
                        _enableClipboardFeatures(controller);
                      },
                      onProgressChanged: (controller, progress) {
                        setState(() {
                          this.progress = progress / 100;
                        });
                      },
                      onLoadStart: (controller, url) {
                        setState(() {
                          isLoading = true;
                          currentUrl = url?.host ?? '';
                        });
                      },
                      onLoadStop: (controller, url) {
                        setState(() {
                          isLoading = false;
                        });
                      },
                      shouldOverrideUrlLoading: (
                        controller,
                        navigationAction,
                      ) async {
                        final uri = navigationAction.request.url;
                        if (uri != null) {
                          return NavigationActionPolicy.ALLOW;
                        }
                        return NavigationActionPolicy.ALLOW;
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
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
              child: Stack(
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
                        IconButton(
                          onPressed: Get.back,
                          icon: Icon(Icons.arrow_back),
                        ),
                        assetImage(image: AppAssets.logo, customHeight: 40),
                        // Obx(() =>
                        // ),
                        SizedBox(width: getWidth(40)),
                        // _buildWebsiteSelector(),
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
                          'AI',
                          style: AppTextStyles.textStyle(
                            fontSize: getWidth(18),
                            fontWeight: FontWeight.w700,
                            txtColor: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: getWidth(16),
                    bottom: getHeight(21),
                    child: _buildWebsiteSelector(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      context: context,
    );
  }

  Widget _buildWebsiteSelector() {
    return Builder(
      builder: (context) {
        return GestureDetector(
          onTap: () {
            showDynamicMenuStatus(
              context: context,
              selectedStatusIndex: selectedWebsiteIndex.value,
              list: websites.map((website) => website['name'] ?? '').toList(),
              onItemSelected: (index) {
                if (isLoading) return;
                navigateToWebsite(index);
                selectedWebsiteIndex.value = index;
              },
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: getWidth(10),
              vertical: getHeight(4),
            ),
            decoration: BoxDecoration(
              color: AppColors.blueColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  textWid(
                    websites[selectedWebsiteIndex.value]['name'] ?? '',
                    style: AppTextStyles.textStyle(
                      txtColor: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_outlined,
                    color: AppColors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
