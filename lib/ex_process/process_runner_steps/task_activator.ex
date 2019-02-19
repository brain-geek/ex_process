defmodule ExProcess.ProcessRunnerSteps.TaskActivator do
  @moduledoc """
    This is part of Process Runner which does tasks execution
  """

  def start(state = %{}) do
    state
  end

  def process_tick(state) do
    # Detect which tasks are we going to run
    current_tick_scheduled_tasks =
      state[:process].activities
      |> Enum.filter(&match?(%ExProcess.Process.Task{}, &1))
      |> Enum.filter(&Enum.member?(state[:scheduled_activation], &1.id))

    # Run the actual Task matchers
    current_tick_scheduled_tasks
      |> Enum.each(&ExProcess.Matcher.Task.run_match(&1.name))

    # require IEx; IEx.pry()

    current_tick_scheduled_task_ids = Enum.map(current_tick_scheduled_tasks, &(&1.id))

    state = update_in(state[:scheduled_activation], &Enum.uniq(&1 -- current_tick_scheduled_task_ids))
    update_in(state[:active_nodes], &Enum.uniq(&1 ++ current_tick_scheduled_task_ids))
  end

  def process_message(state, _msg) do
    state
  end
end
