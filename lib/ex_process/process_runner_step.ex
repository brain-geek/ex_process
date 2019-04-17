defmodule ExProcess.ProcessRunnerStep do
  @moduledoc """
  Generic basics for process runner steps.
  """
  @callback start(map) :: map
  @callback process_tick(map) :: map
  @callback process_message(map, any) :: map

  defmacro __using__(_params) do
    quote do
      @behaviour ExProcess.ProcessRunnerStep

      def start(state = %{}) do
        state
      end

      def process_tick(state) do
        state
      end

      def process_message(state, _msg) do
        state
      end

      defoverridable start: 1, process_tick: 1, process_message: 2
    end
  end
end
