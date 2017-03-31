defmodule PivotalCodereview.WebhookEndpoint do
  use Plug.Router

  plug Plug.Logger, log: :debug
  plug :match
  plug Plug.Parsers, parsers: [:urlencoded, :json], json_decoder: Poison
  plug :dispatch

  post "/merge_request/:project_id" do
    IO.inspect(project_id)
    IO.inspect(conn.body_params)

    send_resp(conn, 200, "OK")
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
