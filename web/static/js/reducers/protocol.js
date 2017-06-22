const initialState = {
  http: true,
  webSockets: false,
  socket: null
}

const reduce = (state = initialState, action) => {

  switch (action.type) {

    case 'USE_HTTP':
      return {
        http: true,
        webSockets: false,
        socket: null
      };

    case 'USE_WEB_SOCKETS':
      return {
        http: false,
        webSocket: true,
        socket: action.socket
      };

    default:
      return state;
  }
};

export default reduce;
