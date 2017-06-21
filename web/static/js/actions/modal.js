export function showModal(title) {
  return (dispatch) => dispatch({ type: 'SHOW_MODAL', title })
}

export function hideModal() {
  return (dispatch) => dispatch({ type: 'HIDE_MODAL' })
}
