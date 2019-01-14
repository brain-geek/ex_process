defmodule ExProcess.ProcessSupervisorTest do
  use ExUnit.Case

  setup do
    ExProcess.TestTools.reset_state()
  end

  test "assigns process a default name " do
    process = ExProcess.TestTools.parsed_fixture("only_start")

    {:ok, pid} = ExProcess.ProcessSupervisor.run(process)

    assert(
      ExProcess.ProcessSupervisor.list_running() == [
        {pid, "Process_02qxbgAq"}
      ]
    )
  end

  test "runs and tracks processes" do
    process = ExProcess.TestTools.parsed_fixture("only_start")

    {:ok, pid1} = ExProcess.ProcessSupervisor.run(process, %{process_name: "Test1"})
    {:ok, pid2} = ExProcess.ProcessSupervisor.run(process, %{process_name: "Test2"})

    assert(
      ExProcess.ProcessSupervisor.list_running() == [
        {pid1, "Test1"},
        {pid2, "Test2"}
      ]
    )
  end

  test "does not run duplicate names" do
    process = ExProcess.TestTools.parsed_fixture("only_start")

    {:ok, pid1} = ExProcess.ProcessSupervisor.run(process, %{process_name: "Test"})
    {:error, _} = ExProcess.ProcessSupervisor.run(process, %{process_name: "Test"})

    assert(
      ExProcess.ProcessSupervisor.list_running() == [
        {pid1, "Test"}
      ]
    )
  end

  test "process data accessors" do
    process = ExProcess.TestTools.parsed_fixture("only_start_looped")

    {:ok, pid} = ExProcess.ProcessSupervisor.run(process, %{process_name: "Africa"})

    assert(ExProcess.ProcessSupervisor.current_state("Africa") == {:ok, ["StartEvent_1kh4mpv"]})

    assert(ExProcess.ProcessSupervisor.process_pid("Africa") == pid)
    assert(ExProcess.ProcessSupervisor.process_name(pid) == "Africa")
  end
end
