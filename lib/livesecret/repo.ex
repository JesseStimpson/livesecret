defmodule LiveSecret.Repo do
  use Ecto.Repo,
    otp_app: :livesecret,
    adapter: Ecto.Adapters.SQLite3
end
