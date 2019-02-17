-module(prop_rbeacon).
-include_lib("proper/include/proper.hrl").

prop_can_send_and_receive_any_string() ->
    ?FORALL(String, string(),
            begin
                {ok, Service} = rbeacon:new(9999),
                ok = rbeacon:set_interval(Service, 100),
                ok = rbeacon:publish(Service, unicode:characters_to_binary(String)),
                
                {ok, Client} = rbeacon:new(9999),
                ok = rbeacon:subscribe(Client, ""),
                
                {ok, Msg, _Addr} = rbeacon:recv(Client),
                
                ok = rbeacon:close(Service),
                ok = rbeacon:close(Client),
                
                % collect(length(String),
                % measure("Lonxitude do string",
                %        length(String),
                % the assert must be the last thing the property does
                equals(unicode:characters_to_binary(String), Msg)
                %        )

            end).

