defmodule LiveSecretWeb.PresenceDo do
  alias LiveSecret.Secret
  alias LiveSecretWeb.ActiveUser

  @doc """
  Builds a map of user info from the current socket
  """
  def user_from_socket(socket) do
    if connect_info?(socket) do
      user_from_connect_info(socket.private[:connect_info])
    else
      nil
    end
  end

  @doc """
  Returns true if the socket has usable info to detect the connection information
  """
  defp connect_info?(socket) do
    case socket.private[:connect_info] do
      nil ->
        false

      %Plug.Conn{} ->
        # User id cannot be constructed until the websocket connects, so the first render
        # does not have a current_user so the presence list is not shown
        false

      _ ->
        true
    end
  end

  defp user_from_connect_info(conn = %Plug.Conn{}) do
    user_from_connect_info(%{
      peer_data: Plug.Conn.get_peer_data(conn),
      label: "unknown connect info"
    })
  end

  defp user_from_connect_info(_connect_info = %{peer_data: %{address: address, port: port}}) do
    address = :erlang.iolist_to_binary(:inet.ntoa(address))
    %{id: "#{address}:#{port}"}
  end

  @doc """
  Track a user in presence for this secret
  """
  def track(id, user) do
    presence =
      case LiveSecretWeb.Presence.track(self(), Secret.topic(id), user.id, user) do
        {:ok, pid} ->
          pid

        {:error, {:already_tracked, pid, _topic, _userid}} ->
          pid
      end

    LiveSecret.PubSubDo.subscribe!(id)

    presence
  end

  @doc """
  Updates presence for an active user to the unlocked state

  Must be called from the process that manages the user that is being unlocked.

  Returns true if succesful
  """
  def on_unlocked(
        id,
        for_user = %ActiveUser{live_action: :receiver, state: :locked, left_at: nil}
      ) do
    {:ok, _} =
      LiveSecretWeb.Presence.update(self(), Secret.topic(id), for_user.id, %ActiveUser{
        for_user
        | state: :unlocked
      })

    true
  end

  def on_unlocked(_id, _for_user) do
    false
  end

  @doc """
  Updates presence for active user to 'revealed'

  Must be called from the process that manages the user that is being unlocked.

  Returns true if succesful
  """
  def on_revealed(id, for_user) do
    LiveSecretWeb.Presence.update(self(), Secret.topic(id), for_user.id, %ActiveUser{
      for_user
      | state: :revealed
    })

    true
  end
end
