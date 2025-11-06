import 'package:bloc/bloc.dart';
import 'package:servelq_agent/models/service_history.dart';
import 'package:servelq_agent/models/token.dart';

part 'service_agent_state.dart';

class ServiceAgentCubit extends Cubit<ServiceAgent> {
  ServiceAgentCubit()
    : super(
        ServiceAgent(
          queue: [
            Token(
              id: 'A106',
              visitor: 'Ahmed Al Balushi',
              service: 'Pension Inquiry',
              waitTime: '05:20',
              type: 'appointment',
            ),
            Token(
              id: 'A107',
              visitor: 'Sara Al Rashdi',
              service: 'Contribution Update',
              waitTime: '06:45',
              type: 'walkin',
            ),
            Token(
              id: 'B201',
              visitor: 'Mohammed Al Habsi',
              service: 'Disability Pension',
              waitTime: '08:10',
              type: 'walkin',
            ),
          ],
          history: [
            ServiceHistory(
              token: 'A104',
              visitor: 'Khalid Ahmed',
              service: 'Pension Renewal',
              time: '04:30',
              rating: 5,
            ),
            ServiceHistory(
              token: 'A103',
              visitor: 'Aisha Said',
              service: 'Certificate Request',
              time: '03:15',
              rating: 4,
            ),
          ],
        ),
      );

  void callNext() {
    // Complete current token if exists
    if (state.currentToken != null) {
      final completedHistory = ServiceHistory(
        token: state.currentToken!.id,
        visitor: state.currentToken!.visitor,
        service: state.currentToken!.service,
        time: state.currentToken!.waitTime,
        rating: 5, // Default rating
      );

      final updatedHistory = [completedHistory, ...state.history];
      if (updatedHistory.length > 10) {
        updatedHistory.removeLast();
      }

      // Call next token
      if (state.queue.isNotEmpty) {
        final nextToken = state.queue.first;
        final updatedQueue = List<Token>.from(state.queue)..removeAt(0);

        emit(
          state.copyWith(
            currentToken: nextToken,
            queue: updatedQueue,
            history: updatedHistory,
          ),
        );
      } else {
        // No more tokens in queue
        emit(state.copyWith(currentToken: null, history: updatedHistory));
      }
    } else {
      // No current token, just get the next one
      if (state.queue.isNotEmpty) {
        final nextToken = state.queue.first;
        final updatedQueue = List<Token>.from(state.queue)..removeAt(0);

        emit(state.copyWith(currentToken: nextToken, queue: updatedQueue));
      }
    }
  }

  void togglePause() {
    emit(state.copyWith(isPaused: !state.isPaused));
  }
}
