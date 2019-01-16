defmodule ExProcess.Bpmn.Parser do
  @moduledoc """
  Parser of .bpmn files into ExProcess.Process struct.
  """
  import SweetXml

  @doc "Parses xml into ExProcess structs"
  def parse(xml) do
    process_id_xpath_call =
      try do
        SweetXml.xpath(xml, ~x"//process/@id"S)
      catch
        :exit, _ -> {:error, "Unable to parse XML"}
      end

    case process_id_xpath_call do
      {:error, _} ->
        process_id_xpath_call

      "" ->
        {:error, "Unable to find process element"}

      _ ->
        process_id = process_id_xpath_call

        {:ok,
         %ExProcess.Process{
           id: process_id,
           name: get_process_name(xml, process_id),
           activities:
             List.flatten([
               get_tasks(xml, process_id),
               get_exclusive_gateways(xml, process_id)
             ]),
           events:
             List.flatten([
               get_mail_throw_events(xml, process_id),
               get_mail_catch_events(xml, process_id),
               get_start_events(xml, process_id),
               get_end_events(xml, process_id)
             ]),
           flows:
             List.flatten([
               get_flows(xml, process_id)
             ])
         }}
    end
  end

  defp get_mail_catch_events(xml, process_id) do
    try do
      SweetXml.xpath(xml, ~x"//process[@id='#{process_id}']/intermediateCatchEvent"l)
    catch
      :exit, _ -> nil
    end
    |> Enum.map(fn x ->
      %ExProcess.Process.MessageCatchEvent{
        id: SweetXml.xpath(x, ~x"./@id"S),
        name: SweetXml.xpath(x, ~x"./@name"S)
      }
    end)
  end

  defp get_mail_throw_events(xml, process_id) do
    try do
      SweetXml.xpath(xml, ~x"//process[@id='#{process_id}']/intermediateThrowEvent"l)
    catch
      :exit, _ -> nil
    end
    |> Enum.map(fn x ->
      %ExProcess.Process.MessageThrowEvent{
        id: SweetXml.xpath(x, ~x"./@id"S),
        name: SweetXml.xpath(x, ~x"./@name"S)
      }
    end)
  end

  defp get_start_events(xml, process_id) do
    try do
      SweetXml.xpath(xml, ~x"//process[@id='#{process_id}']/startEvent"l)
    catch
      :exit, _ -> nil
    end
    |> Enum.map(fn x ->
      %ExProcess.Process.StartEvent{
        id: SweetXml.xpath(x, ~x"./@id"S),
        name: SweetXml.xpath(x, ~x"./@name"S)
      }
    end)
  end

  defp get_end_events(xml, process_id) do
    try do
      SweetXml.xpath(xml, ~x"//process[@id='#{process_id}']/endEvent"l)
    catch
      :exit, _ -> nil
    end
    |> Enum.map(fn x ->
      %ExProcess.Process.EndEvent{
        id: SweetXml.xpath(x, ~x"./@id"S),
        name: SweetXml.xpath(x, ~x"./@name"S)
      }
    end)
  end

  defp get_tasks(xml, process_id) do
    try do
      SweetXml.xpath(xml, ~x"//process[@id='#{process_id}']/task"l)
    catch
      :exit, _ -> nil
    end
    |> Enum.map(fn x ->
      %ExProcess.Process.Task{
        id: SweetXml.xpath(x, ~x"./@id"S),
        name: SweetXml.xpath(x, ~x"./@name"S)
      }
    end)
  end

  defp get_exclusive_gateways(xml, process_id) do
    try do
      SweetXml.xpath(xml, ~x"//process[@id='#{process_id}']/exclusiveGateway"l)
    catch
      :exit, _ -> nil
    end
    |> Enum.map(fn x ->
      %ExProcess.Process.ExclusiveGateway{
        id: SweetXml.xpath(x, ~x"./@id"S),
        name: SweetXml.xpath(x, ~x"./@name"S)
      }
    end)
  end

  defp get_flows(xml, process_id) do
    try do
      SweetXml.xpath(xml, ~x"//process[@id='#{process_id}']/sequenceFlow"l)
    catch
      :exit, _ -> nil
    end
    |> Enum.map(fn x ->
      %ExProcess.Process.Flow{
        id: SweetXml.xpath(x, ~x"./@id"S),
        name: SweetXml.xpath(x, ~x"./@name"S),
        from: SweetXml.xpath(x, ~x"./@sourceRef"S),
        to: SweetXml.xpath(x, ~x"./@targetRef"S)
      }
    end)
  end

  defp get_process_name(xml, process_id) do
    SweetXml.xpath(xml, ~x"//participant[@processRef='#{process_id}']/@name"S)
  catch
    :exit, _ -> nil
  end
end
