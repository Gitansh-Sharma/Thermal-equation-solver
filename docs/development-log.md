# Development Log

## Phase 1 — Initial Plane-Wall Solver

### Objective

Develop a MATLAB solver for steady-state one-dimensional heat conduction through a plane wall.

The initial problem was based on the steady conduction equation for a plane wall.

### Initial capability

The first implementation focused on:

* plane-wall geometry
* constant thermal conductivity
* steady-state conduction
* prescribed boundary conditions
* analytical solution

---

## Phase 2 — Heat Generation

Uniform volumetric heat generation was added.

The governing equation became:

[
\frac{d^2T}{dx^2}
=================

-\frac{\dot q'''}{k}
]

The total generated heat was added to the heat-transfer calculations:

[
\dot Q_{gen}=\dot q'''AL
]

An energy-balance check was introduced.

### Learning

The solver should not only calculate temperatures; it should also verify conservation of energy.

---

## Phase 3 — Boundary Conditions

The following boundary conditions were progressively implemented:

### Type 1 — Specified temperature

[
T=T_s
]

### Type 2 — Specified heat flux

[
-k\frac{dT}{dx}=q''
]

### Type 3 — Insulated

[
q''=0
]

### Type 4 — Convection

[
-k\frac{dT}{dx}=h(T_s-T_\infty)
]

### Type 5 — Radiation

[
-k\frac{dT}{dx}
===============

\epsilon\sigma(T_s^4-T_{sur}^4)
]

---

## Phase 4 — Finite-Difference Solver

`solvePlaneWallFD.m` was developed.

The solver uses:

* nodal discretization
* finite differences
* residual equations
* Jacobian matrix
* Newton iteration for nonlinear radiation
* convergence tolerance
* maximum iteration limit

The analytical `solvePlaneWall.m` was retained.

### Reason

The analytical solver provides a reference against which the numerical solver can be verified.

It is not obsolete.

---

## Phase 5 — First FD Verification

A constant-(k), heat-generation case was tested:

[
L=0.1m
]

[
k=10W/(mK)
]

[
\dot q'''=1000W/m^3
]

[
T_L=T_R=300K
]

[
N=41
]

The analytical maximum temperature is:

[
T_{max}=300.125K
]

at:

[
x=0.05m
]

The FD solver produced:

[
T_{max}=300.1250K
]

The energy balance error was:

[
0%
]

### Status

**PASS**

---

## Phase 6 — Mesh Test

The same physical problem was tested with different values of:

[
N=11,;21,;41,;81,;161
]

The maximum temperature remained approximately:

[
300.125K
]

for all tested grids.

### Interpretation

This does not by itself demonstrate a measurable convergence curve because the governing analytical temperature profile is quadratic and the central second-difference operator reproduces the second derivative of a quadratic function exactly at the interior nodes.

### Learning

A test can verify correctness without necessarily being suitable for demonstrating convergence order.

A separate convergence case will be developed later.

---

## Phase 7 — Convection Verification

A symmetric convection case was tested:

[
L=0.1m
]

[
k=10W/(mK)
]

[
\dot q'''=1000W/m^3
]

[
h_L=h_R=20W/(m^2K)
]

[
T_{\infty,L}=T_{\infty,R}=290K
]

The FD solution produced:

[
T_s=292.5K
]

and:

[
T_{max}=292.625K
]

The heat generation was:

[
100W
]

with approximately:

[
50W
]

leaving through each side.

Energy balance error:

[
0%
]

### Status

**PASS**

---

## Phase 8 — Conservative FD Formulation

The constant-(k) FD equation was reconsidered in preparation for variable conductivity.

The general governing equation was adopted:

[
\frac{d}{dx}
\left(k\frac{dT}{dx}\right)
+\dot q'''=0
]

The finite-difference formulation became:

[
-k_{i-\frac12}T_{i-1}
+
(k_{i-\frac12}+k_{i+\frac12})T_i
--------------------------------

k_{i+\frac12}T_{i+1}
+
\dot q'''\Delta x^2
=0
]

### Reason

Simply replacing a scalar (k) with (k_i) in the constant-(k) equation is not sufficient for a general variable-conductivity formulation.

The face-conductivity formulation provides a conservative treatment of heat flow and is suitable for material interfaces.

### Status

**Implemented and verified for constant (k)**

---

## Phase 9 — Radiation

Radiation was implemented using nonlinear Newton iteration.

The solver calculates:

[
F(T)
]

and:

[
J(T)
]

and solves:

[
J\Delta T=-F
]

until:

[
\max|\Delta T|<10^{-6}
]

or the maximum iteration count is reached.

---

## Phase 10 — Radiation Verification

A no-heat-generation radiation case was tested with:

[
T_{sur,L}=300K
]

[
T_{sur,R}=400K
]

[
\epsilon=0.8
]

The numerical solution produced:

[
T_L=358.3692K
]

[
T_R=362.1769K
]

and:

[
q=-380.7713W/m^2
]

The heat flux was constant throughout the wall, as expected for:

[
\dot q'''=0
]

Newton iteration converged in:

[
5
]

iterations.

### Status

**PASS — initial radiation verification**

---

## Phase 11 — Heat-Flux Visualization Issue

The heat-flux graph initially appeared to show oscillations.

Investigation showed that the numerical differences were extremely small and were being exaggerated by the automatic plot scaling.

A further inspection revealed that different finite-difference definitions were being used at boundary and interior nodes.

The heat-flux post-processing was changed to use consistent nodal derivatives.

### Result

The heat-flux distribution became physically smooth.

### Learning

A visual feature in a numerical plot should be investigated quantitatively before being interpreted as a physical phenomenon.

---

## Current Status

The project is currently at the transition between:

**Constant conductivity**

and:

**Variable conductivity**

The next development step is to introduce:

[
k=k(x)
]

while retaining constant (k) as a special case.

After that:

1. Two-material wall
2. Multilayer wall
3. Insulating layer
4. Interface heat-flux conservation
5. Variable-(k) validation
6. Combined variable-(k) and radiation problems
