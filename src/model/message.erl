-module(message, [Id, Message, CreatedAt]).
-compile([export_all]).

after_create() ->
  send_message(THIS).

send_message(NewMessage) ->
  {ok, Timestamp} = boss_mq:push("Channel", NewMessage).
