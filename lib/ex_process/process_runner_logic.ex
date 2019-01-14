defmodule ExProcess.ProcessRunnerLogic do
  @moduledoc """
    Logic of the BPMN flow runner
  """

  @parts_list [
    ExProcess.ProcessRunnerParts.StartViaStartNodes,
    ExProcess.ProcessRunnerParts.MessageCatcher,
    ExProcess.ProcessRunnerParts.TaskRunner,
    ExProcess.ProcessRunnerParts.MessageThrower,
    ExProcess.ProcessRunnerParts.FlowsNextNodesActivator,
    ExProcess.ProcessRunnerParts.NewTickStarter
  ]

  def start(opts = %{process: _, process_name: _}) do
    start_state = opts |> Map.merge(%{active_next_tick: []})

    Enum.reduce(@parts_list, start_state, fn part, st -> part.start(st) end)
  end

  def process_tick(state) do
    @parts_list
    |> Enum.reduce(state, fn part, st -> part.process_tick(st) end)
  end

  def process_message(state, msg) do
    Enum.reduce(@parts_list, state, fn part, st -> part.process_message(st, msg) end)
  end
end
