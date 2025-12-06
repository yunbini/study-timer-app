import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xtimer/pages/home_page/home_bloc.dart';
import 'package:xtimer/pages/home_page/home_events.dart';
import 'package:xtimer/pages/home_page/home_state.dart';
import 'package:xtimer/widgets/task_widget.dart';
import 'package:xtimer/pages/new_task_page.dart';
import 'package:xtimer/model/task_model.dart';
import 'package:xtimer/services/logout_service.dart';

class HomePage extends StatefulWidget {
  final String title = 'Task Timer';
  final HomeBloc homeBloc;

  const HomePage({Key? key, required this.homeBloc}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeBloc get _homeBloc => widget.homeBloc;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _openBottomSheet() async {
    final newTask = await showModalBottomSheet<Task>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: NewTaskPage(),
              ),
            );
          },
        );
      },
    );

    if (newTask != null) {
      _homeBloc.add(SaveTaskEvent(task: newTask));
    }
  }

  @override
  void initState() {
    super.initState();
    _homeBloc.add(const LoadTasksEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: false,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
          ),
        ),

        // 로그아웃 버튼
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await LogoutService.signOutAll();

              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          )
        ],
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add, size: 26, color: Colors.black),
        backgroundColor: Colors.white,
        onPressed: _openBottomSheet,
      ),

      body: BlocBuilder<HomeBloc, HomeState>(
        bloc: _homeBloc,
        builder: (BuildContext context, HomeState state) {
          if (state is HomeStateLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HomeStateLoaded) {
            final List<Task> tasks = state.tasks;

            if (tasks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const <Widget>[
                    Text(
                      'No Tasks',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add a new Task and it\nwill show up here.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: tasks.length,
              padding: const EdgeInsets.only(top: 8),
              itemBuilder: (BuildContext context, int index) {
                final Task item = tasks[index];

                return Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  child: Dismissible(
                    background: Container(color: Colors.red),
                    direction: DismissDirection.endToStart,
                    key: ObjectKey(item),
                    child: TaskWidget(task: item),
                    onDismissed: (direction) {
                      _homeBloc.add(DeleteTaskEvent(task: item));

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Task Deleted")),
                      );
                    },
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
