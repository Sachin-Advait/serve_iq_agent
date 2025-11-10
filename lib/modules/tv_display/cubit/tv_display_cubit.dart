import 'package:bloc/bloc.dart';
import 'package:servelq_agent/models/display_token.dart';
import 'package:servelq_agent/modules/tv_display/repo/tv_repo.dart';

part 'tv_display_state.dart';

class TVDisplayCubit extends Cubit<TVDisplayState> {
  final TVDisplayRepository tvDisplayRepository;

  TVDisplayCubit(this.tvDisplayRepository) : super(TVDisplayInitial());

  Future<void> loadDisplayData(String branchId) async {
    // try {
    emit(TVDisplayLoading());

    final displayData = await tvDisplayRepository.getDisplayData(branchId);

    emit(
      TVDisplayLoaded(
        latestCalls: displayData.latestCalls,
        nowServing: displayData.nowServing,
        upcomingTokens: displayData.upcomingTokens,
        branchName: displayData.branchName,
      ),
    );
    // } catch (e) {
    //   emit(TVDisplayError(e.toString()));
    // }
  }

  Future<void> refreshData(String branchId) async {
    await loadDisplayData(branchId);
  }
}
