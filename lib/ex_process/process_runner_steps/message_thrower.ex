defmodule ExProcess.ProcessRunnerSteps.MessageThrower do
  use ExProcess.ProcessRunnerStep

  @moduledoc """
    This is part of Process Runner which handles MessageThrowEvent
    nodes, i.e. throws messages to ExProcess internal PubSub
  """

  def process_tick(state) do
    active_nodes_set = Enum.into(state.active_nodes, MapSet.new())

    # Throw events active in the current tick
    current_step_tasks =
      state[:process]
      |> throw_event_ids_set()
      |> MapSet.intersection(active_nodes_set)
      |> MapSet.to_list()

    # Throw events for the current tick
    state[:process].events
    |> Enum.filter(&Enum.member?(current_step_tasks, &1.id))
    |> Enum.each(&ExProcess.Matcher.EventPublish.publish(&1.name))

    update_in(state[:active_nodes], &(&1 -- current_step_tasks))
  end

  defp throw_event_ids_set(process) do
    process.events
    |> Enum.filter(&match?(%ExProcess.Process.MessageThrowEvent{}, &1))
    |> Enum.into(MapSet.new(), & &1.id)
  end
end
