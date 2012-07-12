# Hagl: Haskell Game Language 
#### Eric Walkingshaw, Oregon State University

To play with the examples, load them into GHCi by running `ghci Examples.hs`
from this directory.

There are examples of Normal Form, Extensive Form, and State-Driven games in
`Examples.hs`.  You can view a game tree by simply evaluating the game in GHCi.

For example:

    >> pd
    Player 1
    +- Cooperate -> Player 2
    |  +- Cooperate -> [2,2]
    |  `- Defect -> [0,3]
    `- Defect -> Player 2
       +- Cooperate -> [3,0]
       `- Defect -> [1,1]

The function `runGame` is used to execute a game.  It takes a game, a set of
players to play the game, and a function to execute within the `GameExec`
monad.

Execution functions include:

 * `step` - Process a single node in the game tree.
 * `once` - Run through the game a single time to completion.
 * `times n` - Run the full game `n` times.

There are also many printing functions available for inspecting the execution
state.  These can be found in `Game/Execution/Print.hs`.  Some examples
include:

 * `printLocation` - Print the current location in the game tree.
 * `printTranscript` - Print the transcript of all completed games.
 * `printScore` - Print the current score.

The execution and printing functions can be executed sequentially via bind
operations.  The best way to illustrate how this all works together is a few
examples.

The following processes the first node in the game tree (Player 1's decision),
then prints the current location, i.e. Player 2's decision node.
    
    >> runGame pd [titForTat, pavlov] (step >> printLocation)

The following runs the game four times, prints the transcript of all
iterations, and then prints the current (in this case, final) score.

    >> runGame pd [titForTat, suspicious] (times 4 >> printTranscript >> printScore)

And finally, the following runs the game three times, prints the score, then
runs 100 more iterations and prints the final score.

    >> runGame pd [ccd, grim] (times 3 >> printScore >> times 100 >> printScore)

There is also a "tournament" facility that eases running many combinations of
players and comparing their final scores.  The tournament running functions
can be found in `Game/Execution/Tournament.hs`.

All tournament functions automatically print the scores of all players
involved, in sorted order, when it is finished.

An example tournament:

    >> roundRobin pd [titForTat, titForTwoTats, grim, suspicious, pavlov] (times 100 >> printScore)

For each pair of players from the list, this will run the iterated prisoner's
dilemma 100 times, and print the score of that instance.  At the end, the
total scores of all players involved will be printed in sorted order.
