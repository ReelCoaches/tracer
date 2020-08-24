defmodule TracerTest do
  use ExUnit.Case
  doctest Tracer

  alias Tracer.TraceContext

  @trace_header "my-trace-header"
  @project_id "my-project"

  setup do
    context = TraceContext.new(@trace_header, @project_id)
    {:ok, context: context}
  end

  describe "get_trace_context/0" do
    test "gets trace context", %{context: context} do
      trace_key = self()
      :ok = TraceContext.put(trace_key, context)

      Process.sleep(1)

      fetched_context = Tracer.get_trace_context(trace_key)
      assert is_map(fetched_context)
      assert fetched_context.trace_id == context.trace_id
      assert fetched_context.span_id == context.span_id
      assert fetched_context.should_sample? == context.should_sample?
      assert fetched_context.trace_header == @trace_header
      assert fetched_context.project_id == @project_id
    end
  end

  describe "get_trace_header/0" do
    test "gets trace header", %{context: context} do
      trace_key = self()
      TraceContext.put(trace_key, context)

      Process.sleep(1)

      {header, value} = Tracer.get_trace_header(trace_key)
      assert header == @trace_header
      assert value =~ context.trace_id
      assert value =~ context.span_id
      assert String.ends_with?(value, "0")
    end
  end
end
