defmodule ExProcess.ProcessRunnerSteps.FlowsToProcessMarker do
  use ExProcess.ProcessRunnerStep

  @moduledoc """
    This is part of Process Runner which marks unconditional flows to process this tick
  """

  def process_tick(state) do
    current_tick_active_flows =
      state[:process].flows
      |> Enum.filter(&match?(%ExProcess.Process.Flow{}, &1))
      |> Enum.filter(&Enum.member?(state.active_nodes, &1.from))

    update_in(state[:flows_to_process_this_tick], &Enum.uniq(&1 ++ current_tick_active_flows))
  end
end
