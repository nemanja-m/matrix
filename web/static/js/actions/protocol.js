import { Socket } from 'phoenix';
import { flatten, uniqueTypes } from '../helpers';

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

    channel.on('types:update', (response) => {
      const types = uniqueTypes(flatten(response));

      dispatch({ type: 'UPDATE_TYPES', types });
    });

    channel.on('running:update', (response) => {
      dispatch({ type: 'UPDATE_RUNNING', running: response.agents });
    });

    channel
      .join()
      .receive('ok', () => console.log('Connected to agents channel') );

    dispatch({ type: 'USE_WEB_SOCKETS', channel });
  };
}
