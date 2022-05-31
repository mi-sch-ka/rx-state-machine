part of 'rx_state_machine.dart';

abstract class Transition<STATE, EVENT, SIDE_EFFECT> {
  Transition._();

  factory Transition.valid(STATE fromState, EVENT event, STATE toState, SIDE_EFFECT? sideEffect) =>
      Valid(fromState, event, toState, sideEffect);

  factory Transition.invalid(STATE state, EVENT event) => Invalid(state, event);
}

class Valid<STATE, EVENT, SIDE_EFFECT> extends Transition<STATE, EVENT, SIDE_EFFECT> {
  Valid(this.fromState, this.event, this.toState, this.sideEffect) : super._();

  final STATE fromState;
  final EVENT event;
  final STATE toState;
  final SIDE_EFFECT? sideEffect;
}

class Invalid<STATE, EVENT, SIDE_EFFECT> extends Transition<STATE, EVENT, SIDE_EFFECT> {
  Invalid(this.fromState, this.event) : super._();

  final STATE fromState;
  final EVENT event;
}
