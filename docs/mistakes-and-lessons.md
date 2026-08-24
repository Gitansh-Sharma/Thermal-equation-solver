# Mistakes and Lessons Learned

This document records mistakes, incorrect assumptions, numerical issues, and debugging experiences encountered during development.

The purpose is not to hide mistakes but to document the reasoning process used to identify and correct them.

---

## Lesson 1 — Number of Nodes vs Number of Intervals

### Initial confusion

The meaning of (N) in the finite-difference grid had to be clarified.

### Correct definition

(N) represents the number of computational nodes.

Therefore:

[
\boxed{\Delta x=\frac{L}{N-1}}
]

There are (N-1) intervals between (N) nodes.

### Why it matters

Using:

[
\Delta x=\frac{L}{N}
]

would incorrectly define the grid spacing and affect the finite-difference solution.

### Lesson

Always explicitly distinguish between:

* nodes
* intervals
* elements

when defining a numerical mesh.

---

## Lesson 2 — Incorrect Expected Maximum Temperature

### What happened

For the first heat-generation test, an incorrect expected maximum temperature of approximately:

[
302.5K
]

was initially calculated.

### Correction

The analytical solution was recalculated:

[
T(x)=300+\frac{\dot q'''}{2k}x(L-x)
]

At:

[
x=0.05m
]

the correct result is:

[
\boxed{T_{max}=300.125K}
]

### Lesson

A numerical result should be checked against an independently derived analytical calculation, and arithmetic in the analytical reference must also be verified.

---

## Lesson 3 — Constant-(k) Equation Is Not the General Variable-(k) Equation

### Initial formulation

The finite-difference solver used:

[
k\frac{d^2T}{dx^2}+\dot q'''=0
]

This is valid when (k) is constant.

### Problem

For spatially varying conductivity:

[
k=k(x)
]

the correct governing equation is:

[
\boxed{
\frac{d}{dx}
\left(k\frac{dT}{dx}\right)+\dot q'''=0
}
]

### Correction

A conservative face-conductivity formulation was adopted.

### Lesson

A variable material property cannot always be introduced by simply replacing a constant with an array. The governing differential equation itself must be considered.

---

## Lesson 4 — Radiation Is Nonlinear

### Initial assumption

Radiation was initially approached conceptually like the linear convection boundary condition.

### Problem

Radiation contains:

[
T_s^4
]

through:

[
q''_{rad}
=========

\epsilon\sigma(T_s^4-T_{sur}^4)
]

Therefore the resulting system is nonlinear.

### Correction

Newton iteration was introduced using:

[
J\Delta T=-F
]

### Lesson

The mathematical form of a boundary condition determines the appropriate numerical solution method.

---

## Lesson 5 — Heat-Flux Graph Appeared to Oscillate

### Observation

The heat-flux graph initially appeared to contain large oscillations.

### Investigation

The numerical values were actually extremely close to one another. MATLAB's automatic y-axis scaling magnified tiny floating-point differences.

### Further investigation

The boundary heat flux was also being calculated using a different finite-difference approximation from the interior.

### Correction

Consistent nodal derivative approximations were introduced:

* second-order forward difference at the left boundary
* central difference at interior nodes
* second-order backward difference at the right boundary

### Lesson

A strange-looking plot does not necessarily indicate a physical or numerical instability.

Always inspect:

1. numerical magnitude
2. scale
3. mathematical definition
4. boundary treatment

before concluding that the solver is wrong.

---

## Lesson 6 — Boundary Flux and Plotted Flux Are Not Necessarily the Same Quantity

During development, the boundary finite-volume/control-volume treatment and the nodal heat-flux visualization were temporarily mixed.

For example, the boundary equations included the half-cell heat-generation contribution:

[
\frac{\dot q'''\Delta x}{2}
]

while the heat-flux plotting function was calculating a temperature-gradient-based nodal quantity.

### Lesson

The following should be treated as related but distinct quantities:

* numerical heat flux used by the governing equations
* boundary heat-transfer flux dictated by a boundary condition
* nodal heat-flux quantity used for visualization
* control-volume flux used for energy conservation

Keeping these definitions consistent is especially important when variable conductivity and multilayer materials are introduced.

---

## General Learning Principle

The project is being developed with the following philosophy:

> A numerical solver should not be considered correct merely because it produces a plausible temperature plot.

Each implementation should be checked using:

* governing equations
* limiting cases
* analytical solutions where available
* energy conservation
* boundary-condition satisfaction
* mesh behavior
* physical interpretation
* independent calculations

Mistakes are treated as part of the numerical-learning process and are recorded so that the reasoning behind the final implementation remains traceable.
