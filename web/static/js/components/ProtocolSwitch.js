import React, { Component } from 'react';
import { Button, Row } from 'react-bootstrap';

const styles = {
  switchButton: {
    marginBottom: '5rem',
    padingLeft: '10px'
  },

  wsText: {
    marginRight: '1rem'
  },

  noOutline: {
    outline: 'none'
  }
};

class ProtocolSwitch extends Component {

  render() {
    const { useHttp, useWebSockets, protocol } = this.props;

    return (
      <Row style={ styles.switchButton }>
        <strong style={ styles.wsText }>WebSockets:</strong>
        <Button
          bsStyle={ protocol.http ? 'danger' : 'success' }
          bsSize="xsmall"
          onClick={ () => protocol.http ? useWebSockets() : useHttp() }
          style={ styles.noOutline }
        >
          { protocol.http ? 'Off' : 'On' }
        </Button>
      </Row>
    );
  }
}

export default ProtocolSwitch;
