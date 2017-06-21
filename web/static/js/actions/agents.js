import api from '../api';
import { SubmissionError  } from 'redux-form'

function flatten(responseObject) {
  return Object
    .entries(responseObject)
    .map(([host, dataArray]) => dataArray)
    .reduce((acc, dataArray) => [...acc, ...dataArray], []);
}

function uniqueTypes(types) {
  const typeStrings = types.map(type => `${ type.name }:${ type.module }`);

  return [...new Set(typeStrings)]
    .map(typeString => {
    [name, module] = typeString.split(':');

    return { name, module };
  });
}

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

export function startAgent(name, type) {
  return (dispatch) => {
    throw new SubmissionError({ agentName: 'Agent with given name exists.' });
  }
}
