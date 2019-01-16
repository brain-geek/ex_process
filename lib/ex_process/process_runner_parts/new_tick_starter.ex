defmodule ExProcess.ProcessRunnerParts.NewTickStarter do
  @moduledoc """
    This is part of Process Runner which sets all next tick
    acive nodes to be active in the new tick
  """

  def start(state = %{}) do
    state
  end

  def process_tick(state) do
    active_next_tick = state[:active_next_tick] |> Enum.uniq()
    Map.merge(state, %{active_nodes: active_next_tick, active_next_tick: []})
  end

  def process_message(state, _msg) do
    state
  end
end
