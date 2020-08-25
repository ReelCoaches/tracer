defmodule Tracer.Middleware.TraceHeader do
  @behaviour Tesla.Middleware

  @impl Tesla.Middleware
  @spec call(Tesla.Env.t(), Tesla.Env.stack(), keyword()) :: Tesla.Env.result()
  def call(env, next, options) do
    trace_key = Keyword.get(options, :trace_key, self())
    {header, value} = Tracer.get_trace_header(trace_key)

    env
    |> Tesla.put_header(header, value)
    |> Tesla.run(next)
  end
end
