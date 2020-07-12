defmodule Loggregate.PermissionError do
  defexception message: "Forbidden", plug_stats: 403
end
