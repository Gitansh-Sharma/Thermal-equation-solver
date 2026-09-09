# Development Log

## Graph-Based Thermal Resistance Network — Component Resistance Integration

### Objective

Extend the graph-based thermal network architecture so that individual thermal components can obtain their thermal resistance either from directly supplied resistance values or from physical parameters.

This step moves the project further away from a fixed composite-wall formula solver toward a general thermal-resistance-network solver.

---

## 1. Previous Approach

The initial composite-wall implementation treated the wall as a collection of layers, primarily connected in series.

For a plane wall with constant thermal conductivity, the conduction resistance of a layer was calculated from:

\[
R_{cond}=\frac{L}{kA}
\]

For layers in series:

\[
R_{eq}=R_1+R_2+\cdots+R_n
\]

This approach worked for simple composite walls, but it became restrictive when the network could contain branches and combinations of series and parallel paths.

The project therefore transitioned to a graph-based representation.

---

## 2. Graph-Based Network Approach

The thermal network is represented using a MATLAB `graph`.

### Nodes

Nodes represent thermal points/junctions.

A node may represent:

- a hot boundary,
- a cold boundary,
- an internal junction,
- an intermediate temperature location.

Boundary nodes can have specified temperatures, while internal-node temperatures are solved by the network solver.

### Edges

Edges represent thermal connections between nodes.

An edge stores information such as:

- edge ID,
- starting node,
- ending node,
- thermal component type,
- thermal resistance.

The calculated thermal resistance is also stored as the MATLAB graph edge `Weight`.

Thus:

\[
\text{Edge Weight}=R_{th}
\]

This allows the graph itself to contain the resistance information required by the network solver.

---

## 3. Why the Graph Approach Was Chosen

A traditional implementation would have to explicitly determine whether resistances are in series or parallel and then apply different formulas.

For example:

### Series

\[
R_{eq}=R_1+R_2+\cdots+R_n
\]

### Parallel

\[
\frac{1}{R_{eq}}=
\frac{1}{R_1}+\frac{1}{R_2}+\cdots+\frac{1}{R_n}
\]

This becomes increasingly difficult for networks such as:

- series sections containing parallel branches,
- parallel branches containing series sections,
- multiple junctions,
- more complicated arbitrary networks.

The graph approach avoids explicitly classifying the entire network as series or parallel.

Instead, the network is represented directly by its topology and solved using nodal equations.

---

# 4. Component Resistance Calculation

A new central function was introduced:

```text
src/thermalResistance/calculateThermalResist.m
```

Its purpose is to answer:

> What is the thermal resistance of this individual thermal component?

The function supports two resistance-input modes.

### 4.1 Direct Resistance Mode

The user can directly provide a resistance:

\[
R_{th}=R_{input}
\]

This is useful when the resistance is already known.

For example:

```matlab
parameters.R = 0.015;
```

The function returns:

\[
R_{th}=0.015\;K/W
\]

This approach is also suitable for thermal contact resistance when the user already knows the contact resistance.

---

## 5. Parameter-Based Resistance

The second mode calculates resistance from physical parameters.

### 5.1 Conduction

For one-dimensional plane-wall conduction with constant thermal conductivity:

\[
R_{cond}=\frac{L}{kA}
\]

where:

- \(L\) = conduction length,
- \(k\) = thermal conductivity,
- \(A\) = cross-sectional area.

The existing:

```text
calculateConductionResistance.m
```

function is reused rather than duplicating the conduction equation.

Example:

\[
L=0.02\;m
\]

\[
k=5\;W/(mK)
\]

\[
A=0.5\;m^2
\]

Therefore:

\[
R_{cond}
=
\frac{0.02}{5(0.5)}
=
0.008\;K/W
\]

---

### 5.2 Thermal Contact Resistance

For the current implementation, contact resistance is supplied directly:

\[
R_{contact}=R_c
\]

No contact-resistance correlation is currently imposed.

Example:

\[
R_c=0.010\;K/W
\]

Therefore:

\[
R_{contact}=0.010\;K/W
\]

This was intentionally chosen so that the user can enter a known thermal contact resistance directly.

---

### 5.3 Convection

For convection at a surface:

\[
R_{conv}=\frac{1}{hA}
\]

where:

- \(h\) = convection heat-transfer coefficient,
- \(A\) = heat-transfer area.

