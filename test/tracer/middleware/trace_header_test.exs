defmodule Tracer.Middleware.TraceHeaderTest do
  use ExUnit.Case
  alias Tesla.Env
  alias Tracer.TraceContext

  @middleware Tracer.Middleware.TraceHeader

  describe "call/3" do
    test "adds trace header" do
      context = TraceContext.new("x-cloud-trace-context", "my-project")
      :ok = TraceContext.put(self(), context)

      assert {:ok, env} = @middleware.call(%Env{}, [], [])

      header = Tracer.get_trace_header()

      assert env.headers == [header]
    end
  end
end
