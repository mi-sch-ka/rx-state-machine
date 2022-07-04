import 'dart:async';

import 'package:rxdart/rxdart.dart';

part 'graph.dart';

part 'transition.dart';

class RxStateMachine<STATE, EVENT, SIDE_EFFECT> {
  factory RxStateMachine.create(
      BuildGraph<STATE, EVENT, SIDE_EFFECT> buildGraph) {
    final graphBuilder = GraphBuilder<STATE, EVENT, SIDE_EFFECT>();
    buildGraph(graphBuilder);
    return RxStateMachine._(graphBuilder.build());
  }

  RxStateMachine._(this._graph);

  final Graph<STATE, EVENT, SIDE_EFFECT> _graph;

  late final BehaviorSubject<STATE> _stateSubject =
      BehaviorSubject.seeded(state);
  Stream<STATE> get states => _stateSubject.stream;

  late STATE _stateReference = _graph.initialState;
  STATE get state => _stateReference;

  Transition<STATE, EVENT, SIDE_EFFECT> transition(EVENT event) {
    final fromState = _stateReference;
    final transition = _transition(fromState, event);

    _graph.onTransitionListeners.forEach((onTransition) {
      onTransition(transition);
    });

    if (transition is Valid) {
      final validTransition = transition as Valid;
      _newState(validTransition.toState);
      _notifyOnExit(validTransition.fromState, validTransition.event);
      _notifyOnEnter(validTransition.toState, validTransition.event);
    }

    return transition;
  }

  RxStateMachine<STATE, EVENT, SIDE_EFFECT> as(
      BuildGraph<STATE, EVENT, SIDE_EFFECT> buildGraph) {
    final graphBuilder = GraphBuilder<STATE, EVENT, SIDE_EFFECT>(this._graph);
    buildGraph(graphBuilder);
    return RxStateMachine._(graphBuilder.build());
  }

  void _newState(STATE state) {
    _stateReference = state;
    _stateSubject.add(state);
  }

  Transition<S, E, SIDE_EFFECT> _transition<S extends STATE, E extends EVENT>(
      S state, E event) {
    final createTransitionTo = _graph
        .stateDefinitions[state.runtimeType]?.transitions[event.runtimeType];
    if (createTransitionTo == null) {
      return Transition.invalid(state, event);
    }

    final transition = createTransitionTo(state, event);
    return Transition.valid(
      state,
      event,
      transition.toState as S,
      transition.sideEffect,
    );
  }

  void _notifyOnEnter(STATE state, EVENT cause) {
    _graph.stateDefinitions[state.runtimeType]?.onEnterListeners
        .forEach((listeners) {
      listeners.call(state, cause);
    });
  }

  void _notifyOnExit(STATE state, EVENT cause) {
    _graph.stateDefinitions[state.runtimeType]?.onExitListeners
        .forEach((listeners) {
      listeners.call(state, cause);
    });
  }
}
