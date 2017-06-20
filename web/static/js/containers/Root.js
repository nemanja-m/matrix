import React, { Component } from 'react';
import { connect } from 'react-redux';
import AgentTypes from '../components/AgentTypes'
import { getAgentTypes } from '../actions/types';

class Root extends Component {

  componentDidMount() {
    this.props.getAgentTypes();
  }

  render() {
    const { agentTypes } = this.props;

    return (
      <div style={{ display: 'flex', height: '10vh', flex: '1' }}>
        <AgentTypes types={ agentTypes } />
      </div>
    );
  }
}

const mapStateToProps = (state) => {
  return {
    agentTypes: state.agentTypes
  }
};

const mapDispatchToProps = (dispatch) => {
  return {
    getAgentTypes: () => dispatch(getAgentTypes())
  }
};

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(Root);
