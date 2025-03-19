import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class AppRoutes {
  AppRoutes._();

  static const workflow = "workflow";
  static const categories = "categories";
  static const videos = "videos";
  static const reading = "Reading List";
  static const workflowinitiate = "workflowinitiate";
  static const dynamicForm = "dynamicForm";
  static const workflowcreate = "workflowcreate";
  static const qrscanner = "qrscanner";
  static const workflowlist = "WorkflowList";
  static const workflowRoot = "WorkflowRoot";
  static const dashboard = "Dashboard";
  // static const workflowdetail = "workflowdetails";
  static const fulldetails = 'Details';
  static const fulldetailsMyInbox = 'DetailsMyInbox';

  static const folders = 'Folders';
  static const folderssub = 'SubFolders';
  static const tasklist = "TaskList";
  static const taskcreate = "TaskCreate";
  static const viewfile = 'viewfiles';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    switch (settings.name) {
      //
      // case AppRoutes.videos:
      //   return MaterialPageRoute(builder: (_) => const ExploreScreen());
      // case AppRoutes.categories:
      //   return MaterialPageRoute(builder: (_) => const CategoriesScreen());
      // case AppRoutes.reading:
      //   return MaterialPageRoute(builder: (_) => const ReadListScreen());
      // case AppRoutes.workflow:
      //   //return MaterialPageRoute(settings: settings, builder: (_) => DynamicFormWithData()s);
      //   return MaterialPageRoute(settings: settings, builder: (_) => const Workflow());
      // // case AppRoutes.workflowinitiate:
      // //   return MaterialPageRoute(builder: (_) => const WorkflowInitiate());
      // // case AppRoutes.dynamicForm:
      // //   return MaterialPageRoute(builder: (_) => DynamicForm());
      // case AppRoutes.qrscanner:
      //   return MaterialPageRoute(builder: (_) => const QrScanner());
      // case AppRoutes.workflowRoot:
      //   return MaterialPageRoute(builder: (_) => const MyInbox());
      // // case AppRoutes.workflowlist:
      // //   return MaterialPageRoute(builder: (_) => const InboxWorkflow());
      // // case AppRoutes.workflowdetail:
      // //   return MaterialPageRoute(builder: (_) => const WorkflowDetails());
      // // case AppRoutes.fulldetails:
      // //   return MaterialPageRoute(builder: (_) => const WorkflowDetail());
      // case AppRoutes.fulldetailsMyInbox:
      //   return MaterialPageRoute(builder: (_) => PopupFullpageInboxPageMvvmMyInbox());
      // case AppRoutes.viewfile:
      //   //return MaterialPageRoute(builder: (_) => InAppWebViewPage(title: '', uri: ''));
      //   return MaterialPageRoute(builder: (_) => const ViewFile());
      // case AppRoutes.folders:
      //   return MaterialPageRoute(builder: (_) => const FolderList());
      // case AppRoutes.folderssub:
      //   return MaterialPageRoute(builder: (_) => const SubFolderList());
      // case AppRoutes.tasklist:
      //   return MaterialPageRoute(builder: (_) => const TaskListScreen());
      // case AppRoutes.taskcreate:
      //   return MaterialPageRoute(builder: (_) => const TaskCreate());

      // case AppRoutes.workflowcreate:
      //   return MaterialPageRoute(
      //       builder: (_) => WorkflowCreate(
      //             datas: settings.arguments as dynamic,
      //             isEdit: false,
      //           ));
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("error"),
        ),
        body: const Center(
          child: Text("error"),
        ),
      );
    });
  }

  static initialRouteForIndex(int index) {
    switch (index) {
      case 0:
        return AppRoutes.workflowRoot;
      case 1:
        return AppRoutes.folders;

/*      case 0:
        return AppRoutes.dashboard;
      case 2:
        return AppRoutes.folders;
      case 1:
        return AppRoutes.workflow;
      case 3:
        return AppRoutes.videos;
      case 4:
        return AppRoutes.reading;*/
    }
  }

  static push(BuildContext context, String route) {
    //Navigator.of(context).pushNamed(route);
    Navigator.pushNamed(context, route);
  }

  static pop(BuildContext context, [dynamic data]) {
    Navigator.of(context).pop(data);
  }

  static present(BuildContext context, Widget route, Function(dynamic val) onTap) {
    Navigator.of(context)
        .push(
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (context) => route,
      ),
    )
        .then((value) {
      onTap(value);
    });
  }

  static changeRoot(BuildContext context, String route) {
    Navigator.of(context).pushReplacementNamed(route);
  }

