import React, { Component } from 'react';
import { connect } from 'react-redux';
import AgentTypes from '../components/AgentTypes'
import RunningAgents from '../components/RunningAgents'
import {
  getAgentTypes,
  getRunningAgents
} from '../actions/agents';

class Root extends Component {

  componentDidMount() {
    this.props.getAgentTypes();
    this.props.getRunningAgents();
  }

  render() {
    const { agentTypes, runningAgents } = this.props;

    return (
      <div>
        <AgentTypes types={ agentTypes } />
        <RunningAgents agents={ runningAgents } />
      </div>
    );
  }
}

const mapStateToProps = (state) => {
  return {
    agentTypes:    state.agents.types,
    runningAgents: state.agents.running
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
