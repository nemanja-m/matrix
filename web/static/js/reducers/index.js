import { combineReducers } from 'redux';
import { reducer as form } from 'redux-form';
import agents from './agents';
import modal from './modal';

const reducers = combineReducers({
  form,
  agents,
  modal
});

export default reducers;
