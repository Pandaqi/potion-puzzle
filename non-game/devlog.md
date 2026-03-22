# Potion (Puzzle)

I made another educational puzzle game for my online store, which teaches colors and rudimentary logic/counting.

This article explains the process behind the creation of that game, the problems I faced, and the algorithms I ended up using. Hopefully it's fun or _educational_ to read!

## What's the idea?

I was brainstorming _color puzzles_. And, most of all, color puzzles playable by <4 year olds who are actually learning the colors.

This gave me two requirements.

* Only a SINGLE ACTION
* Only a SINGLE RULE (no text/numbers, only colors)

This led me to the idea of **Potions**.

* The puzzle shows a handful of potions side by side, filled with different colors.
* Your "action" is simply to **tap one potion**, which **adds its content to all the others**.

The goal is to clear the field without any potion overflowing.

## The issue

This is not really a puzzle, of course, and doesn't really do anything with colors. In fact, in this simplified form, any tapping order will solve it ;)

So I added my single rule about colors:

> If a potion has multiple of the same color in a row (like 3-in-a-row games), those disappear.

Now order matters. You need to tap the right potion such that it creates matches here and there, emptying the potions so they don't overflow.

Now you need to correctly identify colors and match them, while adding a _tiny_ bit of logical thinking / thinking ahead.

That idea seemed promising and doable, so I created a prototype.

## Generating Puzzles

My algorithm for generating random puzzles was as follows.

