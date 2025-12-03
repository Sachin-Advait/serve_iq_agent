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

  ServiceAgentCubit(this.agentRepository) : super(ServiceAgentInitial());

  Future<void> loadInitialData() async {
    emit(ServiceAgentLoading());
    await loadingData();
  }

  Future<void> loadingData() async {
    try {
      final counterFuture = agentRepository.getCounter();
      final queueFuture = agentRepository.getQueue();
      final recentServicesFuture = agentRepository.getRecentServices();
      final allCounterFuture = agentRepository.getAllCounters();

      // Check for active token
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
        ServiceAgentLoaded(
          counter: counter,
          queue: queue,
          recentServices: recentServices,
          currentToken: activeToken, // Use active token if exists
          allCounter: allCounter,
          showReview: false,
        ),
      );
    } catch (e) {
      emit(ServiceAgentError('Failed to load data: ${e.toString()}'));
    }
  }

  Future<void> queueAPI() async {
    final currentState = state;
    if (currentState is! ServiceAgentLoaded) return;

    try {
      final queue = await agentRepository.getQueue();

      emit(
        currentState.copyWith(
          queue: queue,
          showReview: (state is ServiceAgentLoaded)
              ? (state as ServiceAgentLoaded).showReview
              : false,
        ),
      );
    } catch (e) {
      // Don't emit error for queue updates, just log
      print('Queue update failed: $e');
    }
  }

  Future<void> callNext() async {
    try {
      customLoader();

      final currentState = state;
      if (currentState is! ServiceAgentLoaded) return;

      // Call next token
      final nextToken = await agentRepository.callNext();

      // Reload queue after calling next
      final updatedQueue = await agentRepository.getQueue();

      emit(currentState.copyWith(queue: updatedQueue, currentToken: nextToken));
    } catch (e) {
      emit(ServiceAgentError(e.toString()));
      // Reload to recover state
      await loadInitialData();
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> completeService() async {
    try {
      customLoader();

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

      final activeToken = await agentRepository.counterActiveToken();
      if (activeToken == null) {
        emit(ServiceAgentLoading());
      }

      await Future.delayed(Duration(milliseconds: 500));

      emit(
        ServiceAgentLoaded(
          queue: updatedQueue,
          recentServices: updatedRecentServices,
          counter: currentState.counter,
          allCounter: currentState.allCounter,
          showReview: false,
        ),
      );

      // Show message if there's another active token
      if (activeToken != null) {
        flutterToast(message: 'Active token detected: ${activeToken.token}');
      }
    } catch (e) {
      emit(ServiceAgentError(e.toString()));
      // Reload to recover state
      await loadInitialData();
    } finally {
      EasyLoading.dismiss();
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

      // Hide review section
      hideReviewSection();

      // Now complete the service and check for active token
      await completeService();
    } catch (e) {
      emit(ServiceAgentError('Failed to submit review: ${e.toString()}'));
    }
  }

  Future<void> recallCurrentToken() async {
    try {
      customLoader();
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
        currentState.copyWith(
          queue: updatedQueue,
          recentServices: updatedRecentServices,
          currentToken: recalledToken,
        ),
      );
      flutterToast(message: 'Token successfully recalled');
    } catch (e) {
      emit(ServiceAgentError(e.toString()));
      // Reload to recover state
      await loadInitialData();
    } finally {
      EasyLoading.dismiss();
    }
  }

  void showReviewSection() {
    final currentState = state;
    if (currentState is ServiceAgentLoaded &&
        currentState.currentToken != null) {
      emit(currentState.copyWith(showReview: true));
    }
  }

  void hideReviewSection() {
    final currentState = state;
    if (currentState is ServiceAgentLoaded) {
      emit(currentState.copyWith(showReview: false));
    }
  }

  Future<void> transferService(String counterId) async {
    try {
      customLoader();

      final currentState = state;
      if (currentState is! ServiceAgentLoaded ||
          currentState.currentToken == null) {
        return;
      }

      final tokenId = currentState.currentToken!.id;

      // Transfer the service
      await agentRepository.transferService(tokenId, counterId);

      // Check for any active token after transfer
      agentRepository.counterActiveToken();

      // Reload all data
      await loadInitialData();

      flutterToast(message: 'Token successfully transferred');
    } catch (e) {
      emit(ServiceAgentError(e.toString()));
      // Reload to recover state
      await loadInitialData();
    } finally {
      EasyLoading.dismiss();
    }
  }

  // New method to check for active token manually
  Future<void> checkActiveToken() async {
    try {
      customLoader();

      final currentState = state;
      if (currentState is! ServiceAgentLoaded) return;

      final activeToken = await agentRepository.counterActiveToken();

      if (currentState.currentToken?.id != activeToken?.id) {
        // If we have a new active token different from current
        final updatedQueue = await agentRepository.getQueue();

        emit(
          currentState.copyWith(currentToken: activeToken, queue: updatedQueue),
        );
        if (activeToken != null) {
          flutterToast(message: 'Active token loaded: ${activeToken.token}');
        }
      }
    } finally {
      EasyLoading.dismiss();
    }
  }
}
