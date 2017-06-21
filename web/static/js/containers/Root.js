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
  getPerformatives
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
          <RunningAgents agents={ runningAgents } />
        </Row>

        <StartAgentModal
          show={ modal.show }
          title={ modal.title }
          onHide={ this.props.hideModal }
          agents={ runningAgents }
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
    showModal: (title) => dispatch(showModal(title))
  }
};

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(Root);
