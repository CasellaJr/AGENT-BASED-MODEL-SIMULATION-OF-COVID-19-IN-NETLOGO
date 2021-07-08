;;BRUNO CASELLA PROJECT BEC

;; Let's define the Turtle characteristics
turtles-own [
  virus? ;;check if the turtle (agent) has virus (true or false)
  dead? ;;check if our agent is alive (true or false)
  immune? ;;check if our agent is immune (true or false)
  vaccinated? ;;check if our agent is vaccinated
  duration ;;a counter for the duration of the virus in the agent
  quarantined? ;;check if the turtle is in quarantine (true or false)
]

to setup ;;this procedure called "setup" sets up the simulation for start
  clear-all ;;clear the environment before of starting
  set-patch-size (400 / max-pxcor) ;,just adjust the display dimensions; adjust according to your hardware
  ;;Now I will create the turtles in this way: a numberAgents turtles that the user can define using the slider,
  ;;without virus, alive, not immune, not vaccinated, not quarantined,
  ;;with a person shape because they represent persons, and in random x-y position, and with a size of 1.2 to see better
  create-turtles numberAgents [
    setxy random-xcor random-ycor
    set virus? false
    set dead? false
    set immune? false
    set vaccinated? false
    set duration 0
    set quarantined? false
    set shape "person"
    set size 1.2 ]

  ;;and we want that one of these turtles gets infected:
  ask one-of turtles [set virus? true]
  ;;we want our turtles to be yellow is they are infected, blue if not infected, green if immune, red if dead, pink if quarantined, white if vaccinated
  ask turtles [recolor] ;;the recolor function will be created later.

  reset-ticks ;reset time of the simulation

end


;;Now another procedure, the "go" procedure.
;;Here we want our agents to move around the screen to interact
;;Turtles will do this for each tick of simulation
;;Inside this go procedure I will call several functions like move, spread, recolor, quarantine, vaccinate and recover
;;that I will define after the go procedure
to go
  ;;if all turtles have virus, then our simulation will stop
  if all? turtles [virus?] = true [stop]
  ;;and also if there are not turtles with virus, we stop the simulation
  if all? turtles [virus? = false] = true [stop]
  ;;and also if there are no more turtles to be vaccinated or dead
  if count turtles with [(vaccinated? = false and dead? = false)] < vaccines-per-day = true [stop]

  ;;what do we want? We want turtles moving and spreading:
  ask turtles [move]
  ;;call the quarantine function
  quarantine

  ask turtles [spread]
  ;;we want also that our turtles recolor depending if they are infected or not.
  ask turtles [recolor]
  ;;then our counter we want to go on.
  ask turtles [recover] ;;we want that our agents recover/die
  ;;call the vaccinate function
  vaccinate
  tick

end


to vaccinate
  if vaccinations = true [ ;;vaccinations is the switch button
    if (ticks > timeForVaccine) [ ;;vaccine developed after timeForVaccine days
    ask n-of vaccines-per-day turtles with [vaccinated? = false and dead? = false ] [ ;;we vaccinate #vaccines-per-day agents that are alive and not yet vaccinated
      set vaccinated? true
      set immune? true
      set virus? false
    ]
  ]
]
end

;;for both setup and go procedures I will create buttons


;;So, let's define our move function
to move
  ;;our agent will move only if it not dead and not quarantined
  if (dead? = false and quarantined? = false) [
    ;;we rotate our turtles of a random degree from 1 to 150.
    right random 150
    left random 150
    ;;now we want that turtles move forward by 1 step

    fd 1
  ]

end

to quarantine
  ask turtles with [virus? = true and dead? = false] ;;we quarantine turtles that are alive and infected, according to a probability-of-quarantine
    [
      if random-float 1 <= probability-of-quarantine[ ;;compare the probability with a random float between 0 and 1
        set quarantined? true
      ]
    ]
end


