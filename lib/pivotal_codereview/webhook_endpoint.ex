defmodule PivotalCodereview.WebhookEndpoint do
  require Logger
  use Plug.Router

  plug Plug.Logger, log: :debug
  plug :match
  plug Plug.Parsers, parsers: [:urlencoded, :json], json_decoder: Poison
  plug :dispatch

  @story_id_regex ~r/.*\/(\d+)\/.*/i

  post "/merge_request/:project_id" do
    Logger.info("Received webhook data for project ID: #{project_id}")

    Logger.debug(inspect(conn.body_params))

    case conn.body_params do
      %{"object_kind" => "merge_request", "object_attributes" => %{"action" => "open", "source_branch" => branch}} ->
        Logger.info("MR Open: #{branch}")
        add_tag(project_id, branch)

      %{"object_kind" => "merge_request", "object_attributes" => %{"action" => "merge", "source_branch" => branch}} ->
        Logger.info("MR Merge: #{branch}")
        remove_tag(project_id, branch)

      %{"object_kind" => "merge_request", "object_attributes" => %{"action" => "close", "source_branch" => branch}} ->
        Logger.info("MR Close: #{branch}")
        remove_tag(project_id, branch)

      _ ->
        Logger.info("Request is ignored")
    end

    send_resp(conn, 200, "OK")
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end

  defp extract_story_id(branch_name) do
    @story_id_regex
    |> Regex.scan(branch_name)
    |> Enum.flat_map(fn([_ | match]) -> match end)
    |> Enum.at(0)
  end

  defp add_tag(project_id, branch_name) do
    story_id = extract_story_id(branch_name)

    if story_id do
      params =  %{"name": tracker_label()}

      resp = PivotalCodereview.Tracker.post_projects_stories_labels(tracker_token(), project_id, story_id,  params)
      Logger.info(inspect(resp))
    end
  end

  defp remove_tag(project_id, branch_name) do
    story_id = extract_story_id(branch_name)

    label_name = tracker_label()
    labels = PivotalCodereview.Tracker.get_projects_stories_labels(tracker_token(), project_id, story_id)

    label_id = Enum.find_value(labels, fn(label) ->
      match?(%{"kind" => "label", "name" => ^label_name}, label) && label["id"]
    end)

    Logger.info("Label ID to remove: #{label_id}")

    if label_id do
      resp = PivotalCodereview.Tracker.delete_projects_stories_labels(tracker_token(), project_id, story_id, label_id)
      Logger.info(inspect(resp))
    end
  end

  defp tracker_token() do
    Application.fetch_env!(:pivotal_codereview, :pivotaltracker_token)
  end

  defp tracker_label() do
    Application.fetch_env!(:pivotal_codereview, :pivotaltracker_label_name)
  end
end
