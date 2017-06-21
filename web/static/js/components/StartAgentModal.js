import React, { Component } from 'react';
import { connect } from 'react-redux';
import { Modal } from 'react-bootstrap';
import StartAgentForm from './StartAgentForm';

class StartAgentModal extends Component {

  _handleStartAgent(values) {
    const { startAgent, type } = this.props;

    startAgent(values.agentName, type);
  }

  render() {
    const { show, onHide, type } = this.props;

    return (
      <Modal show={ show } onHide={ onHide } bsSize="small">
        <Modal.Header closeButton>
          <Modal.Title>
            <strong className="text-success">{ `Start ${ type.name } agent` }</strong>
          </Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <StartAgentForm onSubmit={ (values) => this._handleStartAgent(values) }/>
        </Modal.Body>
      </Modal>
    );
  }
}

export default StartAgentModal;