//   static final routes = [
//     GetPage(name: '/', page: () => const Loading()),
//     GetPage(name: '/noConnection', page: () => const LostConnection()),
//     GetPage(
//         name: '/loginscreen',
//         page: () => LoginPage(),
// /*         page: () => CustomRating(
//                rating: rating,
//                onRatingChanged: (rate) {
//                  setState(() {
//                    rating = rate;
//                  });
//                },
//                color: CustomColors.red,
//              ),*/
//         //page: () => LoginPage(),
//         //page: () => CustomChip(),
//         //page: () => CustomCheckbox("Label1 ", "Label2", (p0) {}, (p0) {}),
//         /*page: () => CustomLogin(
//             // page: () => CustomCheckbox("Label1 ", "Label2", (p0) {}, (p0) {}),
//             // page: () => CustomChip(),
//              page: () => CustomRating(
//             //       rating: rating,
//             //       onRatingChanged: (rate) {
//             //         setState(() {
//             //           rating = rate;
//             //         });
//             //       },
//             //       color: CustomColors.red,
//             //     ),
//             loginType: 0,
//             signInAction: (username, password) {},
//             signUpAction: () {},
//             googleAction: () {},
//             microsoftAction: () {},
//             forgotPassword: () {}),*/
//         transition: Transition.fadeIn,
//         transitionDuration: const Duration(milliseconds: 0)),
// /*    GetPage(
//         name: '/forgotpassword',
//         page: () => ForgotPasswordPage(),
//         transition: Transition.fadeIn,
//         transitionDuration: Duration(milliseconds: 500)),
//     GetPage(
//         name: '/signup',
//         page: () => SignUpPage(),
//         transition: Transition.fadeIn,
//         transitionDuration: Duration(milliseconds: 500)),
//     GetPage(
//         name: '/home',
//         page: () => DashMainScreen(),
//         transition: Transition.fadeIn,
//         transitionDuration: Duration(milliseconds: 500)),
//     GetPage(
//         name: '/workflowinbox',
//         page: () => DashMainScreen(),
//         transition: Transition.fadeIn,
//         transitionDuration: Duration(milliseconds: 500)),
//     GetPage(
//         name: '/task',
//         page: () => TaskScreenMain(),
//         transition: Transition.fadeIn,
//         transitionDuration: Duration(milliseconds: 500)),
//     GetPage(
//         name: '/folder',
//         page: () => FolderMainScreen(),
//         transition: Transition.fadeIn,
//         transitionDuration: Duration(milliseconds: 500)),
//     GetPage(
//         name: '/tasks',
//         page: () => TaskMainScreen(),
//         transition: Transition.fadeIn,
//         transitionDuration: Duration(milliseconds: 500)),
//     GetPage(
//         name: '/web',
//         page: () => WebMainScreen(),
//         transition: Transition.fadeIn,
//         transitionDuration: Duration(milliseconds: 500)),
//     GetPage(
//         name: '/otpscreen',
//         page: () => OtpMianPage(),
//         transition: Transition.fadeIn,
//         transitionDuration: Duration(milliseconds: 500)),
//     GetPage(
//         name: '/inboxpage',
//         page: () => PopupFullpageInboxPage(),
//         transition: Transition.fadeIn,
//         transitionDuration: Duration(milliseconds: 500)),
//     GetPage(
//         name: '/formview',
//         page: () => FormMain(),
//         transition: Transition.fadeIn,
//         transitionDuration: Duration(milliseconds: 500)),
//     GetPage(
//         name: '/formviewinitiate',
//         page: () => FormMainInitiate(),
//         transition: Transition.fadeIn,
//         transitionDuration: Duration(milliseconds: 500)),*/
//   ];
}
