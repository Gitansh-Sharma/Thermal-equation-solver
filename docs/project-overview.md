# 1-D Thermal Equation Solver

## 1. Project Overview

The **1-D Thermal Equation Solver** is a MATLAB-based numerical heat-transfer project developed to solve steady-state one-dimensional heat-conduction problems for different geometries and boundary conditions.

The project began as a plane-wall conduction solver and is being progressively developed into a more general thermal-analysis framework capable of handling:

* 1-D steady-state heat conduction
* Internal heat generation
* Multiple boundary conditions
* Convection
* Radiation
* Finite-difference numerical solutions
* Analytical solutions for verification
* Energy-balance checks
* Variable thermal conductivity
* Multilayer materials
* Insulating layers
* Numerical validation and mesh studies

The project is being developed incrementally, with each new physical or numerical feature being tested against known analytical solutions or conservation principles.

---

## 2. Initial Objective

The initial objective was to develop a MATLAB program capable of solving the steady-state one-dimensional heat-conduction equation for a plane wall.

The initial governing equation for constant thermal conductivity was:

[
k\frac{d^2T}{dx^2}+\dot q'''=0
]

where:

* (T) = temperature
* (x) = spatial coordinate
* (k) = thermal conductivity
* (\dot q''') = volumetric heat-generation rate

For the case without heat generation:

[
\frac{d^2T}{dx^2}=0
]

---

## 3. Initial Project Structure

The project was organized into separate modules so that the analytical solution, boundary conditions, geometry, heat-transfer calculations, validation, input handling, and visualization could be developed independently.

The structure evolved toward:

```text
Thermal-equation-solver/
│
├── main.m
│
├── src/
│   ├── analytical/
│   ├── boundaryConditions/
│   ├── geometry/
│   ├── heatTransfer/
│   ├── input/
│   ├── numerical/
│   ├── validation/
│   └── visualization/
│
└── docs/
```

The modular structure was chosen to make future extensions easier rather than placing all calculations inside `main.m`.

---

## 4. Analytical Plane-Wall Solver

The first major solver was the analytical plane-wall solution.

For constant (k) and uniform heat generation:

[
\frac{d^2T}{dx^2}=-\frac{\dot q'''}{k}
]

The general analytical solution is:

[
T(x)=C_1+C_2x-\frac{\dot q'''}{2k}x^2
]

The analytical solver remains an important part of the project.

It will not be discarded when the numerical solver becomes more advanced.

Instead, it serves as a reference solution for verification and validation of the finite-difference method.

---

## 5. Heat Generation

Uniform volumetric heat generation was subsequently introduced.

The heat-generation term is:

[
\dot q''' \qquad [W/m^3]
]

For a wall of area (A) and thickness (L), the total generated heat is:

[
\dot Q_{gen}=\dot q'''AL
]

An energy-balance calculation was added to verify that the generated heat is accounted for by the heat leaving the boundaries.

---

## 6. Boundary Conditions

The solver was progressively extended to support five boundary-condition types:

1. Specified temperature
2. Specified heat flux
3. Insulated boundary
4. Convection
5. Radiation

The boundary-condition type is stored in the input structure and processed by the solver.

The insulated boundary condition represents:

[
q''=0
]

and should be distinguished from an **insulating material layer**, which will be introduced later through a low thermal conductivity.

---

## 7. Convection

Convection was added using:

[
q''=h(T_s-T_\infty)
]

where:

* (h) = convection coefficient
* (T_s) = surface temperature
* (T_\infty) = surrounding-fluid temperature

The convection boundary condition was tested using a symmetric plane-wall case with heat generation.

Test values:

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
T_\infty=290K
]

[
h=20W/(m^2K)
]

The numerical solution produced:

[
T_s=292.5K
]

and:

[
T_{max}=292.625K
]

with the maximum occurring at:

[
x=0.05m
]

The energy balance error was:

[
0%
]

This test was marked as PASS.

---

## 8. Finite-Difference Solver

A finite-difference solver was introduced as `solvePlaneWallFD.m`.

The finite-difference solver uses the nodal temperature vector:

[
[T_1,T_2,\ldots,T_N]^T
]

where (N) is the number of computational nodes.

The grid spacing is:

[
\boxed{\Delta x=\frac{L}{N-1}}
]

This distinction is important:

> (N) represents the number of nodes, not the number of intervals.

The finite-difference solver uses a residual vector and Jacobian matrix and solves the nonlinear system iteratively when necessary.

