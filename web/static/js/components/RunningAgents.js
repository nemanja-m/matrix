import React, { Component } from 'react';

const Agent = ({ name }) => <li>{ name }</li>;

class RunningAgents extends Component {

  _renderRunningAgents() {
    return this.props.agents.map( (agent) =>
      <Agent
        key={ window.btoa(agent.id.name) }
        name={ agent.id.name }
      />
    );
  }

  render() {
    return (
      <div>
        <h1>Running Agents</h1>
        <ul>
          { this._renderRunningAgents() }
        </ul>
      </div>
    )
  }
}

export default RunningAgents;
