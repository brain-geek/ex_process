defmodule ExProcess.ProcessRunnerParts.FlowsToProcessMarker do
  @moduledoc """
    This is part of Process Runner which marks flows to process this tick
  """

  def start(state = %{}) do
    state
  end

  def process_tick(state) do
    current_tick_active_flows =
      state[:process].flows
      |> Enum.filter(&match?(%ExProcess.Process.Flow{}, &1))
      |> Enum.filter(&Enum.member?(state.active_nodes, &1.from))

    put_in(state[:flows_to_process_this_tick], current_tick_active_flows)
  end

  def process_message(state, _msg) do
    state
  end
end