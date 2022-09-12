defmodule LiveSecretWeb.Presence do
  use Phoenix.Presence,
    otp_app: :live_secret,
    pubsub_server: LiveSecret.PubSub
end
