# Day 23

[Source](https://github.com/h-j-k/advent21/blob/master/src/day23.nim).

## Model

* `CharGrid`, representing the burrow, i.e. input.
* `Amphipod`, representing the position (`Point` of `(x, y)` coordinates) and the type of amphipod.
* `State`, representing the burrow at each move and the energy consumed.

## Parsing

Nothing special, `CharGrid` is just a list of lists of characters. In this solution, it's `seq[seq[char]]`.

## Main loop

Basically just [Dijkstra's algorithm](https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm).

In Nim, this is similar to using a `HeapQueue` and a `CountTable`:

    func process(grid: CharGrid): int =
      var
        heapQueue = [(grid: grid, energy: 0)].toHeapQueue
        seen = initCountTable[CharGrid]()
      while heapQueue.len > 0:
        let state = heapQueue.pop
        if state.grid.isDone: return state.energy
        for next in nextStates(state):
          if next.energy < seen.getOrDefault(next.grid, int.high):
          seen[next.grid] = next.energy
          heapQueue.push next

To solve for part two, we do need to handle for varying heights of the side rooms, so we need to pass that along to the same function too. This can be seen in the final implementation.

## Computing valid moves

Without any extra heuristics, valid moves can be thought of as:

1. If an amphipod is along the hallway, check if its side room is eligible for it to go inside.

2. If an amphipod is not along the hallway, it must remain in the side rooms.
 
3. If it is in the side room, check whether it needs to move.

    1. If it is in its correct room and all the amphipods below, if any, are also correct, then don't move.
 
    2. Else, check if it can even move, i.e. whether it's a free space above it.

    3. If it should move and it can move, then brute-force all possible positions in the hallway for it to move to!

Remember, once along the hallway, it can only move to a position if the direction of travel is clear.

In Nim, this can be something like:

    func isHallwayClear(a: int, b: int, grid: CharGrid): bool =
      (a.min(b) .. a.max(b)).allIt(grid[(it, 1)] == '.')

    func moves(amphipod: Amphipod, grid: CharGrid, rest: seq[int]): seq[Point] =
      let (a, p) = amphipod
      if p.y == 1:
        if rest.anyIt(grid[(cols[a], it)] notin [a, '.']): return @[]
        let
          x = if p.x < cols[a]: p.x + 1 else: p.x - 1
          y = rest.filterIt(grid[(cols[a], it)] == '.').max
        return @[(cols[a], y)].filterIt(x.isHallwayClear(cols[a], grid))
      if p.x == cols[a] and (p.y .. rest.max).allIt(grid[(p.x, it)] == a): return @[]
      return if grid[(p.x, p.y - 1)] != '.': @[] else:
        [1, 2, 4, 6, 8, 10, 11].filterIt(p.x.isHallwayClear(it, grid)).mapIt((it, 1))
