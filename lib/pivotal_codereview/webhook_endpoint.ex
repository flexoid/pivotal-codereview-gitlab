defmodule PivotalCodereview.WebhookEndpoint do
  require Logger
  use Plug.Router

  plug Plug.Logger, log: :debug
  plug :match
  plug Plug.Parsers, parsers: [:urlencoded, :json], json_decoder: Poison
  plug :dispatch

  post "/merge_request/:project_id" do
    Logger.info("Received webhook data for project ID: #{project_id}")

    Logger.debug(inspect(conn.body_params))

    case conn.body_params do
      %{"object_kind" => "merge_request", "object_attributes" => %{"action" => "open", "source_branch" => branch}} ->
        Logger.info("MR Open: #{branch}")
        PivotalCodereview.WebhookHandler.merge_request_opened(project_id, branch)

      %{"object_kind" => "merge_request", "object_attributes" => %{"action" => "merge", "source_branch" => branch}} ->
        Logger.info("MR Merge: #{branch}")
        PivotalCodereview.WebhookHandler.merge_request_merged(project_id, branch)

      %{"object_kind" => "merge_request", "object_attributes" => %{"action" => "close", "source_branch" => branch}} ->
        Logger.info("MR Close: #{branch}")
        PivotalCodereview.WebhookHandler.merge_request_closed(project_id, branch)

      _ ->
        Logger.info("Request is ignored")
    end

    send_resp(conn, 200, "OK")
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
