-module(loy_messages_controller, [Req]).
-compile(export_all).
-export([receive_message/2]).

index('GET', []) ->
  Messages = boss_db:find(message, []),
  Timestamp = boss_mq:now("Channel"),
  {ok, [{timestamp, Timestamp}, {messages, Messages}]}.

create('GET', []) ->
  ok;
create('POST', []) ->
  Message = Req:post_param("message"),
  NewMessage = message:new(id, Message, erlang:now()),
  case NewMessage:save() of
    {ok, SavedMessage} ->
      {redirect, [{action, "create"}]};
    {error, ErrorList} ->
      {ok, [{errors, ErrorList}, {new_msg, NewMessage}]}
  end.

receive_message('GET', [LastTimestamp]) ->
  {ok, Timestamp, Message} = boss_mq:pull("Channel", list_to_integer(LastTimestamp)),
  {json, [{timestamp, Timestamp}, {message, Message}]}.
