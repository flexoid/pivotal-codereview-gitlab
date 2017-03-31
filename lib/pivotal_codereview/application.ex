defmodule PivotalCodereview.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    port = Application.fetch_env!(:pivotal_codereview, :port)
    Logger.info("Start listening port #{port}")

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: PivotalCodereview.Worker.start_link(arg1, arg2, arg3)
      # worker(PivotalCodereview.Worker, [arg1, arg2, arg3]),

      Plug.Adapters.Cowboy.child_spec(:http, PivotalCodereview.WebhookEndpoint, [], [port: port])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PivotalCodereview.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
