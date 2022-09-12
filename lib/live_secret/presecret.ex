defmodule LiveSecret.Presecret do
  use Ecto.Schema

  alias LiveSecret.{CreatorKey, Presecret}

  schema "presecrets" do
    field :content, :string, redact: true
    field :iv, :string, redact: true
    field :duration, :string, default: "1h"
  end

  @durations ["1h", "1d", "3d", "1w"]

  def new() do
    %Presecret{iv: :base64.encode(:crypto.strong_rand_bytes(12))}
  end

  # TODO - this can be done purely with changesets, I'm sure of it
  def make_secret_attrs(%{"content" => content, "iv" => iv, "duration" => duration}) do
    now = NaiveDateTime.utc_now()

    %{
      content: :base64.decode(content),
      iv: :base64.decode(iv),
      creator_key: CreatorKey.generate(),
      expires_at: NaiveDateTime.add(now, duration_to_seconds(duration))
    }
  end

  def supported_durations(), do: @durations

  defp duration_to_seconds("1h"), do: div(:timer.hours(1), 1000)
  defp duration_to_seconds("1d"), do: div(:timer.hours(24), 1000)
  defp duration_to_seconds("3d"), do: div(:timer.hours(24) * 3, 1000)
  defp duration_to_seconds("1w"), do: div(:timer.hours(24) * 7, 1000)

  def changeset(presecret, params) do
    presecret
    |> Ecto.Changeset.cast(params, [:content, :iv, :duration])
    |> Ecto.Changeset.validate_required([:content, :iv, :duration])
    |> Ecto.Changeset.validate_inclusion(:duration, @durations)
  end
end
