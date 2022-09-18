defmodule LiveSecret.PubSubDo do
  alias LiveSecret.Secret

  @doc """
  Subscribe to secret
  """
  def subscribe!(id) do
    :ok = Phoenix.PubSub.subscribe(LiveSecret.PubSub, Secret.topic(id))
  end

  @doc """
  Notifies PubSub topic for the secret that the provided user has been unlocked. All
  listeners should update their state for this user, and the user specified is allowed
  to receive the ciphertext.
  """
  def notify_unlocked!(id, user_id) do
    :ok = Phoenix.PubSub.broadcast(LiveSecret.PubSub, Secret.topic(id), {:unlocked, user_id})
  end

  @doc """
  Notifies PubSub topic for the secret that the given user `burned_by` burned the secret at
  timestamp `burned_at`. All listeners should update their state for this secret.
  """
  def notify_burned!(id, burned_at, extra) do
    :ok =
      Phoenix.PubSub.broadcast(
        LiveSecret.PubSub,
        Secret.topic(id),
        {:burned, burned_at, extra}
      )
  end

  @doc """
  Notifies PubSubtopic for the secret that it has been expired. All listeners should update
  their state for this secret.
  """
  def notify_expired(id) do
    Phoenix.PubSub.broadcast(LiveSecret.PubSub, Secret.topic(id), :expired)
  end
end
