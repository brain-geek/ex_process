defmodule ExProcess.ProcessSupervisor do
  @moduledoc """
    RunnerProcess processes supervisor.

    Is parent to all processes started by ExProcess.run
  """

  @process_registry ExProcess.ProcessRegistry

  use DynamicSupervisor

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc "Starts given ExProcess process in a separate Elixir process"
  def run(process) do
    run(process, %{})
  end

  def run(process, opts) do
    child_spec = {ExProcess.RunnerProcess, Map.merge(%{process: process}, opts)}
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def terminate(process_name) do
    case process_pid(process_name) do
      {:ok, pid} ->
        DynamicSupervisor.terminate_child(__MODULE__, pid)
      {:error, msg} ->
        {:error, msg}
    end
  end

  @doc "Lists running ExProcess processes"
  def list_running do
    processes = DynamicSupervisor.which_children(__MODULE__)

    Enum.flat_map(processes, fn {_, pid, _, _} ->
      Registry.lookup(@process_registry, {:pid, pid})
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
    case Registry.lookup(@process_registry, {:pid, process_pid}) do
      [{^process_pid, process_name}] ->
        {:ok, process_name}
      [] ->
        {:error, "Process not started"}
    end
  end

  @doc "Returns process PID by given process name."
  def process_pid(process_name) do
    case Registry.lookup(ExProcess.ProcessRegistry, {:process_name, process_name}) do
      [{pid, pid}] ->
        {:ok, pid}
      [] ->
        {:error, "Process not started"}
    end
  end
end
