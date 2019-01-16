defmodule ExProcess.ExclusiveGatewayLogicExampleTest do
  use ExUnit.Case

  setup do
    ExProcess.TestTools.reset_state()

    # Actual Task firing logic is tested elsewere, check basic OneEventOneHandlerTest.
    ExProcess.Matcher.Task.register_matcher(~r/Task \w+/, fn _ -> nil end)
  end

  @process_name "Parallel"

  test "activates all the outgoing flows" do
    # Run the process, note the step_by_step mode requested
    {:ok, xml} = "#{__DIR__}/split_state.bpmn" |> File.read!() |> ExProcess.Bpmn.Parser.parse()

    {:ok, _} =
      ExProcess.ProcessSupervisor.run(xml, %{
        process_name: @process_name,
        runner_options: %{step_by_step: true}
      })

    # Initial state would be start node
    assert(
      ExProcess.ProcessSupervisor.current_state(@process_name) == {:ok, ["StartEvent_168gadc"]}
    )

    # Request new tick processing
    ExProcess.ProcessSupervisor.force_tick(@process_name)

    # On the second tick we have Exclusive Gateway activated
    assert(
      ExProcess.ProcessSupervisor.current_state(@process_name) ==
        {:ok, ["ExclusiveGateway_161dqo9"]}
    )

    # Request new tick processing
    ExProcess.ProcessSupervisor.force_tick(@process_name)

    # On the next tick we're having both Tasks enabled
    assert(
      ExProcess.ProcessSupervisor.current_state(@process_name) ==
        {:ok, ["Task_1wpg8n3", "Task_1v0sozz"]}
    )
  end

  test "activates outgoing flow when all incoming flows are active" do
    {:ok, xml} = "#{__DIR__}/positive_case.bpmn" |> File.read!() |> ExProcess.Bpmn.Parser.parse()

    {:ok, _} =
      ExProcess.ProcessSupervisor.run(xml, %{
        process_name: @process_name,
        runner_options: %{step_by_step: true}
      })

    # Initial state would be start node
    assert(
      ExProcess.ProcessSupervisor.current_state(@process_name) == {:ok, ["StartEvent_168gadc"]}
    )

    # On the second tick we have both tasks activated
    ExProcess.ProcessSupervisor.force_tick(@process_name)

    assert(
      ExProcess.ProcessSupervisor.current_state(@process_name) ==
        {:ok, ["Task_1wpg8n3", "Task_1v0sozz"]}
    )

    # On the third tick we have Gateway activated because it has all the incoming flows active
    ExProcess.ProcessSupervisor.force_tick(@process_name)

    assert(
      ExProcess.ProcessSupervisor.current_state(@process_name) ==
        {:ok, ["ExclusiveGateway_034og2t"]}
    )

    # On the last tick we see that final task has been enabled
    ExProcess.ProcessSupervisor.force_tick(@process_name)
    assert(ExProcess.ProcessSupervisor.current_state(@process_name) == {:ok, ["Task_0i98aym"]})
  end

  test "does not activate outgoing flow when not all incoming flows are active" do
    {:ok, xml} = "#{__DIR__}/negative_case.bpmn" |> File.read!() |> ExProcess.Bpmn.Parser.parse()

    {:ok, _} =
      ExProcess.ProcessSupervisor.run(xml, %{
        process_name: @process_name,
        runner_options: %{step_by_step: true}
      })

    # Initial state would be start node
    assert(
      ExProcess.ProcessSupervisor.current_state(@process_name) == {:ok, ["StartEvent_168gadc"]}
    )

    # On the second tick we have the task B activated
    ExProcess.ProcessSupervisor.force_tick(@process_name)
    assert(ExProcess.ProcessSupervisor.current_state(@process_name) == {:ok, ["Task_1v0sozz"]})

    # Gateway not activated due to not having all the needed flows
    ExProcess.ProcessSupervisor.force_tick(@process_name)
    assert(ExProcess.ProcessSupervisor.current_state(@process_name) == {:ok, []})
  end
end
