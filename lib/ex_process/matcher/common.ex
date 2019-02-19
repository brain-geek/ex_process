defmodule ExProcess.Matcher.Common do
  @moduledoc """
    Shared functionality between matcher storages
  """
  defmacro __using__(_) do
    quote do
      use Agent

      def start_link(_) do
        Agent.start_link(fn -> MapSet.new() end, name: __MODULE__)
      end

      @doc "Returns all the present matchers"
      def take_all do
        Agent.get(__MODULE__, fn state -> state end)
      end

      @doc "Matches string to existing matchers"
      def match(message) do
        matches =
          take_all()
          |> Enum.map(fn
            matcher when is_bitstring(elem(matcher, 0)) ->
              if elem(matcher, 0) == message do
                matcher
              end

            matcher ->
              if match = Regex.named_captures(elem(matcher, 0), message) do
                put_elem(matcher, 0, match)
              end
          end)
          |> Enum.reject(&is_nil/1)

        if Enum.empty?(matches) do
          {:error, {"No matches found", message}}
        else
          {:ok, matches}
        end
      end
    end
  end
end
