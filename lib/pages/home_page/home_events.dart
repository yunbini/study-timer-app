import 'package:equatable/equatable.dart';
import 'package:xtimer/model/task_model.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasksEvent extends HomeEvent {
  const LoadTasksEvent();

  @override
  List<Object?> get props => [];

  @override
  String toString() => 'LoadTasksEvent';
}

class SaveTaskEvent extends HomeEvent {
  final Task task;

  const SaveTaskEvent({required this.task});

  @override
  List<Object?> get props => [task];

  @override
  String toString() => 'SaveTaskEvent';
}

class DeleteTaskEvent extends HomeEvent {
  final Task task;

  const DeleteTaskEvent({required this.task});

  @override
  List<Object?> get props => [task];

  @override
  String toString() => 'DeleteTaskEvent';
}
