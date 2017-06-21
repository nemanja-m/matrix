const initialState = {
  show: false,
  title: "Start agent"
}

const reduce = (state = initialState, action) => {

  switch (action.type) {

    case 'SHOW_MODAL':
      return {
        title: action.title,
        show: true
      };

    case 'HIDE_MODAL':
      return initialState;

    default:
      return state;
  }
};

export default reduce;
