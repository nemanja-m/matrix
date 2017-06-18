import React, { Component } from 'react';

const AgentType = ({ name }) => <li>{ name }</li>;

class AgentTypes extends Component {

  _renderAvailableTypes() {
    return this.props.types.map( (type) =>
      <AgentType
        key={ window.btoa(`$(type.name):$(type.module)`) }
        name={ type.name }
      />
    );
  }

  render() {
    return (
      <ul>
        { this._renderAvailableTypes() }
      </ul>
    )
  }
}

export default AgentTypes;
