defmodule ExProcess.ProcessRunnerParts.TaskRunner do
  @moduledoc """
    This is part of Process Runner which does tasks execution
  """

  def start(state = %{}) do
    state
  end

  def process_tick(state) do
    active_nodes_set = Enum.into(state.active_nodes, MapSet.new())

    # tasks active in the current tick
    current_step_tasks =
      state[:process]
      |> task_ids_set()
      |> MapSet.intersection(active_nodes_set)
      |> MapSet.to_list()

    # Start tasks for the current tick
    state[:process].activities
    |> Enum.filter(&Enum.member?(current_step_tasks, &1.id))
    |> Enum.each(&ExProcess.Matcher.Task.run_match(&1.name))

    state
  end

  def process_message(state, _msg) do
    state
  end

  defp task_ids_set(process) do
    process.activities
    |> Enum.filter(&match?(%ExProcess.Process.Task{}, &1))
    |> Enum.into(MapSet.new(), & &1.id)
  end
end
