defmodule ExProcess.ProcessRunnerTest do
  use ExUnit.Case

  setup do
    ExProcess.TestTools.reset_state()
  end

  describe "initital state" do
    test "accepts custom sent name for process" do
      process = ExProcess.TestTools.parsed_fixture("only_start_looped")

      {:ok, pid} = ExProcess.ProcessSupervisor.run(process, %{process_name: "Africa"})

      starts =
        process.events
        |> Enum.filter(&match?(%ExProcess.Process.StartEvent{}, &1))
        |> Enum.map(fn x -> x.id end)

      assert(ExProcess.ProcessSupervisor.current_state("Africa") == {:ok, starts})

      assert(ExProcess.ProcessSupervisor.process_pid("Africa") == {:ok, pid})
      assert(ExProcess.ProcessSupervisor.process_name(pid) == {:ok, "Africa"})
    end
  end

  describe "step-by-step mode" do
    test "works correctly" do
      process = ExProcess.TestTools.parsed_fixture("only_start")

      {:ok, _} =
        ExProcess.ProcessSupervisor.run(process, %{
          process_name: "T",
          runner_options: %{step_by_step: true}
        })

      assert(ExProcess.ProcessSupervisor.current_state("T") == {:ok, ["StartEvent_1kh4mpv"]})
    end
  end
end
