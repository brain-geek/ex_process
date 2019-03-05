defmodule ExProcess.Matcher.FlowCondition do
  use ExProcess.Matcher.Common

  @moduledoc """
    Separate module which handles matching flow condition text to code.
  """

  @doc "Adds matcher to list"
  def register_matcher(expression, handler) do
    item = {expression, handler}
    Agent.update(__MODULE__, &MapSet.put(&1, item))
  end

  @doc "Runs the actual matched text"
  def run_match(message) do
    {:ok, [{params, handler}]} = match(message)

    handler.(params)
  end
end
