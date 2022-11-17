defmodule Upload17.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      Upload17Web.Telemetry,
      # Start the Ecto repository
      Upload17.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Upload17.PubSub},
      # Start Finch
      {Finch, name: Upload17.Finch},
      # Start the Endpoint (http/https)
      Upload17Web.Endpoint
      # Start a worker by calling: Upload17.Worker.start_link(arg)
      # {Upload17.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Upload17.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    Upload17Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
