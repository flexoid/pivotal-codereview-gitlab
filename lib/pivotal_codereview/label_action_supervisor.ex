defmodule PivotalCodereview.LabelActionSupervisor do
  use Supervisor

  @name PivotalCodereview.LabelActionSupervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def add_label(project_id, story_id) do
    Supervisor.start_child(@name, [project_id, story_id, :add])
  end

  def remove_label(project_id, story_id) do
    Supervisor.start_child(@name, [project_id, story_id, :remove])
  end

  def init(:ok) do
    children = [
      worker(PivotalCodereview.LabelAction, [], restart: :temporary)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
