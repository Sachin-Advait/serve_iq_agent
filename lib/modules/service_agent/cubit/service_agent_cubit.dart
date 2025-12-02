import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:servelq_agent/configs/flutter_toast.dart';
import 'package:servelq_agent/models/counter_model.dart';
import 'package:servelq_agent/models/service_history.dart';
import 'package:servelq_agent/models/token_model.dart';
import 'package:servelq_agent/modules/service_agent/repository/agent_repo.dart';

part 'service_agent_state.dart';

class ServiceAgentCubit extends Cubit<ServiceAgentState> {
  final AgentRepository agentRepository;

  ServiceAgentCubit(this.agentRepository) : super(ServiceAgentInitial());

  Future<void> loadInitialData() async {
    emit(ServiceAgentLoading());

    loadingData();
  }

  Future<void> loadingData() async {
    final counterFuture = agentRepository.getCounter();
    final queueFuture = agentRepository.getQueue();
    final recentServicesFuture = agentRepository.getRecentServices();
    final allCounterFuture = agentRepository.getAllCounters();

    final results = await Future.wait([
      counterFuture,
      queueFuture,
      recentServicesFuture,
      allCounterFuture,
    ]);

    final counter = results[0] as CounterModel;
    final queue = results[1] as List<TokenModel>;
    final recentServices = results[2] as List<ServiceHistory>;
    final allCounter = results[3] as List<CounterModel>;

    emit(
      ServiceAgentLoaded(
        counter: counter,
        queue: queue,
        recentServices: recentServices,
        currentToken: null,
        allCounter: allCounter,
        showReview: false,
      ),
    );
  }

  Future<void> queueAPI() async {
    final queue = await agentRepository.getQueue();
    final currentState = state;
    if (currentState is! ServiceAgentLoaded) return;

    emit(
      ServiceAgentLoaded(
        counter: currentState.counter,
        queue: queue,
        recentServices: currentState.recentServices,
        currentToken: currentState.currentToken,
        allCounter: currentState.allCounter,
        showReview: (state is ServiceAgentLoaded)
            ? (state as ServiceAgentLoaded).showReview
            : false,
      ),
    );
  }

  Future<void> callNext() async {
    try {
      final currentState = state;
      if (currentState is! ServiceAgentLoaded) return;

      // Call next token
      final nextToken = await agentRepository.callNext();

      // Reload queue after calling next
      final updatedQueue = await agentRepository.getQueue();

      emit(
        ServiceAgentLoaded(
          counter: currentState.counter,
          queue: updatedQueue,
          recentServices: currentState.recentServices,
          currentToken: nextToken,
          allCounter: currentState.allCounter,
          showReview: (state is ServiceAgentLoaded)
              ? (state as ServiceAgentLoaded).showReview
              : false,
        ),
      );
    } catch (e) {
      emit(ServiceAgentError(e.toString()));
      // Reload to recover state
      loadInitialData();
    }
  }

  Future<void> completeService() async {
    try {
      final currentState = state;
      if (currentState is! ServiceAgentLoaded ||
          currentState.currentToken == null) {
        return;
      }

      final tokenId = currentState.currentToken!.id;

      // Complete the current service
      await agentRepository.completeService(tokenId);

      // Reload queue and recent services
      final updatedQueue = await agentRepository.getQueue();
      final updatedRecentServices = await agentRepository.getRecentServices();

      emit(
        ServiceAgentLoaded(
          counter: currentState.counter,
          queue: updatedQueue,
          recentServices: updatedRecentServices,
          currentToken: null,
          allCounter: currentState.allCounter,
          showReview: (state is ServiceAgentLoaded)
              ? (state as ServiceAgentLoaded).showReview
              : false,
        ),
      );
    } catch (e) {
      emit(ServiceAgentError(e.toString()));
      // Reload to recover state
      loadInitialData();
    }
  }

  Future<void> recallCurrentToken() async {
    try {
      final currentState = state;
      if (currentState is! ServiceAgentLoaded ||
          currentState.currentToken == null) {
        return;
      }

      final tokenId = currentState.currentToken!.id;

      // Call the recall API from repository
      final recalledToken = await agentRepository.recallToken(tokenId);

      // Reload queue and recent services
      final updatedQueue = await agentRepository.getQueue();
      final updatedRecentServices = await agentRepository.getRecentServices();

      emit(
        ServiceAgentLoaded(
          counter: currentState.counter,
          queue: updatedQueue,
          recentServices: updatedRecentServices,
          currentToken: recalledToken,
          allCounter: currentState.allCounter,
          showReview: (state is ServiceAgentLoaded)
              ? (state as ServiceAgentLoaded).showReview
              : false,
        ),
      );
    } catch (e) {
      emit(ServiceAgentError(e.toString()));
      // Reload to recover state
      loadInitialData();
    }
  }

  Future<void> refreshData() async {
    await loadingData();
  }

  // Add these methods to ServiceAgentCubit class:

  void showReviewSection() {
    final currentState = state;
    if (currentState is ServiceAgentLoaded) {
      emit(currentState.copyWith(showReview: true));
    }
  }

  void hideReviewSection() {
    final currentState = state;
    if (currentState is ServiceAgentLoaded) {
      emit(currentState.copyWith(showReview: false));
    }
  }

  Future<void> submitReview(int rating, String review) async {
    try {
      final currentState = state;
      if (currentState is! ServiceAgentLoaded ||
          currentState.currentToken == null) {
        return;
      }

      // Submit feedback to API
      await agentRepository.submitFeedback(
        tokenId: currentState.currentToken!.id,
        counterCode: currentState.counter.code,
        rating: rating,
        review: review,
      );

      // Hide review section and complete service
      hideReviewSection();
      await completeService();
    } catch (e) {
      emit(ServiceAgentError('Failed to submit review: ${e.toString()}'));
    }
  }

  Future<void> transferService(String counterId) async {
    try {
      final currentState = state;
      if (currentState is! ServiceAgentLoaded ||
          currentState.currentToken == null) {
        return;
      }

      final tokenId = currentState.currentToken!.id;

      // Complete the current service
      await agentRepository.transferService(tokenId, counterId);
      flutterToast(message: 'Token successfully recalled');
      loadInitialData();
    } catch (e) {
      emit(ServiceAgentError(e.toString()));
      // Reload to recover state
      loadInitialData();
    }
  }
}
