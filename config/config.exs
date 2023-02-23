use Mix.Config

config :test, bots: [
%{:server => "irc.libera.chat", :port => 6667,
:nick => "exirc-bot",
:user => "exirc-bot",
:name => "ExIRC bot",
:pass => "",
:channel => "##exirc-test"}
]
