defprotocol ExProcess.Runnable do
  def to_process(data)
end

defimpl ExProcess.Runnable, for: ExProcess.Process do
  def to_process(process), do: {:ok, process}
end
