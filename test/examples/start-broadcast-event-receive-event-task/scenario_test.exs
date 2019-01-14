defmodule ExProcess.StartBroadcastEventReceiveEventTask do
  use ExUnit.Case

  setup do
    ExProcess.TestTools.reset_state()
  end

  test "runs correctly" do
    # Set up check that handler has been run to receive event from process
    ExProcess.Matcher.Task.register_matcher(
      "Triggered via broadcast",
      fn _ ->
        ExProcess.PubSub.broadcast(:from_process, %{it: :works})
      end
    )

    ExProcess.PubSub.subscribe(self(), :from_process)

    # Set up event sender and receiver to work in tandem
    ExProcess.Matcher.EventPublish.register_matcher("Broadcast event", :inside_process)
    ExProcess.Matcher.EventReceive.register_matcher("Broadcast receiver", :inside_process)

    {:ok, xml} = "#{__DIR__}/diagram.bpmn" |> File.read!() |> ExProcess.Parser.parse()
    {:ok, _} = ExProcess.ProcessSupervisor.run(xml, %{process_name: "Flow"})

    # It should proceed to running handler right after start and therefor receive this message
    assert_receive %ExProcess.PubSub.Message{channel: :from_process, info: %{it: :works}}

    # Task has no outgoing flows flows, so this ends with it being active
    assert(ExProcess.ProcessSupervisor.current_state("Flow") == {:ok, []})
  end
end
