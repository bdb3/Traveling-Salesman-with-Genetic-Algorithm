__includes [ "GA.nls" "greedy-path.nls" "GUI.nls" "intersecting-edges.nls" "path-utils.nls" "utils.nls" ]

; These are the "cities."
breed [nodes node]

; These are the links from Node to Node. Each link has link-length as a built-in primitive.
undirected-link-breed [edges edge]
edges-own [
  used            ;; This is used when building greedy paths.
]

;; An earlier version of this code used the breek  path  to keep track of paths. It worked
;; well. A problem arose in that when the continual search button was down, new paths were
;; generated faster than they could be garbage collected. To get around this problem I gave
;; up on the  path  breed  and now store the node list and the length as a list of two elements.
;; That'a a lot uglier, but at least we don't run out of memory.  Here is the orignal path declaration.

; These are the paths through the nodes "cities.". Each path is a permutation of the Nodes.
; Had to make them breeds of turtles since each has both list and a length
;breed [paths path]
;paths-own [
;  path-route
;  path-length
;]

globals [
  backward-stack         ;; a stack of paths. If not empty can be popped to get to a previous path
  best-path              ;; the best path found so far (a list of nodes)
  forward-stack          ;; a stack of paths. If not empty can be popped to get to a forward path
  best-path-age          ;; used to store how many ticks it has been since the current best path
  next-node-number
  initial-best-length    ;; the solution before GA started working
  population-at-match    ;; the point at which GA matched or surpassed the initial solution
  best-length            ;; the length of the best path
  node-color             ;; the standard node color
  node-label-color       ;; the color of the node label
  path-color             ;; the color to use on edges in the best path
  selected-node          ;; the node the will be deleted or that is being dragged
  showing-all-edges      ;; whether all edges should be shown

  nodes-to-add           ;; a stack of nodes to be added to populations
  nodes-to-del           ;; a stack of nodes to be added to populations

  absolute-worst         ;; the worst path length with this number of nodes
  absolute-best          ;; the best path length with this number of nodes
]

to setup [from-file]
  clear-all
  set backward-stack []
  set forward-stack []
  ask patches [set pcolor white]
  set-default-shape nodes "dot"
  set showing-all-edges show-all-edges ; initial-node-count <= 5
  set node-color blue - 2
  set node-label-color red - 1
  set path-color cyan - 1
  set best-path  []                 ;; Create an initial best-path with no nodes.
  set best-length 0
  set selected-node nobody          ;; initially no node is selected

  set nodes-to-add []
  set nodes-to-del []
  ;; TODO: delete these and replace them with notes-to-add and nodes-to-delete
  ;set node-added false              ;; initially, no node is added
  ;set node-deleted false            ;; initially, no node is deleted

  set next-node-number 1
  set absolute-worst -1
  set absolute-best -1

  if-else from-file
  [ load-nodes-from-file ]
  [
    foreach range initial-node-count [create-node-at-xy next-node-number
                                                        min (list (max-pxcor - 1) max (list (min-pxcor + 1) random-xcor))
                                                        min (list (max-pycor - 1) max (list (min-pycor + 1) random-ycor))]
  ]

  display-best-path
  reset-ticks                       ;; This is so that the forever buttons can be disabled until after setup.
end                                 ;; This model doesn't use ticks. It makes explicit display calls.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Operations on best-path ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Triggered by a forever button. When running it searches continually for a greedy path that is better than the
;; current best-path or for an intersection that it can untwist. When it finds one it replaces the current
;; best-path with the better one.
to continual-improvement
;  if length best-path > 2 [
;    let new-path (ifelse-value (random 2 = 0) [greedy-path false] [an-untwist best-path])
;    if length-of-path new-path < best-length [
;      set-new-best-path new-path
;      display-best-path
;    ]
;  ]
  evolve-path

  display-best-path

  tick
end

; display the best-path
to display-best-path
  ask edges [set color black set thickness 0 set hidden? not show-all-edges]
  foreach (path-edges best-path) [ ed -> ask ed [set color path-color set thickness 0.2 set hidden? false] ]
  display
end

; forward-backward-stack :: {forward-stack popped and assigned to best-path}
to go-forward
  if not empty? forward-stack
  [
    set backward-stack fput best-path backward-stack
    set best-path first forward-stack
    set forward-stack but-first forward-stack
  ]
  display-best-path
end

; pop the path stack
;; pop-backward-stack :: {backward-stack popped and assigned to best-path}
to go-backward
  if not empty? backward-stack
  [
    set forward-stack fput best-path forward-stack
    set best-path first backward-stack
    set backward-stack but-first backward-stack
  ]
  display-best-path
end

; create a path with the nodes-list as its list of nodes
; Return a list of [ nodes-list length-of-path ]
to-report path-with-nodes [nodes-list]
  report (list nodes-list length-of-path nodes-list)
end

; push current best-path onto the path-stack and make path-and-length the new best
;; set-new-best-path :: Path -> {best-path pushed onto stack-path; best-path <- a-path; forward-stack emptied}
to set-new-best-path [a-path]
  ;if length best-path > 2 [set path-stack fput (list best-path best-length) path-stack]
  set forward-stack []
  if not ( best-path = [] )
  [ set backward-stack fput best-path backward-stack ]
  set best-path a-path
  set best-length length-of-path a-path
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; File utils ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to load-nodes-from-file
  let file user-file

  if ( file != false )
  [
    file-open file
    while [ not file-at-end? ]
    [ create-node-at-xy file-read file-read file-read ]
    file-close
  ]
end

;; Public Domain:
;; To the extent possible under law, Uri Wilensky has waived all
;; copyright and related or neighboring rights to this model.
@#$#@#$#@
GRAPHICS-WINDOW
231
10
1239
424
-1
-1
9.901
1
14
1
1
1
0
0
0
1
-50
50
-20
20
1
1
1
Generation No.
30.0

