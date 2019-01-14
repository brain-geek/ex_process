defmodule ExProcess.ProcessRunnerParts.FlowsNextNodesActivator do
  @moduledoc """
    This is part of Process Runner which marks nodes connected by flows
    to be active in the next tick
  """

  def start(state = %{}) do
    state
  end

  def process_tick(state) do
    active_next_tick_from_flows =
      state[:process].flows
      |> Enum.filter(&match?(%ExProcess.Process.Flow{}, &1))
      |> Enum.filter(&Enum.member?(state.active_nodes, &1.from))
      |> Enum.map(& &1.to)

    update_in(state[:active_next_tick], &(&1 ++ active_next_tick_from_flows))
  end

  def process_message(state, _msg) do
    state
  end
end
