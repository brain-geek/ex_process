defmodule ExProcess.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {Registry, keys: :unique, name: ExProcess.ProcessRegistry},
      {Registry, keys: :duplicate, name: ExProcess.PubSubRegistry},
      {ExProcess.Matcher.Task, name: ExProcess.Matcher.Task},
      {ExProcess.Matcher.EventPublish, name: ExProcess.Matcher.EventPublish},
      {ExProcess.Matcher.EventReceive, name: ExProcess.Matcher.EventReceive},
      {ExProcess.ProcessSupervisor, strategy: :one_for_one, name: ExProcess.ProcessSupervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExProcess.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
