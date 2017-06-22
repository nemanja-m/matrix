defmodule Matrix.AclMessage do
  @moduledoc """
  Represents ACL message. ACL message is used for communication between agents.
  """

  @derive [Poison.Encoder]
  defstruct [
    :performative,
    :sender,
    :receivers,
    :reply_to,
    :content,
    :content_obj,
    :user_args,
    :language,
    :encoding,
    :ontology,
    :protocol,
    :conversation_id,
    :reply_with,
    :in_reply_to,
    :reply_by
  ]

  @type t :: %__MODULE__{
    performative:    atom,
    sender:          Matrix.AID.t,
    receivers:       list(Matrix.AID.t),
    reply_to:        Matrix.AID.t,
    content:         String.t,
    content_obj:     Map.t,
    user_args:       Map.t,
    language:        String.t,
    encoding:        String.t,
    ontology:        String.t,
    protocol:        String.t,
    conversation_id: String.t,
    reply_with:      String.t,
    in_reply_to:     String.t,
    reply_by:        integer
  }

  def performatives do
    [
      :accept_proposal,
      :agree,
      :cancel,
      :cfp,
      :confirm,
      :disconfirm,
      :failure,
      :inform,
      :inform_if,
      :inform_ref,
      :not_understood,
      :propagate,
      :propose,
      :proxy,
      :query_if,
      :query_ref,
      :refuse,
      :reject_proposal,
      :request,
      :request_when,
      :request_whenever,
      :subscribe
    ]
  end

  def from_hash(hash) do
    message =
      hash
      |> Poison.encode!
      |> Poison.decode!(as: %__MODULE__{})

    atom_performative = message.performative |> String.to_existing_atom

    put_in(message.performative, atom_performative)
  end

end
