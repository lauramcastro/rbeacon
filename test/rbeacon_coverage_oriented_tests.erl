%%% -*- erlang -*-
%%%
%%% This file is part of rbeacon released under the Mozilla Public License
%%% Version 2.0. See the NOTICE for more information.

-module(rbeacon_coverage_oriented_tests).

-include_lib("eunit/include/eunit.hrl").

%% 1 test (4 lines) => 51% to 51%
close_closed_beacon_test() ->
    {ok, Service} = rbeacon:new(9999),
    ok = rbeacon:close(Service),
    ?assertEqual(ok, rbeacon:close(Service)).

%% 1 test (11 lines) => 51% to 54%
subscribe_using_string_and_filtering_test() ->
    {ok, Service} = rbeacon:new(9999),
    ok = rbeacon:set_interval(Service, 100),
    ok = rbeacon:publish(Service, <<"announcement">>),

    {ok, Client} = rbeacon:new(9999),
    ok = rbeacon:subscribe(Client, "noun"),

    {ok, Msg, _Addr} = rbeacon:recv(Client),
    ?assertEqual(<<"announcement">>, Msg),

    ok = rbeacon:close(Service),
    ok = rbeacon:close(Client),
    
    true.

%% 1 test (12 lines) => 54% to 58%
subscription_unsubscription_test() ->
    {ok, Service} = rbeacon:new(9999),
    ok = rbeacon:set_interval(Service, 100),
    ok = rbeacon:publish(Service, <<"announcement">>),

    {ok, Client} = rbeacon:new(9999),
    ok = rbeacon:subscribe(Client, <<>>),

    {ok, <<"announcement">>, _Addr} = rbeacon:recv(Client),
    ok = rbeacon:unsubscribe(Client),
    ?assertMatch({error, _}, rbeacon:recv(Client, 200)),

    ok = rbeacon:close(Service),
    ok = rbeacon:close(Client),
    
    true.

%% 1 test (18 lines) => 58% to 60%
hostname_and_broadcast_ip_test() ->
    {ok, Service} = rbeacon:new(9999),

    IP = rbeacon:hostname(Service),

    {ok, NetworkInterfaces} = inet:getifaddrs(),
    UsefulNetworkInterfaces = [ {Name, Options} || {Name, Options} <- NetworkInterfaces, proplists:lookup(addr, Options) =/= none andalso Name =/= "lo"], % we ignore the loopback interface

    IPAddresses = [element(2, proplists:lookup(addr, element(2, NI))) || NI <- UsefulNetworkInterfaces],
    ?assert(lists:member(IP, IPAddresses)), % it would be good to test if this is a valid IP

    Masks = [element(2, proplists:lookup(netmask, element(2, NI))) || NI <- UsefulNetworkInterfaces],
    BroadcastIPs = [calculate_broadcast_ip(IPAddress, Mask) || IPAddress <- IPAddresses, Mask <- Masks],
    ?assert(lists:member(rbeacon:broadcast_ip(Service), BroadcastIPs)),

    ok = rbeacon:close(Service),
    
    true.

calculate_broadcast_ip({A, B, C, D}, {M1, M2, M3, M4}) ->
    {A bor (255-M1), B bor (255-M2), C bor (255-M3), D bor (255-M4)}.

%% 1 test (5 lines) => 60% to 60%
set_invalid_interval_test() ->
    {ok, Service} = rbeacon:new(9999),
    ?assertEqual({error, badarg}, rbeacon:set_interval(Service, patata)),
    ok = rbeacon:close(Service),
    
    true.

%% 1 test (5 lines) => 60% to 66%
setopts_test() ->
    {ok, Service} = rbeacon:new(9999),
    ?assertEqual(ok, rbeacon:setopts(Service, [{interval, 100}])),
    ok = rbeacon:close(Service),
    
    true.

%% 1 test (6 lines) => 66% to 67%
creator_can_control_test() ->
    {ok, Service} = rbeacon:new(9999),
    Pid = spawn(fun() -> receive stop -> ok end end),
    ?assertEqual(ok, rbeacon:control(Service, Pid)),
    ok = rbeacon:close(Service),
    
    true.

%% 1 test (8 lines) => 67% to 67%
not_creator_cannot_control_test() ->
    {ok, Service} = rbeacon:new(9999),
    Pid = self(),
    spawn(fun() -> Pid ! rbeacon:control(Service, Pid) end),
    Error = receive Msg -> Msg end,
    ?assertEqual({error, not_owner}, Error),
    ok = rbeacon:close(Service),
    
    true.
    
%% 1 test (15 lines) => 67% to 70%
silence_test() ->
    {ok, Service} = rbeacon:new(9999),
    ok = rbeacon:set_interval(Service, 100),
    ok = rbeacon:publish(Service, <<"announcement">>),

    {ok, Client} = rbeacon:new(9999),
    ok = rbeacon:subscribe(Client, "noun"),

    {ok, Msg, _Addr} = rbeacon:recv(Client),
    ?assertEqual(<<"announcement">>, Msg),
    ok = rbeacon:silence(Service),
    timer:sleep(200),
    Received = rbeacon:recv(Client, 200),
    ?assertMatch({error, _}, Received),

    ok = rbeacon:close(Service),
    ok = rbeacon:close(Client),
    
    true.

%% 1 test (5 lines) => 70% to 71%
set_interval_twice_test() ->
    {ok, Service} = rbeacon:new(9999),
    ?assertEqual(ok, rbeacon:set_interval(Service, 100)),
    ok = rbeacon:publish(Service, <<"announcement">>),
    ?assertEqual(ok, rbeacon:set_interval(Service, 500)),
    ok = rbeacon:close(Service),
    
    true.
