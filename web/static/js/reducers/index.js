import { combineReducers } from 'redux';
import { reducer as form } from 'redux-form';
import types from './types';

const reducers = combineReducers({
  form,
  agentTypes: types
});

export default reducers ;
