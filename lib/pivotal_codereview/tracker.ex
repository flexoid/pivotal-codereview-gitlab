defmodule PivotalCodereview.Tracker do
  @endpoint "https://www.pivotaltracker.com/services/v5"
  @token_header "X-TrackerToken"

  def get_projects_stories_labels(token, project_id, story_id) do
    url = full_url("/projects/#{project_id}/stories/#{story_id}/labels")

    HTTPoison.get!(url, headers(token)).body
    |> Poison.decode!

    # [%{"created_at" => "2016-08-08T17:48:42Z", "id" => 16067795, "kind" => "label",
    #    "name" => "control api", "project_id" => 526263,
    #    "updated_at" => "2016-08-08T17:48:42Z"},
    #  %{"created_at" => "2016-11-15T12:56:08Z", "id" => 16969787, "kind" => "label",
    #    "name" => "v21", "project_id" => 526263,
    #    "updated_at" => "2016-11-15T12:56:08Z"}]
  end

  def post_projects_stories_labels(token, project_id, story_id, params) do
    url = full_url("/projects/#{project_id}/stories/#{story_id}/labels")
    body = Poison.encode!(params)

    HTTPoison.post!(url, body, post_headers(token)).body
    |> Poison.decode!

    # %{"created_at" => "2016-09-05T13:20:00Z", "id" => 16354853, "kind" => "label",
    #   "name" => "v20", "project_id" => 526263,
    #   "updated_at" => "2016-09-05T13:20:00Z"}
  end

  def delete_projects_stories_labels(token, project_id, story_id, label_id) do
    url = full_url("/projects/#{project_id}/stories/#{story_id}/labels/#{label_id}")

    HTTPoison.delete!(url, post_headers(token)).body
    |> Poison.decode!

    # %{"created_at" => "2016-09-05T13:20:00Z", "id" => 16354853, "kind" => "label",
    #   "name" => "v20", "project_id" => 526263,
    #   "updated_at" => "2016-09-05T13:20:00Z"}
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
