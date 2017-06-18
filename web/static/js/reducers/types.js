const initialState = [];

const reduce = (state = initialState, action) => {

  switch (action.type) {

    case 'ADD_TYPE':
      return [...state, action.type];

    default:
      return state;
  }
};

export default reduce;
