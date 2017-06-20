import api from '../api';

export function getAgentTypes() {
  return (dispatch) => {
    api
      .getAgentTypes()
      .then( response => {

        // Parse response and form list of available agent types.
        const agentTypes = Object
          .entries(response.data.data)
          .map( ([host, types]) => types)
          .reduce( (acc, types) => [...acc, ...types] );

        dispatch({ type: 'ADD_TYPES', types: agentTypes });
      });
  };
}
