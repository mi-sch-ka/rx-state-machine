import 'dart:developer';

import 'package:flutter_test/flutter_test.dart';
import 'package:rx_state_machine/rx_state_machine.dart';

abstract class State {}

class Open extends State {}
class Closed extends State {}

abstract class Event {}

class OnOpening extends Event {}
class OnClosing extends Event {}

void main() {

  /**
   * # Simple state machine that represents a door.
   *
   * **State transition table:**
   * ```
   * | Sate / Event | Event.OnOpening | Event.Closing     |
   * |--------------|-----------------|-------------------|
   * | State.Open   |                 | State.Closed      |
   * | State.Closed | State.Open      |                   |
   * ```
   */
  RxStateMachine<State, Event, Function> _stateMachine = RxStateMachine<State, Event, Function>.create((g) => g
    ..initialState(Open())
    ..state<Open>((b) => b
      ..on<OnClosing>((state, event) {
        return b.transitionTo(Closed());
      }))
    ..state<Closed>((b) => b
      ..on<OnOpening>((state, event) {
        return b.transitionTo(Open());
      })
    )
    ..onTransition((transition) {
      if(transition is Valid) {
        final item = transition as Valid;
        log("Valid transition: from [${item.fromState}] to [${item.toState}] by [${item.event}]");
      } else if(transition is Invalid) {
        final item = transition as Invalid;
        log("Invalid transition: from [${item.fromState}] by [${item.event}]");
      }
    })
  );

  RxStateMachine<State, Event, Function> _givenStateIs(State state) =>  _stateMachine.as((g) {g.initialState(state);});

  test('state is open and on closing should transition to closed state', () {
    // Given
    final machine = _givenStateIs(Open());
    // When
    final transition = machine.transition(OnClosing());
    // Then
    expect(transition, isA<Valid>());
    expect(machine.state, isA<Closed>());
  });

  test('state is closes and on opening should transition to open state', () {
    // Given
    final machine = _givenStateIs(Closed());
    // When
    final transition = machine.transition(OnOpening());
    // Then
    expect(transition, isA<Valid>());
    expect(machine.state, isA<Open>());
  });
}
