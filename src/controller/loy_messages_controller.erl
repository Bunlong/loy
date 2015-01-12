-module(loy_messages_controller, [Req]).
-compile(export_all).

index('GET', []) ->
  {json, [{messages, "Hello, world!"}]}.
