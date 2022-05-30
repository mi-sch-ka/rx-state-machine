part of 'rx_state_machine.dart';

class Graph<STATE, EVENT, SIDE_EFFECT> {
  Graph(this.initialState, this.finishStates, this.stateDefinitions, this.onTransitionListeners);

  final STATE initialState;
  final Set<STATE>? finishStates;
  final Map<Type, _State<STATE, EVENT, SIDE_EFFECT>> stateDefinitions;
  final List<TransitionListener<STATE, EVENT, SIDE_EFFECT>> onTransitionListeners;
}

class _State<STATE, EVENT, SIDE_EFFECT> {
  _State();

  final Map<Type, TransitionTo<STATE, SIDE_EFFECT> Function(STATE, EVENT)> transitions = {};
  final List<Function(STATE, EVENT)> onEnterListeners = [];
  final List<Function(STATE, EVENT)> onExitListeners = [];
}

class TransitionTo<STATE, SIDE_EFFECT> {
  TransitionTo._(this.toState, [this.sideEffect]);

  final STATE toState;
  final SIDE_EFFECT? sideEffect;
}

class GraphBuilder<STATE, EVENT, SIDE_EFFECT> {
  GraphBuilder([this._graph]);

  final Graph<STATE, EVENT, SIDE_EFFECT>? _graph;

  late STATE? _initialState = _graph?.initialState;
  late Set<STATE>? _finishStates = _graph?.finishStates;
  late final Map<Type, _State<STATE, EVENT, SIDE_EFFECT>> _stateDefinitions =  _graph?.stateDefinitions ?? {};
  late List<TransitionListener<STATE, EVENT, SIDE_EFFECT>> _onTransitionListeners = _graph?.onTransitionListeners ?? [];

  void initialState(STATE state) => _initialState = state;

  void finishStates(Set<STATE> states) => _finishStates = states;

  /// Adds state definition.
  void state<S extends STATE>(BuildState<S, STATE, EVENT, SIDE_EFFECT> buildState) {
    final builder = StateDefinitionBuilder<S, STATE, EVENT, SIDE_EFFECT>();
    buildState(builder);
    final definition = builder.build();
    _stateDefinitions[S] = definition;
  }

  /// Sets [listener] that will be called on each transition.
  void onTransition(TransitionListener<STATE, EVENT, SIDE_EFFECT> listener) => _onTransitionListeners.add(listener);

  Graph<STATE, EVENT, SIDE_EFFECT> build() =>
      Graph(_initialState!, _finishStates, _stateDefinitions, _onTransitionListeners);
}

class StateDefinitionBuilder<S extends STATE, STATE, EVENT, SIDE_EFFECT> {
  final _State<STATE, EVENT, SIDE_EFFECT> _stateDefinition = _State();

  void on<E extends EVENT>(CreateTransitionTo<S, STATE, E, EVENT, SIDE_EFFECT> createTransitionTo) {
    _stateDefinition.transitions[E] = (STATE state, EVENT event) => createTransitionTo(state as S, event as E);
  }

  void onEnter(void Function(S, EVENT) doOnEnter) {
    _stateDefinition.onEnterListeners.add((STATE state, EVENT cause) => doOnEnter.call(state as S, cause));
  }

  void onExit(void Function(S, EVENT) doOnEnter) {
    _stateDefinition.onExitListeners.add((STATE state, EVENT cause) => doOnEnter.call(state as S, cause));
  }

  TransitionTo<STATE, SIDE_EFFECT> transitionTo(
    STATE toState, [
    SIDE_EFFECT? sideEffect,
  ]) => TransitionTo._(toState, sideEffect);

  _State<STATE, EVENT, SIDE_EFFECT> build() => _stateDefinition;
}

typedef CreateTransitionTo<S extends STATE, STATE, E extends EVENT, EVENT, SIDE_EFFECT>
    = TransitionTo<STATE, SIDE_EFFECT> Function(S s, E e);

typedef BuildState<S extends STATE, STATE, EVENT, SIDE_EFFECT> = Function(
    StateDefinitionBuilder<S, STATE, EVENT, SIDE_EFFECT>);

typedef BuildGraph<STATE, EVENT, SIDE_EFFECT> = void Function(GraphBuilder<STATE, EVENT, SIDE_EFFECT>);

typedef TransitionListener<STATE, EVENT, SIDE_EFFECT> = void Function(Transition<STATE, EVENT, SIDE_EFFECT>);

typedef VoidCallback<T> = void Function(T);
