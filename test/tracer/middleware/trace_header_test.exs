defmodule Tracer.Middleware.TraceHeaderTest do
  use ExUnit.Case
  alias Tesla.Env
  alias Tracer.TraceContext

  @middleware Tracer.Middleware.TraceHeader

  describe "call/3" do
    test "adds trace header" do
      trace_key = self()
      context = TraceContext.new("x-cloud-trace-context", "my-project")
      :ok = TraceContext.put(trace_key, context)

      assert {:ok, env} = @middleware.call(%Env{}, [], trace_key: trace_key)

      header = Tracer.get_trace_header(trace_key)

      assert env.headers == [header]
    end
  end
end
