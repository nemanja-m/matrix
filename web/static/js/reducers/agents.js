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

    default:
      return state;
  }
};

export default reduce;
