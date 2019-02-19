defmodule ExProcess.ProcessRunnerLogicTest do
  use ExUnit.Case, async: true

  describe "ProcessRunnerLogic.start/1" do
    test "starts with one initial start_event" do
      process = ExProcess.TestTools.parsed_fixture("only_start")
      state = ExProcess.ProcessRunnerLogic.start(%{process: process, process_name: "Test"})

      assert(state[:active_nodes] == ["StartEvent_1kh4mpv"])
    end

    test "sets correct multiple initial start_events" do
      process = %ExProcess.Process{
        id: "testid",
        events: [
          %ExProcess.Process.StartEvent{id: "StartEvent_1kh4mpv"},
          %ExProcess.Process.StartEvent{id: "StartEvent_2"},
          %ExProcess.Process.StartEvent{id: "StartEvent_3"}
        ]
      }

      state = ExProcess.ProcessRunnerLogic.start(%{process: process, process_name: "Test"})

      assert(state[:active_nodes] == ["StartEvent_1kh4mpv", "StartEvent_2", "StartEvent_3"])
    end
  end

  describe "ProcessRunnerLogic.process_message/2" do
    setup do
      %{
        typical_state: %{
          scheduled_activation: [],
          active_nodes: [],
          process: %ExProcess.Process{
            activities: [%ExProcess.Process.Task{id: "Task_1cbh4mg", name: "Test handler"}],
            events: [
              %ExProcess.Process.MessageThrowEvent{
                id: "IntermediateThrowEvent_1pfwjvv",
                name: "Test Event"
              },
              %ExProcess.Process.MessageThrowEvent{
                id: "IntermediateThrowEvent_1pfwajzz",
                name: "Other Event"
              }
            ],
            flows: [
              %ExProcess.Process.Flow{
                from: "IntermediateThrowEvent_1pfwjvv",
                id: "SequenceFlow_0klx3rb",
                name: "",
                to: "Task_1cbh4mg"
              }
            ],
            id: "sid-C3803939-0872-457F-8336-EAE484DC4A04",
            name: "Customer"
          },
          process_name: "Flow",
          message_catcher: %{
            subscriptions: [
              {"IntermediateThrowEvent_1pfwjvv", :start},
              {"IntermediateThrowEvent_1pfwajzz", :finish, &(&1 == "should make it")}
            ]
          },
          steps_list: ExProcess.ProcessRunnerLogic.default_steps_list()
        }
      }
    end

    test "schedules correctly when one proper listener found", %{typical_state: typical_state} do
      msg = %ExProcess.PubSub.Message{channel: :start, info: :start_contents}
      new_state = ExProcess.ProcessRunnerLogic.process_message(typical_state, msg)
      assert(new_state[:scheduled_activation] == ["IntermediateThrowEvent_1pfwjvv"])
    end

    test "schedules correctly with conditions", %{typical_state: typical_state} do
      msg_not_passing = %ExProcess.PubSub.Message{channel: :finish, info: :start_contents}
      msg_passing = %ExProcess.PubSub.Message{channel: :finish, info: "should make it"}

      new_state = ExProcess.ProcessRunnerLogic.process_message(typical_state, msg_passing)
      assert(new_state[:scheduled_activation] == ["IntermediateThrowEvent_1pfwajzz"])

      new_state = ExProcess.ProcessRunnerLogic.process_message(typical_state, msg_not_passing)
      assert(new_state[:scheduled_activation] == [])
    end
  end
end
