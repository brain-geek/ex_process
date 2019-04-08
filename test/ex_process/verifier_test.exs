defmodule ExProcess.VerifierTest do
  use ExUnit.Case, async: true

  describe "verify_links_integrity" do
    test "accepts definitely correct .bpmn files" do
      ["no_start", "small", "start-parallel-end", "only_start_looped", "start-parallel-end"]
      |> Enum.each(fn fixture_name ->
        result = fixture_name
          |> ExProcess.TestTools.fixture()
          |> ExProcess.Bpmn.Parser.parse()
          |> elem(1)
          |> ExProcess.Verifier.check()

        assert(result == :ok, "#{fixture_name} failed check")
      end)
    end

    test "accepts all example .bpmn files" do
      "examples/*/*.bpmn"
      |> Path.wildcard()
      |> Enum.each(fn file_path ->
        {:ok, xml} = file_path |> File.read!() |> ExProcess.Bpmn.Parser.parse()

        assert(ExProcess.Verifier.check(xml) == :ok)
      end)
    end

    test "negative case - start event missing" do
      process = %ExProcess.Process{
        id: "Process_0829syz",
        flows: [
          %ExProcess.Process.Flow{
            id: "SequenceFlow_0kmwis1",
            from: "StartEvent_1x0nb4n",
            to: "Task_1gy68eb"
          }
        ],
        activities: [%ExProcess.Process.Task{id: "Task_1gy68eb", name: "Switch off lightbulb 0"}]
      }

      assert ExProcess.Verifier.check(process) ==
               {:error, "missing elements found", ["StartEvent_1x0nb4n"]}
    end

    test "negative case - task missing" do
      process = %ExProcess.Process{
        id: "Process_0829syz",
        flows: [
          %ExProcess.Process.Flow{
            id: "SequenceFlow_0kmwis1",
            from: "StartEvent_1x0nb4n",
            to: "Task_1gy68eb"
          }
        ],
        events: [
          %ExProcess.Process.StartEvent{id: "StartEvent_1x0nb4n", name: "Switch state changed"}
        ]
      }

      assert ExProcess.Verifier.check(process) ==
               {:error, "missing elements found", ["Task_1gy68eb"]}
    end

    test "negative case - end event missing" do
      process = %ExProcess.Process{
        flows: [
          %ExProcess.Process.Flow{
            from: "StartEvent_1",
            id: "SequenceFlow_1sh87mv",
            to: "EndEvent_0p6f41t"
          }
        ],
        id: "Process_1",
        name: "",
        events: [
          %ExProcess.Process.StartEvent{id: "StartEvent_1", name: "Start 1"}
        ]
      }

      assert ExProcess.Verifier.check(process) ==
               {:error, "missing elements found", ["EndEvent_0p6f41t"]}
    end

    test "negative case - everything missing" do
      process = %ExProcess.Process{
        flows: [
          %ExProcess.Process.Flow{
            from: "StartEvent_1",
            id: "SequenceFlow_1sh87mv",
            to: "EndEvent_0p6f41t"
          },
          %ExProcess.Process.Flow{
            from: "StartEvent_1",
            id: "SequenceFlow_0ku3eag",
            name: "",
            to: "ExclusiveGateway_0169psm"
          }
        ],
        id: "Process_1"
      }

      assert ExProcess.Verifier.check(process) ==
               {:error, "missing elements found",
                ["EndEvent_0p6f41t", "StartEvent_1", "ExclusiveGateway_0169psm"]}
    end
  end
end
