const initialState = {
  http: true,
  webSockets: false,
  channel: null
}

const reduce = (state = initialState, action) => {

  switch (action.type) {

    case 'USE_HTTP':
      return {
        http: true,
        webSockets: false,
        channel: null
      };

    case 'USE_WEB_SOCKETS':
      return {
        http: false,
        webSocket: true,
        channel: action.channel
      };

    default:
      return state;
  }
};

export default reduce;
