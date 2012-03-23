Bitwise Operators by Bart Massey begins here.

"Provides phrases for bitwise arithmetic/logical operators."

Chapter - Primitive Operators

To decide what number is bit-not (A - a number):
	(- (~{A}) -).

To decide what number is (A - a number) bit-and (B - a number):
	(- ({A} & {B}) -).

To decide what number is (A - a number) bit-or (B - a number):
	(- ({A} | {B}) -).

Chapter - Bit Shifts

[ This is frustrating. The Z-machine and Glulx both include shift instructions, but apparently Inform 6 not so much. ]

Section - Bit Shift Primitives (for Glulx only)

Include (-
[ SHL A B;
  @shiftl A B A;
  return A;
];
[ SHR A B;
  @sshiftr A B A;
  return A;
]; -).

Section - Bit Shift Primitives (for Z-machine only)

Include (-
[ SHL A B;
  @art_shift A B -> A;
  return A;
];
[ SHR A B;
  B = -B;
  @art_shift A B -> A;
  return A;
]; -).


Section - Bit Shift Phrases

To bit-shl (A - an existing number variable) by (B - a number):
	(- {A} = SHL({A}, {B}); -).
        
To bit-shl (A - an existing number variable) by (B - a number):
	(- {A} = SHR({A}, {B}); -).
        
To decide what number is (A - a number) bit-shl by (B - a number):
	(- SHL({A}, {B}) -).

To decide what number is (A - a number) bit-shr by (B - a number):
	(- SHR({A}, {B}) -).

Chapter - XOR

[ Glulx includes an XOR opcode, but the Z machine does not. ]

Section - XOR Phrases (for Glulx only)

To bit-xor (A - a number) into (B - an existing number variable):
	(- @bitxor {A} {B} {B}; -)

To decide what number is (A - a number) bit-xor (B - a number):
	let C be B;
	bit-xor A into C;
        decide on C.

Section - XOR Phrases (for Z-machine only)

