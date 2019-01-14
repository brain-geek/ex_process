defmodule ExProcess.Matcher.EventPublish do
  use ExProcess.Matcher.Common

  @moduledoc """
    Separate module which handles matching step text to code run.
  """

  @doc "Adds matcher to list"
  def register_matcher(expression, handler) do
    item = {expression, handler}
    Agent.update(__MODULE__, &MapSet.put(&1, item))
  end

  @doc "Gets data about channel for subscription"
  def get_publish_data(message) do
    case match(message) do
      {:ok, matches} ->
        matches

      _ ->
        raise RuntimeError, "Unable to find corresponding matcher"
    end
  end

  def publish(message) do
    message
    |> get_publish_data()
    |> Enum.each(fn {payload, channel} ->
      ExProcess.PubSub.broadcast(channel, payload)
    end)
  end
end
