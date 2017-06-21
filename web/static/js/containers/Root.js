import React, { Component } from 'react';
import { connect } from 'react-redux';
import AgentTypes from '../components/AgentTypes';
import RunningAgents from '../components/RunningAgents';
import StartAgentModal from '../components/StartAgentModal';
import {
  Grid,
  Row,
  Col
} from 'react-bootstrap';
import {
  getAgentTypes,
  getRunningAgents,
  getPerformatives,
  startAgent,
  stopAgent
} from '../actions/agents';
import {
  showModal,
  hideModal
} from '../actions/modal'

class Root extends Component {

  componentDidMount() {
    this.props.getAgentTypes();
    this.props.getRunningAgents();
    this.props.getPerformatives();
  }

  render() {
    const { agentTypes, runningAgents, modal } = this.props;

    return (
      <Grid fluid={ true } style={ { margin: "10rem 15rem" } }>
        <Row>
          <AgentTypes
            types={ agentTypes }
            showModal={ this.props.showModal }
          />
          <Col md={ 6 } />
          <RunningAgents
            agents={ runningAgents }
            stopAgent= { this.props.stopAgent }
          />
        </Row>

        <StartAgentModal
          show={ modal.show }
          type={ modal.type }
          onHide={ this.props.hideModal }
          startAgent={ this.props.startAgent }
        />
      </Grid>
    );
  }
}

const mapStateToProps = (state) => {
  return {
    agentTypes:    state.agents.types,
    runningAgents: state.agents.running,
    performatives: state.agents.performatives,
    modal:         state.modal
  }
};

const mapDispatchToProps = (dispatch) => {
  return {
    getAgentTypes:    () => dispatch(getAgentTypes()),
    getRunningAgents: () => dispatch(getRunningAgents()),
    getPerformatives: () => dispatch(getPerformatives()),

    hideModal: () => dispatch(hideModal()),
    showModal: (type) => dispatch(showModal(type)),

    startAgent: (name, type) => dispatch(startAgent(name, type)),
    stopAgent:  (name, type, host) => dispatch(stopAgent(name, type, host))
  }
};

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(Root);
