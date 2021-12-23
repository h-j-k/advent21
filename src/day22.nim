import sequtils
import sets
import strscans

type Point3D = tuple[x: int, y: int, z: int]

type Step = tuple[mode: bool, xMin: int, xMax: int, yMin: int, yMax: int, zMin: int, zMax: int]

type Cube = tuple[x1: int, x2: int, y1: int, y2: int, z1: int, z2: int]

func parse(step: string): Step =
  let (_, mode, xMin, xMax, yMin, yMax, zMin, zMax) = step.scanTuple "$w x=$i..$i,y=$i..$i,z=$i..$i"
  (mode: mode == "on", xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax, zMin: zMin, zMax: zMax)

func part1*(input: seq[string]): int =
  let limit = -50 .. 50
  var set = initHashSet[Point3D]()
  for step in input.mapIt(it.parse):
    let (isOn, xMin, xMax, yMin, yMax, zMin, zMax) = step
    if [xMin, xMax, yMin, yMax, zMin, zMax].anyIt(it notin limit): continue
    for x in xMin .. xMax:
        for y in yMin .. yMax:
          for z in zMin .. zMax:
            let p = (x: x, y: y, z: z)
            if isOn: set.incl p else: set.excl p
  set.len
