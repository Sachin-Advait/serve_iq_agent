import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:servelq_agent/models/display_token.dart';
import 'package:servelq_agent/models/token.dart';

part 'tv_display_state.dart';

class TVDisplayCubit extends Cubit<TVDisplayState> {
  TVDisplayCubit()
    : super(
        TVDisplayState(
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
          displayedTokens: [
            DisplayToken(
              counter: '1',
              token: 'A104',
              service: 'Pension Inquiry',
              agent: 'Mariam',
            ),
            DisplayToken(
              counter: '2',
              token: 'A105',
              service: 'Contribution Update',
              agent: 'Ahmed',
            ),
            DisplayToken(
              counter: '3',
              token: 'B203',
              service: 'Disability Pension',
              agent: 'Khalid',
            ),
          ],
          latestCall: [
            DisplayToken(counter: '2', token: 'A205', service: '', agent: ''),
            DisplayToken(counter: '1', token: 'A105', service: '', agent: ''),
            DisplayToken(counter: '5', token: 'A535', service: '', agent: ''),
            DisplayToken(counter: '6', token: 'A615', service: '', agent: ''),
          ],
        ),
      );

  void updateDisplayedTokens(List<DisplayToken> newTokens) {
    emit(state.copyWith(displayedTokens: newTokens));
  }

  void updateLatestCall(List<DisplayToken> latestCalls) {
    emit(state.copyWith(latestCall: latestCalls));
  }
}
