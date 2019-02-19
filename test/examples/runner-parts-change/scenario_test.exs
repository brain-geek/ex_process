defmodule ExProcess.RunnerPartsChangeExampleTest do
  @moduledoc """
    This is based off TickByTickUsageExampleTest, but the difference is that
    due to FlowsNextNodesActivator is removed, so the second node isn't activated
  """
  use ExUnit.Case

  setup do
    ExProcess.TestTools.reset_state()
  end

  test "runs correctly in step by step mode" do
    # Test handler in this example is empty, as we'll be doing/checking ticks.
    # Actual Task firing logic is tested elsewere, check basic OneEventOneHandlerTest.
    ExProcess.Matcher.Task.register_matcher(~r/\w+ runner parts task/, fn _ -> nil end)

    # Run the process, note the step_by_step mode requested as well
    {:ok, xml} = "#{__DIR__}/diagram.bpmn" |> File.read!() |> ExProcess.Bpmn.Parser.parse()

    {:ok, _} =
      ExProcess.ProcessSupervisor.run(
        xml,
        %{
          process_name: "RunnerPartsChange",
          runner_options: %{step_by_step: true},
          steps_list:
            ExProcess.ProcessRunnerLogic.default_steps_list() --
              [ExProcess.ProcessRunnerSteps.FlowsProcessor]
        }
      )

    # Initial state would be obviously start node, note that it
    # won't change/advance due to special mode enabled
    assert(
      ExProcess.ProcessSupervisor.current_state("RunnerPartsChange") ==
        {:ok, ["StartEvent_0onhtuk"]}
    )

    # Request new tick processing
    ExProcess.ProcessSupervisor.force_tick("RunnerPartsChange")

    # As process here has FlowsProcessor disabled, no states are being changed.
    assert(
      ExProcess.ProcessSupervisor.current_state("RunnerPartsChange") ==
        {:ok, ["StartEvent_0onhtuk"]}
    )
  end
end