[ http://www.firthworks.com/roger/informfaq/tt.html#2 ]

Include (-
[ XOR a b;
  return (a | b) & (~(a & b));
]; -).

To bit-xor (A - a number) into (B - an existing number variable):
	(- {B} = (XOR({A}, {B}); -)

To decide what number is (A - a number) bit-xor (B - a number):
	(- XOR({A}, {B}) -).

Chapter - Other Phrases

[ Numbers by Krister Fundin showed me the pattern for this. ]

To bit-negate (A - an existing number variable):
	(- {A} = ~{A}; -)

To bit-and (A - a number) into (B - an existing number variable):
	(- {B} = {A} & {B}; -)

To bit-or (A - a number) into (B - an existing number variable):
	(- {B} = {A} | {B}; -)

Bitwise Operators ends here.

---- Documentation ----

This module extends Inform 7 by providing some standard bitwise logical operations on numbers. Bitwise operations are rarely needed in the course of stories; the use of XOR in the example below was the inspiration for creating this extension.

The supported bitwise logical operators are "NOT", "AND", "OR", "XOR" (eXclusive-OR), "SHL" (left shift) and "SHR" (arithmetic right shift). Negative shift counts work as expected.

	bit-not (number)
	(number) bit-and (number)
	(number) bit-or (number)
	(number) bit-xor (number)
	(number) bit-shl by (number)
	(number) bit-shr by (number)

It is useful to be able to modify variables "in-place". Bitwise NOT is the simplest case.

	bit-negate (existing number variable)

For binary increment and decrement, the standard Inform 7
syntax provides:

	increase (existing number variable) by (number)
	decrease (existing number variable) by (number)

A similar syntax is used for bitwise shifts SHL and SHR.

	bit-shl (existing number variable) by (number)
	bit-shr (existing number variable) by (number)

This right-to-left syntax is grammatically awkward for the binary logical operators. Bitwise AND, OR and XOR use a left-to-right construction with "into".

	bit-and (number) into (existing number variable)
	bit-or (number) into (existing number variable)
	bit-xor (number) into (existing number variable)

Example: ** Nimrod - Using bitwise XOR to play Nim.

The game of Nim is a skill game in which players take turns taking stones from any one of a number pits until some player wins by taking the last stone. It turns out that a strategy involving XOR is optimal for this game. It is possible to play this strategy in your head, and easy for a computer to play it. Since Nimrod lets the player go first, it is possible for the player to force a win; if the player makes any mistakes, however, the player will lose.

The name "Nimrod" is a Biblical name meaning "Mighty Hunter".

	*: "Nimrod" by "Bart Massey".

	Include Bitwise Operators by Bart Massey.

	The maximum score is 1.

We first set up the game.

	There is a room called The Game Room. "An ancient, pitted Nim Table dominates the center of the room. Behind the table, seated in a high-backed chair, is the legendary Nim champion Nimrod. You, it appears, may stand."

	A high-backed chair is a scenery supporter in The Game Room. The description is "This chair is carved from ashen granite."

	A nim table is a scenery supporter in The Game Room.  The description is "This table is waist-high, and has three pits for stones. [The description of pit one] [The description of pit two] [The description of pit three]".

	Nimrod is a scenery man on the high-backed chair. The description is "Nimrod is pale, dark-haired and inscrutable."

Next we build a bunch of auxiliary machinery to support the algorithm.

	To say (n - a number) stones: if n is 0, say "nothing"; if n is 1, say "one stone"; if n is greater than 1, say "[n] stones".

	A pit is a kind of thing. Every pit has a number called the stone count. The description of a pit is "[The item described] contains [the stone count of the item described stones]."

	A pit called pit one is part of the nim table. The stone count of it is 3. Understand "pit 1" as pit one.

	A pit called pit two is part of the nim table. The stone count of it is 5. Understand "pit 2" as pit two.

	A pit called pit three is part of the nim table. The stone count of it is 7. Understand "pit 3" as pit three.

	Taking it stones from is an action applying to one value and one visible thing and requiring light. Understand "take [number] stone/stones/-- from [pit]" as taking it stones from.

	Check taking a number (called n) stones from a pit (called p): let np be the stone count of p; if n > np, say "Your reach exceeds your grasp. Too many stones? The wrong pit? Just confused? Who can say?" instead; if n < 1, say "Clever...but also illegal. Nimrod glares mercilessly at you as you pull your hand back." instead. 

	Carry out taking a number (called n) stones from a pit (called p): now the stone count of p is the stone count of p - n; say "You feel [n stones] magically fade away at your touch. [The p] now contains [the stone count of p stones]."; try Nimrod moving.

	Carry out Nimrod taking a number (called n) stones from a pit (called p): now the stone count of p is the stone count of p - n; say "Nimrod deftly erases [n stones] from [p], leaving [the stone count of p stones]."

	Moving is an action applying to nothing.

	Definition: A pit is nonempty if the stone count of it is greater than 0.

	To decide whether the table is empty: let l be the list of nonempty pits; if the number of entries of l is 0, yes; otherwise no.

Finally (finally!) the actual game mechanic is fairly simple.

	Check Nimrod moving when the table is empty: say "Nimrod stares sadly at the empty pits. He hangs his head in shame. He has been defeated."; now the score is 1; end the story.

	Report Nimrod moving when the table is empty: say "Nimrod's eyes flash in triumph as he completes his victory."; end the story.

	Carry out Nimrod moving:
		say "Nimrod ponders the situation ponderously...[line break]";
		let q be 0;
		repeat with p running through the list of nonempty pits:
			let n be the stone count of p;
			let q be q bit-xor n;
		repeat with p running through the list of nonempty pits:
			let n be the stone count of p;
			let r be q bit-xor n;
			if n > r:
				let t be n - r;
				try Nimrod taking t stones from p instead;
		let m be pit one;
		repeat with p running through the list of nonempty pits:
			let nm be the stone count of m;
			let np be the stone count of p;
			if np > nm:
				now m is p;
		try Nimrod taking 1 stones from m.

To test, it would be best to look at both winning and losing games.

	Test winning with "take 1 stone from pit 1 / take 1 stone from pit 2 / take 1 stone from pit 1 / take 1 stone from pit 1 / take 1 stone from pit 3 / take 1 stone from pit 3 / take 1 stone from pit 3 / take 1 stone from pit 3".

	Test losing with "take 3 stones from pit 1 / take 4 stones from pit 3 / take 1 stone from pit 2".

	Test me with "test losing".
	
