import { combineReducers } from 'redux';
import { reducer as form } from 'redux-form';
import agents from './agents';
import modal from './modal';
import protocol from './protocol';

const reducers = combineReducers({
  form,
  agents,
  modal,
  protocol
});

export default reducers;
