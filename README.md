<img src="https://github.com/mi-sch-ka/rx-state-machine/blob/main/.github/thumbnail.png?raw=true"/>
    
[![Pub](https://img.shields.io/pub/v/rx_state_machine.svg)](https://pub.dartlang.org/packages/rx_state_machine)

A library for finite state machine realization in Dart. Inspired by [Tinder StateMachine library](https://github.com/Tinder/StateMachine).

# How to use

Define states, events and side effects:

```dart

abstract class State {}
class Open extends State {}
class Closed extends State {}


abstract class Event {}
class OnOpening extends Event {}
class OnClosing extends Event {}


abstract class SideEffect {
  void call(State state, Event event);
}

class MakeSomeNoise extends SideEffect {
  @override
  void call(State state, Event event) => print("Ka-chunk-creeeeeeak-squeekie-squeekie");
}
```

Initialize state machine and declare state transitions:

```dart
final RxStateMachine<State, Event, SideEffect> _stateMachine =
    RxStateMachine<State, Event, SideEffect>.create((g) => g
      ..initialState(Open())
      ..state<Open>((b) => b
        ..on<OnClosing>((state, event) {
          return b.transitionTo(Closed(), MakeSomeNoise());
        }))
      ..state<Closed>((b) => b
        ..on<OnOpening>((state, event) {
          return b.transitionTo(Open(), MakeSomeNoise());
        }))
      ..onTransition((transition) {
        if (transition is Valid) {
          final item = transition as Valid;
          print("Valid transition: from [${item.fromState}] to [${item.toState}] by [${item.event}]");
          if(item.sideEffect is SideEffect) {
            item.sideEffect(item.toState, item.event);
          }
        } else if (transition is Invalid) {
          final item = transition as Invalid;
          print("Invalid transition: from [${item.fromState}] by [${item.event}]");
        }
      })
);
```

Observe the machine and react to changes.

```dart
_stateMachine.states.listen((state) {
    if(state is Open && !_security.authenticated()) {
      _security.alarm();
    }
  });
```

Perform state transitions:

```dart
  _stateMachine.transition(new OnClosing());
  //...
  _stateMachine.transition(new OnOpening());
```



