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
