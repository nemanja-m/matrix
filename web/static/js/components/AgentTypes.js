import React, { Component } from 'react';
import {
  Table,
  Col,
  Label,
  Button
} from 'react-bootstrap';

const AgentType = ({ name, module }) =>
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
        <Button bsStyle="success" bsSize="xsmall">
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
            <th width="30px"></th>
            <th width="120px"></th>
            <th width="50px"></th>
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
