import React, { Component } from 'react';
import { connect } from 'react-redux';
import AgentTypes from '../components/AgentTypes'
import RunningAgents from '../components/RunningAgents'
import { Grid, Row, Col } from 'react-bootstrap';
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
      <Grid fluid={ true } style={ { margin: "10rem 15rem" } }>
        <Row>
          <AgentTypes types={ agentTypes } />
          <Col md={ 6 } />
          <RunningAgents agents={ runningAgents } />
        </Row>
      </Grid>
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
