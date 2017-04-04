defmodule PivotalCodereview.Tracker do
  @endpoint Application.fetch_env!(:pivotal_codereview, :pivotaltracker_endpoint)
  @token_header "X-TrackerToken"

  def get_projects_stories_labels(token, project_id, story_id) do
    url = full_url("/projects/#{project_id}/stories/#{story_id}/labels")

    HTTPoison.get!(url, headers(token)).body
    |> Poison.decode!
  end

  def post_projects_stories_labels(token, project_id, story_id, params) do
    url = full_url("/projects/#{project_id}/stories/#{story_id}/labels")
    body = Poison.encode!(params)

    HTTPoison.post!(url, body, post_headers(token)).body
    |> Poison.decode!
  end

  def delete_projects_stories_labels(token, project_id, story_id, label_id) do
    url = full_url("/projects/#{project_id}/stories/#{story_id}/labels/#{label_id}")

    HTTPoison.delete!(url, post_headers(token)).body
    |> Poison.decode!
  end

  defp full_url(url) do
    @endpoint <> url
  end

  defp headers(token) do
    [{"Accept", "Application/json; Charset=utf-8"}, {@token_header, token}]
  end

  defp post_headers(token) do
    [{"Content-Type", "application/json"} | headers(token)]
  end
end
