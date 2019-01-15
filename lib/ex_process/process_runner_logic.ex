defmodule ExProcess.ProcessRunnerLogic do
  @moduledoc """
    Logic of the BPMN flow runner
  """

  @doc """
    The default list of parts used in BPM engine.
    This list may change between versions due to being internal to
    ExProcess, so the recommended way is basing off this function
    result when doing customizations.
  """
  def default_parts_list do
    [
      ExProcess.ProcessRunnerParts.StartViaStartNodes,
      ExProcess.ProcessRunnerParts.MessageCatcher,
      ExProcess.ProcessRunnerParts.TaskRunner,
      ExProcess.ProcessRunnerParts.MessageThrower,
      ExProcess.ProcessRunnerParts.FlowsNextNodesActivator,
      ExProcess.ProcessRunnerParts.NewTickStarter
    ]
  end

  def start(opts = %{process: _, process_name: _}) do
    parts_list = opts |> Map.get(:parts_list, default_parts_list())
    start_state = opts |> Map.merge(%{active_next_tick: [], parts_list: parts_list})

    Enum.reduce(parts_list, start_state, fn part, st -> part.start(st) end)
  end

  def process_tick(state) do
    state[:parts_list]
    |> Enum.reduce(state, fn part, st -> part.process_tick(st) end)
  end

  def process_message(state, msg) do
    Enum.reduce(state[:parts_list], state, fn part, st -> part.process_message(st, msg) end)
  end
end
