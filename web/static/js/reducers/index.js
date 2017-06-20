import { combineReducers } from 'redux';
import { reducer as form } from 'redux-form';
import agents from './agents';

const reducers = combineReducers({
  form,
  agents
});

export default reducers;
