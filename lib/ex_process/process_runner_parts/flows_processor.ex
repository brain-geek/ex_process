defmodule ExProcess.ProcessRunnerParts.FlowsProcessor do
  @moduledoc """
    This is part of Process Runner which processes flows for this turn
    Bases off the FlowsToProcessMarker result.
  """

  def start(state = %{}) do
    state
  end

  def process_tick(state) do
    active_next_tick_from_flows = state[:flows_to_process_this_tick] |> Enum.map(& &1.to)

    update_in(state[:active_next_tick], &Enum.uniq(&1 ++ active_next_tick_from_flows))
  end

  def process_message(state, _msg) do
    state
  end
end
