import React, { Component } from 'react';
import { connect } from 'react-redux';
import AgentTypes from '../components/AgentTypes'
import RunningAgents from '../components/RunningAgents'
import {
  getAgentTypes,
  getRunningAgents,
  getPerformatives
} from '../actions/agents';

class Root extends Component {

  componentDidMount() {
    this.props.getAgentTypes();
    this.props.getRunningAgents();
    this.props.getPerformatives();
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
    runningAgents: state.agents.running,
    performatives: state.agents.performatives
  }
};

const mapDispatchToProps = (dispatch) => {
  return {
    getAgentTypes:    () => dispatch(getAgentTypes()),
    getRunningAgents: () => dispatch(getRunningAgents()),
    getPerformatives: () => dispatch(getPerformatives())
  }
};

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(Root);
