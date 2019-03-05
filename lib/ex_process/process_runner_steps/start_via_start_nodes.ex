defmodule ExProcess.ProcessRunnerSteps.StartViaStartNodes do
  use ExProcess.ProcessRunnerStep
  @moduledoc """
    This is part of Process Runner which initializes start nodes for the first tick
  """

  def start(opts = %{process: process, process_name: _}) do
    start_node_ids =
      process.events
      |> Enum.filter(&match?(%ExProcess.Process.StartEvent{}, &1))
      |> Enum.map(fn x -> x.id end)

    Map.put_new(opts, :active_nodes, start_node_ids)
  end
end
