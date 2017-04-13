defmodule PivotalCodereview.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = endpoint_children() ++
      [worker(PivotalCodereview.LabelActionSupervisor, [])]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PivotalCodereview.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp endpoint_children() do
    port = Application.get_env(:pivotal_codereview, :port)

    if port do
      Logger.info("Start listening port #{port}")
      [Plug.Adapters.Cowboy.child_spec(:http, PivotalCodereview.WebhookEndpoint, [], [port: port])]
    else
      []
    end
  end
end
