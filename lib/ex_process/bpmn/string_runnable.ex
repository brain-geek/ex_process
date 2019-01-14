defimpl ExProcess.Runnable, for: BitString do
  def to_process(xml) do
    case ExProcess.Bpmn.Parser.parse(xml) do
      {:ok, %ExProcess.Process{events: events}}
      when is_list(events) and events == [] ->
        {:error, "Unable to use XML with no starts"}

      {:ok, parsed_process = %ExProcess.Process{}} ->
        {:ok, parsed_process}

      error_output ->
        error_output
    end
  end
end
