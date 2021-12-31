# Day 18

[Source](https://github.com/h-j-k/advent21/blob/master/src/day18.nim).

## Model

* `SfNumber`, with nested `a` and `b` limbs.
* `Literal`, a subtype of `SfNumber` that only has one numeric value.

My solution works on objects with mutable states, please bear that in mind. 

## Parsing

Parsing can be done recursively with a function that also returns the offset after having processed a certain length of the input string.

Using the given format (just `[],` other than numbers), we can quite easily derive the offsets after processing each limb.

In pseudocode, the function may look something like:

    function parse(input: String): (SfNumber, Integer) {
        if input starts with digits: return Literal(number, length of number)
        (a, aOffset) = parse(input.substr(1, input.lastIndex))
        (b, bOffset) = parse(input.substr(aOffset + 2, input.lastIndex)) // 2 = account for [,
        return (SfNumber(a, b), aOffset + bOffset + 3) // 3 = account for [],
    }

## Addition and reduction

Addition of two `SfNumbers` must be reduced as well.

We also know that the reduction is to apply explosions first, before moving onto splittings.

In pseudocode, it can be something like:

    function add(a: SfNumber, b: SfNumber): SfNumber {
        result = SfNumber(a, b)
        while (result.canExplode or resultcanSplit) {
            // loop until terminating condition
        }
    }

My solution models the return type of performing an explosion as an `Option`, so in Nim:

    func `+`(a: SfNumber, b: SfNumber): SfNumber =
      result = SfNumber(a: a, b: b)
      while (result.explode.isSome or result.split): discard

## Exploding a number

1. `Literal` numbers are not exploded.
 
2. Only at levels above four (using 1-indexed levels!), do we perform an explosion under the right conditions.

    * Through recursion, we need to carry over to the lower levels information whether an explosion was done, and the exploding numbers.

    * In Nim, the return type `Option[(int, int)]` is good enough.

    * The question mentions the exploding level will always contain a valid pair of `Literal`, so we have to handle the check ourselves:

          func explode(sf: SfNumber, level = 1): Option[(int, int)] =
            if sf of Literal: return none[(int, int)]()
            if level > 4 and sf.a of Literal and sf.b of Literal:
              return some((Literal(sf.a).n, Literal(sf.b).n))
            # ...

4. For levels four and below, we really only need to do three things:

    1. Attempt an explosion (`a` limb followed by `b`).
       
    2. Handle the result of explosion, i.e. carrying, if any, at the current level.

    3. Pass the result of the explosion to the lower level.

### Attempt an explosion

We need to differentiate whether the explosion attempt is on the `a` or `b` limb.

This is because it affects how we will do the carrying in the next step.

In Nim, the code may look something like:

    var x = explode(sf.a, level + 1)
    var isASide = true
    if x.isNone: # No explosion on this limb, try the other
      x = explode(sf.b, level + 1)
      isASide = false
    if x.isNone: return x # early return
    var (xA, xB) = x.get 

### Carrying

1. If we are back at level four, we know we will have to  replace the exploded number with a `0`.

        if isASide:
          if level == 4: sf.a = Literal(n: 0) # mutable state...
          # ...
        else:
          if level == 4: sf.b = Literal(n: 0)
          # ...

2. The logic to carry over the remaining exploded number can be described as looping on the other limb until the first `Literal` is found, then add them.

3. If we have performed the explosion on the `a` limb and replaced `sf.a` with `0`, we know we will do the previous step on the `b` limb, looking at the nesting `a` limbs.
 
4. Conversely, if we have performed the explosion on the `b` limb and replaced `sf.b` with `0`, we know we will do the previous step on the `a` limb, looking at the nesting `b` limbs.

        [[[[a1, b1], b2], b3]] <- if a1 is exploded and replaced by 0, we will scan from b1 to b2 to b3
        [[a1, [a2, [a3, b3]]]] <- if b3 is exploded and replaced by 0, we will scan from a3 to a2 to a1

### Passing

1. For the exploded number on the same limb, we will carry that to the lower levels.

2. In Nim, the code may look something like, for one limb:

        if isASide:
          if level == 4: sf.a = Literal(n: 0)
          var t = sf.b # Start from the current level's b limb
          while (not (t of Literal)): t = t.a
          if t of Literal: # just to be sure
            Literal(t).n += xB
            xB = 0 # We have handled xB's value, so zero it
        else:
          # ...
        some((xA, xB)) # Pass this on to lower levels 

## Splitting a number

1. Similar to how we explode numbers, we need to carry over information about any splitting through recursion on both limbs.

2. In Nim, the code may look something like:

        func splitLiteral(literal: Literal): Option[SfNumber] =
          if literal.n >= 10: some(SfNumber(a: (literal.n div 2).sf, b: ((literal.n + 1) div 2).sf))
          else: none[SfNumber]()

3. To perform the recursion, we just need to recurse for non-`Literal` numbers on each limb.

4. In Nim, the code may look something like:

        func split(sf: Number): bool =
            if sf of Literal: return false # Cannot recurse into a Literal
            if sf.a of Literal:
              let aSplit = Literal(sf.a).splitLiteral # attempt split
              result = aSplit.isSome # have we split?
              if result: sf.a = aSplit.get # if so, replace sf.a
           else: result = split(sf.a) # Recurse into non-Literal
           if not result: # If no splits on this limb, try the other
             # repeat for sf.b

## Calculating the magnitude

Finally, the calculation for magnitude is quite straightforward:

    func magnitude(sf: SfNumber): int =
      if (sf of Literal): Literal(sf).n else: 3 * sf.a.magnitude + 2 * sf.b.magnitude