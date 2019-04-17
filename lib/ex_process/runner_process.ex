defmodule ExProcess.RunnerProcess do
  @moduledoc """
  GenServer which actually runs separate BPM process.
  """

  use GenServer

  alias ExProcess.ProcessRunnerLogic

  @process_registry ExProcess.ProcessRegistry
  @process_supervisor ExProcess.ProcessSupervisor

  # GenServer stuff

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
    Registry.register(@process_registry, registry_name_key(process_name), self())
    Registry.register(@process_registry, registry_pid_key(self()), process_name)

    process_runner_output = ProcessRunnerLogic.start(opts)

    process_runner_output[:message_catcher][:subscriptions]
    |> Enum.each(&ExProcess.PubSub.subscribe(self(), elem(&1, 1)))

    schedule_next_tick(opts, true)

    {:ok, process_runner_output}
  end

  def handle_call(:get_current_state, _from, state) do
    {:reply, {:ok, state[:active_nodes]}, state}
  end

  def handle_info(:process_next_tick, state) do
    new_state = ProcessRunnerLogic.process_tick(state)
    schedule_next_tick(state)

    {:noreply, new_state}
  end

  def handle_info(msg = %ExProcess.PubSub.Message{}, state) do
    new_state = ProcessRunnerLogic.process_message(state, msg)

    # Schedule next tick to respond to external events
    schedule_next_tick(state, true)

    {:noreply, new_state}
  end

  # External interface

  @doc "Lists running ExProcess processes"
  def list_running do
    processes = DynamicSupervisor.which_children(@process_supervisor)

    Enum.flat_map(processes, fn {_, pid, _, _} ->
      Registry.lookup(@process_registry, registry_pid_key(pid))
    end)
  end

  @doc "Returns set of active nodes for the given process."
  def current_state(process_name) do
    case process_pid(process_name) do
      {:ok, pid} ->
        GenServer.call(pid, :get_current_state)

      {:error, msg} ->
        {:error, msg}
    end
  end

  @doc "Forces to process to start new tick. Used in combination with `step_by_step: true` runner option"
  def force_tick(process_name) do
    case process_pid(process_name) do
      {:ok, pid} ->
        send(pid, :process_next_tick)

      {:error, msg} ->
        {:error, msg}
    end
  end

  @doc "Returns process name by given PID."
  def process_name(process_pid) do
    case Registry.lookup(@process_registry, registry_pid_key(process_pid)) do
      [{^process_pid, process_name}] ->
        {:ok, process_name}

      [] ->
        {:error, "Process not started"}
    end
  end

  @doc "Returns process PID by given process name."
  def process_pid(process_name) do
    case Registry.lookup(@process_registry, registry_name_key(process_name)) do
      [{pid, pid}] ->
        {:ok, pid}

      [] ->
        {:error, "Process not started"}
    end
  end

  # Private functions for GenServer part

  defp schedule_next_tick(state, immediate \\ false) do
    unless get_in(state, [:runner_options, :step_by_step]) do
      if immediate do
        send(self(), :process_next_tick)
      else
        # TODO: make this constant configurable
        Process.send_after(self(), :process_next_tick, 10)
      end
    end
  end

  # Private functions for process control part

  defp registry_pid_key(pid) do
    {:pid, pid}
  end

  defp registry_name_key(name) do
    {:process_name, name}
  end
end
