export function showModal(agentType) {
  return (dispatch) => dispatch({ type: 'SHOW_MODAL', agentType })
}

export function hideModal() {
  return (dispatch) => dispatch({ type: 'HIDE_MODAL' })
}
