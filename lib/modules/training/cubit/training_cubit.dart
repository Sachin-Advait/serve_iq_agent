import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servelq_agent/common/constants/api_constants.dart';
import 'package:servelq_agent/common/utils/get_it.dart';
import 'package:servelq_agent/models/training_model.dart';
import 'package:servelq_agent/services/api_client.dart';
import 'package:servelq_agent/services/session_manager.dart';

part 'training_state.dart';

class TrainingCubit extends Cubit<TrainingState> {
  final ApiClient apiClient = getIt<ApiClient>();

  TrainingCubit() : super(TrainingInitial());

  /// Keep original list for filters
  List<TrainingAssignment> _allTrainings = [];

  Future<void> loadTrainings() async {
    emit(TrainingLoading());
    final response = await apiClient.getApi(
      '${ApiConstants.training}${SessionManager.getUserId()}/details',
    );

    if (response != null && response.statusCode == 200) {
      final resposneData = TrainingModel.fromJson(response.data!);
      _allTrainings = resposneData.data!;

      emit(TrainingLoaded(_allTrainings));
    } else {
      emit(TrainingError('Failed to load training materials'));
    }
  }

  void filterByType(String type) {
    if (type == "all") {
      emit(TrainingLoaded(_allTrainings));
    } else {
      emit(TrainingLoaded(_allTrainings.where((e) => e.type == type).toList()));
    }
  }

  Future<void> updateTrainingProgess(String trainingId, int progress) async {
    await apiClient.postApi(
      ApiConstants.trainingProgess,
      body: {trainingId, progress},
    );
  }
}
