defmodule ExProcess.ProcessRunnerParts.NewTickStarter do
  @moduledoc """
    This is part of Process Runner which sets all next tick
    acive nodes to be active in the new tick
  """

  def start(state = %{}) do
    state
  end

  def process_tick(state) do
    Map.merge(state, %{active_nodes: state[:active_next_tick], active_next_tick: []})
  end

  def process_message(state, _msg) do
    state
  end
end
