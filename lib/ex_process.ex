defmodule ExProcess do
  @moduledoc """
  BPMN entry point.

  This project allows running code orchestrated via BPMN diagrams.
  """
  @doc """
    Launches provided BPMN process

    ## Examples

        iex> {:ok, pid} = ExProcess.run(File.stream!("./test/fixtures/only_start_looped.bpmn", [], 2048), %{process_name: "Doctest"})
        iex> is_pid(pid)
        true

  """

  def run(process) do
    run(process, %{})
  end

  def run(process = %ExProcess.Process{}, opts) do
    ExProcess.ProcessSupervisor.run(process, opts)
  end

  def run(xml, opts) do
    case ExProcess.Parser.parse(xml) do
      {:ok, %ExProcess.Process{events: events}}
      when is_list(events) and events == [] ->
        {:error, "Unable to use XML with no starts"}

      {:ok, parsed_process = %ExProcess.Process{}} ->
        run(parsed_process, opts)

      error_output ->
        error_output
    end
  end
end
