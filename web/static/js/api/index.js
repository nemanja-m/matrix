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

  get(resourceUrl) {
    const url = `${ apiUrl() }${ resourceUrl }`;

    return axios
      .get(url, { headers: headers() })
      .catch(error => handleError(error));
  },

  startAgent(name, type) {
    const url = `${ apiUrl() }/agents/running`;

    return axios.put(url, { data: { name, type } }, { headers: headers() });
  },

  stopAgent(name, type, host) {
    const agentUri = `${ name }/host/${ host.aliaz }/type/${ type.name }/${ type.module }`;
    const url = `${ apiUrl() }/agents/running/id/${ agentUri }`;

    return axios.delete(url);
  },

  sendAclMessage(values) {
    const url = `${ apiUrl() }/messages`;

    return axios
      .post(url, { data: values }, { headers: headers() })
      .catch(error => handleError(error));
  }
};
