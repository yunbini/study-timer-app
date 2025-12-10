import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xtimer/data/task_manager.dart';
import 'package:xtimer/pages/home_page/home_events.dart';
import 'package:xtimer/pages/home_page/home_state.dart';
import 'package:xtimer/data/study_time_repository.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final TaskManager taskManager;
  final StudyTimeRepository studyRepo;

  HomeBloc({required this.taskManager}) : super(HomeStateLoading()) {
    /// Event → Handler 등록
    on<LoadTasksEvent>(_onLoadTasks);
    on<SaveTaskEvent>(_onSaveTask);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<SaveStudyTimeEvent>(_onSaveStudyTime);
  }

  /// 처리: LoadTasksEvent
  Future<void> _onLoadTasks(
      LoadTasksEvent event, Emitter<HomeState> emit) async {
    emit(HomeStateLoading());
    final data = await taskManager.loadAllTasks();
    emit(HomeStateLoaded(tasks: data));
  }

  /// 처리: SaveTaskEvent
  Future<void> _onSaveTask(
      SaveTaskEvent event, Emitter<HomeState> emit) async {
    emit(HomeStateLoading());
    await taskManager.addNewTask(event.task);

    /// dispatch → add
    add(LoadTasksEvent());
  }

  /// 처리: DeleteTaskEvent
  Future<void> _onDeleteTask(
      DeleteTaskEvent event, Emitter<HomeState> emit) async {
    await taskManager.deleteTask(event.task);

    /// 삭제 후 리스트 다시 로드
    add(LoadTasksEvent());
  }

  /// 처리: SaveStudyTimeEvent
  Future<void> _onSaveStudyTime(
      SaveStudyTimeEvent event, Emitter<HomeState> emit) async {
    await studyRepo.addStudyTime(event.seconds);
    emit(HomeStateStudyTimeSaved());
  }
}
