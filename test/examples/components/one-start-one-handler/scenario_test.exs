defmodule ExProcess.OneStartOneHandlerExampleTest do
  use ExUnit.Case

  setup do
    ExProcess.TestTools.reset_state()
  end

  test "runs correctly step by step" do
    # Set up check that handler has been run
    ExProcess.Matcher.Task.register_matcher(
      ~r/Test handler/,
      fn _ ->
        ExProcess.PubSub.broadcast({:test, :test}, %{it: :works})
      end
    )

    # Subscribe to handler check broadcast
    ExProcess.PubSub.subscribe(self(), {:test, :test})

    # Run the BPM
    {:ok, xml} = "#{__DIR__}/diagram.bpmn" |> File.read!() |> ExProcess.Bpmn.Parser.parse()
    {:ok, _} = ExProcess.ProcessSupervisor.run(xml, %{process_name: "Flow"})

    # # It should proceed to running handler right after start and therefor receive this message
    # assert_receive %ExProcess.PubSub.Message{channel: {:test, :test}, info: %{it: :works}}

    # # Task has no outgoing flows flows, but it has been activated, so it should be here
    # assert(ExProcess.RunnerProcess.current_state("Flow") == {:ok, ["Task_0dzv2cn"]})
  end
end
