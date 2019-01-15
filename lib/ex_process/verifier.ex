defmodule ExProcess.Verifier do
  @moduledoc """
  Checks integrity and integrality of provided ExProcess.Process .
  """

  @doc "Verifies integrity of given process. Checks whether all links point to existing elements"
  def check(process_struct = %ExProcess.Process{}) do
    ExProcess.Verifier.Integrity.check(process_struct)
  end
end
