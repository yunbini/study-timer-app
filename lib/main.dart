import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/login_page.dart';
import 'pages/splash_page.dart';
import 'pages/home_page/home_page.dart';
import 'data/database.dart';
import 'data/task_manager.dart';
import 'pages/home_page/home_bloc.dart';
import 'data/study_time_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyObserver extends BlocObserver {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print(" Firebase initialized: ${Firebase.apps}");

  // Kakao SDK 초기화
  KakaoSdk.init(
    nativeAppKey: "660acd54e02c9c0edaa528aa7fef440e",
    javaScriptAppKey: "e27b403c714463c1aa3c49aeb0bd177a",
  );

  print("실제 앱 KeyHash: ${await KakaoSdk.origin}");

  Bloc.observer = MyObserver();

  final database = DatabaseProvider.db;
  final taskManager = TaskManager(dbProvider: database);
  final studyRepo = StudyTimeRepository(firestore: FirebaseFirestore.instance,);
  final homeBloc = HomeBloc(taskManager: taskManager, studyRepo:studyRepo,);

  runApp(MyApp(homeBloc: homeBloc));
}

class MyApp extends StatelessWidget {
  final HomeBloc homeBloc;

  const MyApp({Key? key, required this.homeBloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>.value(
      value: homeBloc,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        home: const SplashPage(),
        routes: {
          '/login': (_) => const LoginPage(),
          '/home': (_) => HomePage(homeBloc: homeBloc),
        },
      ),
    );
  }
}
