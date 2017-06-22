import React, { Component } from 'react'
import { Field, reduxForm } from 'redux-form'
import {
  Form,
  FormControl,
  FormGroup,
  Button
} from 'react-bootstrap'

const renderField = ({ input, label, type, meta: { touched, error } }) => (
  <div>
    <FormGroup
      controlId="startAgent"
      bsSize="small"
      validationState={ touched ? (error ? 'error' : 'success') : null }
    >
      <FormControl
        { ...input }
        placeholder={ label }
        type={ type }
        autoComplete="off"
      />
    </FormGroup>
    {
      touched && error &&
      <p className="text-danger mt-3 mb-3 form-text text-muted">{ error }</p>
    }
  </div>
)

class StartAgentForm extends Component {
  render () {
    const { pristine, handleSubmit, onSubmit } = this.props;

    return (
      <Form onSubmit={ handleSubmit }>
        <Field name="agentName" type="text" component={ renderField } label="Agent Name" />

        <Button
          type="submit"
          bsStyle="success"
          bsSize="xsmall"
          disabled={pristine}
        >
          Start
        </Button>
      </Form>
    );
  }
}

const validate = (values) => {
  const errors = {};

  if (!values.agentName) {
    errors.agentName = 'You must enter agent name.';
  } else if (!/^[a-zA-Z]*$/.test(values.agentName)) {
    errors.agentName = 'Only letters are allowed.';
  }

  return errors;
}

export default reduxForm({
  form: 'StartAgentForm',
  validate
})(StartAgentForm);
