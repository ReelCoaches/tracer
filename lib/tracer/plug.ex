defmodule Tracer.Plug do
  alias Plug.Conn
  alias Tracer.TraceContext

  @behaviour Plug

  require Logger

  @impl Plug
  @spec init(keyword) :: keyword
  def init(opts), do: opts

  @impl Plug
  @spec call(Plug.Conn.t(), keyword) :: Plug.Conn.t()
  def call(conn, opts) do
    key = Keyword.get(opts, :trace_key)
    header = Keyword.get(opts, :trace_context_header, "x-cloud-trace-context")
    project_id = Keyword.get(opts, :project_id, "my-project")

    context = get_trace_context(conn, header, project_id)
    :ok = set_trace_context(key, context)
    set_trace_header(conn, context)
  end

  @spec get_trace_header(Tracer.TraceContext.t()) :: {binary(), binary()}
  def get_trace_header(context) do
    {context.trace_header,
     "#{context.trace_id}/#{context.span_id};o=#{boolean_to_string(context.should_sample?)}"}
  end

  defp get_trace_context(conn, header, project_id) do
    case Conn.get_req_header(conn, header) do
      [] -> TraceContext.new(header, project_id)
      [val | _] -> parse_trace_header(header, val, project_id)
    end
  end

  defp set_trace_context(key, context) do
    # Log Entry trace format: projects/my-projectid/traces/06796866738c859f2f19b7cfb3214824
    trace = "projects/#{context.project_id}/traces/#{context.trace_id}"

    # Special Fields: https://cloud.google.com/logging/docs/agent/configuration
    Logger.metadata("logging.googleapis.com/trace": trace)
    Logger.metadata("logging.googleapis.com/spanId": context.span_id)
    Logger.metadata("logging.googleapis.com/trace_sampled": context.should_sample?)

    # Save trace context for use in rest of request
    TraceContext.put(key, context)
  end

  defp set_trace_header(conn, context) do
    {header, value} = get_trace_header(context)

    Conn.put_resp_header(conn, header, value)
  end

  defp parse_trace_header(header, val, project_id) do
    # Cloud Trace context header format: TRACE_ID/SPAN_ID;o=TRACE_TRUE
    # Where:
    #
    # TRACE_ID is a 32-character hexadecimal value representing a 128-bit number.
    # SPAN_ID is the decimal representation of the (unsigned) span ID.
    # TRACE_TRUE must be 1 to trace this request. Specify 0 to not trace the request.
    [trace_id, rest] = String.split(val, "/")

    if String.contains?(rest, ";") do
      [span_id, options] = String.split(rest, ";")
      [_, should_sample?] = String.split(options, "=")

      TraceContext.new(header, project_id, trace_id, span_id, parse_boolean(should_sample?))
    else
      TraceContext.new(header, project_id, trace_id, rest, false)
    end
  end

  defp parse_boolean("1"), do: true
  defp parse_boolean("0"), do: false

  defp boolean_to_string(true), do: "1"
  defp boolean_to_string(false), do: "0"
end
