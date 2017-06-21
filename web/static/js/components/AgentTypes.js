import React, { Component } from 'react';
import {
  Table,
  Col,
  Label,
  Button
} from 'react-bootstrap';

const AgentType = ({ name, module, showModal }) =>
  <tr>
    <td>
      <h4><Label bsStyle="primary">{ module }</Label></h4>
    </td>
    <td>
      <h4 className="text-danger text-center">
        <strong>{ name }</strong>
      </h4>
    </td>
    <td>
      <h4>
        <Button
          bsStyle="success"
          bsSize="xsmall"
          onClick={ () => showModal({ name, module }) }
        >
          Start agent
        </Button>
      </h4>
    </td>
  </tr>

class AgentTypes extends Component {

  _renderAvailableTypes() {
    return this.props.types.map(type =>
      <AgentType
        key={ window.btoa(`${ type.name }:${ type.module }`) }
        name={ type.name }
        module={ type.module }
        showModal={ this.props.showModal }
      />
    );
  }

  render() {
    return (
      <Col md={ 3 } className="roundedBorders">
        <Table>
          <caption>
            <h1 className="text-center">Agent Classes</h1>
          </caption>
          <thead>
            <tr width="30px"></tr>
            <tr width="120px"></tr>
            <tr width="50px"></tr>
          </thead>
          <tbody>
            { this._renderAvailableTypes() }
          </tbody>
        </Table>
      </Col>
    )
  }
}

export default AgentTypes;
