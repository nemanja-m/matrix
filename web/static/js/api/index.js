const axios = require('axios');

function apiUrl() {
  const host = window.location.host;
  const [protocol , ...rest] = window.location.href.split(host);

  return `${ protocol }${ host }`;
}

function headers() {
  return {
    'Content-Type': 'application/json'
  };
}

function handleError(error) {
  if (error.response) {
    // Status code falls out of the range of 2xx.
    console.log(error.response.data)
  } else {
    // No response was received.
    console.log(error.request);
  }
}

export default {

  getAgentTypes() {
    const url = `${ apiUrl() }/agents/classes`;

    axios
      .get(url, { headers: headers() })
      .then( (response) => {
        const agentTypes = response.data.data;

        return Object
          .entries(agentTypes)
          .map( ([host, types]) => types)
          .reduce( (acc, types) => [...acc, ...types] );
      })
      .catch( (error) => handleError(error) );
  }
};
