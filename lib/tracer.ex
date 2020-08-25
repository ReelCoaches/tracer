defmodule Tracer do
  @moduledoc """
  Documentation for `Tracer`.
  """

  alias Tracer.Plug
  alias Tracer.TraceContext

  @spec get_trace_context(any) :: %{
          trace_id: binary(),
          span_id: binary(),
          should_sample?: boolean()
        }
  def get_trace_context(key \\ self()) do
    TraceContext.get(key)
    |> Map.from_struct()
  end

  @spec get_trace_header(any) :: {binary(), binary()}
  def get_trace_header(key \\ self()) do
    Plug.get_trace_header(TraceContext.get(key))
  end
end
