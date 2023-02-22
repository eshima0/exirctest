use Mix.Config

config :test, bots: [
  %{:server => "irc.libera.chat", :port => 6697,
    :nick => "exirc-bot-test123", :user => "exirc-bot-test123", :name => "ExIRC test bot",
    :channel => "##exirc-test"}
]
