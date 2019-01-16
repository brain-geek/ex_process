defmodule ExProcess.ProcessRunnerParts.FlowsExclusiveGatewayProcessor do
  @moduledoc """
    This is part of Process Runner which makes sure that ExclusiveGateway will
    be enabled only in case of all the incoming flows being active
  """

  def start(state = %{}) do
    state
  end

  def process_tick(state) do
    exclusive_gateways =
      state[:process].activities
      |> Enum.filter(&match?(%ExProcess.Process.ExclusiveGateway{}, &1))

    fully_enabled_exclusive_gateways =
      exclusive_gateways
      |> Enum.filter(fn exclusive_gateway ->
        incoming_flows =
          state[:process].flows
          |> Enum.filter(&match?(%ExProcess.Process.Flow{}, &1))
          |> Enum.filter(&(&1.to == exclusive_gateway.id))

        MapSet.subset?(MapSet.new(incoming_flows), MapSet.new(state[:flows_to_process_this_tick]))
      end)

    disabled_exclusive_gateways = exclusive_gateways -- fully_enabled_exclusive_gateways
    disabled_exclusive_gateway_ids = disabled_exclusive_gateways |> Enum.map(& &1.id)

    update_in(state[:flows_to_process_this_tick], fn flows_list ->
      Enum.filter(flows_list, &(!Enum.member?(disabled_exclusive_gateway_ids, &1.to)))
    end)
  end

  def process_message(state, _msg) do
    state
  end
end
