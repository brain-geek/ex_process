defmodule ExProcess.TickByTickUsageExampleTest do
  use ExUnit.Case

  setup do
    ExProcess.TestTools.reset_state()
  end

  test "runs correctly step by step" do
    # Test handler in this example is empty, as we'll be doing/checking ticks.
    # Actual Task firing logic is tested elsewere, check basic OneEventOneHandlerTest.
    ExProcess.Matcher.Task.register_matcher(~r/\w+ tick task/, fn _ -> nil end)

    # Run the process, note the step_by_step mode requested
    {:ok, xml} = "#{__DIR__}/diagram.bpmn" |> File.read!() |> ExProcess.Bpmn.Parser.parse()

    {:ok, _} =
      ExProcess.ProcessSupervisor.run(xml, %{
        process_name: "TickByTick",
        runner_options: %{step_by_step: true}
      })

    # Initial state would be obviously start node, note that it
    # won't change/advance due to special mode enabled
    assert(
      ExProcess.ProcessSupervisor.current_state("TickByTick") == {:ok, ["StartEvent_0onhtuk"]}
    )

    # Request new tick processing
    ExProcess.ProcessSupervisor.force_tick("TickByTick")

    # Note that after requesting to process one more tick we now have next process state
    assert(ExProcess.ProcessSupervisor.current_state("TickByTick") == {:ok, ["Task_1_tick"]})

    # Request the third tick processing
    ExProcess.ProcessSupervisor.force_tick("TickByTick")

    assert(
      ExProcess.ProcessSupervisor.current_state("TickByTick") ==
        {:ok, ["Task_2_tick_first", "Task_2_tick_second"]}
    )

    # Request the final tick processing
    ExProcess.ProcessSupervisor.force_tick("TickByTick")

    # Due to not having any outgoing flows this process will now have zero active nodes
    assert(ExProcess.ProcessSupervisor.current_state("TickByTick") == {:ok, []})
  end
end
