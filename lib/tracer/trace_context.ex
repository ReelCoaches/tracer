defmodule Tracer.TraceContext do
  alias Tracer.TraceCache

  require Logger

  defstruct trace_header: "",
            project_id: "",
            span_id: "",
            trace_id: "",
            should_sample?: false

  @type t() :: %__MODULE__{
          trace_header: binary(),
          project_id: binary(),
          span_id: binary(),
          trace_id: binary(),
          should_sample?: boolean()
        }

  @spec new(binary(), binary()) :: Tracer.TraceContext.t()
  def new(trace_header, project_id) do
    %__MODULE__{
      trace_header: trace_header,
      project_id: project_id,
      trace_id: generate_trace_id(),
      span_id: generate_span_id(),
      should_sample?: false
    }
  end

  @spec new(binary(), binary(), binary(), binary(), boolean()) :: Tracer.TraceContext.t()
  def new(trace_header, project_id, trace_id, span_id, should_sample?) do
    %__MODULE__{
      trace_header: trace_header,
      project_id: project_id,
      trace_id: trace_id,
      span_id: span_id,
      should_sample?: should_sample?
    }
  end

  @spec get(any) :: Tracer.TraceContext.t()
  def get(key) do
    TraceCache.read(key)
  end

  @spec put(any, Tracer.TraceContext.t()) :: :ok
  def put(nil, _context) do
    Logger.warn("No trace key provided. Not caching trace context")
    :ok
  end

  def put(key, %__MODULE__{} = context) do
    TraceCache.cache(key, context)
  end

  defp generate_trace_id do
    generate_hex_bytes(16)
  end

  defp generate_span_id do
    generate_hex_bytes(8)
  end

  defp generate_hex_bytes(num_bytes) do
    num_bytes
    |> :crypto.strong_rand_bytes()
    |> :binary.decode_unsigned()
    |> Integer.to_string(16)
    |> String.downcase()
  end
end