Example:

\[
h=80\;W/(m^2K)
\]

\[
A=0.5\;m^2
\]

Therefore:

\[
R_{conv}
=
\frac{1}{80(0.5)}
=
0.025\;K/W
\]

---

## 6. `calculateThermalResist` Architecture

The function first determines how the resistance is being supplied:

```text
Input mode
│
├── Direct
│   └── Use supplied R
│
└── Parameters
    │
    ├── Conduction
    ├── Contact
    └── Convection
```

This gives a common interface for different thermal components.

The current mathematical mapping is:

| Component | Input mode | Resistance |
|---|---|---|
| Any supported component | Direct | \(R=R_{input}\) |
| Conduction | Parameters | \(R=L/(kA)\) |
| Contact | Parameters | \(R=R_c\) |
| Convection | Parameters | \(R=1/(hA)\) |

Radiation is intentionally not included at this stage.

---

# 7. Modification of `addThermalEdge`

Previously, the edge was created by directly supplying the resistance.

The architecture has now been changed so that `addThermalEdge` can receive:

- node 1,
- node 2,
- component type,
- resistance input mode,
- component parameters.

It then calls:

```matlab
calculateThermalResist(...)
```

to determine the resistance.

The calculated value is stored in the edge and used as the graph weight.

The resulting flow is:

```text
Component parameters
        ↓
addThermalEdge
        ↓
calculateThermalResist
        ↓
Rth
        ↓
network.edges.R
        ↓
network.graph.Edges.Weight
```

This separates component-level resistance calculation from network-level analysis.

---

# 8. Network Resistance Solver

The existing:

```text
calculateNetworkResistance.m
```

was retained as the network-level solver.

Its job is not to determine what type of thermal component an edge represents.

It only needs the final resistance stored on each graph edge.

Therefore:

```text
Conduction
Contact
Convection
        ↓
      Rth
        ↓
Graph Weight
        ↓
Network Solver
```

This means the network solver does not need separate logic for each resistance type.

---

# 9. Mathematical Method Used by `calculateNetworkResistance`

The network solver uses nodal thermal energy balances.

For an edge connecting nodes \(i\) and \(j\):

\[
Q_{ij}=\frac{T_i-T_j}{R_{ij}}
\]

Define thermal conductance:

\[
G_{ij}=\frac{1}{R_{ij}}
\]

Therefore:

\[
Q_{ij}=G_{ij}(T_i-T_j)
\]

The conductance is used internally to construct the nodal equation matrix.

---

## 10. Conductance Matrix Assembly

For every edge between nodes \(i\) and \(j\), the solver adds:

\[
+G_{ij}
\]

to the diagonal terms:

\[
K_{ii}=K_{ii}+G_{ij}
\]

\[
K_{jj}=K_{jj}+G_{ij}
\]

and:

\[
-G_{ij}
\]

to the off-diagonal terms:

\[
K_{ij}=K_{ij}-G_{ij}
\]

\[
K_{ji}=K_{ji}-G_{ij}
\]

The complete network therefore produces a matrix equation of the form:

\[
[K]\{T\}=\{b\}
\]

where:

- \([K]\) = thermal conductance matrix,
- \(\{T\}\) = vector of nodal temperatures,
- \(\{b\}\) = contribution from known boundary temperatures.

---

# 11. Normalized Boundary Temperatures

To calculate equivalent resistance, the solver currently uses:

\[
T_{hot}=1
\]

\[
T_{cold}=0
\]

Therefore:

\[
\Delta T=1
\]

This is a normalized temperature difference.

The internal-node temperatures are solved from the nodal equations.

The resulting heat flow at the hot boundary is then calculated.

Finally:

\[
R_{eq}=\frac{\Delta T}{Q}
\]

Since:

\[
\Delta T=1
\]

the calculated equivalent resistance is simply:

\[
R_{eq}=\frac{1}{Q}
\]

This method avoids explicitly reducing the network into a sequence of series and parallel formulas.

---

# 12. Validation Test

A mixed series-parallel network was constructed using both direct and parameter-based resistance inputs.

The graph contained:

```text
Node 1
   │
   │ R = 0.008
   │
Node 2
  / \
 /   \
R=.010 R=.025
 |       |
Node 3  Node 4
 |       |
R=.010 R=.025
 \       /
  \     /
   Node 5
      │
      │ R=.010
      │
   Node 6
```

