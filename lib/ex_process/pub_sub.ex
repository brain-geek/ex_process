defmodule ExProcess.PubSub do
  @moduledoc """
  Handles Pub/Sub functionality for events.
  """

  defmodule Message do
    @moduledoc """
    Struct to wrap PubSub messages.
    """

    @enforce_keys [:channel]
    defstruct channel: nil, info: nil
  end

  @registry ExProcess.PubSubRegistry

  def subscribe(pid, channel) do
    Registry.register(@registry, channel, pid)
  end

  def broadcast(channel, info) do
    message = %Message{
      channel: channel,
      info: info
    }

    Registry.dispatch(@registry, channel, fn entries ->
      for {pid, _} <- entries, do: send(pid, message)
    end)
  end

  def broadcast(message) when is_bitstring(message) do
    matches = ExProcess.Matcher.EventPublish.get_publish_data(message)
    matches |> Enum.each(fn {match, channel} -> broadcast(channel, match) end)
  end
end
