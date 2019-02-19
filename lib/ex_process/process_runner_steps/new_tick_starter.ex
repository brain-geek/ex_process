defmodule ExProcess.ProcessRunnerSteps.NewTickStarter do
  @moduledoc """
    This is part of Process Runner which sets all next tick
    acive nodes to be active in the new tick
  """

  def start(state = %{}) do
    state
  end

  def process_tick(state) do
    active_next_tick =
      (state[:active_nodes] ++ (state[:scheduled_activation] || [])) |> Enum.uniq()

    Map.merge(state, %{
      active_nodes: active_next_tick,
      scheduled_activation: [],
      flows_to_process_this_tick: []
    })
  end

  def process_message(state, _msg) do
    state
  end
end
