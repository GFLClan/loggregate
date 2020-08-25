defmodule Loggregate.Repo.Migrations.CreateGrokMsgPatterns do
  use Ecto.Migration

  def change do
    create table(:grok_msg_patterns) do
      add :name, :string
      add :pattern, :string
      add :type, :string

      timestamps()
    end

    create unique_index(:grok_msg_patterns, [:name])

    flush()

    {:ok, _} = Loggregate.Grok.create_message_pattern(%{
      name: "CS:GO VPN",
      type: "vpn_detected",
      pattern: ~S'^\[vpnchecker\.smx\] \[VPN\] VPN Detected: <%{STEAMID:who_steamid}> <%{DATA:who_name}> <%{IP:who_address}> \| (?<vpn_action>KICKED|ALLOWED)$'
    })

    {:ok, _} = Loggregate.Grok.create_message_pattern(%{
      name: "Chat",
      type: "chat",
      pattern: ~S'^"%{DATA:who_name}<\d+><%{STEAMID:who_steamid}><\w+>" (?:say|say_team) "%{DATA:message}"$'
    })

    {:ok, _} = Loggregate.Grok.create_message_pattern(%{
      name: "RCON",
      type: "rcon",
      pattern: ~S'^rcon from "%{IP:from_addr_address}:%{POSINT:from_addr_port}": command "%{DATA:command}"$'
    })

    {:ok, _} = Loggregate.Grok.create_message_pattern(%{
      name: "Map load",
      type: "map",
      pattern: ~S'^Started map "%{DATA:map}" \(CRC "(?<map_crc>[A-z0-9\-]+)"\)$'
    })

    {:ok, _} = Loggregate.Grok.create_message_pattern(%{
      name: "Srcds connected",
      type: "connected",
      pattern: ~S'^"%{DATA:who_name}<\d+><%{STEAMID:who_steamid}><>" connected, address "%{IP:who_address}:%{POSINT:who_port}"$'
    })

    {:ok, _} = Loggregate.Grok.create_message_pattern(%{
      name: "Connected plugin",
      type: "connected",
      pattern: ~S'^\[logconnections.smx\] [0-9:]+ - <%{DATA:who_name}> <%{STEAMID:who_steamid}> <%{IP:who_address}> CONNECTED from <%{DATA:country_name}>$'
    })

    {:ok, _} = Loggregate.Grok.create_message_pattern(%{
      name: "Cvar changed",
      type: "cvar",
      pattern: ~S'^server_cvar: "(?<cvar_name>\w+)" "(?<cvar_value>\w+)"$'
    })

    {:ok, _} = Loggregate.Grok.create_message_pattern(%{
      name: "Cvar map load",
      type: "cvar",
      pattern: ~S'^"(?<cvar_name>\w+)" = "(?<cvar_value>\w+)"$'
    })

    {:ok, _} = Loggregate.Grok.create_message_pattern(%{
      name: "CS:GO KZ chat",
      type: "chat",
      pattern: ~S'^\[KZTimerGlobal.smx\] \[GFL ChatLog\] %{DATA:who_name}: %{DATA:message}$'
    })
  end
end
