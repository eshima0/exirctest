defmodule Test.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias Test.Bot
  @impl true
  def start(_type, _args) do
    children = 
      Application.get_env(:test, :bots)
      |> Enum.map(fn bot -> {Bot, bot} end)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Test.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
