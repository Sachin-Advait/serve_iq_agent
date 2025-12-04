import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:servelq_agent/configs/custom_loader.dart';
import 'package:servelq_agent/configs/flutter_toast.dart';
import 'package:servelq_agent/models/counter_model.dart';
import 'package:servelq_agent/models/service_history.dart';
import 'package:servelq_agent/models/token_model.dart';
import 'package:servelq_agent/modules/service_agent/repository/agent_repo.dart';

part 'service_agent_state.dart';

class ServiceAgentCubit extends Cubit<ServiceAgentState> {
  final AgentRepository agentRepository;

  ServiceAgentCubit(this.agentRepository) : super(const ServiceAgentState());

  Future<void> loadInitialData() async {
    emit(state.copyWith(status: ServiceAgentStatus.loading));
    await loadingData();
  }

  Future<void> loadingData() async {
    try {
      final counterFuture = agentRepository.getCounter();
      final queueFuture = agentRepository.getQueue();
      final recentServicesFuture = agentRepository.getRecentServices();
      final allCounterFuture = agentRepository.getAllCounters();
      final activeTokenFuture = agentRepository.counterActiveToken();

      final results = await Future.wait([
        counterFuture,
        queueFuture,
        recentServicesFuture,
        allCounterFuture,
        activeTokenFuture,
      ]);

      final counter = results[0] as CounterModel;
      final queue = results[1] as List<TokenModel>;
      final recentServices = results[2] as List<ServiceHistory>;
      final allCounter = results[3] as List<CounterModel>;
      final activeToken = results[4] as TokenModel?;

      emit(
        ServiceAgentState(
          status: ServiceAgentStatus.loaded,
          currentTokenStatus: activeToken?.id != null
              ? CurrentTokenStatus.loaded
              : CurrentTokenStatus.initial,
          counter: counter,
          queue: queue,
          recentServices: recentServices,
          currentToken: activeToken,
          allCounter: allCounter,
          showReview: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ServiceAgentStatus.error,
          errorMessage: 'Failed to load data: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> queueAPI() async {
    if (state.status != ServiceAgentStatus.loaded) return;
    final queue = await agentRepository.getQueue();
    emit(state.copyWith(queue: queue));
  }

  Future<void> callNext() async {
    try {
      customLoader();

      final nextToken = await agentRepository.callNext();
      emit(
        state.copyWith(
          status: ServiceAgentStatus.loaded,
          currentToken: nextToken,
          currentTokenStatus: CurrentTokenStatus.loaded,
        ),
      );
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> completeService() async {
    try {
      customLoader();
      final tokenId = state.currentToken!.id;

      // Complete the current service
      await agentRepository.completeService(tokenId);
      final updatedRecentServices = await agentRepository.getRecentServices();

      emit(
        state.copyWith(
          currentTokenStatus: CurrentTokenStatus.initial,
          recentServices: updatedRecentServices,
          currentToken: TokenModel(),
          showReview: false,
        ),
      );
    } catch (e) {
      await loadInitialData();
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> submitReview(int rating, String review) async {
    try {
      // Submit feedback to API
      await agentRepository.submitFeedback(
        tokenId: state.currentToken!.id,
        counterCode: state.counter!.code,
        rating: rating,
        review: review,
      );

      // Hide review section
      hideReviewSection();

      // Now complete the service and check for active token
      await completeService();
    } catch (e) {
      emit(
        state.copyWith(
          status: ServiceAgentStatus.error,
          errorMessage: 'Failed to submit review: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> recallCurrentToken() async {
    try {
      customLoader();
      final tokenId = state.currentToken!.id;

      final recalledToken = await agentRepository.recallToken(tokenId);

      emit(state.copyWith(currentToken: recalledToken));
      flutterToast(message: 'Token successfully recalled');
    } finally {
      EasyLoading.dismiss();
    }
  }

  void showReviewSection() {
    if (state.status == ServiceAgentStatus.loaded &&
        state.currentToken != null) {
      emit(state.copyWith(showReview: true));
    }
  }

  void hideReviewSection() {
    if (state.status == ServiceAgentStatus.loaded) {
      emit(state.copyWith(showReview: false));
    }
  }

  Future<void> transferService(String counterId) async {
    try {
      customLoader();

      final tokenId = state.currentToken!.id;
      await agentRepository.transferService(tokenId, counterId);

      emit(
        state.copyWith(
          currentTokenStatus: CurrentTokenStatus.initial,
          currentToken: TokenModel(),
        ),
      );

      flutterToast(message: 'Token successfully transferred');
    } catch (e) {
      flutterToast(message: 'Error while transfering. Please try again');
    } finally {
      EasyLoading.dismiss();
    }
  }

  // New method to check for active token manually
  Future<void> checkActiveToken() async {
    try {
      customLoader();

      if (state.status != ServiceAgentStatus.loaded) return;

      final activeToken = await agentRepository.counterActiveToken();

      if (state.currentToken?.id != activeToken?.id) {
        // If we have a new active token different from current
        final updatedQueue = await agentRepository.getQueue();

        emit(state.copyWith(currentToken: activeToken, queue: updatedQueue));
        if (activeToken != null) {
          flutterToast(message: 'Active token loaded: ${activeToken.token}');
        }
      }
    } finally {
      EasyLoading.dismiss();
    }
  }
}
