defmodule ExProcess.ProcessSupervisor do
  @moduledoc """
    RunnerProcess processes supervisor.

    Is parent to all processes started by ExProcess.run
  """

  use DynamicSupervisor

  @runner_process ExProcess.RunnerProcess

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
    child_spec = {@runner_process, Map.merge(%{process: process}, opts)}
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def terminate(process_name) do
    case @runner_process.process_pid(process_name) do
      {:ok, pid} ->
        DynamicSupervisor.terminate_child(__MODULE__, pid)
      {:error, msg} ->
        {:error, msg}
    end
  end
end
