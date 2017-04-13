defmodule PivotalCodereview.LabelAction do
  use GenServer

  require Logger

  defmodule State do
    defstruct [:project_id, :story_id, :action, :retry_number]
  end

  @max_retries 10
  @delay_factor 2

  ## Client API

  # @spec start_link(project_id :: String.t, story_id :: String.t, action :: :add | :remove) :: any
  def start_link(project_id, story_id, action) do
    state = %State{
      project_id: project_id,
      story_id: story_id,
      action: action,
      retry_number: 0
    }

    GenServer.start_link(__MODULE__, state, [])
  end

  ## Server Callbacks

  def init(state) do
    schedule_next_try(state.retry_number)
    {:ok, state}
  end

  def handle_info(:next_try, state) do
    Logger.info("Performing action #{state.action}")
    Logger.info("Project ID: #{state.project_id}, story ID: #{state.story_id}. Retry: #{state.retry_number}")

    action_result =
      case state.action do
        :add -> add_label(state)
        :remove -> remove_label(state)
      end

    case action_result do
      :ok ->
        {:stop, :normal, state}
      :err ->
        if state.retry_number < @max_retries do
          state = Map.put(state, :retry_number, state.retry_number + 1)
          schedule_next_try(state.retry_number)
          {:noreply, state}
        else
          {:stop, :normal, state}
        end
    end
  end

  def schedule_next_try(retry_number) do
    delay = trunc(:math.pow(retry_number, @delay_factor)) * 1000
    Process.send_after(self(), :next_try, delay)
  end

  defp add_label(state) do
    params =  %{"name": tracker_label()}

    resp = PivotalCodereview.Tracker.post_projects_stories_labels(tracker_token(),
      state.project_id, state.story_id,  params)
    Logger.info(inspect(resp))

    case resp do
      body when is_map(body) ->
        :ok
      {_http_code, _err_body} ->
        :err
    end
  end

  defp remove_label(state) do
    case get_label_id(state.project_id, state.story_id) do
      {:ok, label_id} ->
        Logger.info("Label ID to remove: #{label_id}")

        case remove_label_by_id(state.project_id, state.story_id, label_id) do
          {:ok} ->
            :ok
          _ ->
            :err
        end
      _ ->
        :err
    end
  end

  defp tracker_token() do
    Application.fetch_env!(:pivotal_codereview, :pivotaltracker_token)
  end

  defp tracker_label() do
    Application.fetch_env!(:pivotal_codereview, :pivotaltracker_label_name)
  end

  defp get_label_id(project_id, story_id) do
    label_name = tracker_label()
    resp = PivotalCodereview.Tracker.get_projects_stories_labels(tracker_token(),
      project_id, story_id)

    case resp do
      labels when is_list(labels) ->
        label_id = Enum.find_value(labels, fn(label) ->
          match?(%{"kind" => "label", "name" => ^label_name}, label) && label["id"]
        end)

        if label_id do
          {:ok, label_id}
        else
          {:err, :label_not_found}
        end
      {http_code, err_body} ->
        {:err, http_code, err_body}
    end
  end

  defp remove_label_by_id(project_id, story_id, label_id) do
    resp = PivotalCodereview.Tracker.delete_projects_stories_labels(tracker_token(),
      project_id, story_id, label_id)

    Logger.info(inspect(resp))

    case resp do
      body when is_map(body) ->
        {:ok}
      {http_code, err_body} ->
        {:err, http_code, err_body}
    end
  end
end