The edge resistances calculated by the new architecture were:

| Edge | Resistance |
|---|---:|
| 1 → 2 | 0.008 K/W |
| 2 → 3 | 0.010 K/W |
| 2 → 4 | 0.025 K/W |
| 3 → 5 | 0.010 K/W |
| 4 → 5 | 0.025 K/W |
| 5 → 6 | 0.010 K/W |

The upper branch was:

\[
R_{upper}=0.010+0.010=0.020\;K/W
\]

The lower branch was:

\[
R_{lower}=0.025+0.025=0.050\;K/W
\]

Their parallel equivalent was:

\[
R_p=
\frac{R_{upper}R_{lower}}
{R_{upper}+R_{lower}}
\]

\[
R_p=
\frac{(0.020)(0.050)}
{0.020+0.050}
=
0.014285714\;K/W
\]

The total resistance was:

\[
R_{eq}=0.008+0.014285714+0.010
\]

\[
\boxed{R_{eq}=0.032285714\;K/W}
\]

The MATLAB graph-based solver returned:

```text
Equivalent Thermal Resistance = 0.032285714 K/W
```

The numerical result therefore agrees with the independent analytical series-parallel calculation.

---

# 13. What This Validation Demonstrated

The test simultaneously verified:

- direct resistance input,
- parameter-based conduction resistance,
- parameter-based convection resistance,
- direct contact resistance,
- resistance storage in thermal edges,
- graph edge weights,
- series behavior,
- parallel behavior,
- series sections surrounding parallel branches,
- nodal network solution,
- equivalent resistance calculation.

The most important architectural result is that the solver determined the network behavior from graph connectivity rather than requiring the user/programmer to manually specify which edges were series or parallel.

---

# 14. Current Architecture

The current conceptual architecture is:

```text
                   Thermal Network
                         │
              ┌──────────┴──────────┐
              │                     │
            Nodes                 Edges
                                    │
                           Thermal component
                                    │
                         calculateThermalResist
                                    │
                                    ↓
                                   Rth
                                    │
                                    ↓
                            Graph Edge Weight
                                    │
                                    ↓
                       calculateNetworkResistance
                                    │
                                    ↓
                         Nodal thermal solution
                                    │
                                    ↓
                         Equivalent resistance
```

The responsibilities are now separated:

### `calculateThermalResist`

Determines the resistance of an individual component.

### `addThermalEdge`

Creates the thermal connection and stores its calculated resistance in the graph.

### `calculateNetworkResistance`

Solves the complete resistance network.

This modularity will make future additions easier.

---

# 15. Radiation Status

Radiation is intentionally postponed.

Radiation cannot generally be treated as a constant resistance using the same simple linear equations because:

\[
Q_{rad}
=
\epsilon\sigma A
\left(T_s^4-T_{sur}^4\right)
\]

The heat-transfer relation is nonlinear in temperature.

The existing project already contains a nonlinear finite-difference radiation treatment using iterative solution methods. Radiation will therefore be integrated into the thermal-network architecture as a later extension rather than being forced into the current constant-resistance framework.

---

# 16. Future Development

The planned next steps are:

1. Integrate the new resistance architecture into `main.m`.
2. Test mixed networks directly through the main project workflow.
3. Improve the thermal-network data structure as required.
4. Add more complex network topologies.
5. Add thermal contact resistance and convection as standard GUI-selectable components.
6. Develop a Python-based graphical network editor.
7. Allow users to draw nodes and edges visually.
8. Allow users to select component types and choose direct resistance or parameter-based input.
9. Connect the GUI to the MATLAB thermal-network solver.
10. Later investigate the correct nonlinear treatment of radiation within the network framework.
11. Continue validation against analytical solutions, energy balances, mesh studies, and other planned verification cases.

---

## Engineering Lesson

The major lesson from this stage is that **component physics and network topology should be separated**.

The resistance calculation answers:

> What is the resistance of this component?

The graph answers:

> How are these components connected?

The network solver answers:

> What is the resulting heat flow and equivalent resistance?

Keeping these responsibilities separate prevents the network solver from becoming dependent on individual component types and provides a scalable foundation for the future GUI and additional heat-transfer mechanisms.
