defmodule PivotalCodereview.WebhookHandler do
  require Logger

  @story_id_regex ~r/.*\/(\d+)\/.*/i

  def merge_request_opened(project_id, branch) do
    add_tag(project_id, branch)
  end

  def merge_request_merged(project_id, branch) do
    remove_tag(project_id, branch)
  end

  def merge_request_closed(project_id, branch) do
    remove_tag(project_id, branch)
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
