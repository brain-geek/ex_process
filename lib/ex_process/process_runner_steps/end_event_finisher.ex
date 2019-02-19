defmodule ExProcess.ProcessRunnerSteps.EndEventFinisher do
  @moduledoc """
    This is part of Process Runner which prevents activation of end events, as
    they shouldn't be activated ever
  """

  def start(state = %{}) do
    state
  end

  def process_tick(state) do
    end_event_node_ids =
      state[:process].events
      |> Enum.filter(&match?(%ExProcess.Process.EndEvent{}, &1))
      |> Enum.map(& &1.id)

    update_in(state[:scheduled_activation], &Enum.uniq(&1 -- end_event_node_ids))
  end

  def process_message(state, _msg) do
    state
  end
end
