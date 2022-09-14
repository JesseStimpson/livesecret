defmodule LiveSecret.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      LiveSecret.Repo,
      # Start the Telemetry supervisor
      LiveSecretWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: LiveSecret.PubSub},
      # Start the Presence
      LiveSecretWeb.Presence,
      # Start the Endpoint (http/https)
      LiveSecretWeb.Endpoint
      # Start a worker by calling: LiveSecret.Worker.start_link(arg)
      # {LiveSecret.Worker, arg}
    ]

    LiveSecret.Expiration.setup_job()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LiveSecret.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LiveSecretWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
