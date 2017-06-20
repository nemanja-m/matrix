import React, { Component } from 'react';

const AgentType = ({ name }) => <li>{ name }</li>;

class AgentTypes extends Component {

  _renderAvailableTypes() {
    return this.props.types.map(type =>
      <AgentType
        key={ window.btoa(`$(type.name):$(type.module)`) }
        name={ type.name }
      />
    );
  }

  render() {
    return (
      <div>
        <h1>Agent Classes</h1>
        <ul>
          { this._renderAvailableTypes() }
        </ul>
      </div>
    )
  }
}

export default AgentTypes;
