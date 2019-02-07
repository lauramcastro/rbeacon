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
    ?assertEqual(Msg, <<"announcement">>),

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

%% 1 test (8 lines) => 58% to 60%
hostname_and_broadcast_ip_test() ->
    {ok, Service} = rbeacon:new(9999),

    IP = rbeacon:hostname(Service),
    ?assertMatch({_, _, _, _}, IP), % it would be much better to test if this is a valid IP
    {A, B, C, _} = IP,
    ?assertMatch({A, B, C, 255}, rbeacon:broadcast_ip(Service)),

    ok = rbeacon:close(Service),
    
    true.

%% 1 test (5 lines) => 60% to 60%
set_invalid_interval_test() ->
    {ok, Service} = rbeacon:new(9999),
    ?assertMatch({error, badarg}, rbeacon:set_interval(Service, patata)),
    ok = rbeacon:close(Service),
    
    true.