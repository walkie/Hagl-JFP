Hagl: Haskell Game Language -- (Eric Walkingshaw)

To play with the examples, load them into GHCi by running "ghci Examples.hs"
from this directory.

There are examples of Normal Form, Extensive Form, and State-Driven games in
Examples.hs.  You can view a game tree by simply evaluating the game in GHCi.

For example:

>> pd

Should print:

Player 1
+- Cooperate -> Player 2
|  +- Cooperate -> [2,2]
|  `- Defect -> [0,3]
`- Defect -> Player 2
   +- Cooperate -> [3,0]
   `- Defect -> [1,1]

The function runGame is used to execute a game.  It takes a game, a set of
players to play the game, and some functions to execute within the 
GameExec monad.

Execution functions are:

step - Process a single node in the game tree.
once - Run through the game a single time to completion.
times n - Run the full game n times.

There are also many printing functions available for inspecting the execution
state.  These can be found in Game/Execution/Print.hs.  Some examples are:

printLocation - Print the current location in the game tree.
printTranscript - Print the transcript of all completed games.
printScore - Print the current score.

The execution and printing functions can be executed sequentially via bind
operations.  The best way to illustrate how this all works together is a few
examples:

>> runGame pd [titForTat, pavlov] (step >> printLocation)

This processes the first node (Player 1's Decision), and then print the current
location: Player 2's Decision node.

>> runGame pd [titForTat, suspicious] (times 4 >> printTranscript >> printScore)

This will run the game four times, print the transcript of all games, and then
print the current (in this case, final) score.

>> runGame pd [ccd, grim] (times 3 >> printScore >> times 100 >> printScore)

And finally, this will run the game three times, print the score, then run it
100 more times and print the final score.

There is also a "tournament" facility that eases running many combinations of
players and comparing their final scores.  The tournament running functions
can be found in Game/Execution/Tournament.hs

All tournament functions automatically print the scores of all players
involved, in sorted order, when it is finished.

An example tournament:

>> roundRobin pd [titForTat, titForTwoTats, grim, suspicious, pavlov] (times 100 >> printScore)

For each pair of players from the list, this will run the iterated prisoner's
dilemma 100 times, and print the score of that instance.  At the end, the
total scores of all players involved will be printed in sorted order.
