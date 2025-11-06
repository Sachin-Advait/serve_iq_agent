// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'tv_display_cubit.dart';

class TVDisplayState extends Equatable {
  final List<DisplayToken> displayedTokens;
  final List<DisplayToken> latestCall;
  final List<Token> queue;

  const TVDisplayState({
    required this.displayedTokens,
    required this.latestCall,
    required this.queue,
  });

  TVDisplayState copyWith({
    List<DisplayToken>? displayedTokens,
    List<DisplayToken>? latestCall,
    List<Token>? queue,
  }) {
    return TVDisplayState(
      displayedTokens: displayedTokens ?? this.displayedTokens,
      latestCall: latestCall ?? this.latestCall,
      queue: queue ?? this.queue,
    );
  }

  @override
  List<Object?> get props => [displayedTokens, latestCall, queue];
}
