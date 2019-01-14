defmodule ExProcess.ProcessRunnerParts.MessageCatcher do
  @state_path :message_catcher

  def start(opts = %{process: process}) do
    subscriptions =
      process.events
      |> Enum.filter(&match?(%ExProcess.Process.MessageCatchEvent{}, &1))
      |> Enum.map(fn node ->
        node.name
        |> ExProcess.Matcher.EventReceive.get_subscribe_data()
        |> Enum.map(&put_elem(&1, 0, node.id))
      end)
      |> List.flatten()

    Map.put_new(opts, @state_path, %{subscriptions: subscriptions})
  end

  def process_tick(state) do
    state
  end

  def process_message(state, %ExProcess.PubSub.Message{channel: channel, info: info}) do
    # We find which event nodes are activated via this message

    corresp_events =
      state[@state_path][:subscriptions]
      |> Enum.filter(fn subscr -> elem(subscr, 1) == channel end)
      |> Enum.filter(fn
        subscr when tuple_size(subscr) == 3 -> elem(subscr, 2).(info)
        _subscr -> true
      end)

    # We get a list of node ids touched by this message
    new_event_nodes = corresp_events |> Enum.map(&elem(&1, 0))

    # We push them to the next active tick
    update_in(state[:active_next_tick], &(&1 ++ new_event_nodes))
  end
end
