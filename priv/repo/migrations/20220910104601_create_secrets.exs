defmodule LiveSecret.Repo.Migrations.CreateSecrets do
  use Ecto.Migration

  def change do
    create table(:secrets, primary_key: false) do
      add :id, :string, primary_key: true
      add :creator_key, :string
      add :burn_key, :string
      add :content, :binary
      add :iv, :binary
      add :live?, :boolean
      add :burned_at, :naive_datetime
      add :expires_at, :naive_datetime

      timestamps()
    end
  end
end
