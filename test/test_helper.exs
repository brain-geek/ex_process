ExUnit.start()

defmodule ExProcess.TestTools do
  def reset_state do
    # Clear processes
    Application.ensure_all_started(:ex_process)
    Supervisor.terminate_child(ExProcess.Supervisor, ExProcess.ProcessSupervisor)
    Supervisor.restart_child(ExProcess.Supervisor, ExProcess.ProcessSupervisor)

    # Clear matchers
    Agent.update(ExProcess.Matcher.Task, fn _ -> MapSet.new() end)

    # Clear event matchers
    Agent.update(ExProcess.Matcher.EventPublish, fn _ -> MapSet.new() end)
    Agent.update(ExProcess.Matcher.EventReceive, fn _ -> MapSet.new() end)

    :ok
  end

  def fixture(name) do
    File.read!("./test/fixtures/#{name}.bpmn")
  end

  def parsed_fixture(name) do
    {:ok, process} = name |> fixture() |> ExProcess.Bpmn.Parser.parse()
    process
  end
end
