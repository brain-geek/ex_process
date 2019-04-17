defmodule ExProcess.ProcessRunnerSteps.TaskActivator do
  use ExProcess.ProcessRunnerStep

  @moduledoc """
    This is part of Process Runner which does tasks execution
  """

  def process_tick(state) do
    # Detect which tasks are we going to run
    current_tick_scheduled_tasks =
      state[:process].activities
      |> Enum.filter(&match?(%ExProcess.Process.Task{}, &1))
      |> Enum.filter(&Enum.member?(state[:scheduled_activation], &1.id))

    # Run the actual Task matchers
    current_tick_scheduled_tasks
    |> Enum.each(&ExProcess.Matcher.Task.run_match(&1.name))

    current_tick_scheduled_task_ids = Enum.map(current_tick_scheduled_tasks, & &1.id)

    state =
      update_in(state[:scheduled_activation], &Enum.uniq(&1 -- current_tick_scheduled_task_ids))

    update_in(state[:active_nodes], &Enum.uniq(&1 ++ current_tick_scheduled_task_ids))
  end
end
