import React, { Component } from 'react';
import { connect } from 'react-redux';
import { Modal } from 'react-bootstrap';

class StartAgentModal extends Component {

  render() {
    const { show, onHide, agents, title } = this.props;

    return (
      <Modal show={ show } onHide={ onHide } bsSize="small">
        <Modal.Header closeButton>
          <Modal.Title>{ title }</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <h4>Hello world</h4>
        </Modal.Body>
      </Modal>
    );
  }
}

export default StartAgentModal;
