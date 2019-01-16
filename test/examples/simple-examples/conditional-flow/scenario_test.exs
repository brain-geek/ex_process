defmodule ExProcess.ConditionalFlowExampleTest do
  use ExUnit.Case

  setup do
    ExProcess.TestTools.reset_state()

    # Set up matchers for this process
    ExProcess.Matcher.Task.register_matcher("Before flow", fn _ -> nil end)
    ExProcess.Matcher.Task.register_matcher("After flow",
      fn _ ->
        ExProcess.PubSub.broadcast(:conditional_example, :it_worked)
      end
    )

    # Subscribe to handler check broadcast
    ExProcess.PubSub.subscribe(self(), :conditional_example)

    :ok
  end

  test "when condition evaluated to true, flow executed" do
    # Run the BPM
    {:ok, xml} = "#{__DIR__}/diagram.bpmn" |> File.read!() |> ExProcess.Bpmn.Parser.parse()
    {:ok, _} = ExProcess.ProcessSupervisor.run(xml, %{process_name: "ConditionalExample"})

    # Set the conditional flow to pass
    ExProcess.Matcher.FlowCondition.register_matcher("If everything is awesome", fn _ -> true end)

    # It should proceed to running handler and therefor receive this message
    assert_receive %ExProcess.PubSub.Message{channel: :conditional_example, info: :it_worked}
  end

  test "when condition evaluated to false, flow doesn't execute" do
    # Run the BPM
    {:ok, xml} = "#{__DIR__}/diagram.bpmn" |> File.read!() |> ExProcess.Bpmn.Parser.parse()
    {:ok, _} = ExProcess.ProcessSupervisor.run(xml, %{process_name: "ConditionalExample"})

    # Set the conditional flow to NOT pass
    ExProcess.Matcher.FlowCondition.register_matcher("If everything is awesome", fn _ -> false end)

    # It should fail the flow check and not receive this message
    refute_receive %ExProcess.PubSub.Message{channel: :conditional_example, info: :it_worked}
  end
end
