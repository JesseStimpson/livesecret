defmodule LiveSecretWeb.Presence do
  use Phoenix.Presence,
    otp_app: :livesecret,
    pubsub_server: LiveSecret.PubSub
end
