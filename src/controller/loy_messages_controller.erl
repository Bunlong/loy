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

% Since we are talking Comet, you would do a boss_mq:pull with a 15 second timeout. 
% Once that times out, the server sends a last timestamp in response to the client 
% telling it to resubmit the polling request from that timestamp.
receive_message('GET', [LastTimestamp]) ->
  {ok, Timestamp, Message} = boss_mq:pull("Channel", list_to_integer(LastTimestamp), 60),
  {json, [{timestamp, Timestamp}, {message, Message}]}.
