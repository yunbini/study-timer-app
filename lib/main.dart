import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xtimer/data/database.dart';
import 'package:xtimer/data/task_manager.dart';
import 'package:xtimer/pages/home_page/home_bloc.dart';
import 'package:xtimer/pages/new_task_page.dart';
import 'package:xtimer/pages/splash_page.dart';
import 'package:xtimer/pages/home_page/home_page.dart';

/// 최신 BlocObserver (BlocDelegate 대체)
class MyObserver extends BlocObserver {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }
}

void main() {
  /// Bloc Delegate (구버전) → BlocObserver (신버전)
  Bloc.observer = MyObserver();

  /// DI
  DatabaseProvider dbProvider = DatabaseProvider.db;
  TaskManager taskManager = TaskManager(dbProvider: dbProvider);
  HomeBloc homeBloc = HomeBloc(taskManager: taskManager);

  runApp(MyApp(homeBloc: homeBloc));
}

class MyApp extends StatefulWidget {
  final HomeBloc homeBloc;
  const MyApp({Key? key, required this.homeBloc}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void dispose() {
    /// bloc.dispose → bloc.close()
    widget.homeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>.value(
      value: widget.homeBloc,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),

        /// 스플래시 페이지
        home: const SplashPage(),

        routes: {
          '/home': (context) => HomePage(homeBloc: widget.homeBloc),
          '/new': (context) => const NewTaskPage(),
        },
      ),
    );
  }
}
