defmodule ExProcess.ProcessRunnerSteps.FlowsProcessor do
  @moduledoc """
    This is part of Process Runner which processes flows for this turn
    Bases off the FlowsToProcessMarker result.
  """

  def start(state = %{}) do
    state
  end

  def process_tick(state) do
    activation_from_flows = state[:flows_to_process_this_tick] |> Enum.map(& &1.to)
    deactivation_from_flows = state[:flows_to_process_this_tick] |> Enum.map(& &1.from)

    state = update_in(state[:active_nodes], &(&1 -- deactivation_from_flows))

    update_in(
      state[:scheduled_activation],
      &Enum.uniq(&1 ++ activation_from_flows)
    )
  end

  def process_message(state, _msg) do
    state
  end
end
