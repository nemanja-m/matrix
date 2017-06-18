const initialState = [];

const reduce = (state = initialState, action) => {

  switch (action.type) {

    case 'ADD_TYPES':
      return [...state, ...action.types];

    default:
      return state;
  }
};

export default reduce;
