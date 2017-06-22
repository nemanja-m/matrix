const initialState = {
  types:          [],
  running:        [],
  performatives:  []
}

const reduce = (state = initialState, action) => {

  switch (action.type) {

    case 'ADD_TYPES':
      return {
        ...state,
        types: [...state.types, ...action.types]
      };

    case 'ADD_RUNNING':
      return {
        ...state,
        running: [...state.running, ...action.runningAgents]
      };

    case 'START_AGENT':
      return {
        ...state,
        running: [...state.running, action.agent]
      };

    case 'STOP_AGENT':
      const running = state.running.filter(agent => agent.id.name !== action.name);

      return {
        ...state,
        running
      };

    case 'SET_PERFORMATIVES':
      return {
        ...state,
        performatives: action.performatives
      }

    default:
      return state;
  }
};

export default reduce;
