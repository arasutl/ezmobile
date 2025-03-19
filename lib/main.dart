import 'package:ez/core/CustomColors.dart';
import 'package:ez/core/v5/controllers/auth_controller.dart';
import 'package:ez/core/v5/controllers/login_controller.dart';
import 'package:ez/core/v5/controllers/session_controller.dart';
import 'package:ez/core/v5/models/popup/controllers/commentcontroller.dart';
import 'package:ez/core/v5/pages/loading.dart';
import 'package:ez/features/dynamic_form/dynamic_form.dart';
import 'package:ez/features/workflowinitiate/viewmodel/viewmodel.dart';
import 'package:ez/screens/Homepage.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// import 'package:catcher/catcher.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';

import 'core/di/injection.dart';

void initialize() {
  //SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.black87, //or set color with: Color(0xFF0000FF)
  ));
  Get.put<AuthController>(AuthController());
  Get.put<LoginController>(LoginController());
  Get.put<CommentController>(CommentController());
  // Get.put<SessionController>(SessionController());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  Get.put<SessionController>(SessionController());
  initialize();
  setupLazySingleton();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    const MyApp(),
  );
}

/*Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (await _isBiometricAvailable()) {
    await _getListOfBiometricTypes();
    await _authenticateUser();
  }

  runApp(App());
}*/

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (authController) {
      return ScreenUtilInit(
        builder: (_, child) => GetMaterialApp(
          theme: ThemeData(
              radioTheme: RadioThemeData(
                fillColor: MaterialStateProperty.all(Colors.red), // Set globally to red
              ),
              primarySwatch: Colors.red,
              fontFamily: 'Outfit',
              colorScheme: ColorScheme.fromSwatch()
                  .copyWith(secondary: Colors.red, background: Colors.white),
              dividerColor: Colors.white),
          // navigatorKey: Catcher.navigatorKey,
          title: 'EZOFIS V5',
          debugShowCheckedModeBanner: false,
          // initialRoute: '/',
          home: const Loading(),
          // getPages: AppRoutes.routes
        ),
      );
    });
  }
}
//DynamicForm(formId: 27, repositoryId: 26, workflowId: 14)
/*class Authentication {
  static Future<bool> authenticateWithBiometrics() async {
    LocalAuthentication localAuthentication = LocalAuthentication();
    bool isBiometricSupported = await localAuthentication.isDeviceSupported();
    bool canCheckBiometrics = await localAuthentication.canCheckBiometrics;

    bool isAuthenticated = false;

    if (isBiometricSupported && canCheckBiometrics) {
      isAuthenticated = await localAuthentication.authenticate(
        localizedReason: 'Please complete the biometrics to proceed.',
        //biometricOnly: true,
        stickyAuth: true,
      );
    }

    return isAuthenticated;
  }
}*/
