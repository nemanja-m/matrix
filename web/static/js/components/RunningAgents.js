import React, { Component } from 'react';
import {
  Table,
  Col,
  Label,
  Button
} from 'react-bootstrap';

const Agent = ({ name, type }) =>
  <tr>
    <td>
      <h4><Label bsStyle="success">{ type }</Label></h4>
    </td>
    <td>
      <h4 className="text-danger text-center">
        <strong>{ name }</strong>
      </h4>
    </td>
    <td>
      <h4>
        <Button bsStyle="danger" bsSize="xsmall">
          Stop agent
        </Button>
      </h4>
    </td>
  </tr>

class RunningAgents extends Component {

  _renderRunningAgents() {
    return this.props.agents.map(agent =>
      <Agent
        key={ window.btoa(agent.id.name) }
        name={ agent.id.name }
        type={ agent.id.type.name }
      />
    );
  }

  render() {
    return (
      <Col md={ 3 } className="roundedBorders">
        <Table>
          <caption>
            <h1 className="text-center">Running Agents</h1>
          </caption>
          <thead>
            <tr width="30px"></tr>
            <tr width="120px"></tr>
            <tr width="50px"></tr>
          </thead>
          <tbody>
            { this._renderRunningAgents() }
          </tbody>
        </Table>
      </Col>
    )
  }
}

export default RunningAgents;
