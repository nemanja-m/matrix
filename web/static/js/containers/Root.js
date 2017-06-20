import React, { Component } from 'react';
import { connect } from 'react-redux';
import AgentTypes from '../components/AgentTypes'
import {
  getAgentTypes,
  getRunningAgents
} from '../actions/types';

class Root extends Component {

  componentDidMount() {
    this.props.getAgentTypes();
    this.props.getRunningAgents();
  }

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

const mapDispatchToProps = (dispatch) => {
  return {
    getAgentTypes:    () => dispatch(getAgentTypes()),
    getRunningAgents: () => dispatch(getRunningAgents())
  }
};

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(Root);
