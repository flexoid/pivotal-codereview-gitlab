defmodule PivotalCodereview.WebhookHandler do
  require Logger

  @story_id_regex ~r/.*\/(\d+)\/.*/i

  def merge_request_opened(project_id, branch) do
    story_id = extract_story_id(branch)
    if story_id do
      PivotalCodereview.LabelActionSupervisor.add_label(project_id, story_id)
    end
  end

  def merge_request_merged(project_id, branch) do
    story_id = extract_story_id(branch)
    if story_id do
      PivotalCodereview.LabelActionSupervisor.remove_label(project_id, story_id)
    end
  end

  def merge_request_closed(project_id, branch) do
    story_id = extract_story_id(branch)
    if story_id do
      PivotalCodereview.LabelActionSupervisor.remove_label(project_id, story_id)
    end
  end

  defp extract_story_id(branch_name) do
    @story_id_regex
    |> Regex.scan(branch_name)
    |> Enum.flat_map(fn([_ | match]) -> match end)
    |> Enum.at(0)
  end
end
