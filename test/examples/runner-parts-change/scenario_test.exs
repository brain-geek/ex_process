defmodule ExProcess.RunnerPartsChangeExampleTest do
  @moduledoc """
    This is based off TickByTickUsageExampleTest, but the difference is that
    due to FlowsNextNodesActivator removed, the second node isn't activated
  """
  use ExUnit.Case

  setup do
    ExProcess.TestTools.reset_state()
  end

  test "runs correctly in step by step mode" do
    # Test handler in this example is empty, as we'll be doing/checking ticks.
    # Actual Task firing logic is tested elsewere, check basic OneEventOneHandlerTest.
    ExProcess.Matcher.Task.register_matcher(~r/\w+ tick task/, fn _ -> nil end)

    # Run the process, note the step_by_step mode requested as well
    {:ok, xml} = "#{__DIR__}/diagram.bpmn" |> File.read!() |> ExProcess.Bpmn.Parser.parse()
    {:ok, _} = ExProcess.ProcessSupervisor.run(xml,
      %{
        process_name: "TickByTick",
        runner_options: %{step_by_step: true},
        parts_list: (ExProcess.ProcessRunnerLogic.default_parts_list() -- [ExProcess.ProcessRunnerParts.FlowsNextNodesActivator])
      })

    # Initial state would be obviously start node, note that it
    # won't change/advance due to special mode enabled
    assert(ExProcess.ProcessSupervisor.current_state("TickByTick") == {:ok, ["StartEvent_0onhtuk"]})

    # Request new tick processing
    ExProcess.ProcessSupervisor.force_tick("TickByTick")

    # Here is the key difference caused by removing ProcessRunnerParts.FlowsNextNodesActivator
    # While in the same case in TickByTickUsageExampleTest (without this change) it causes next node activation,
    # in this case nothing happens, as corresponding middleware for this feature has been disabled

    assert(ExProcess.ProcessSupervisor.current_state("TickByTick") == {:ok, []})
  end
end
