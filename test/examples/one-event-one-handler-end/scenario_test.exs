defmodule ExProcess.OneEventOneHandlerEndTest do
  use ExUnit.Case

  setup do
    ExProcess.TestTools.reset_state()
  end

  test "runs correctly step by step" do
    # Set up check that handler has been run
    ExProcess.Matcher.Task.register_matcher(
      "Test handler",
      fn _ ->
        ExProcess.PubSub.broadcast({:test, :test}, %{it: :works})
      end
    )

    # Subscribe to handler check broadcast
    ExProcess.PubSub.subscribe(self(), {:test, :test})

    # Set up event matcher
    ExProcess.Matcher.EventReceive.register_matcher("Test Event", {:test, :start})
    ExProcess.Matcher.EventPublish.register_matcher("Publish Test Event", {:test, :start})

    # Run the BPM
    {:ok, xml} = "#{__DIR__}/diagram.bpmn" |> File.read!() |> ExProcess.Parser.parse()
    {:ok, _} = ExProcess.ProcessSupervisor.run(xml, %{process_name: "Flow"})

    # Started with no start nodes
    assert(ExProcess.ProcessSupervisor.current_state("Flow") == {:ok, []})

    # Broadcast event to start the Flow
    ExProcess.PubSub.broadcast("Publish Test Event")

    # It should proceed to running handler and therefor receive this message
    assert_receive %ExProcess.PubSub.Message{channel: {:test, :test}, info: %{it: :works}}

    # It has flows to end, so this ends ending with empty state
    assert(ExProcess.ProcessSupervisor.current_state("Flow") == {:ok, []})
  end
end
