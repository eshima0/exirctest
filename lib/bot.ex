defmodule Test.Bot do
  use GenServer
  require Logger

  defmodule Config do
    defstruct server: nil,
              port: nil,
              pass: nil,
              nick: nil,
              user: nil,
              name: nil,
              channel: nil,
              client: nil

    def from_params(params) when is_map(params) do
      Enum.reduce(params, %Config{}, fn {k, v}, acc ->
        case Map.has_key?(acc, k) do
          true -> Map.put(acc, k, v)
          false -> acc
        end
      end)
    end
  end

  alias ExIRC.Client
  alias ExIRC.SenderInfo

  def start_link(%{:nick => nick} = params) when is_map(params) do
    config = Config.from_params(params)
    GenServer.start_link(__MODULE__, [config], name: String.to_atom(nick))
  end

  def init([config]) do
    {:ok, client} = ExIRC.start_link!()
    Client.add_handler(client, self())

    Logger.debug("Connecting to #{config.server}:#{config.port}")
    Client.connect!(client, config.server, config.port)

    {:ok, %Config{config | :client => client}}
  end

  def handle_info({:connected, server, port}, config) do
    Logger.debug("Connected to #{server}:#{port}")
    Logger.debug("Logging to #{server}:#{port} as #{config.nick}..")
    Client.logon(config.client, config.pass, config.nick, config.user, config.name)
    {:noreply, config}
  end

  def handle_info(:logged_in, config) do
    Client.join(config.client, config.channel)
    {:noreply, config}
  end

  def handle_info({:joined, msg}, config) do
    Logger.debug("joined channel #{msg}")
    {:noreply, config}
  end

  def handle_info({:notice, msg, sender_info}, config) do
    Logger.debug("#{msg}")
    Logger.debug("#{inspect(sender_info)}")
    {:noreply, config}
  end

  def handle_info({:topic_changed, channel, changedto}, config) do
    Logger.debug("topic changed to #{changedto} in #{channel}")
    {:noreply, config}
  end

  def handle_info({:names_list, channel, names}, config) do
    Logger.debug("users in #{channel}: #{names}")
    {:noreply, config}
  end

  def handle_info({:unrecognized, msg, ircmessage}, config) do
    Logger.debug("#{msg}")
    Logger.debug("#{inspect(ircmessage)}")
    {:noreply, config}
  end


  def handle_info({:received, msg, %SenderInfo{:nick => nick}, channel}, config) do
    Logger.info("#{nick} from #{channel}: #{msg}")
    {:noreply, config}
  end

  def handle_info({:received, msg, %SenderInfo{:nick => nick}}, config) do
    Logger.info("from #{nick}: #{msg}")
    Client.msg(config.client, :privmsg, nick, "Hej!")
    Logger.info("responded with: Hej!")

    {:noreply, config}
  end

  def handle_info({:mentioned, msg, %SenderInfo{:nick => nick}, channel}, config) do
    Logger.info("#{nick} mentioned you in #{channel}")
    Client.msg(config.client, :notice, channel, "#{nick}, hej!")
    {:noreply, config}
  end

  def handle_info(x, config) do
    Logger.debug("#{inspect x}")
    {:noreply, config}
  end

  def terminate(_, state) do
    # Quit the channel and close the underlying client connection when the process is terminating
    Client.quit(state.client, "Goodbye, cruel world.")
    Client.stop!(state.client)
    :ok
  end
end
