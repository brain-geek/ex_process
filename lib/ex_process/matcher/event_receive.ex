defmodule ExProcess.Matcher.EventReceive do
  use ExProcess.Matcher.Common

  @moduledoc """
    Separate module which handles matching step text to code run.
  """

  @doc "Adds matcher to list"
  def register_matcher(expression, channel) do
    item = {expression, channel}
    Agent.update(__MODULE__, &MapSet.put(&1, item))
  end

  def register_matcher(expression, channel, condition) do
    item = {expression, channel, condition}
    Agent.update(__MODULE__, &MapSet.put(&1, item))
  end

  @doc "Converts 'humanized' string to data for publishing event"
  def get_subscribe_data(message) do
    case match(message) do
      {:ok, matches} ->
        matches

      _ ->
        raise RuntimeError, "Unable to find corresponding matcher"
    end
  end
end
