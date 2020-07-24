defmodule Loggregate.LogReceiver.ParsedLogEntry do
  @enforce_keys [:server_id, :server_name, :address, :port, :timestamp, :log_data, :index]
  defstruct [:server_id, :server_name, :address, :port, :timestamp, :log_data, :index]
end