BUTTON
7
11
102
44
Generate
setup false
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1288
75
1374
108
NIL
GUI-on
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
1290
231
1371
264
Delete a node
delete-node
NIL
1
T
OBSERVER
NIL
D
NIL
NIL
0

MONITOR
6
178
74
223
path length
best-length
17
1
11

TEXTBOX
1248
140
1321
229
To delete a node, press the \"d\" key. The selected (orange) node will be deleted. \n\n
11
0.0
1

BUTTON
1248
319
1422
352
greedy path step-by-step
greedy-path-visible
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SWITCH
1248
27
1369
60
show-all-edges
show-all-edges
1
1
-1000

MONITOR
1247
523
1712
568
best-path
best-path
17
1
11

BUTTON
1248
358
1320
391
NIL
untwist
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
1246
401
1362
434
NIL
go-backward
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

MONITOR
1247
572
1713
617
previous path
;ifelse-value empty? path-stack \n;[\"stack empty\"]\n;[ path-part first path-stack ]\nifelse-value empty? backward-stack \n[\"stack empty\"]\n[ first backward-stack ]
17
1
11

TEXTBOX
1322
142
1449
240
YOU MAY HAVE TO CLICK OUTSIDE THE COMMAND CENTER AND THE VIEW, E.G., WHEN THE CURSOR IS A LARGE + SIGN, TO ACTIVATE THE \"D\" KEY.
11
0.0
1

BUTTON
109
48
225
81
GA Loop
continual-improvement
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

TEXTBOX
1262
113
1426
131
To add a node, click in the view.
11
0.0
1

TEXTBOX
1261
55
1426
73
___________________________
11
0.0
1

TEXTBOX
1259
261
1414
279
_________________________
11
0.0
1

MONITOR
1248
275
1329
320
NIL
count nodes
17
1
11

SLIDER
109
11
224
44
initial-node-count
initial-node-count
3
200
35.0
1
1
NIL
HORIZONTAL

TEXTBOX
1375
31
1455
62
Requires GUI-on to switch.
11
0.0
1

BUTTON
1246
437
1385
470
NIL
go-forward
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1248
475
1710
520
next path
;ifelse-value empty? path-forward-stack \n;[\"stack empty\"]\n;[ path-part first path-forward-stack ]\nifelse-value empty? forward-stack \n[\"stack empty\"]\n[ first forward-stack ]
17
1
11

TEXTBOX
8
233
214
275
---------------------------------------------------\nGenetic Algorithm inputs:
11
0.0
1

SLIDER
4
318
176
351
pop-size
pop-size
2
300
50.0
2
1
NIL
HORIZONTAL

SLIDER
3
385
175
418
percent-elite
percent-elite
0
100
6.0
1
1
NIL
HORIZONTAL

SLIDER
3
351
175
384
tournament-size
tournament-size
2
pop-size
2.0
1
1
NIL
HORIZONTAL

SLIDER
4
454
176
487
crossover-probability
crossover-probability
0
1
0.55
0.01
1
NIL
HORIZONTAL

SLIDER
1402
435
1574
468
mutation-probability
mutation-probability
0
1
0.54
0.01
1
NIL
HORIZONTAL

PLOT
230
426
575
682
Fitness over Generations
Generation
Path Length
0.0
10.0
0.0
1000.0
true
true
"" ""
PENS
"Best" 1.0 0 -2674135 true "" "plot min [fitness] of individuals"
"Worst" 1.0 0 -13791810 true "" "plot max [fitness] of individuals"
"Average" 1.0 0 -13840069 true "" "plot mean [fitness] of individuals"

PLOT
580
426
921
682
Diversity
Generation
Diversity
0.0
10.0
0.0
100.0
true
true
"" ""
PENS
"Diversity" 1.0 0 -16777216 true "" "plot 100 - diversity * 100"

SLIDER
3
419
175
452
percent-worst
percent-worst
0
100
1.0
1
1
NIL
HORIZONTAL

SLIDER
2
544
222
577
RANDOM_SWAP
RANDOM_SWAP
0
100
10.0
1
1
NIL
HORIZONTAL

SLIDER
2
578
222
611
UNTWIST_PAIR
UNTWIST_PAIR
0
100
10.0
1
1
NIL
HORIZONTAL

SLIDER
1
613
222
646
REVERSE_RANDOM_SUBSEQUENCE
REVERSE_RANDOM_SUBSEQUENCE
0
100
10.0
1
1
NIL
HORIZONTAL

SLIDER
2
648
221
681
REPLACE_PART_WITH_GREEDY
REPLACE_PART_WITH_GREEDY
0
100
10.0
1
1
NIL
HORIZONTAL

SLIDER
4
509
222
542
OPTIMIZE_RANDOM_NODE
OPTIMIZE_RANDOM_NODE
0
100
10.0
1
1
NIL
HORIZONTAL

SWITCH
7
264
110
297
FUSS
FUSS
1
1
-1000

MONITOR
76
178
133
223
age
best-path-age
1
1
11

TEXTBOX
1246
8
1396
26
Legacy UI Components:
11
0.0
1

MONITOR
7
83
94
128
initial solution
initial-best-length
1
1
11

MONITOR
5
132
130
177
NIL
population-at-match
1
1
11

BUTTON
7
47
102
80
Load File
setup true
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
109
86
226
119
GA Once
one-cycle
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

This is a code sample illustrating how to let the user drag turtles around with the mouse.

## NETLOGO FEATURES

The code also demonstrates the use of the `watch`, `subject`, and `reset-perspective` primitives.

<!-- 2004 -->
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.2
@#$#@#$#@
setup
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
