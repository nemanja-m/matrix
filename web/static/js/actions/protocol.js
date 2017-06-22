import { Socket } from 'phoenix';

export function useHttp() {
  return (dispatch) => dispatch({ type: 'USE_HTTP' });
}

export function useWebSockets() {
  return (dispatch) => {
    const socket = new Socket('/socket');
    socket.connect();

    const channel = socket.channel('agents');

    channel.on('agent:start', (response) => {
      dispatch({ type: 'START_AGENT', agent: response.agent });
    });

    channel.on('agent:stop', (response) => {
      dispatch({ type: 'STOP_AGENT', name: response.name });
    });

    channel
      .join()
      .receive('ok', () => console.log('Connected to agents channel') );

    dispatch({ type: 'USE_WEB_SOCKETS', channel });
  };
}
