defmodule LiveSecret.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :livesecret

  require Logger

  def migrate do
    load_app()

    for repo <- repos() do

      # Ensures datbaase file exists on disk
      database_path = repo.config()[:database]
      case Exqlite.Basic.open(database_path) do
        {:ok, conn} ->
          Exqlite.Basic.close(conn)
        error ->
          Logger.critical("""
          Error opening database at #{inspect(database_path)}:

          #{inspect(error)}
          """)
      end

      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
