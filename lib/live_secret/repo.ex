defmodule LiveSecret.Repo do
  use Ecto.Repo,
    otp_app: :live_secret,
    adapter: Ecto.Adapters.SQLite3
end
