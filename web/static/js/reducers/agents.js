const initialState = {
  types:   [],
  running: []
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

    default:
      return state;
  }
};

export default reduce;
