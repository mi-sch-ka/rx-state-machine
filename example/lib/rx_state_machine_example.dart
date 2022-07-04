import 'package:rx_state_machine/rx_state_machine.dart';

void main() {
  print("current state is: ${_stateMachine.state}");
  _stateMachine.transition(new OnClosing());
  print("current state is: ${_stateMachine.state}");
  print("try to close a closed door");
  _stateMachine.transition(new OnClosing());
  print("current state is: ${_stateMachine.state}");
  _stateMachine.transition(new OnOpening());
  print("current state is: ${_stateMachine.state}");
}

/// # Simple state machine that represents a door.
///
/// **State transition table:**
/// ```
/// | Sate / Event | Event.OnOpening | Event.OnClosing     |
/// |--------------|-----------------|-------------------|
/// | State.Open   |                 | State.Closed      |
/// | State.Closed | State.Open      |                   |
/// ```
final RxStateMachine<State, Event, Function> _stateMachine =
    RxStateMachine<State, Event, Function>.create((g) => g
      ..initialState(Open())
      ..state<Open>((b) => b
        ..on<OnClosing>((state, event) {
          return b.transitionTo(Closed());
        }))
      ..state<Closed>((b) => b
        ..on<OnOpening>((state, event) {
          return b.transitionTo(Open());
        }))
      ..onTransition((transition) {
        if (transition is Valid) {
          final item = transition as Valid;
          print(
              "Valid transition: from [${item.fromState}] to [${item.toState}] by [${item.event}]");
        } else if (transition is Invalid) {
          final item = transition as Invalid;
          print(
              "Invalid transition: from [${item.fromState}] by [${item.event}]");
        }
      }));

RxStateMachine<State, Event, Function> _givenStateIs(State state) =>
    _stateMachine.as((g) {
      g.initialState(state);
    });

abstract class State {}

class Open extends State {}

class Closed extends State {}

abstract class Event {}

class OnOpening extends Event {}

class OnClosing extends Event {}
