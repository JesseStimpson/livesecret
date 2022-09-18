defmodule LiveSecret do
  @moduledoc """
  LiveSecret keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias LiveSecret.{Do, PubSubDo, Secret}

  defdelegate count_secrets(), to: Do
  defdelegate get_secret!(id), to: Do
  defdelegate get_secret(id), to: Do
  defdelegate insert!(presecret_attrs), to: Do
  defdelegate validate_presecret(presecret_attrs), to: Do

  def burn!(secret, event_extra \\ []) do
    secret = %Secret{id: id, burned_at: burned_at} = Do.burn!(secret)
    PubSubDo.notify_burned!(id, burned_at, event_extra)
    secret
  end

  defdelegate go_live!(id), to: Do
  defdelegate go_async!(id), to: Do

  defdelegate subscribe!(id), to: PubSubDo
  defdelegate notify_unlocked!(id, user_id), to: PubSubDo
  defdelegate notify_expired(id), to: PubSubDo
end
