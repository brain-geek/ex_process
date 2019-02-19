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
  def default_steps_list do
    [
      # Startup only
      ExProcess.ProcessRunnerSteps.StartViaStartNodes,

      # Mark flows for execution
      ExProcess.ProcessRunnerSteps.FlowsToProcessMarker,

      # Messaging
      ExProcess.ProcessRunnerSteps.MessageCatcher,
      ExProcess.ProcessRunnerSteps.MessageThrower,

      # Executing Flows logic
      ExProcess.ProcessRunnerSteps.FlowsWithConditionsToProcessMarker,
      ExProcess.ProcessRunnerSteps.FlowsExclusiveGatewayProcessor,
      ExProcess.ProcessRunnerSteps.FlowsProcessor,

      # Activating activities (they were marked mostly in FlowsProcessor)
      ExProcess.ProcessRunnerSteps.TaskActivator,

      # Disabling end event scheduled for start
      ExProcess.ProcessRunnerSteps.EndEventFinisher,

      # Prepare/cleanup state before next tick
      ExProcess.ProcessRunnerSteps.NewTickStarter
    ]
  end

  def start(opts = %{process: _, process_name: _}) do
    steps_list = opts |> Map.get(:steps_list, default_steps_list())

    start_state =
      opts
      |> Map.merge(%{
        scheduled_activation: [],
        flows_to_process_this_tick: [],
        steps_list: steps_list
      })

    Enum.reduce(steps_list, start_state, fn part, st -> part.start(st) end)
  end

  def process_tick(state) do
    Enum.reduce(state[:steps_list], state, fn part, st -> part.process_tick(st) end)
  end

  def process_message(state, msg) do
    Enum.reduce(state[:steps_list], state, fn part, st -> part.process_message(st, msg) end)
  end
end
