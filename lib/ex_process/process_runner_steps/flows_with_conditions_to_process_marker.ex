defmodule ExProcess.ProcessRunnerSteps.FlowsWithConditionsToProcessMarker do
  @moduledoc """
    This is part of Process Runner which marks flows with conditions to process this tick
    (if condition has evaluated to true)
  """

  def start(state = %{}) do
    state
  end

  def process_tick(state) do
    current_tick_conditional_candidate_flows =
      state[:process].flows
      |> Enum.filter(&match?(%ExProcess.Process.ConditionalFlow{}, &1))
      |> Enum.filter(&Enum.member?(state.active_nodes, &1.from))

    current_tick_active_conditional_flows =
      current_tick_conditional_candidate_flows
      |> Enum.filter(&ExProcess.Matcher.FlowCondition.run_match(&1.condition))

    update_in(
      state[:flows_to_process_this_tick],
      &Enum.uniq(&1 ++ current_tick_active_conditional_flows)
    )
  end

  def process_message(state, _msg) do
    state
  end
end
