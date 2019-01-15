defmodule ExProcess do
  @moduledoc """
  ExProcess entry point.

  This project allows running code orchestrated via business logic diagrams.

  """
  @doc """
    Launches provided process

    ## Examples

        iex> {:ok, pid} = ExProcess.run(File.read!("./test/fixtures/only_start_looped.bpmn"), %{process_name: "Doctest"})
        iex> is_pid(pid)
        true

  """

  def run(process, opts \\ %{}) do
    case ExProcess.Runnable.to_process(process) do
      {:ok, process_struct} ->
        ExProcess.ProcessSupervisor.run(process_struct, opts)

      {:error, error} ->
        {:error, error}
    end
  end
end
