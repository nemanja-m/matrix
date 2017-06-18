import React, { Component } from 'react';
import { connect } from 'react-redux';
import AgentTypes from '../components/AgentTypes'

class Root extends Component {
  render() {
    const { agentTypes } = this.props;

    return (
      <div style={{ display: 'flex', height: '10vh', flex: '1' }}>
        <AgentTypes types={ agentTypes } />
      </div>
    );
  }
}

const mapStateToProps = (state) => {
  return {
    agentTypes: state.agentTypes
  }
};

export default connect(mapStateToProps, null)(Root);
