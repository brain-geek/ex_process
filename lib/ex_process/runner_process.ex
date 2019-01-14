defmodule ExProcess.RunnerProcess do
  @moduledoc """
  GenServer which actually runs separate BPM process.
  """

  use GenServer

  alias ExProcess.ProcessRunnerLogic

  @process_registry ExProcess.ProcessRegistry

  def start_link(opts = %{process: process}) do
    process_name = opts[:process_name] || process.id
    opts = put_in(opts[:process_name], process_name)

    GenServer.start_link(
      __MODULE__,
      opts,
      name: :"process:#{process_name}"
    )
  end

  def init(opts = %{process: _, process_name: process_name}) do
    Registry.register(@process_registry, {:process_name, process_name}, self())
    Registry.register(@process_registry, {:pid, self()}, process_name)

    process_runner_output = ProcessRunnerLogic.start(opts)

    process_runner_output[:message_catcher][:subscriptions]
    |> Enum.each(&ExProcess.PubSub.subscribe(self(), elem(&1, 1)))

    schedule_next_tick(opts)

    {:ok, process_runner_output}
  end

  def handle_call(:get_current_state, _from, state) do
    {:reply, {:ok, state[:active_nodes]}, state}
  end

  def handle_cast(:process_next_tick, state) do
    new_state = ProcessRunnerLogic.process_tick(state)
    schedule_next_tick(state)

    {:noreply, new_state}
  end

  def handle_info(msg = %ExProcess.PubSub.Message{}, state) do
    new_state = ProcessRunnerLogic.process_message(state, msg)

    # Schedule next tick to respond to external events
    schedule_next_tick(state)

    {:noreply, new_state}
  end

  defp schedule_next_tick(state) do
    unless get_in(state, [:runner_options, :step_by_step]) do
      GenServer.cast(self(), :process_next_tick)
    end
  end
end