;;now define the spread function
to spread
  ;;we ask if the agent has virus and it can spread the virus
  ifelse virus? [] [
    if any? other turtles-here with [virus?] = true [
      ;;"here" means another agent in the area around this one single agent
      ;;if true, we set the agent virus? to true, but first we have to check if our agent is immune
      ;;but first, let's check if the agent is vaccinated
      ;;if it is vaccinated, with a simple formula, we reduce the probability to get infected
      let temp (1) ;;this variable will be used to reduce the probability of infection
      if vaccinated? [
        set temp (1 - vaccine-efficacy)
      ]
      if (virus? = false and immune? = false) [
        if (random-float 1 < (probabilityOfTransmission * temp))[ ;;compare the probabilityOfTransmission (that can be changed with the slider)
          ;;multiplied per temp, with a random float between 0 and 1. So, higher vaccine-efficacy implies less probability to set virus? true
          set virus? true ;;if agent is not immune, then the virus will spread
                        ;;the if that follows below is related to the switch button you see in the interface:
                        ;;if the switch is on you will see the connections among all the infected
          if connections [ask self [create-links-from other turtles-here with [virus?]]]
          ]
        ]
    ]
  ]
end

;the recolor function: it recolors agents based on their state
;;yellow = infected, blue = not infected, immune = green, dead = red, quarantined = pink, vaccinated = white
to recolor
  ifelse virus? [set color yellow] [set color blue]
  ;;very intuitive function: if virus? is true, we set the color of the turtle to yellow,
  ;;otherwise to blue
  ;;if immune we want green turtles
  if immune? = true [
    set color green
  ]
  if dead? = true [
    set color red
  ]
  if vaccinated? = true [
    set color white
  ]
  if quarantined? = true [
    set color pink
  ]
end

