const initialState = {
  show: false,
  type: {}
}

const reduce = (state = initialState, action) => {

  switch (action.type) {

    case 'SHOW_MODAL':
      return {
        type: action.agentType,
        show: true
      };

    case 'HIDE_MODAL':
      return initialState;

    default:
      return state;
  }
};

export default reduce;
