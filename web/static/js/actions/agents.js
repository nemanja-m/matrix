import api from '../api';

function flatten(responseObject) {
  return Object
    .entries(responseObject)
    .map(([host, dataArray]) => dataArray)
    .reduce((acc, dataArray) => [...acc, ...dataArray], []);
}

export function getAgentTypes() {
  return (dispatch) => {
    api
      .get('/agents/classes')
      .then(response =>
        dispatch({ type: 'ADD_TYPES', types: flatten(response.data) })
      );
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
