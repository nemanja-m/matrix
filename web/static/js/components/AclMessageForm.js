import React, { Component } from 'react';
import { Field, reduxForm } from 'redux-form'
import {
  Col,
  Form,
  FormControl,
  ControlLabel,
  FormGroup,
  Button
} from 'react-bootstrap'

const renderField = ({ input: { value, ...rest}, label, type, componentClass, multiple, options }) => (
  <div>
    <FormGroup
      controlId={ label }
      bsSize="small"
    >
      <ControlLabel>{ label }</ControlLabel>
      <FormControl
        { ...rest }
        type={ type }
        autoComplete="off"
        componentClass={ componentClass }
        multiple={ multiple }
      >
        { options }
      </FormControl>
    </FormGroup>
  </div>
)
class AclMessageForm extends Component {

  _parsePerformative(performative) {
    const capitalized = performative.charAt(0).toUpperCase() + performative.slice(1);

    return capitalized.replace("_", " ");
  }

  _renderPerformatives() {
    const options =  this.props.performatives.map(performative =>
      <option key={ performative } value={ performative }>
        { this._parsePerformative(performative) }
      </option>
    );

    return [(<option key="0">Select performative</option>), ...options];
  }

  _renderRunningAgents() {
    const options =  this.props.runningAgents.map(agent =>
      <option key={ agent.id.name } value={ agent.id.name }>
        { agent.id.name }
      </option>
    );

    return [(<option key="0" value="">Select agent</option>), ...options];
  }

  _renderTextFields() {
    return [
      'content',
      'language',
      'encoding',
      'ontology',
      'protocol',
      'conversation_id',
      'reply_with'
    ].map(fieldName =>
      <Field
        key={ fieldName }
        name={ fieldName }
        component={ renderField }
        type="text"
        label={ this._parsePerformative(fieldName) }
      />
    );
  }

  render() {
    const { pristine, handleSubmit, onSubmit } = this.props;

    return (
      <Col md={ 4 } mdOffset={ 1 } className="component" >
        <h3 className="text-center text-muted">ACL Message</h3>

        <hr/>

        <Form onSubmit={ handleSubmit }>
          <Field
            name="performative"
            component={ renderField }
            componentClass="select"
            options={ this._renderPerformatives() }
            label="Performative"
          />

          <Field
            name="sender"
            component={ renderField }
            componentClass="select"
            options={ this._renderRunningAgents() }
            label="Sender"
          />

          <Field
            name="receivers"
            component={ renderField }
            componentClass="select"
            multiple
            options={ this._renderRunningAgents() }
            label="Receivers"
          />

          <Field
            name="replyTo"
            component={ renderField }
            componentClass="select"
            options={ this._renderRunningAgents() }
            label="ReplyTo"
          />

          { this._renderTextFields() }

          <Field
            name="replyBy"
            component={ renderField }
            type="number"
            label="Reply by"
          />

          <Button
            style={ { marginBottom: '9px' } }
            type="submit"
            bsStyle="success"
            bsSize="small"
            disabled={ pristine }
          >
            Send message
          </Button>
        </Form>
      </Col>
    )
  }
}

export default reduxForm({
  form: 'AclMessageForm'
})(AclMessageForm);