;;finally, the recover function: it will work only if our agent has virus
to recover
  if virus? = true [
    set duration duration + 1 ;;we increase the duration of the agent having virus
    ;;now we add a probability for recovering
    if random-float 1.0 < recoverProbability and duration > 10 [ ;;this is the chance to recover
    ;;random-float generates a number from 0 to 1 (in this case)
    ;;if this number is lower than a given threshold (in this case I put recoverProbability that you can modify using the slider),
    ;;which is the probability of recovery and if, moveover, the duration of infection is concrete (greater than 10 in this case)
    ;;the agent can recover, so an infected will be considered healthy, and immune.
      set virus? false ;;no more infection
      set immune? true ;;obtained immunity
      set quarantined? false ;;recovered, so no more quarantine
    ]
  if random-float 1.0 < deathProbability and duration > 5[ ;;this is the chance to die (i put deathProbability, you can change in the slider)
      set dead? true
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
339
10
1157
829
-1
-1
10.0
1
10
1
1
1
0
1
1
1
-40
40
-40
40
1
1
1
ticks
50.0

BUTTON
4
66
106
136
Setup
setup
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
114
66
230
136
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
3
168
213
201
recoverProbability
recoverProbability
0
1
0.9
0.05
1
NIL
HORIZONTAL

SLIDER
4
225
212
258
deathProbability
deathProbability
0
1
0.1
0.05
1
NIL
HORIZONTAL

SLIDER
4
285
211
318
numberAgents
numberAgents
15000
30000
18800.0
100
1
NIL
HORIZONTAL

PLOT
3
383
334
592
History
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"virus" 1.0 0 -1184463 true "" "plot count turtles with [virus?]"
"immune" 1.0 0 -13840069 true "" "plot numberAgents - count turtles with [immune?]"
"dead" 1.0 0 -2674135 true "" "plot count turtles with [dead?]"
"vaccinated" 1.0 0 -7500403 true "" "plot count turtles with [vaccinated?]"
"quarantined" 1.0 0 -2064490 true "" "plot count turtles with [quarantined?]"

SWITCH
4
341
211
374
connections
connections
0
1
-1000

SWITCH
2
605
136
638
vaccinations
vaccinations
1
1
-1000

SLIDER
4
701
176
734
timeForVaccine
timeForVaccine
5
50
30.0
1
1
NIL
HORIZONTAL

SLIDER
4
753
176
786
vaccine-efficacy
vaccine-efficacy
0
1
0.9
0.01
1
NIL
HORIZONTAL

SLIDER
3
653
222
686
probabilityOfTransmission
probabilityOfTransmission
0
1
0.75
0.01
1
NIL
HORIZONTAL

SLIDER
4
816
176
849
vaccines-per-day
vaccines-per-day
100
250
140.0
1
1
NIL
HORIZONTAL

SLIDER
4
869
217
902
probability-of-quarantine
probability-of-quarantine
0
1
0.9
0.01
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

Inspired in the COVID-19 (aka coronavirus) pandemic, this simplified model simulates the transmission and perpetuation of a virus in a human population. 

## HOW IT WORKS

The model is initialized with 18800 people, of which only 1 is infected. People move randomly about the world in one of the following states: not infected (blue), infected (yellow), immune (green), quarantined (pink), vaccinated (white). People may die (red) of infection. 

Some of these factors are summarized below with an explanation of how each one is treated in this model.

**The density of the population**

Population density affects how often infected, immune and susceptible individuals come into contact with each other. You can change the size of the initial population through the numberAgents slider.

**Population decrease**

People may die from the virus, the chances of which are determined by the slider deathProbability and the duration of the infection in the agent.

**Infectiousness (or transmissibility)**

How easily does the virus spread? Some viruses with which we are familiar spread very easily. Some viruses spread from the smallest contact every time. Others (the HIV virus, which is responsible for AIDS, for example) require significant contact, perhaps many times, before the virus is transmitted. In this model, infectiousness is determined by the "turtles-here" command patch.

**Duration of infectiousness**

How long is a person infected before they either recover or die? This length of time is essentially the virus's window of opportunity for transmission to new hosts. In this model, duration of infectiousness is fixed to 10, and matched with a probability of recover, to recover, otherwise is fixed to 5 and matched with a probability of death, to die. 

## HOW TO USE IT

Each "tick" represents a day in the time scale of this model.

The recoverProbability slider controls the likelihood that an infection will end in recovery/immunity. 

The deathProbability slider controls the likelihood that an infection will end in death. 

The numberAgents slider controls the number of agents involved in the simulation.

The connections switch controls the possibility of drawing links among the infected.

The Setup button resets the graphics and plots and randomly distributes numberAgents in the view. The GO button starts the simulation and the plotting function.

The vaccinations switch controls the possibility of vaccinate people or not. The timeForVaccine slider is basically the number in days after which the vaccine is released. Vaccines-per-day controls the flow of vaccinations per day. And probabilityOfTransmission controls the possibility of infection according with the vaccine-efficacy.

The probability-of-quarantine slider controls the probability of agent to be quarantined (stop moving) when infected. If 1, it always stop the agent.

An output monitor plots the number of agents that are infected, the number of agents that are immune, and the number of agents that are dead.


## THINGS TO NOTICE

The factors controlled by the sliders interact to influence how likely the virus is to thrive in this population. Notice that in all cases, these factors must create a balance in which an adequate number of potential hosts remain available to the virus and in which the virus can adequately access those hosts.

Often there will initially be an explosion of infection since no one in the population is immune. This approximates the initial "outbreak" of a viral infection in a population, one that often has devastating consequences for the humans concerned. Soon, however, the virus becomes less common as the population dynamics change. What ultimately happens to the virus is determined by the factors controlled by the sliders.

Notice that viruses that are too successful at first (infecting almost everyone) may not survive in the long term. Since everyone infected generally dies or becomes immune as a result, the potential number of hosts is often limited. 

## THINGS TO TRY

Think about how different slider values might approximate the dynamics of different scenarios. The famous Ebola virus in central Africa has a very short duration, a very high infectiousness value, and an extremely low recovery rate. For all the fear this virus has raised, how successful is it? Set the sliders appropriately and watch what happens.

The HIV virus, which causes AIDS, has an extremely long duration, an extremely low recovery rate, but an extremely low infectiousness value. How does a virus with these slider values fare in this model?

For the covid-19, it tipically produces a single bell-shaped distribution.

## EXTENDING THE MODEL

Assign a random age to population. Change the risk to die from the disease depending on the age. Die of old age. Assign a duration to the immunity.

## RELATED MODELS

Virus model from the NetLogo library. Wilensky, U. (1998).

## CREDITS AND REFERENCES

http://ccl.northwestern.edu/netlogo/models/Virus
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

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.0
@#$#@#$#@
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
