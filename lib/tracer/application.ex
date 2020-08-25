defmodule Tracer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Tracer.Worker.start_link(arg)
      {ConCache,
       [
         name: :trace_cache,
         ttl_check_interval: :timer.seconds(1),
         global_ttl: :timer.seconds(10),
         touch_on_read: true
       ]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tracer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
