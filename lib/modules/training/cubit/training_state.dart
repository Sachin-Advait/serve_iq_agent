part of 'training_cubit.dart';

abstract class TrainingState {}

class TrainingInitial extends TrainingState {}

class TrainingLoading extends TrainingState {}

class TrainingLoaded extends TrainingState {
  final List<TrainingAssignment> trainings;
  TrainingLoaded(this.trainings);
}

class TrainingError extends TrainingState {
  final String message;
  TrainingError(this.message);
}
