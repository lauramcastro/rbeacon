%%% -*- erlang -*-
%%%
%%% This file is part of rbeacon released under the Mozilla Public License
%%% Version 2.0. See the NOTICE for more information.

%% @doc The rbeacon module implements a peer-to-peer discovery service for local
%% networks. A beacon can broadcast and/or capture service announcements using
%% UDP messages on the local area network. This implementation uses IPv4 UDP
%% broadcasts. You can define the format of your outgoing beacons, and set a
%% filter that validates incoming beacons. Beacons are sent and received
%% asynchronously in the background.
%%
-module(rbeacon_tests).

-include_lib("eunit/include/eunit.hrl").


loop_sub(_Beacon, Acc, 0) ->
    Acc;
loop_sub(Beacon, Acc, N) ->
    receive
        {rbeacon, Beacon, Msg, _} ->
            loop_sub(Beacon, [Msg | Acc], N-1)
    end.


rbeacon_test() ->
    {ok, Service} = rbeacon:new(9999),
    ?assert(is_pid(Service)),

    ok = rbeacon:set_interval(Service, 100),
    ok = rbeacon:publish(Service, <<"announcement">>),

    {ok, Client} = rbeacon:new(9999),
    ok = rbeacon:subscribe(Client, <<>>),

    {ok, Msg, _Addr} = rbeacon:recv(Client),
    ?assertEqual(Msg, <<"announcement">>),


    ok = rbeacon:close(Service),
    ok = rbeacon:close(Client),

    {ok, Node1} = rbeacon:new(5670),
    {ok, Node2} = rbeacon:new(5670),
    {ok, Node3} = rbeacon:new(5670),

    ok = rbeacon:noecho(Node1),

    rbeacon:publish(Node1, <<"Node/1">>),
    rbeacon:publish(Node2, <<"Node/2">>),
    rbeacon:publish(Node3, <<"GARBAGE">>),
    rbeacon:subscribe(Node1, <<"Node">>),

    {ok, Msg2, _Addr} = rbeacon:recv(Node1),
    ?assertEqual(Msg2, <<"Node/2">>),

    rbeacon:close(Node1),
    rbeacon:close(Node2),
    rbeacon:close(Node3),

    ok.

rbeacon_active_test() ->
    {ok, Service} = rbeacon:new(9999, [active, noecho]),
    ?assert(is_pid(Service)),

    ok = rbeacon:set_interval(Service, 100),
    ok = rbeacon:publish(Service, <<"announcement">>),

    {ok, Client} = rbeacon:new(9999, [active]),
    ok = rbeacon:subscribe(Client, <<>>),
    receive
        {rbeacon, Client, <<"announcement">>, _Addr} ->
            ok
    end,

    ok = rbeacon:close(Service),
    receive
        {rbeacon, Service, closed} -> ok
    end,

    ok = rbeacon:close(Client),
    receive
        {rbeacon, Client, closed} -> ok
    end,

    {ok, Node1} = rbeacon:new(5670, [active, noecho]),
    {ok, Node2} = rbeacon:new(5670, [active, noecho]),
    {ok, Node3} = rbeacon:new(5670, [active, noecho]),

    rbeacon:publish(Node1, <<"Node/1">>),
    rbeacon:publish(Node2, <<"Node/2">>),
    rbeacon:publish(Node3, <<"GARBAGE">>),
    rbeacon:subscribe(Node1, <<"Node">>),

    Result = loop_sub(Node1, [], 1),

    ?assert(lists:member(<<"Node/2">>, Result)),

    rbeacon:close(Node1),
    rbeacon:close(Node2),
    rbeacon:close(Node3),

    ok.

