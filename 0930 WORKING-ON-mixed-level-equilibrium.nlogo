;`@model shallow lake ecosystem (Netlogo model)
;`@author Yanjie Zhao

;`@global Global variables
;`@details There are two parts of global variables, to support environmental and biological settings respectively. 
;`@code TRUE
globals [ water-depth ] ; the depth of the lake and the lake is assumed to be flat in bottom
globals [ water-temperature ]  
globals [ total-nutrient-concentration ]  ; The assumption is total nutrient and water volumn is constant in the whole system. 
globals [ global-free-nutrient-concentration ]  ; Variable Nf, nutrient in water: P is mainly evaluated as a nutrient indicator; mg/L
globals [ nutrient-concentration-in-phytoplankton ]  ; Np, default value= 0.01, g g-1
globals [ nutrient-concentration-in-zooplankton]
globals [ nutrient-concentration-in-fish]                                                             ;; time scale  calculated by ticks
globals [ days ] ; time scale
globals [ basic-photosynthesis-rate ]                                        ;; function of temperature; generic growing rate, applied on cynaobacteria, diatom and green algae (Goldman, 1974)
globals [ phytoplankton-size-default ]
globals [ cyanobacteria-start-amount ]
  cyanobacteria-amount                                              ;; cyanobacteria initial agents number
  diatom-start-amount                                               ;; diatom initial agents number
  phytopolankton-amount                                                      ;; sum of diatom, cyanobacteria and green algae
  diatom-amount                                                     ;; keep track of diatom numbers for results
  greenalgae-start-amount                                           ;; green algae initial agents number
  greenalgae-amount
  phytoplankton-concentration                                       ;; biomass of all phytoplankton / volumn of the world / baseline
  zooplankton-concentration
  fish-concentration
  ;; PLANTS ;;
  macrophyte-start-amount
  submerged-macrophyte-amount
  fp-start-amount                                                   ;; floating plant starting amount
  fp-amount
  ;; CONSUMERS ;;-----------------------------------------------------
  zooplankton-start-amount
  zooplankton-amount
  planktivore-fish-start-amount                                     ;; planktivore fish initial amount depending on the phase this model is emphasizing on
  planktivore-fish-amount
  omnivore-fish-start-amount                                        ;; omnivorous fishes take a large part of fish in Erhai, eating mollusk, snails and plankton as well
  omnivore-fish-amount
  herbivore-fish-start-amount                                       ;; herbivore fish eats mainly grass, e.g. grass carp
  herbivore-fish-amount
  piscivore-start-amount                                           ;; **piscivore fish is not considered now in Erhai as there is no report stating its significant effect
  piscivore-amount
  extinct?

  pf-hunting-rate
  hf-hunting-rate
  omf-hunting-rate
  pisci-hunting-rate

  ;; statistics/ output
  this-tick-reproduction
  this-tick-mortality
  mortality-accumulation-history
  reproduction-accumulation-history
]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;---------------------------------Ecosystem design---------------------------------------------------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; create agent sets of biome------------------------------------------------------------------------------------------------------------------
breed [ cyanobacteria a-cyanobacteria ]
breed [ diatom a-diatom]
breed [ greenalgae a-greenalgae ]
breed [ zooplankton a-zooplankton ]
breed [ submerged-macrophytes submerged-macrophyte ]
breed [ floating-plants floating-plant]
breed [ planktivore-fishes planktivore-fish ]
breed [ herbivore-fishes herbivore-fish ]
breed [ omnivore-fishes omni-fish ]
breed [ piscivores piscivore ]

;; attribute variables of all agents (turtles)---------------------------------------------------------------------------------------------------
turtles-own [
  last-energy
  energy                                                            ;; track of individual turtle's living status
  biodensity
  biomass                                                         ;; dry mass, ug
  BMR                                                               ;basal metabolic rate
  age                                                               ;; aging process for natural mortality (and maybe different living habitat)
  life-span
  shaded?
  light-attenuation
  nutrient-availability
  food
  food-preference
  now-survival-energy
;  target-prey
  vertical-factor
  growth-rate
  Z
]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;SETUP INITIALS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; setup and initiation process----------------------------------------------------------------------------------------------------------------------------------------------------------------
to setup
  ca
  clear-all-plots
  initialize-parameters                                             ;; initialize constants of variables
  create-function-groups
  initialize-variables
  ;; setup agents' vars based on function groups in Erhai
  output-type "This scope of lake is formed by " output-type world-width output-type " x " output-type world-height output-print " patches."
  output-type "Phytoplankton are initially set in agents of size " output-type phytoplankton-size-default output-print " ."
  output-type "The depth of the lake is set as a constant of " output-type water-depth output-print " m." output-type "Water temperature " output-type water-temperature output-type " celcius degree."
    ; set-refuge
  show-existence
  reset-ticks
end
to initialize-parameters
  set days 0
  ;; create agents' initial number---------------------------------------------------------------------------------------------------------
  set cyanobacteria-start-amount 20
  set diatom-start-amount 20
  set greenalgae-start-amount 20
  set macrophyte-start-amount 10
  set zooplankton-start-amount 60
  set phytopolankton-amount (diatom-start-amount + greenalgae-start-amount + cyanobacteria-start-amount)
  set fp-start-amount 10
  set planktivore-fish-start-amount 3
  set herbivore-fish-start-amount 2
  set omnivore-fish-start-amount 2
  set piscivore-start-amount 3
  set extinct? [ ]
  set phytoplankton-size-default 1

  set pf-hunting-rate 2
  set hf-hunting-rate 2
  set omf-hunting-rate 2
  set pisci-hunting-rate 2
;; set global environment in lake-----------------------------------------------------------------------------------------------------------------------------------------------

  set water-depth 5
  set nutrient-concentration-in-phytoplankton 0.1
  set nutrient-concentration-in-zooplankton 1
  set nutrient-concentration-in-fish 10

;; initial local setting of patches from gloabl background----------------------------------------------------------------------------------------------------------------------
  ask patches [
    set pcolor white
  ]
end

to create-function-groups
  create-cyanobacteria cyanobacteria-start-amount
  create-diatom diatom-start-amount
  create-greenalgae greenalgae-start-amount
  create-zooplankton zooplankton-start-amount
  create-submerged-macrophytes macrophyte-start-amount
  create-floating-plants fp-start-amount
  create-planktivore-fishes planktivore-fish-start-amount
  create-herbivore-fishes herbivore-fish-start-amount
  create-omnivore-fishes omnivore-fish-start-amount
  create-piscivores piscivore-start-amount
  breeds_settings
end

to initialize-variables
  set  cyanobacteria-amount count cyanobacteria
  set  diatom-amount count diatom
  set  greenalgae-amount count greenalgae
  set  zooplankton-amount zooplankton-start-amount
  set  submerged-macrophyte-amount macrophyte-start-amount
  set  fp-amount fp-start-amount
  set  planktivore-fish-amount planktivore-fish-start-amount
  set  piscivore-amount piscivore-start-amount
  set  basic-photosynthesis-rate 5.35 * 10 ^ 9 * e ^ ( -6473 / (water-temperature + 273.15) )      ;;~= 2                  ;; from Monod Model and Arrhenius function (Goldman, 1974)
;; set environment-------------------------------------------------------------------------------------------------------------------------
  set global-free-nutrient-concentration total-nutrient-concentration
  set phytoplankton-concentration ( sum [ biomass ] of diatom + sum [ biomass ] of cyanobacteria + sum [ biomass ] of greenalgae ) / ( world-width * world-height * water-depth)
end

to breeds_settings
  ask cyanobacteria [
    setxy random-xcor random-ycor
    set shape "cyano"
    set size phytoplankton-size-default
    set color 65
    ; biometrics
    set biodensity 0.1
    set biomass biodensity * size
    set energy 60 * ln ( biomass ^ 2 ) + 300
    set last-energy energy
    set BMR 0.75
    set age 0.5
    set life-span 20
    set Z random-normal 1 0.5
    set light-attenuation 1
    set nutrient-availability 1 - exp ( - 2 * Z - 2)
    set now-survival-energy  22 +  e ^ (30 * global-free-nutrient-concentration )
    set vertical-factor light-attenuation *  nutrient-availability
    set shaded? False
  ]
  ask diatom [
    setxy random-xcor random-ycor
    set shape "diatom"
    set size phytoplankton-size-default
    ; biometrics
    set biodensity 0.1
    set biomass  biodensity * size
    set energy 60 * ln ( biomass ^ 2 ) + 300
     set last-energy energy
    set BMR 0.75
    set age 0.5
    set life-span 20
    set Z random-normal 1 0.5
    set light-attenuation 1
    set nutrient-availability 1 - exp ( - 1.2 * Z - 1)
    set now-survival-energy  22 +  e ^ (30 * global-free-nutrient-concentration )
    set vertical-factor light-attenuation *  nutrient-availability
    set shaded? False
  ]
  ask greenalgae [
    setxy random-xcor random-ycor
    set shape "dot"
    set color green
    set size phytoplankton-size-default
    ; biometrics
    set biodensity 0.1
    set biomass  biodensity * size
    set energy 60 * ln ( biomass ^ 2 ) + 300
     set last-energy energy
    set BMR 0.75   ;; stronger competition in saving energy
    set age 0.5
    set life-span 20

    set Z random-normal 1 0.5
    set light-attenuation 1
    set nutrient-availability 1 - exp ( - 1.2 * Z - 1)
    set now-survival-energy  22 +  e ^ (30 * global-free-nutrient-concentration )
    set vertical-factor light-attenuation *  nutrient-availability
    set shaded? False
  ]

  ask submerged-macrophytes [
    setxy random-xcor random-ycor
    set shape "plant"
    set size 2
    ; biometrics
    set biodensity 0.2
    set biomass  biodensity * size
    set energy 60 * ln ( biomass ^ 2 ) + 300
     set last-energy energy
    set color 67
    set BMR 0.75
    set age 0.5
    set life-span 200
    set now-survival-energy  22 +  e ^ (30 * global-free-nutrient-concentration )
  ]
  ask floating-plants [
    setxy random-xcor random-ycor
    set shape "fp"
    set color 64
    set size 2
  ; biometrics
    set biodensity 0.2
    set biomass  biodensity * size
    set energy 60 * ln ( biomass ^ 2 ) + 300
     set last-energy energy
    set BMR 0.75
    set age 0.5
    set life-span 200

  ]
;; CONSUMERS ;;-----------------------------------------------
  ask zooplankton  [
    setxy random-xcor random-ycor
    set shape "zooplankton"
    set size 1
   ; biometrics
    set biodensity 0.15
    set biomass  biodensity * size
    set energy 60 * ln ( biomass ^ 2 ) + 300
     set last-energy energy
    set BMR 0.5
    set age 0.5
    set life-span 80
    set food (list "greenalgae" "diatom" "cyanobacteria" )
    set food-preference (list 10 10 7 3)   ;; scale 10 to weigh how possible the food is taken when agents meet them --if random 9 < ?
  ]

  ask planktivore-fishes [
    setxy random-xcor random-ycor
    set shape "planktivore-fish"
    set size 2
    ; biometrics
    set biodensity 0.3
    set biomass  biodensity * size
    set energy 60 * ln ( biomass ^ 2 ) + 300
     set last-energy energy
    set BMR 0.2
    set age 0.5
    set life-span 365                                               ;; life span is arbitary and qualitative
    set food ( list "greenalgae" "diatom" "cyanobacteria"  "zooplankton" )
    set food-preference (list 8 7 3 10 )
  ]
  ask omnivore-fishes [
    setxy random-xcor random-ycor
    set shape "planktivore-fish"
    set size 2
    ; biometrics
    set biodensity 0.3
    set biomass  biodensity * size
    set energy 60 * ln ( biomass ^ 2 ) + 300
     set last-energy energy
    set BMR 0.2
    set age 0.5
    set life-span 365
    set food (list  "greenalgae" "diatom" "zooplankton" "submerged-macrophytes")
    set food-preference (list 8 7 9 6 )
  ]
  ask herbivore-fishes [
    setxy random-xcor random-ycor
    set shape "planktivore-fish"
    set color grey
     set size 2
    ; biometrics
    set biodensity 0.3
    set biomass  biodensity * size
    set energy 60 * ln ( biomass ^ 2 ) + 300
     set last-energy energy
    set BMR 0.2
    set age 0.5
    set life-span 365
    set food ( list "submerged-macrophytes" "floating-plants" )
    set food-preference (list 10 10 10 10 )
  ]
  ask piscivores [
    setxy random-xcor random-ycor
    set shape "piscivore-fish"
     set size 2
    ; biometrics
    set biodensity 0.4
    set biomass  biodensity * size
    set energy 60 * ln ( biomass ^ 2 ) + 300
     set last-energy energy
     set BMR 0.2
    set age 0.5
    set life-span 700
     set food (list "planktivore-fishes" "herbivore-fishes" "omnivore-fishes" )
    set food-preference (list 8 8 8 8 )
    ]

end

;; run life cycles of agents------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
to go                                                               ;; ecosystem running cycles we care about!
    set days ticks / 2
    ask turtles [
    set last-energy energy
    set age 0.5 + days ]
    phytoplankton-life
    macrophyte-life
    consumer-life
    wake-up-seeds
    show-existence
    tick
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ----------------------------biomes' life cycles---------------------------------------------------------------------------------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;LIFE LOOP 1: DIATOM AS A CANARY SPECIES (SLOW REPLICATING, WEAK COMPETITIVENESS) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;LIFE LOOP 2: GREENALGAE AS A KEYSTONE SPECIES (SLOW REPLICATING, BUT STRONG COMPETITIVENESS);;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;LIFE LOOP 3: CYANOBACTERIA AS A WEEDY SPECIES (FAST REPLICATING, BUT WEAK COMPETITIVENESS);;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; can form large inedible colonies whcih makes them less vulnerable to top-down control

to phytoplankton-life
  ask ( turtle-set diatom greenalgae cyanobacteria ) [
  repeat 4 [
  count-amounts
  phytoplankton-life-strategy
  phytoplankton-growth
  phytoplankton-spread
    ]
    phytoplankton-spread
    phytoplankton-reproduction
    phytoplankton-mortality-decomposition
  ]
end
;----diatom serving functions
to phytoplankton-life-strategy
  ;; algae repel each other and spread out
  ;; phytoplankton-spread
  ;; optimize the position for growth
  set light-attenuation exp ( - ( 0.1 * ( ( sum [ biomass ] of diatom + sum [ biomass ] of cyanobacteria + sum [ biomass ] of greenalgae + sum [biomass] of floating-plants) / ( world-width * world-height * water-depth) / 6) * Z / 2 )    )                        ;; Iz = I0 * exp(-Ez)  E light attenuation efficiency, m-1, 0.8 prox from He(2015)
  set nutrient-availability 1 - exp ( - 0.7 * Z )
  if any? other turtles-here with [ breed = diatom or breed = cyanobacteria or breed = greenalgae or breed = submerged-macrophytes or breed = floating-plants ] [
  if [ Z ] of one-of other turtles-here < Z [ set shaded? True ]
  set light-attenuation light-attenuation * e ^ ( 0.5 - [ count cyanobacteria-here + count diatom-here + count greenalgae-here ] of patch-here / 2)                           ;;shading effects
    if breed = cyanobacteria [ set light-attenuation light-attenuation * 1.2  ]     ;; shade tolerant and can grow at a higher turbidity than other algae
  ]
  phytoplankton-adapt                                          ;; shade, poor nutrient drives phytoplankton move to a better place
end
to phytoplankton-adapt                                         ;; phytoplankton move vertically towards the best combination of light and nutrient condition. light is assumed 100% penetrating.
  set vertical-factor light-attenuation * nutrient-availability
  if ( any? ( turtle-set diatom greenalgae cyanobacteria ) and vertical-factor < mean [ vertical-factor ] of ( turtle-set diatom greenalgae cyanobacteria ) ) [
      let best-Z [ Z ] of one-of other ( turtle-set diatom greenalgae cyanobacteria ) with-max [vertical-factor]
      let past-Z Z
      set Z ( best-Z - past-Z ) / ( random 2 + 1 ) + past-Z             ;; use up to 3 steps to approach the best factor position
   ;; check if there is any other older phytoplankon already there in the way
  if ( vertical-factor = max [ vertical-factor ] of ( turtle-set diatom greenalgae cyanobacteria ) and age < [ age ] of one-of other diatom-here with [ Z = best-Z ] )
    [ ifelse random 10 = 1
      [  die
      count-amounts ]                                          ;; fail to get best position
      [ set Z past-Z ]                                  ;; wait for a chance in the next round
    ]
  ]
end
to phytoplankton-growth    ;; idea: all phytoplankton share similar mechanism but
                           ;;   1) cyanobacteria have more shade tolerance, better ability to optimize their position, cause a higher turbidity per unit of biomass than other algae, and have a lower max production rate and metabolism rate.
                           ;;   2) diatom can divide more rapidly than other phytoplankton when condition is favourable for growth, can adapt to surviving long periods of nutrient and light limitation, and prevalent in cold waters(Anne-sophie, 2017).
                           ;;   3) green algae have medium replication rate and environment tolerance.
  ; photosynthesis
  count-amounts
  set growth-rate  basic-photosynthesis-rate * light-attenuation * ( global-free-nutrient-concentration  + 1.4 ) ;; phytoplankton-concentration is calculated
  ifelse growth-rate < 0 or global-free-nutrient-concentration < 0.01
    [    set growth-rate 0      ]   ;; stop photosynthesising
    [
    if breed = diatom  [set growth-rate growth-rate * ( 0.2 + 0.002 * (water-temperature + 0.7 * water-temperature ^ 2 - water-temperature ^ 3 / 63 ))  ]
    if breed = greenalgae [set growth-rate growth-rate * ( 0.2 + 0.0016 * (water-temperature + 0.7 * water-temperature ^ 2 - water-temperature ^ 3 / 72 ))  ]
    if breed = cyanobacteria [set growth-rate growth-rate * ( 0.2 + 0.003 * (water-temperature + 0.26 * water-temperature ^ 2 - water-temperature ^ 3 / 200 ))  ]
      let dEnergy energy * growth-rate
      set energy energy + dEnergy
      set biomass sqrt (e ^( (energy - 300) / 60 ) )
    ]
    ;;Metabolism - For benthic animial, Kleiber's law of the 3/4 power law works. Size-scaling of phytoplankton metabolism cannot be predicted by Kleiber’s rule.
   set energy energy - biomass ^ BMR       ;; benthic 3/4. body-mass 0.1 ~ 100; energy 0.1 ~ 32
   set biomass sqrt (e ^( (energy - 300) / 60 ) )
end
to phytoplankton-spread           ;; These algae have enzymes to repel each other, so they spread out evenly throughout the water
  if breed = diatom or breed = cyanobacteria or breed = greenalgae and count turtles with [ breed = diatom or breed = cyanobacteria or breed = greenalgae ] > 9
    [
      move-to min-one-of neighbors [sum [ biomass ] of diatom + sum [ biomass ] of cyanobacteria + sum [ biomass ] of greenalgae]
    ]
end

;; diatom reproduction: Daughter cells are identical to the parent except stock variables like age, energy.
   ;The reproduction process can occur by either sexual or asexual reproduction. All diatoms pass through a seed-like or a spore phase called the resting spore.
to phytoplankton-reproduction
   count-amounts
   let heir round ( energy / 23.69 )
   if heir - 1 > 0 [
   if breed = greenalgae [
    ifelse energy > 70 - 90  *  global-free-nutrient-concentration
      [
        set energy energy / heir   ;; ready to split and reproduce
        set biomass sqrt ( e ^ ( (energy - 300) / 60 ) )
         hatch ( heir - 1 )
             [ lt random 360 fd 1
               set age 0.5
               set shaded? False
               set this-tick-reproduction this-tick-reproduction + 1
               move-to min-one-of neighbors [ count diatom + count cyanobacteria + count greenalgae ]
             ]
      ] [ move-to min-one-of neighbors [count diatom + count cyanobacteria + count greenalgae] ]
  ]
 if breed = cyanobacteria [
    ifelse energy > 70 - 90  *  global-free-nutrient-concentration
      [
        set energy energy / heir
         set biomass sqrt ( e ^ ( (energy - 300) / 60 ) )
         hatch ( heir - 1 )
             [ lt random 360 fd 1
               set age 0.5
               set shaded? False
               set this-tick-reproduction this-tick-reproduction + 1
               move-to min-one-of neighbors [ count diatom + count cyanobacteria + count greenalgae]
             ]
    ] [  move-to min-one-of neighbors [count diatom + count cyanobacteria + count greenalgae] ]
  ]
 if breed = diatom [
    ifelse energy > 70 - 90  *  global-free-nutrient-concentration
      [
        set energy energy / heir
       set biomass sqrt ( e ^ ( (energy - 300) / 60 ) )
         hatch ( heir - 1 )
             [ lt random 360 fd 1
               set age 0.5
               set shaded? False
               set this-tick-reproduction this-tick-reproduction + 1
               move-to min-one-of neighbors [count diatom + count cyanobacteria + count greenalgae]
             ]
    ] [  move-to min-one-of neighbors [count diatom + count cyanobacteria + count greenalgae] ]
  ]
  ]
end

to phytoplankton-mortality-decomposition
   count-amounts
   set now-survival-energy 23
   if breed = diatom or breed = greenalgae or breed = cyanobacteria [
    if ( energy < now-survival-energy  or ( age > life-span and random 1 = 0 ))
     [
     set this-tick-mortality  this-tick-mortality + 1
     die
     count-amounts
     ]
   ]
end

;; some cyanobacteria can reproduce daughter cells who have more N fix heterocysts, or gas vesicles, depending on what is needed to dominate the lake.
 ;  Daughter cells / spores can be akinetes, which rest on the sediment until a future season, and then all rise up at about the same time to “take over” the lake.

;;;;;;;;;;;;LIFE LOOP 4: SUBMERGED MACROPHYTE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to macrophyte-life
  ask ( turtle-set submerged-macrophytes floating-plants ) [
  count-amounts
  repeat 2 [
   macrophyte-growth
   macrophyte-reproduction
    ]
  plant-mortality
  ]
end

to macrophyte-growth
   count-amounts
   set growth-rate  basic-photosynthesis-rate * ( global-free-nutrient-concentration  + 1.4 )
   ifelse growth-rate < 0 or global-free-nutrient-concentration < 0
    [    set growth-rate 0      ]
    [
    if breed = submerged-macrophytes [  set growth-rate growth-rate * ( 0.4 + 0.003 * (water-temperature + 0.7 * water-temperature ^ 2 - water-temperature ^ 3 / 60 ))  ]
    if breed = floating-plants [ set growth-rate growth-rate * ( 0.4 + 0.004 * (water-temperature + 0.7 * water-temperature ^ 2 - water-temperature ^ 3 / 60 ))  ]
     ]
  let dEnergy energy * growth-rate
  set energy energy + dEnergy
  set biomass sqrt (e ^ ( (energy - 300) / 60 ) )
  ;; Metabolism - For benthic animial, Kleiber's law of the 3/4 power law works. Size-scaling of phytoplankton metabolism cannot be predicted by Kleiber’s rule.
   set energy energy - biomass ^ BMR       ;; benthic 3/4. body-mass 0.1 ~ 100; energy 0.1 ~ 32
   set biomass sqrt (e ^ ( (energy - 300) / 60 ) )
   count-amounts
end
to macrophyte-reproduction
   ask submerged-macrophytes [
     count-amounts
     if energy > 300 * e ^ (-3 * global-free-nutrient-concentration) and age mod 31 = 30 and sum [ biomass ] of submerged-macrophytes-on neighbors + sum [ biomass ] of floating-plants-on neighbors   < 1000
      [
      move-to min-one-of neighbors [ sum [ biomass ] of submerged-macrophytes + sum [ biomass ] of floating-plants]
        let heir round (energy / 190 )
        set energy energy / heir
        set biomass sqrt (e ^ ( (energy - 300) / 60 ) )
        hatch (heir - 1)  [
          lt random 360 fd 2
          set age 0.5
          set energy energy / heir
          set biomass sqrt (e ^ ( (energy - 300) / 60 ) )
        ]
       ]
    ]
   ask floating-plants [
    count-amounts
    if ( energy > 150 and ( sum [ biomass ] of submerged-macrophytes-on neighbors + sum [ biomass ] of floating-plants-on neighbors ) < 1140 and age mod 16 = 15) [
      move-to min-one-of neighbors [ sum [ biomass ] of submerged-macrophytes + sum [ biomass ] of floating-plants]
      let heir round (energy / 190 )
      set energy energy / heir
      hatch (heir - 1) [
        lt random 360 fd 1
        set age 0.5
        set energy energy / heir
          set biomass sqrt (e ^ ( (energy - 300) / 60 ) )
       ]
    ]
  ]
end

to plant-mortality
  if breed = submerged-macrophytes [
    if energy < 100 or age > life-span
    [ die
      count-amounts
    ]
  ]
  if breed = floating-plants [
    if energy < 100  or age > life-span
    [ die
      count-amounts
    ]
  ]
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CONSUMERS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to consumer-life
  ask zooplankton [
    count-amounts
    repeat 3 [ zooplankton-seek-food ]
    excretion
    zoo-mortality-decomposition
    zoo-reproduction
  ]
  ask ( turtle-set planktivore-fishes omnivore-fishes herbivore-fishes piscivores ) [
    count-amounts
    fish-seek-food
    excretion
    zoo-mortality-decomposition
    zoo-reproduction
  ]
end

to  zooplankton-seek-food
   zooplankton-sweep-food-on-patch  ;; have food on spot
   if energy < 120                  ;; go for better food in neighbors if not full
     [ if (any? (turtle-set planktivore-fishes omnivore-fishes) in-cone 3 120 ) [ rt 90 ]
       move-to max-one-of patches in-cone 2 120 [ food-stock-count-here-of "zooplankton" ]
     ]
end
to zooplankton-sweep-food-on-patch
  let killing-list  turtles-here with [ (breed = greenalgae) or (breed = cyanobacteria) or (breed = diatom) ]
 ;; print killing-list
  let food-energy sum [ energy ] of killing-list
  set energy food-energy * 0.1 + energy
  set  biomass sqrt (e ^ ( (energy - 300) / 60 ) )
  ask killing-list [ die ]
end

to-report first-food-choice-here-of [ a ]
  let x 0   ;; select the richest food around
  let i 0
  let j 0
  if breed = a  [
    foreach food [
      name -> set x max (list x food-number-detect name 3 )
      if x = food-number-detect name 3 [ set j i ]
      set i i + 1
    ]
  ]
  report item j food
end
to-report food-number-detect [ name range-of-patch ]
  report count turtles with [ breed = name ] in-radius range-of-patch
end
to-report food-stock-count-here-of [ identity ]  ;; this is a reporter for patches
  let turtle-model turtles with [ breed = identity ]
  let x 0
  foreach [ food ] of turtle-model
  [
    name -> set x x + count turtles-here with [ breed = name ]
  ]
  report x
end

to fish-seek-food
    let pf  planktivore-fish-amount * pf-hunting-rate
    let omf omnivore-fish-amount *  omf-hunting-rate
    let hf   herbivore-fish-amount *  hf-hunting-rate
    let pisci  piscivore-amount *  pisci-hunting-rate

    if breed = "planktivore-fishes" [
    repeat pf     [ consumer-predating-as "planktivore-fishes"   ]
  ]
    if breed = "omnivore-fishes" [
    repeat omf    [ consumer-predating-as "omnivore-fishes"   ]
  ]
    if breed = "herbivore-fishes" [
    repeat hf     [ consumer-predating-as "herbivore-fishes"   ]
  ]
    if breed = "piscivores" [
    repeat pisci  [ consumer-predating-as "piscivores"   ]
  ]
end

to consumer-predating-as [ identity ]
   consumers-sweep-food-on-patch identity  ;; sweep food to achieve "ideal free distribution" experiment by Milinsky
   if energy < 1.2 * ( 60 * ln (biomass ^ 2) + 300 ) [
      move-to max-one-of patches in-cone 2 120 [ food-stock-count-here-of identity ]
     ]
    set biomass sqrt (e ^ ( (energy - 300) / 60 ) )   ;; Assimilate energy intake as excessive biomass
end
to  consumers-sweep-food-on-patch [ identity ]
  let turtle-model turtles with [ breed = identity ]
  let food-list [ food ] of turtle-model
  let killing-list turtles-here with [ member? breed food-list ]
  print killing-list
  let food-energy sum [ energy ] of killing-list
  set energy food-energy * 0.1 + energy
  set  biomass sqrt (e ^ ( (energy - 300) / 60 ) )
  ask killing-list [ die ]
end

to ingest [ target ]                                          ;; ingestion doesn't include the movement to predate, so only eat food on the patch
   let prey one-of turtles-here with [ breed = target ]
   if prey != nobody
   [
   let  energy-from-food [ energy ] of prey * 0.1            ;; assume assimilation rate
   set  energy energy + energy-from-food
   set  biomass sqrt (e ^ ( (energy - 300) / 60 ) )
   ask  prey [ die ]
  ]
end

to zoo-reproduction
   ask zooplankton [
    if ( energy > 100 and sum [ [ biomass ] of zooplankton ] of neighbors  < 12 )
    [
       let heir-number round (energy / 23 )
       set energy energy / heir-number
       set biomass sqrt (e ^ ( (energy - 300) / 60 ) )
        hatch ( heir-number - 1 ) [
          lt random 360 fd 1
          set age 0.5
          set energy energy / heir-number
          set biomass sqrt (e ^ ( (energy - 300) / 60 ) )
          set shaded? False
          set heading random 360
          fd 1
          ]
    ]
  ]
   ask planktivore-fishes [
    if ( energy > 280  and sum [ sum [ biomass ] of planktivore-fishes + sum [ biomass ] of herbivore-fishes + sum [ biomass ] of omnivore-fishes ] of neighbors  < 20) [

      let heir round (energy / 72 )
      set energy energy / heir
      set biomass sqrt (e ^ ( (energy - 300) / 60 ) )
      hatch (heir - 1 ) [
          lt random 360 fd 2
          set age 0.5
          set energy energy / heir
          set biomass sqrt (e ^ ( (energy - 300) / 60 ) )
          set shaded? False
          ]
      ]
  ]
   ask herbivore-fishes [
      if ( energy > 350  and sum [  sum [ biomass ] of planktivore-fishes + sum [ biomass ] of herbivore-fishes + sum [ biomass ] of omnivore-fishes ] of neighbors < 20 ) [

      let heir round (energy / 72 )
      set energy energy / heir
      set biomass sqrt (e ^ ( (energy - 300) / 60 ) )
     hatch heir - 1  [
          lt random 360 fd 2
          set age 0.5
          set energy energy / heir
          set biomass sqrt (e ^ ( (energy - 300) / 60 ) )
          set shaded? False
          ]
      ]
  ]
   ask omnivore-fishes [
   if ( energy > 238 + ( sum [  energy ] of herbivore-fishes + sum [ energy ] of planktivore-fishes + sum [ energy ] of omnivore-fishes  ) / ( world-width * world-height * water-depth) * 10  and sum [  sum [ biomass ] of planktivore-fishes + sum [ biomass ] of herbivore-fishes + sum [ biomass ] of omnivore-fishes ] of neighbors  < 20) [

      let heir round (energy / 72 )
      set energy energy / heir
      set biomass sqrt (e ^ ( (energy - 300) / 60 ) )
      hatch (heir - 1 ) [
          lt random 360 fd 2
          set age 0.5
          set energy energy / heir
          set biomass sqrt (e ^ ( (energy - 300) / 60 ) )
          set shaded? False
          ]

      ]
  ]
   ask piscivores [
   if ( energy > 273 + ( sum [ energy ] of piscivores  ) / ( world-width * world-height * water-depth) * 10 ) [
      let heir round (energy / 72 )
      set energy energy / heir
      set biomass sqrt (e ^ ( (energy - 300) / 60 ) )
      hatch (heir - 1 ) [
          lt random 360 fd 2
          set age 0.5
          set energy energy / heir
          set biomass sqrt (e ^ ( (energy - 300) / 60 ) )
          set shaded? False
          ]
      ]
  ]
end

to excretion
   ask zooplankton [
    if energy > 72.34 and random 10 > 2  [ excrete ]
  ]
   ask (turtle-set planktivore-fishes herbivore-fishes omnivore-fishes ) [
    if energy > 238.7  and random 10 > 2 [ excrete ]
  ]
   ask piscivores [
    if energy > 273 and random 10 > 2 [ excrete ]
  ]
end

to excrete
  set energy energy * 0.9   ;; portion of excretion is 0.6 in all assimilation
  set biomass sqrt (e ^ ( (energy - 300) / 60 ) )
  count-amounts
end

to zoo-mortality-decomposition
  if breed = zooplankton [
    set now-survival-energy 70
     if ( energy < now-survival-energy )  or (age > life-span )
  [
     set this-tick-mortality  this-tick-mortality + 1
     die
     count-amounts
  ]
  ]
  if breed = planktivore-fishes or breed = herbivore-fishes or breed = omnivore-fishes or breed = piscivores [
    set now-survival-energy  200
     if ( energy < now-survival-energy )  or (age > life-span)
    [
     set this-tick-mortality  this-tick-mortality + 1
     die
     count-amounts
    ]
  ]
   if breed = piscivores [
    set now-survival-energy  200
     if ( energy < now-survival-energy )  or (age > life-span)
    [
     set this-tick-mortality  this-tick-mortality + 1
     die
     count-amounts
    ]
  ]
end

to wake-up-seeds ;; referred from TOPOGRAPHIC MICHIGAN ABM

  if cyanobacteria-amount = 0 [ set extinct? lput cyanobacteria extinct? ]
  if diatom-amount = 0 [  set extinct? lput diatom  extinct?  ]
  if greenalgae-amount = 0 [ set extinct?  lput greenalgae extinct? ]
  if submerged-macrophyte-amount = 0 [ set extinct? lput submerged-macrophytes  extinct?  ]
  if fp-amount = 0 [ set extinct? lput floating-plants  extinct?  ]
  if zooplankton-amount = 0 [ set extinct? lput zooplankton  extinct?  ]
  if planktivore-fish-amount = 0 [ set extinct? lput planktivore-fishes extinct?  ]
  if herbivore-fish-amount = 0 [ set extinct? lput herbivore-fishes  extinct?  ]
  if omnivore-fish-amount = 0 [ set extinct? lput omnivore-fishes extinct?  ]
  if piscivore-amount = 0 [ set extinct? lput piscivores extinct?]

  if global-free-nutrient-concentration > 0.15 and empty? extinct? = false [
    ask patch random-xcor random-ycor [
      foreach extinct? [ seed -> sprout 1 [  set breed seed  breeds_settings set extinct? remove seed extinct?] ]
    ]
  ]
end

;;''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
;;------------------------------ life function toolkit-------------------------------------------------------------------------------------------
;;..............................................................................................................................................

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;REPORT, OUTPUT AND COUNTING;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to count-amounts
  ;; biological
  set cyanobacteria-amount count cyanobacteria
  set diatom-amount count diatom
  set greenalgae-amount count greenalgae
  set submerged-macrophyte-amount count submerged-macrophytes
  set fp-amount count floating-plants
  set phytopolankton-amount (diatom-amount + greenalgae-amount + cyanobacteria-amount)
  set zooplankton-amount count zooplankton
  set planktivore-fish-amount count planktivore-fishes
  set herbivore-fish-amount count herbivore-fishes
  set omnivore-fish-amount count omnivore-fishes
  set piscivore-amount count piscivores

  ;; global environment
  set phytoplankton-concentration ( sum [ biomass ] of diatom + sum [ biomass ] of cyanobacteria + sum [ biomass ] of greenalgae ) / ( world-width * world-height * water-depth)
  set zooplankton-concentration ( sum [ biomass ] of zooplankton) / ( world-width * world-height * water-depth)
  set fish-concentration ( sum [ biomass ] of herbivore-fishes + sum [ biomass ] of planktivore-fishes + sum [ biomass ] of omnivore-fishes + sum [ biomass ] of piscivores  ) / ( world-width * world-height * water-depth)
  set global-free-nutrient-concentration total-nutrient-concentration - phytoplankton-concentration * nutrient-concentration-in-phytoplankton - zooplankton-concentration * nutrient-concentration-in-zooplankton - fish-concentration * nutrient-concentration-in-fish
end

to show-existence ;; this function referred to turtlegrass.nlogo
  ask patches [     set pcolor white   ]
  ask (turtle-set diatom cyanobacteria greenalgae floating-plants submerged-macrophytes ) [
   ifelse show-energy?
    [ set label precision energy 0
    ifelse energy > now-survival-energy
          [ set label-color black ]
          [ set label-color red ]
    ]
    [ set label " " ]
]
 ask (turtle-set zooplankton herbivore-fishes omnivore-fishes planktivore-fishes piscivores ) [
  ifelse show-energy?
    [ set label precision energy 0
      ifelse energy > now-survival-energy
          [  ]
          [ set color red ]
    ]
    [ set label " " ]
  ]
end

to-report mean-net-flux-indi-energy-zooplankton
  report ( mean [ energy ] of zooplankton - mean [ last-energy] of zooplankton ) ;; mean net flux of energy in zooplankton
end
to-report mean-net-flux-indi-energy-greenalgae
  report ( mean [ energy ] of greenalgae - mean [ last-energy] of greenalgae ) ;
end
to-report mean-net-flux-indi-energy-diatom
  report ( mean [ energy ] of diatom - mean [ last-energy] of diatom )
end
to-report mean-net-flux-indi-energy-cyanobacteria
  report ( mean [ energy ] of cyanobacteria - mean [ last-energy] of cyanobacteria )
end
to-report mean-net-flux-indi-energy-fp
  report ( mean [ energy ] of floating-plants - mean [ last-energy] of floating-plants )
end
to-report mean-net-flux-indi-energy-sm
  report ( mean [ energy ] of submerged-macrophytes - mean [ last-energy] of submerged-macrophytes )
end
to-report mean-net-flux-indi-energy-pf
  report ( mean [ energy ] of planktivore-fishes - mean [ last-energy] of planktivore-fishes )
end
to-report mean-net-flux-indi-energy-omf
  report ( mean [ energy ] of omnivore-fishes - mean [ last-energy] of omnivore-fishes )
end
to-report mean-net-flux-indi-energy-hf
  report ( mean [ energy ] of herbivore-fishes - mean [ last-energy] of herbivore-fishes )
end
to-report mean-net-flux-indi-energy-pisci
  report ( mean [ energy ] of piscivores - mean [ last-energy] of piscivores )
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;EXTRA FUNCTIONS TO PLAY;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;---1. SET REFUGE AREA TO PREVENT FLOATING PLANT OVERGROWING (PRETENT FP CANNOT GROW IN REFUGE BECAUSE OF NET)
to set-refuge
  ask patches [
    if pxcor > 0.2 * max-pxcor and pycor > 0.2 * max-pycor [ set pcolor blue ]
  ]
end
;;---2. SET ADDITIONAL NUTRIENT INJECTED IN WATER BY TIME

;;---3. SET MANIPULATION MIMICING SOME RECOVERY ENGINEERING WORK, E.G. REMOVE SEDIMENT NUTRIENT, PLANT MACROPHYTE, CHANGE FISH COMPOSITION
@#$#@#$#@
GRAPHICS-WINDOW
23
158
174
310
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-5
5
-5
5
0
0
1
ticks
30.0

BUTTON
20
326
83
359
NIL
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
107
327
170
360
NIL
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

OUTPUT
19
373
475
460
11

SLIDER
25
25
198
58
water-temperature
water-temperature
0
40
36.0
1
1
°C
HORIZONTAL

PLOT
495
218
872
423
population size
step
number
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"diatom" 1.0 0 -3844592 true "" "if count diatom > 0 [ plot count diatom  ]\n\n\n"
"green algae" 1.0 0 -14439633 true "" "if count greenalgae > 0 \n[  plot count greenalgae  ]\n"
"cyanobacteria" 1.0 0 -12345184 true "" "if count cyanobacteria > 0 [ plot count cyanobacteria ]"
"zooplankton" 1.0 0 -12895429 true "" "if count zooplankton > 0 [ plot count zooplankton ]"

MONITOR
284
116
383
165
NIL
count diatom
17
1
12

MONITOR
392
116
536
165
NIL
count cyanobacteria
17
1
12

MONITOR
542
116
666
165
NIL
count greenalgae
17
1
12

PLOT
495
428
872
578
individual energy growth rate
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"diatom" 1.0 0 -3844592 true "" "ifelse count diatom > 0\n [ plot mean [ growth-rate ] of diatom ]\n [ stop ]"
"greenalgae" 1.0 0 -14439633 true "" "plot mean [ growth-rate ] of greenalgae"
"cyanobacteria" 1.0 0 -11221820 true "" "plot mean [ growth-rate ] of cyanobacteria"

TEXTBOX
495
193
645
211
Producer statistics
14
64.0
1

TEXTBOX
236
559
386
577
Fauna statistics
14
12.0
1

SLIDER
25
111
259
144
total-nutrient-concentration
total-nutrient-concentration
0
1
0.65
0.01
1
mg/L
HORIZONTAL

MONITOR
324
63
470
112
NIL
count zooplankton
17
1
12

MONITOR
828
64
992
113
NIL
count herbivore-fishes
17
1
12

MONITOR
473
63
653
112
NIL
count planktivore-fishes
17
1
12

MONITOR
659
63
823
112
NIL
count omnivore-fishes
17
1
12

MONITOR
537
10
690
59
NIL
count piscivores
17
1
12

PLOT
1035
18
1302
182
free nutrient concentration in water
NIL
NIL
0.0
0.2
0.0
0.3
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "\nplot global-free-nutrient-concentration"

PLOT
883
219
1344
399
biomass per unit space
NIL
NIL
0.0
10.0
0.0
0.01
true
true
"" ""
PENS
"phytoplankton" 1.0 0 -16777216 true "" "plot phytoplankton-concentration"
"zooplankton" 1.0 0 -7500403 true "" "plot zooplankton-concentration"
"fish" 1.0 0 -2674135 true "" "plot fish-concentration"

MONITOR
19
466
160
511
NPP
precision sum [ energy ] of ( turtle-set cyanobacteria diatom greenalgae floating-plants submerged-macrophytes)  2
17
1
11

MONITOR
18
520
196
565
Energy of Primary consumers 
precision ( sum [energy] of (turtle-set zooplankton herbivore-fishes) + 0.5 * sum [energy] of omnivore-fishes) 2
17
1
11

MONITOR
18
578
208
623
Energy of secondary consumers
precision ( sum [energy] of piscivores + 0.5 * sum [energy] of omnivore-fishes) 2
17
1
11

SWITCH
25
68
159
101
show-energy?
show-energy?
1
1
-1000

MONITOR
237
464
417
509
NIL
mean [energy] of zooplankton
17
1
11

MONITOR
237
514
402
559
NIL
mean [age ] of zooplankton
17
1
11

MONITOR
671
116
859
165
NIL
count submerged-macrophytes
17
1
12

MONITOR
861
116
1003
165
NIL
count floating-plants
17
1
12

PLOT
884
403
1347
599
Mean individual energy flux
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
"zooplankton" 1.0 0 -16777216 true "" "plot mean-net-flux-indi-energy-zooplankton"
"greenalgae" 1.0 0 -11085214 true "" "plot mean-net-flux-indi-energy-greenalgae"
"diatom" 1.0 0 -612749 true "" "plot mean-net-flux-indi-energy-diatom"
"cyanobacteria" 1.0 0 -12345184 true "" "plot mean-net-flux-indi-energy-cyanobacteria"
"floating plants" 1.0 0 -955883 true "" "plot mean-net-flux-indi-energy-fp"
"submerged macrophytes" 1.0 0 -6459832 true "" "plot mean-net-flux-indi-energy-sm"
"planktivore" 1.0 0 -7500403 true "" "plot mean-net-flux-indi-energy-pf"
"omnivore" 1.0 0 -2674135 true "" "plot mean-net-flux-indi-energy-omf"
"herbivore" 1.0 0 -1184463 true "" "plot mean-net-flux-indi-energy-hf"
"piscivore" 1.0 0 -10899396 true "" "plot mean-net-flux-indi-energy-pisci"

MONITOR
235
593
408
638
NIL
mean [age ] of planktivore-fishes
17
1
11

MONITOR
420
593
606
638
NIL
mean [age ] of omnivore-fishes
17
1
11

MONITOR
234
641
408
686
NIL
mean [age ] of herbivore-fishes
17
1
11

MONITOR
420
642
572
687
NIL
mean [age ] of piscivores
17
1
11

MONITOR
233
707
394
752
NIL
mean [age ] of greenalgae
17
1
11

MONITOR
401
708
561
753
NIL
mean [age ] of cyanobacteria
17
1
11

MONITOR
566
709
701
754
NIL
mean [age ] of diatom
17
1
11

@#$#@#$#@
## WHAT IS IT?

This model is an experiment field of ecosystem interactions. The environment is assumed as very simple to highlight biotic feedback loops that lead to system equilibrium.
* ENVIRONMENT ASSUMPTION: 
  - shallow (0-6 m)
  - transparent (turbidity builds on initial setting, coming from organisms)
  - fixed nutrient pool (total = nutrient in organism + nutrient in water)

BIOTIC PROPERTIES
 **GLOBAL

  + days

  + water-temperature

  + water-depth

  + turbidity

  + nutrient-concentration (total/free/in-phytoplankton/in-zooplankton/in-fish)

 **PATCH

  + patch suitability: intrinsic richness R

  + consumer density P
  
 **BREED of PRODUCERS

  + basic-photosynthesis-rate    a function of temperature 

  + Z                            depth, influencing nutrient and light in somatic growth

 **BREED of CONSUMERS

  + 

## HOW IT WORKS

rules the agents
* whole-system behavior

  The system behaviors are controlled by switches and sliders on the interface. 
  
  + switch: 'setup' 'go'
   'setup' includes setting initial parameters, creating agents, and returing the initial state of global variables.
   'go' includes life cycles of each agent in order of trophic levels, and fundamental refreshing processes in which variables and parameters are updated to keep agents adaptive to environment and community. 
  
  + stable state ("equilibrium")
    To keep an ecosystem balanced, annual total respiration should balance annual total GPP.  As energy passes from trophic level to trophic level, the following rules apply:

    1) Only a fraction of the energy available at one trophic level is transferred to the next trophic level. The rule of thumb is 10%, but this is very approximate. 

    2) Typically the numbers and biomass of organisms decrease as one ascends the food chain.
    
   + trophic level 
  - PRIMER
  - PRIMARY CONSUMER
   NPP(Net Primary Production) consumed by herbivores is used in respiration ( maintain body temperature, synthesize proteins, and move around), excretion/defecation, and death
   Assimilation = (Ingestion - Excretion)  ; The efficiency of this process of assimilation varies in animals, ranging from 15-50% if the food is plant material, and from 60-90% if the food is animal material. 

  - SECONDARY CONSUMER



* adaptive parameters and variables
  The agents' properties could vary after every action of each agent as a response to environmental pressure and community strategy. For producers, individual photopynthesis rate, somatic reproductive rate and mortality criteria are multiplied by impact factors of environmental variables. For consumers, individual growth rate, somatic reproductive rate and mortality criteria are multiplied by impact factors too. The adaptive variables allow our system to stablise itself.

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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

cyano
true
7
Circle -1184463 false false 120 150 0
Circle -1184463 true false 105 225 0
Circle -14835848 true true 174 24 42
Circle -14835848 true true 69 174 42
Circle -14835848 true true 84 144 42
Circle -14835848 true true 114 114 42
Circle -14835848 true true 144 84 42
Circle -14835848 true true 174 54 42

cylinder
false
0
Circle -7500403 true true 0 0 300

diatom
true
0
Circle -955883 true false 105 105 90

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

fp
false
0
Polygon -7500403 true true 148 166 135 135 120 90 105 90 75 105 60 135 60 165 60 180 75 210 120 240 150 240 180 240 195 225 210 210 225 180 225 150 210 120 195 105 180 90 150 90 150 75
Line -13840069 false 150 165 195 105
Circle -13840069 false false 135 165 22
Line -13840069 false 75 150 120 165
Line -13840069 false 135 180 75 210
Line -13840069 false 150 195 150 240
Line -13840069 false 165 195 195 225
Line -13840069 false 165 180 225 165
Line -13840069 false 135 150 105 105

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

phytoplankton
true
0
Circle -10899396 true false 133 133 32

piscivore-fish
true
0
Polygon -16777216 true false 255 165 240 150 270 150 270 150 255 120 225 105 180 105 90 120 60 120 30 135 -5 99 -6 112 4 142 -6 175 -5 185 30 150 45 165 49 164 60 165 90 165 120 180 195 195
Polygon -7500403 true true 199 191 152 196 135 195 169 184
Polygon -7500403 true true 195 105 165 90 150 90 150 90 150 105 153 112
Circle -7500403 true true 225 128 14

planktivore-fish
true
2
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true false 30 136 151 77 226 81 280 119 292 146 270 165 287 170 270 195 195 210 135 210 30 166
Circle -16777216 true false 215 106 30

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

snail
true
0
Polygon -6459832 true false 165 150 180 135 195 135 210 120 210 105 210 90 195 75 210 60 225 60 240 75 225 90 225 150 210 165 195 180 180 195 45 210
Circle -7500403 false true 45 90 120
Circle -6459832 true false 51 96 108
Circle -955883 true false 60 105 90
Circle -6459832 true false 71 116 67
Circle -7500403 true true 88 133 32
Circle -16777216 true false 105 150 0
Circle -16777216 true false 210 75 0
Line -6459832 false 210 60 195 45
Line -6459832 false 225 60 240 45

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

zooplankton
true
0
Polygon -13791810 true false 150 45 90 15 135 60 120 75 120 105 135 120 135 135 120 150 120 195 150 240 120 270 150 255 180 270 150 240 180 195 180 150 165 135 165 120 180 105 180 60 225 30 150 45
Polygon -1184463 true false 150 150 165 180 150 210 135 180
Circle -16777216 true false 135 75 0
Circle -16777216 true false 135 90 0
Polygon -16777216 true false 165 75 165 90 180 90 180 75 165 75
Rectangle -16777216 true false 120 75 135 90
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment perturbation-breed number" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="200"/>
    <metric>count diatom</metric>
    <metric>count cyanobacteria</metric>
    <metric>count greenalgae</metric>
    <metric>count submerged-macrophytes</metric>
    <metric>count floating-plants</metric>
    <metric>count zooplankton</metric>
    <metric>count planktivore-fishes</metric>
    <metric>count omnivore-fishes</metric>
    <metric>count herbivore-fishes</metric>
    <metric>count piscivores</metric>
    <enumeratedValueSet variable="total-nutrient-concentration">
      <value value="0.15"/>
      <value value="0.25"/>
      <value value="0.35"/>
      <value value="0.45"/>
      <value value="0.55"/>
      <value value="0.65"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="water-temperature">
      <value value="12"/>
      <value value="16"/>
      <value value="20"/>
      <value value="24"/>
      <value value="28"/>
      <value value="32"/>
      <value value="36"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment purtubation-breed biomass" repetitions="1" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="200"/>
    <metric>sum [ biomass ] of diatom</metric>
    <metric>sum [ biomass ] of cyanobacteria</metric>
    <metric>sum [ biomass ] of greenalgae</metric>
    <metric>sum [ biomass ] of submerged-macrophytes</metric>
    <metric>sum [ biomass ] of floating-plants</metric>
    <metric>sum [ biomass ] of zooplankton</metric>
    <metric>sum [ biomass ] of planktivore-fishes</metric>
    <metric>sum [ biomass ] of omnivore-fishes</metric>
    <metric>sum [ biomass ] of herbivore-fishes</metric>
    <metric>sum [ biomass ] of piscivores</metric>
    <enumeratedValueSet variable="total-nutrient-concentration">
      <value value="0.15"/>
      <value value="0.25"/>
      <value value="0.35"/>
      <value value="0.45"/>
      <value value="0.55"/>
      <value value="0.65"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="water-temperature">
      <value value="12"/>
      <value value="16"/>
      <value value="20"/>
      <value value="24"/>
      <value value="28"/>
      <value value="32"/>
      <value value="36"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="internal validation" repetitions="20" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="200"/>
    <metric>mean [ growth-rate ] of cyanobacteria</metric>
    <metric>mean [ growth-rate ] of diatom</metric>
    <metric>mean [ growth-rate ] of greenalgae</metric>
    <metric>mean [ growth-rate ] of submerged-macrophytes</metric>
    <metric>mean [ growth-rate ] of floating-plants</metric>
    <metric>count diatom</metric>
    <metric>count cyanobacteria</metric>
    <metric>count greenalgae</metric>
    <metric>count submerged-macrophytes</metric>
    <metric>count floating-plants</metric>
    <metric>count zooplankton</metric>
    <metric>count planktivore-fishes</metric>
    <metric>count omnivore-fishes</metric>
    <metric>count herbivore-fishes</metric>
    <metric>count piscivores</metric>
    <metric>precision sum [ energy ] of ( turtle-set cyanobacteria diatom greenalgae floating-plants submerged-macrophytes)  2</metric>
    <metric>precision ( sum [energy] of (turtle-set zooplankton herbivore-fishes) + 0.5 * sum [energy] of omnivore-fishes) 2</metric>
    <metric>precision ( sum [energy] of piscivores + 0.5 * sum [energy] of omnivore-fishes) 2</metric>
    <enumeratedValueSet variable="total-nutrient-concentration">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="water-temperature">
      <value value="24"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
