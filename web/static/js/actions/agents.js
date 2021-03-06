import api from '../api';
import { SubmissionError  } from 'redux-form'
import { flatten, uniqueTypes } from '../helpers';

export function getAgentTypes() {
  return (dispatch) => {
    api
      .get('/agents/classes')
      .then(response => {
        const types = uniqueTypes(flatten(response.data));

        dispatch({ type: 'ADD_TYPES', types })
      });
  };
}

export function getRunningAgents() {
  return (dispatch) => {
    api
      .get('/agents/running')
      .then(response =>
        dispatch({ type: 'ADD_RUNNING', runningAgents: flatten(response.data) })
      );
  };
}

export function getPerformatives() {
  return (dispatch) => {
    api
      .get('/messages')
      .then(response =>
        dispatch({ type: 'SET_PERFORMATIVES', performatives: response.data })
      );
  }
}

export function startAgent(name, type, protocol) {
  return (dispatch) => {
    if (protocol.http) {
      return api
        .startAgent(name, type)
        .catch(error => {
          if (error.response) {
            throw new SubmissionError({ agentName: 'Agent with given name exists.' });
          } else {
            throw new SubmissionError({ agentName: 'Something went wrong, try again.' });
          }
        })
        .then(response => {
          dispatch({ type: 'HIDE_MODAL' });
          dispatch({ type: 'START_AGENT', agent: response.data });
        });
    } else {
      const promise = new Promise((resolve, reject) => {
        protocol
          .channel
          .push('agent:start', { name, type })
          .receive('ok', response => resolve('ok') )
          .receive('error', response => reject('Agent with given name exists.') );
      })

      promise
        .then(response => dispatch({ type: 'HIDE_MODAL' }) )
        .catch(error => { throw new SubmissionError({ agentName: error }); });

      return promise;
    }
  }
}

export function stopAgent(name, type, host, protocol) {
  return (dispatch) => {
    if (protocol.http) {
      api
        .stopAgent(name, type, host)
        .then(response => dispatch({ type: 'STOP_AGENT', name }));
    } else {
      protocol
        .channel
        .push('agent:stop', { name, type, host })
    }
  }
}

export function sendAclMessage(values, protocol) {
  return (dispatch) => {
    if (protocol.http) {
      api
        .sendAclMessage(values)
        .then(response => console.log(response));
    } else {
      protocol
        .channel
        .push('message:new', values)
        .receive('ok', response => console.log('Message sent successully'))
        .receive('error', response => console.log('Message failed'));
    }
  }
}
