# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Loggregate.Repo.insert!(%Loggregate.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Loggregate.{LogEntry, Repo, ServerMapping, Accounts}
%LogEntry{} |> LogEntry.changeset(%{timestamp: DateTime.utc_now(), log_data: %{line: "\"Dreae<8><STEAM_0:1:123><TERRORIST>\" say \"Hello world\"", message: "Hello world", server: 1234, type: "chat", from: %{name: "Dreae", steamid: "STEAM_0:1:123", team: false}, address: "127.0.0.1:27015"}}) |> Repo.insert!()
%LogEntry{} |> LogEntry.changeset(%{timestamp: DateTime.utc_now(), log_data: %{line: "\"mp_fraglimit\" = \"0\"", server: 1234, type: "cvar", cvar: %{name: "mp_fraglimit", value: "0"}, address: "127.0.0.1:27015"}}) |> Repo.insert!()
{:ok, _} = ServerMapping.create_server_mapping(1234, "test")
{:ok, _} = Accounts.create_user(%{steamid: "76561197984674419", name: "Dreae", admin: true})
