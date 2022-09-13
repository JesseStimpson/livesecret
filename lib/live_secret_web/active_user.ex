defmodule LiveSecretWeb.ActiveUser do
  use Ecto.Schema

  alias LiveSecretWeb.ActiveUser

  schema "active_users" do
    field :live_action, Ecto.Enum, values: [:admin, :receiver]
    field :joined_at, :naive_datetime
    field :left_at, :naive_datetime
    field :state, Ecto.Enum, values: [:locked, :unlocked, :revealed]
  end

  def connected?(%ActiveUser{left_at: nil}), do: true
  def connected?(_), do: false

  def changeset(active_user, params) do
    active_user
    |> Ecto.Changeset.cast(params, [:live_action, :joined_at, :left_at])
    |> Ecto.Changeset.validate_required([:live_action, :joined_at, :left_at])
  end
end
