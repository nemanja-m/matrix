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
      .catch( error => handleError(error) );
  }

};
