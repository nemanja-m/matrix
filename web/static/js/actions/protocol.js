import { Socket } from 'phoenix';

export function useHttp() {
  return (dispatch) => dispatch({ type: 'USE_HTTP' });
}

export function useWebSockets() {
  return (dispatch) => {

    const socket = new Socket('/socket');
    socket.connect();

    dispatch({ type: 'USE_WEB_SOCKETS', socket });
  };
}
