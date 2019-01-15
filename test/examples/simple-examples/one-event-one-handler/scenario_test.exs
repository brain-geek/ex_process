defmodule ExProcess.OneEventOneHandlerExampleTest do
  use ExUnit.Case

  setup do
    ExProcess.TestTools.reset_state()
  end

  test "runs correctly step by step" do
    # Set up check that handler has been run
    ExProcess.Matcher.Task.register_matcher(
      ~r/Test handler/,
      fn _ ->
        ExProcess.PubSub.broadcast(:test_ch, %{it: :works})
      end
    )

    # Subscribe to handler check broadcast
    ExProcess.PubSub.subscribe(self(), :test_ch)

    # Set up event matcher
    ExProcess.Matcher.EventReceive.register_matcher("Test Event", :start)

    # Run the BPM
    {:ok, xml} = "#{__DIR__}/diagram.bpmn" |> File.read!() |> ExProcess.Bpmn.Parser.parse()
    {:ok, _} = ExProcess.ProcessSupervisor.run(xml, %{process_name: "Flow"})

    # # Started with no start nodes
    # assert(ExProcess.ProcessSupervisor.current_state("Flow") == {:ok, []})

    # Broadcast event to start the Flow
    ExProcess.PubSub.broadcast(:start, true)

    # It should proceed to running handler and therefor receive this message
    assert_receive %ExProcess.PubSub.Message{channel: :test_ch, info: %{it: :works}}

    # Task has no outgoing flows flows, so this ends with it being active
    assert(ExProcess.ProcessSupervisor.current_state("Flow") == {:ok, []})
  end
end