* Start with random potion contents => not specific colors, but rather "2 chunks inside" or "3 chunks inside"
* Repeat the following loop.
  * Pick a random potion.
  * Add its contents to all other potions.
  * If a potion overflows (or it's at maximum and it's not the end of the puzzle) ...
    * Set a constraint on the top section of new potion + bottom section of old: they must be the _same_. (They must match, so that they're removed and the potion is reduced.)
    * Repeat until potion does not overflow anymore.
  * Once only a single potion remains, we have our "constraints".
    * Set all chunks that must be the same to the same (unique) color.
    * Pick random different ones for the others.

This works. I was quite proud of writing a rather elegant algorithm that solves "constraints" of colors that must be the same or not.

However, it also showed that my rules are **bad**! Why?

* Because we add a potion to _all other (remaining) potions_, they fill up extremely quickly.
* Which means you only have, like, 2 moves before they are full. And so my algorithm solves that by ... making 90% of the chunks the same color, so they all match and go away and the puzzle is solvable :p Which is just not a good puzzle anymore.
* Additionally, "pouring" a potion into the others means the colors are added "in reverse". (Because, well, the potion's opening is at the top not the bottom.) This might trip up some kids, so I'd rather pick rules/theme where this does not matter.

## Generating Puzzles: Smarter

I realized that I was thinking the wrong way around. I was thinking of some puzzle idea first, and then finding an algorithm to generate random ones (quickly, easily). But it's much easier to **come up with a simple algorithm, then design the rules around it**!

In other words, what would be an _easy_ generation algorithm to implement?

* Start with a single potion with random content.
* Calculate a different potion that would "fit" in the existing potion => simply add a new potion with those contents!
* Repeat until we have X potions.

That's much simpler. You just take X steps, adding a new potion each time, and you're guaranteed to have a solvable puzzle.

What _puzzle rule_ would make this possible?

* **Idea #1:** Colors simply match _in the entire potion_. So if you add two potions together, and now it has 2 RED chunks, they're both removed (even if they're not touching/far apart).
* **Idea #2:** When you tap a potion, it only adds its content to its **neighbor**. This prevents the issue of basically all colors needing to match because you're adding the content to _all_ potions.
* **Idea #3:** When you match colors, it **clears the whole potion** (instead of just removing those elements). And then you can't tap a potion that's empty, so you also can't be too greedy clearing everything.
* **Idea #4:** When you tap a potion, it adds its contents _one by one_ to the other potions. (So it adds chunk 1 to potion 1, chunk 2 to potion 2, etcetera until done.)
* **Idea #5:** When you tap a potion, it only adds **one** of its chunks (the top one) to all other potions.
* **Idea #6:** We do the **reverse**. You're filling the potions and a potion only goes away ("is finished") if you _fill it completely/perfectly_.

All these changes make it somewhat easy to simply "calculate" what potion to add such that you can always solve it.

I decided to try _Idea #1_ first, and I'll use that to show an example of what I mean.

## Idea #1 -> Match Anywhere

As stated, the only step in our algorithm is to "find a new potion" that, when added to the current potions, would result in our current state.

We have two tricks to calculate this new potion.

* Simply add **unused colors, that will go away once merged**. (As I wrote it in my code: "thicken" every potion so we have enoug elements to split off a new potion.) 
  * Example: add "GREEN" to every existing potion, and a single "GREEN" to the new potion.
  * Because now, if we were to "tap" this new potion, it would give every potion matching GREENS, which would make them go away.
* **If we already have multiple potions:** Find the colors that _all potions share_. We can give one or more of these colors to the new potion.
  * Example: Potion 1 has "BLUE, YELLOW, RED" and Potion 2 has "BLUE, GREEN, GREEN"
  * Then we can simply say "the new potion has a BLUE", and remove that blue from Potion 1 and 2.

In this way, we can "expand" our existing potions and split off a new one. This always works and leads to functional puzzles.

However ... the puzzles are just **not interesting**. They're obvious. They're not even puzzles at all. Now order doesn't really matter anymore. All solutions are just an alternating loop of "add color everywhere, remove color everywhere".

We can make it "harder" by just adding random colors that do nothing to random potions (if it fits) ... but that's just adding noise to cover up a mediocre puzzle.

So, like before, the code works but the resulting puzzles are just bad. The issue is my idea of "adding a potion to ALL other potions".

Can we keep the idea of "just tap 1 potion (as your move)" while fixing those inherent issues? All games similar to this will at least have _two inputs_: pick the thing you want to use, then pick the target where it should go. But I _really_ want to keep it to a single action. 

## Final Attempt

I wanted to give this one more try, before calling the idea infeasible and dropping it. 

{{% remark %}}
This is a massive improvement over my previous workflow that I only recently truly learned/embraced. Instead of wasting days trying to get an idea to work (or "be fun") when it's just not working, I give prototypes one whole day. If there's not at least a _glimmer of hope_ for it working/being good after that, then I publish the idea for free on my database of shared ideas that anyone else can try if they want, and don't pursue it further.
{{% /remark %}}

Let's recap.

* Gameplay should be "tap one of the (remaining) potions", about 5 to 10 times in a row. Nothing else, no other actions, that simple.
* I don't want it to affect all other potions, or even two other potions. It's too much happening at once, too much to think about, while also not leading to actually interesting puzzles.
* It should be tightly focused on _color_ (matching/not matching/naming).

My best idea within these constraints was as follows.

* Your goal is to **put all chunks of the same color into the same potion** (so it's a sorting exercise really).
  * To help out, we give every potion (vial) a color too, so you know exactly WHERE the RED chunks should go.
* Each move is about moving **one chunk** from a potion to **another potion**.
* When generating the puzzle, I simply "save" where every chunk went. When you're playing, I simply **highlight the target** (you don't pick it yourself, the game just tells you where it will go.)

Now, to generate this, we can do the following.

* Start with all potions perfectly sorted. (So just create a few empty potions, then fill each with 1--3 chunks of same color.)
* Repeat the following loop a random number of times.
  * Pick a TARGET POTION with something inside.
  * Pick a START POTION that is not full.
  * Move the top chunk from _TARGET POTION -> START POTION_. 
  * (Remember, the generation is in "reverse". We take steps backwards. The same steps _forwards_ is the solution the player needs to find. So, save both potions used in a list as the _solution_.)

The "maximum size" of potions still applies. That is actually, for the most part, what makes the puzzle interesting.

## The Magic Of Iteration

This works! Even with just 5 or 10 "steps", it's an actual puzzle, but not too hard. By requiring my puzzle to only have that one input (tap a potion), and giving it a few tries, I accidentally stumbled into a new puzzle idea! One that's actually quite unique and seriously challenging with larger puzzles.

> Because the _game_ tells you the target potion each turn, you suddenly have to think ahead in a different way. For example, you have to "make space" ahead of time if you notice you need to move something to the PURPLE potion in two turns.

This does require, of course, actually _showing the player_ what the target potions will be. This is, fortunately, completely doable through color now.

> Below the row of big potions, is a row of smaller potions showing exactly _what the target potion is every turn_. And because every potion has a single _assigned color_, we can just show that color.

The nice thing is that the player does not need to know this row even exists or what it means. A kid can just try a level a few times, memorize the order (it's only ~5 steps), and solve it like that. It's a useful thing if you want to, but does not overcomplicate the core puzzle.

I _never_ would've thought about doing a puzzle this way when I wrote down the idea. I've never even seen a puzzle that just takes away half your input and tells you "it must go HERE this turn". But with a few iterations, trying a few different ideas, I stumbled upon this and it works stupidly well.

* Even with just a few potions and 5 moves, it's an actual puzzle. For older kids and adults too.
* You can modulate that difficulty by increasing potions, moves, and max size.
* It allows our random generation to be "stupid" (for example: move a chunk, then move it back again the next turn). Because by forcing you to target a specific potion, those moves simply become an extra challenge to calculate ahead of time.
* While the game needs absolutely no text, or numbers, or explanation, or complexity.

## Finishing Touches

We can improve this a bit more by ...

* Doing some checks (at the end) to see if the puzzle is "hard enough". That is, check if every potion (in its starting state) has a good variety of colors.
* Checking for "early solutions" => when shuffling, it can happen that we randomly return to the solved state already. Don't allow this, as it can ruin a puzzle. (The player suddenly solves it in 5 moves instead of the 10 we asked for!)
* I briefly wanted to add back the rule that matching colors remove each other ... then realized this was incredibly silly, because the entire _goal_ now is to fill every potion with entirely the same color :p

Then I had to do the usual honors in terms of adding some animations, sound effects, menu, buttons, and all that jazz. And we have a puzzle game!

## Conclusion

If you take anything away from this devlog/diary, let it be three things.

1. **Iteration is key.** Almost all creative ideas start off vague and bad, but there's some nugget of gold in there. And it only comes out by first getting rid of all the noise around it---by first making some bad prototypes.
2. **That's why being nimble and flexible is also key.** I made all _three_ different versions of this puzzle in a single day with a break between them (_morning, afternoon, evening_). I was completely ready to ditch the idea completely if the final attempt did not work out. No use beating a dead horse.
  * Of course, the time period to assign a project before "dropping" it depends on you and your project. This is a tiny puzzle game. A much larger game, a book, something bigger would need perhaps a week of prototyping.
3. More specifically, when creating educational puzzle games, you want "endless puzzles" which requires being able to randomly generate them (quickly, accurately). Randomly generating 100% solvable, correct puzzles is _hard_. Which is why it makes more sense to think about **a generation algorithm first**, and then simply pick rules around that, instead of the other way around.

Potion Puzzle is not some amazing puzzle game. But it's one of the few educational puzzle games available to (very) young kids that teaches colors, matching, and a bit of logical thinking quite well. The original idea was nothing like the end result at which I arrived after only a day or two.

Until the next devlog,

Pandaqi





## @TODO

Architecture / Logic / Generation

* Potions should react to PotionData changes
* Just have a permanent Chunk inside PotionSegment -> show/hide (and recolor) as needed
* Simulation Checks (enough variation at start, no save state revisiting)

Graphics

* Fix tiny Potion issues: center should not extend into top, edges don't perfectly align, etc
* Add Balatro-like painerly swirl as background? => Yes, and then use the current target color as the colors to swirl!
* Add the "shine" shader to both PotionSmall and Target potion again?
* Tween the ball actually moving from one potion to another
* Tween changes in PotionSmall active
* Some smaller tweens for nicety (such as small ball rotations, small reaction to hover over potion, etc)
* Sound Effects: Tap Potion, Ball Move?

Finishing Touches

* Five difficulty levels
* @IDEA: Can we involve actual _color mixing_ somehow as the final difficulty?



@SOURCE: Great website to compress WebM I record for these video games => https://www.xconvert.com/compress-webm



PuzzleFramework:

* Write some short docs on the few steps to take to _integrate the framework_ in each new game.
* Actually _save_ user settings between sessions? (And save other data, like completed puzzles/highscore/etc?)
* Even more generic tutorial support?
* Localization (both text and audio)
