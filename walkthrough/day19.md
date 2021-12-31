# Day 19

[Source](https://github.com/h-j-k/advent21/blob/master/src/day19.nim).

## Model

* `Point3D`, self-explanatory.

* `Edge`, the 'line' between two `Point3D` points.

* `Scanner`, again, self-explanatory. In my solution, we need to store all the `Point3D` points, the `Edge` pairs and the number of scanners that have been combined.

* `Mapping`, this models the information of how the axes of one `Scanner` lines up with the other.

* `Delta`, after knowing the axes' mappings, we also need to calculate the offsets and direction.

## Parsing

1. Parsing the co-ordinates into `Point3D` is left as an exercise for the reader.

2. We do need to calculate the edges from one point to the other points, in pseudocode that can be something like:

        function toEdges(points: Collection<Point3D>): Collection<Edge> {
            result = Collection<Edge>
            for index, point in points.get(0, points.lastIndex - 1):
                result + points.get(index + 1, points.lastIndex)
                                .map(other => Edge(point, other))
                                .filter(edge => edge.pointsWithin1000EachAxis)
        }

3. It's important to model the edges as going in 'one direction' (no puns intended) only, so that we can determine afterwards whether the directions of two scanners are the same.

## Main loop

1. The main logic is to keep track of the results of matching Scanners together, and looping until all are matched.

2. In pseudocode, that can be something like:

        function process(input: Collection<String>): (Scanner, Collection<Point3D>) {
            scanners = parse(input)
            combined = scanners.get(0)
            remaining = Deque(scanners.get(1, scanners.lastIndex))
            offsets = Collection<Point3D>
            while (remaining.hasLeftover) {
                next = remaining.pop
                (updated, offset) = match(combined, next)
                if (offset.isPresent) {
                    offsets + offset // done with one more!
                } else {
                    remaining.push(next) // try again later
                }
            }
        }

        function match(aggregated: Scanner, toMatch: Scanner): (Scanner, Something<Point3D>) {
            /* 
                if we can combine, return the combined result and the offset
                else return aggregated, and the equivalent of an absent offset value
                think of Something => Present<Point3D> with value, or Absent<Point3D> with nothing 
                operations here should assume immutable models!
            */
        }

## Matching Scanners

1. If we have seen/matched this scanner before, we can return early.

2. Try to match the scanner. This is done by simply comparing whether any three pairs of axes matches in distance.

3. In Nim, that can be something like:

        func matches(e1, e2: Edge): Table[(Mapping, Delta), HashSet[Point3D]] =
          var mapping = none[Mapping]()
          let
            (de1x, de1y, de1z) = e1.length3
            (de2x, de2y, de2z) = e2.length3
          if de1x == de2x:
            if de1y == de2y and de1z == de2z: mapping = some((xTo: 'x', yTo: 'y', zTo: 'z'))
            elif de1y == de2z and de1z == de2y: mapping = some((xTo: 'x', yTo: 'z', zTo: 'y'))
          elif de1x == de2y:
            if de1y == de2x and de1z == de2z: mapping = some((xTo: 'y', yTo: 'x', zTo: 'z'))
            elif de1y == de2z and de1z == de2x: mapping = some((xTo: 'y', yTo: 'z', zTo: 'x'))
          elif de1x == de2z:
            if de1y == de2y and de1z == de2x: mapping = some((xTo: 'z', yTo: 'y', zTo: 'x'))
            elif de1y == de2x and de1z == de2y: mapping = some((xTo: 'z', yTo: 'x', zTo: 'y'))
          if mapping.isSome:
            # got a possible match, will need to calculate the delta and store what are the points related to this match

        func match(s1, s2: Scanner): Option[(Mapping, Delta)] =
          for e1 in s1.edges:
            for e2 in s2.edges:
              # Call matches(e1, e2)

4. We may end up with more than one possible result, but we can safely assume that the correct match will involve more than two points. The full Nim implementation for `match` can be something like:

        func match(s1, s2: Scanner): Option[(Mapping, Delta)] =
          var mappings = initTable[(Mapping, Delta), HashSet[Point3D]]()
          for e1 in s1.edges:
            for e2 in s2.edges:
              for k, v in matches(e1, e2)
                mappings[k] = mappings.getOrDefault(k, initHashSet[Point3D]()) + v
          # done with all the loops, time to conclude!
          let candidates = mappings.pairs.toSeq.filterIt(it[1].len > 2).sortedByIt(-1 * it[1].len)
          # the correct (Mapping, Delta) match should be the one with the most points matched 
          return if candidates.len > 0: some(candidates[0][0]) else: none[(Mapping, Delta)]()

6. If we have a match, we create a new `Scanner` that combines both, remembering to regenerate the edges too.

## Calculating delta

When we have a possible match, we need to calculate the delta given the known mapping, and the two edges.

For brevity, please look at the implementation at `func delta(mapping: Mapping, edge: Edge, reference: Edge): Delta`.

For example, if the reference edge runs from `(0, 10)` and the edge to match runs from `(20, 10)`, we know that they are in opposing direction.

As we go from `0` to `10` on the reference edge, the other edge counts downwards from `20`. The offset is simply `10`.

Please pay attention to how we need anchor the `reference` edge.

## Calculating offset

The next piece of information required for part two is to determine the offsets from the first scanner (happens to be `scanners[0]`).

Thankfully, this calculation is much more straightforward, as it is simply the aggregate of the offsets on all three axes.

In Nim, that can be something like:

    func toOffset(mapping: Mapping, delta: Delta): Point3D =
      let
        (xTo, yTo, zTo) = mapping
        (_, _, _, dx, dy, dz) = delta
      var x, y, z: int
      case xTo:
        of 'x': x = dx
        of 'y': y = dx
        of 'z': z = dx
        else: discard
      case yTo:
        of 'x': x = dy
        of 'y': y = dy
        of 'z': z = dy
        else: discard
      case zTo:
        of 'x': x = dz
        of 'y': y = dz
        of 'z': z = dz
        else: discard
      (x, y, z)