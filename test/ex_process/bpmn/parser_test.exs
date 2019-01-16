defmodule ExProcess.Bpmn.ParserTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureLog

  describe "parse" do
    test "it fails when XML is mailformed" do
      capture_log(fn ->
        assert(ExProcess.Bpmn.Parser.parse("Hello world") == {:error, "Unable to parse XML"})
      end)
    end

    test "it fails when no elements found" do
      assert(
        ExProcess.Bpmn.Parser.parse(~s(<?xml version="1.0" encoding="UTF-8"?><a></a>)) ==
          {:error, "Unable to find process element"}
      )
    end

    test "empty BPMN" do
      xml = ExProcess.TestTools.fixture("no_start")

      assert(
        ExProcess.Bpmn.Parser.parse(xml) ==
          {:ok,
           %ExProcess.Process{
             id: "Process_1nm1w9v",
             name: "Test tiny process"
           }}
      )
    end

    test "BPMN with only message throw event" do
      xml = ExProcess.TestTools.fixture("only_interim_event")

      assert(
        ExProcess.Bpmn.Parser.parse(xml) ==
          {:ok,
           %ExProcess.Process{
             events: [
               %ExProcess.Process.MessageThrowEvent{
                 id: "IntermediateThrowEvent_1pfwjvv",
                 name: "Test Event"
               }
             ],
             id: "sid-C3803939-0872-457F-8336-EAE484DC4A04",
             name: "Customer"
           }}
      )
    end

    test "BPMN with few objects correctly" do
      xml = ExProcess.TestTools.fixture("small")

      assert(
        ExProcess.Bpmn.Parser.parse(xml) ==
          {:ok,
           %ExProcess.Process{
             id: "Process_0829syz",
             flows: [
               %ExProcess.Process.Flow{
                 id: "SequenceFlow_0kmwis1",
                 from: "StartEvent_1x0nb4n",
                 to: "Task_1gy68eb"
               }
             ],
             events: [
               %ExProcess.Process.StartEvent{
                 id: "StartEvent_1x0nb4n",
                 name: "Switch state changed"
               }
             ],
             activities: [
               %ExProcess.Process.Task{id: "Task_1gy68eb", name: "Switch off lightbulb 0"}
             ]
           }}
      )
    end

    test "BPMN with start, parallel gateway and end" do
      xml = ExProcess.TestTools.fixture("start-parallel-end")

      assert(
        ExProcess.Bpmn.Parser.parse(xml) ==
          {:ok,
           %ExProcess.Process{
             flows: [
               %ExProcess.Process.Flow{
                 from: "StartEvent_1",
                 id: "SequenceFlow_1sh87mv",
                 name: "",
                 to: "ExclusiveGateway_0169psm"
               },
               %ExProcess.Process.Flow{
                 from: "Task_1jo73o5",
                 id: "SequenceFlow_0d99rmu",
                 name: "",
                 to: "EndEvent_0p6f41t"
               },
               %ExProcess.Process.Flow{
                 from: "StartEvent_07knhrl",
                 id: "SequenceFlow_0ku3eag",
                 name: "",
                 to: "ExclusiveGateway_0169psm"
               },
               %ExProcess.Process.Flow{
                 from: "ExclusiveGateway_0169psm",
                 id: "SequenceFlow_1sttm64",
                 name: "",
                 to: "Task_1jo73o5"
               }
             ],
             id: "Process_1",
             name: "",
             events: [
               %ExProcess.Process.StartEvent{id: "StartEvent_1", name: "Start 1"},
               %ExProcess.Process.StartEvent{id: "StartEvent_07knhrl", name: "Start 2"},
               %ExProcess.Process.EndEvent{id: "EndEvent_0p6f41t", name: "The end"}
             ],
             activities: [
               %ExProcess.Process.Task{id: "Task_1jo73o5", name: "Task"},
               %ExProcess.Process.ExclusiveGateway{
                 id: "ExclusiveGateway_0169psm",
                 name: "Parallel Gateway - converging"
               }
             ]
           }}
      )
    end

    test "BPMN with message send/receive" do
      xml = ExProcess.TestTools.fixture("message-throw-catch")

      assert(
        ExProcess.Bpmn.Parser.parse(xml) ==
          {:ok,
           %ExProcess.Process{
             flows: [],
             id: "sid-C3803939-0872-457F-8336-EAE484DC4A04",
             name: "Customer",
             events: [
               %ExProcess.Process.MessageThrowEvent{
                 id: "IntermediateThrowEvent_0vky209",
                 name: "Something sent here"
               },
               %ExProcess.Process.MessageCatchEvent{
                 id: "IntermediateCatchEvent_12ds6wx",
                 name: "Something received here"
               }
             ],
             activities: []
           }}
      )
    end
  end
end
