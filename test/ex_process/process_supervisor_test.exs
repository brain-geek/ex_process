defmodule ExProcess.ProcessSupervisorTest do
  use ExUnit.Case

  setup do
    ExProcess.TestTools.reset_state()
  end

  test "assigns process a default name " do
    process = ExProcess.TestTools.parsed_fixture("only_start")

    {:ok, pid} = ExProcess.ProcessSupervisor.run(process)

    assert(
      ExProcess.RunnerProcess.list_running() == [
        {pid, "Process_02qxbgAq"}
      ]
    )
  end

  test "runs and tracks processes" do
    process = ExProcess.TestTools.parsed_fixture("only_start")

    {:ok, pid1} = ExProcess.ProcessSupervisor.run(process, %{process_name: "Test1"})
    {:ok, pid2} = ExProcess.ProcessSupervisor.run(process, %{process_name: "Test2"})

    assert(
      ExProcess.RunnerProcess.list_running() == [
        {pid1, "Test1"},
        {pid2, "Test2"}
      ]
    )
  end

  test "terminates processes by name" do
    process = ExProcess.TestTools.parsed_fixture("only_start")

    {:ok, _pid1} = ExProcess.ProcessSupervisor.run(process, %{process_name: "Test1"})
    {:ok, pid2} = ExProcess.ProcessSupervisor.run(process, %{process_name: "Test2"})

    assert(:ok = ExProcess.ProcessSupervisor.terminate("Test1"))
    assert({:error, "Process not started"} = ExProcess.ProcessSupervisor.terminate("Test5"))

    assert(
      ExProcess.RunnerProcess.list_running() == [
        {pid2, "Test2"}
      ]
    )
  end

  test "does not run duplicate names" do
    process = ExProcess.TestTools.parsed_fixture("only_start")

    {:ok, pid1} = ExProcess.ProcessSupervisor.run(process, %{process_name: "Test"})
    {:error, _} = ExProcess.ProcessSupervisor.run(process, %{process_name: "Test"})

    assert(
      ExProcess.RunnerProcess.list_running() == [
        {pid1, "Test"}
      ]
    )
  end

  test "process data accessors" do
    process = ExProcess.TestTools.parsed_fixture("only_start_looped")

    {:ok, pid} = ExProcess.ProcessSupervisor.run(process, %{process_name: "Africa"})

    assert(ExProcess.RunnerProcess.current_state("Africa") == {:ok, ["StartEvent_1kh4mpv"]})
    assert(ExProcess.RunnerProcess.current_state("Not Africa") == {:error, "Process not started"})

    assert(ExProcess.RunnerProcess.process_pid("Africa") == {:ok, pid})
    assert(ExProcess.RunnerProcess.process_pid("Not Africa") == {:error, "Process not started"})

    assert(ExProcess.RunnerProcess.process_name(pid) == {:ok, "Africa"})
    assert(ExProcess.RunnerProcess.process_name(self()) == {:error, "Process not started"})
  end
end
