import React, { Component } from 'react';
import { connect } from 'react-redux';
import AgentTypes from '../components/AgentTypes';
import RunningAgents from '../components/RunningAgents';
import StartAgentModal from '../components/StartAgentModal';
import ProtocolSwitch from '../components/ProtocolSwitch';
import AclMessageForm from '../components/AclMessageForm';
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
  useHttp,
  useWebSockets
} from '../actions/protocol';
import {
  showModal,
  hideModal
} from '../actions/modal'

class Root extends Component {

  componentDidMount() {
    this.props.getAgentTypes();
    this.props.getRunningAgents();
    this.props.getPerformatives();
    this.props.useWebSockets();
  }

  render() {
    const { agentTypes, runningAgents, modal, protocol } = this.props;

    return (
      <Grid fluid={ true } style={ { margin: "2rem 10rem" } }>
        <ProtocolSwitch
          protocol={ protocol }
          useHttp={ this.props.useHttp }
          useWebSockets={ this.props.useWebSockets }
        />
        <hr />
        <Row>
          <AgentTypes
            types={ agentTypes }
            showModal={ this.props.showModal }
          />
          <AclMessageForm
            performatives={ this.props.performatives }
            runningAgents={ runningAgents }
            onSubmit={ (values) => console.log(values) }
          />
          <RunningAgents
            agents={ runningAgents }
            stopAgent={ (name, type, host) => this.props.stopAgent(name, type, host, protocol) }
          />
        </Row>

        <StartAgentModal
          show={ modal.show }
          type={ modal.type }
          onHide={ this.props.hideModal }
          startAgent={ (name, type) => this.props.startAgent(name, type, protocol) }
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
    modal:         state.modal,
    protocol:      state.protocol
  }
};

const mapDispatchToProps = (dispatch) => {
  return {
    getAgentTypes:    () => dispatch(getAgentTypes()),
    getRunningAgents: () => dispatch(getRunningAgents()),
    getPerformatives: () => dispatch(getPerformatives()),

    hideModal: () => dispatch(hideModal()),
    showModal: (type) => dispatch(showModal(type)),

    startAgent: (name, type, protocol) => dispatch(startAgent(name, type, protocol)),
    stopAgent:  (name, type, host, protocol) => dispatch(stopAgent(name, type, host, protocol)),

    useHttp:       () => dispatch(useHttp()),
    useWebSockets: () => dispatch(useWebSockets())
  }
};

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(Root);
