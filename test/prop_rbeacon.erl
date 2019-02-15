-module(prop_rbeacon).
-include_lib("proper/include/proper.hrl").

prop_rbeacon() ->
    ?FORALL(_A, any(), true). % always passes
