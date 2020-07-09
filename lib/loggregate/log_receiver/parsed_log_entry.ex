defmodule Loggregate.LogReceiver.ParsedLogEntry do
  @enforce_keys [:server_id, :address, :port, :timestamp, :log_data, :index]
  defstruct [:server_id, :address, :port, :timestamp, :log_data, :index]
end