---

## 9. Conservative Finite-Difference Formulation

Initially, the interior equation was formulated for constant (k):

[
T_{i-1}-2T_i+T_{i+1}
+\frac{\dot q'''\Delta x^2}{k}=0
]

During development, it was recognized that this formulation is not the appropriate general form for spatially varying conductivity.

The governing equation was therefore reformulated as:

[
\boxed{
\frac{d}{dx}
\left(k\frac{dT}{dx}\right)
+\dot q'''=0
}
]

The corresponding conservative finite-difference equation is:

[
\boxed{
-k_{i-\frac12}T_{i-1}
+
(k_{i-\frac12}+k_{i+\frac12})T_i
--------------------------------

k_{i+\frac12}T_{i+1}
+
\dot q'''\Delta x^2
=0
}
]

This formulation was selected because it can naturally be extended to:

* variable (k(x))
* piecewise-constant conductivity
* multilayer walls
* insulating materials
* thermal interfaces

For the current constant-(k) case:

[
k_{i-\frac12}=k_{i+\frac12}=k
]

so the new formulation reduces to the original constant-(k) equation.

---

## 10. Radiation

Radiation was introduced as the fifth boundary-condition type.

The nonlinear radiation heat flux is:

[
\boxed{
q''_{rad}
=========

\epsilon\sigma
\left(T_s^4-T_{sur}^4\right)
}
]

where:

* (\epsilon) = surface emissivity
* (\sigma) = Stefan-Boltzmann constant
* (T_s) = surface temperature
* (T_{sur}) = surrounding temperature

Because the radiation term contains (T_s^4), the boundary condition is nonlinear.

The finite-difference solver therefore uses Newton iteration.

The Newton correction is obtained from:

[
J\Delta T=-F
]

followed by:

[
T^{new}=T+\Delta T
]

The Jacobian contribution from radiation contains:

[
4\epsilon\sigma T_s^3
]

---

## 11. Radiation Verification

A radiation test with no internal heat generation was performed:

[
L=0.1m
]

[
k=10W/(mK)
]

[
N=41
]

[
\epsilon_L=\epsilon_R=0.8
]

[
T_{sur,L}=300K
]

[
T_{sur,R}=400K
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
q_x=-380.7713W/m^2
]

at both boundaries.

Newton iteration converged in 5 iterations.

Maximum residual:

[
4.34\times10^{-6}
]

The constant heat flux was physically consistent with:

[
\dot q'''=0
]

because there is no internal heat generation.

---

## 12. Heat-Flux Post-Processing

A heat-flux visualization was developed from the finite-difference temperature solution.

The initial implementation used:

* first-order forward difference at the left boundary
* central difference at interior nodes
* first-order backward difference at the right boundary

This was mathematically valid, but it resulted in small endpoint deviations when plotting smooth heat-flux distributions.

The post-processing was subsequently changed to use consistent nodal derivatives:

### Left boundary

[
\frac{dT}{dx}
\approx
\frac{-3T_1+4T_2-T_3}{2\Delta x}
]

### Interior

[
\frac{dT}{dx}
\approx
\frac{T_{i+1}-T_{i-1}}{2\Delta x}
]

### Right boundary

[
\frac{dT}{dx}
\approx
\frac{3T_N-4T_{N-1}+T_{N-2}}{2\Delta x}
]

The resulting heat-flux distribution became physically consistent.

---

## 13. Current Project State

At the current stage, the project contains:

* Analytical plane-wall solution
* Finite-difference plane-wall solution
* Uniform heat generation
* Specified-temperature BC
* Specified-heat-flux BC
* Insulated BC
* Convection BC
* Radiation BC
* Newton iteration for radiation
* Heat-flux calculation
* Heat-transfer calculations
* Energy-balance checks
* Boundary-condition validation
* Temperature and heat-flux visualization

The next major development is:

[
\boxed{\text{Variable thermal conductivity }k(x)}
]

followed by:

[
\boxed{\text{Multilayer and insulating materials}}
]

---

## 14. Development Philosophy

The solver is being developed incrementally.

Each new feature should follow:

```text
Theory
   ↓
Mathematical formulation
   ↓
Implementation
   ↓
Test
   ↓
Error diagnosis
   ↓
Correction
   ↓
Validation
   ↓
Documentation
```

Mistakes and failed approaches are intentionally documented because they represent part of the numerical-learning process and help explain why the final implementation was selected.
