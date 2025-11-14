import 'package:equatable/equatable.dart';
import 'package:xtimer/model/task_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeStateLoading extends HomeState {
  const HomeStateLoading();

  @override
  List<Object?> get props => [];

  @override
  String toString() => 'HomeStateLoading';
}

class HomeStateLoaded extends HomeState {
  final List<Task> tasks;

  const HomeStateLoaded({required this.tasks});

  @override
  List<Object?> get props => [tasks];

  @override
  String toString() => 'HomeStateLoaded';
}
