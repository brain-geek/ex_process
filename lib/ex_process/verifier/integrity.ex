defmodule ExProcess.Verifier.Integrity do
  @moduledoc """
  Checks integrity provided ExProcess.Process .
  """

  @doc "Verifies integrity of given process. Checks whether all links point to existing elements"
  def check(process_struct = %ExProcess.Process{}) do
    elements =
      List.flatten([
        process_struct.events,
        process_struct.activities,
        process_struct.flows
      ])

    uniq_elements = elements |> Enum.map(& &1.id) |> Enum.uniq()

    uniq_linked_ids =
      process_struct.flows
      |> Enum.filter(&match?(%ExProcess.Process.Flow{}, &1))
      |> Enum.map(&[&1.to, &1.from])
      |> List.flatten()
      |> Enum.uniq()

    diff = uniq_linked_ids -- uniq_elements

    if diff do
      {:error, "missing elements found", diff}
    else
      :ok
    end
  end
end
