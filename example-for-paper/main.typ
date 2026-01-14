#import "@preview/diagraph:0.3.6": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import "graph-fns.typ": mkgraph, program-trace

#let eqmod(x) = $attach(=, b: #x)$
#let neqmod(x) = $attach(!=, b: #x)$

```c
int q[] = {1, 2, 3};
int *p = q;
int x = &p;
*p = *(p+1);
```

#pagebreak()

// step 0

#program-trace((
  (
    code: "",
    vars: (
      q: (val: "bot"),
      p: (val: "bot"),
      x: (val: "bot"),
    ),
  ),
))


#pagebreak()

// step 1

#program-trace((
  (
    code: "",
    vars: (
      q: (val: "m_0", points-to: "m_0"),
      p: (val: "bot"),
      x: (val: "bot"),
    ),
    custom-nodes: (
      (name: "m_0", label: "m_0"),
      (name: "m_1", label: "m_1"),
      (name: "m_2", label: "m_2"),

      (name: "v_m_0", label: "1"),
      (name: "v_m_1", label: "2"),
      (name: "v_m_2", label: "3"),
    ),
    custom-edges: (
      (from: "m_0", to: "m_1", label: "+1"),
      (from: "m_1", to: "m_2", label: "+1"),

      (from: "m_0", to: "v_m_0", label: "*"),
      (from: "m_1", to: "v_m_1", label: "*"),
      (from: "m_2", to: "v_m_2", label: "*"),

      (from: "v_m_0", to: "m_0", label: "\&"),
      (from: "v_m_1", to: "m_1", label: "\&"),
      (from: "v_m_2", to: "m_2", label: "\&"),
    ),
  ),
))

#pagebreak()

// step 2

#program-trace((
  (
    code: "",
    vars: (
      q: (val: "m_0", points-to: "m_0"),
      p: (val: "m_0", points-to: "m_0"),
      x: (val: "bot"),
    ),
    custom-nodes: (
      (name: "m_0", label: "m_0"),
      (name: "m_1", label: "m_1"),
      (name: "m_2", label: "m_2"),

      (name: "v_m_0", label: "1"),
      (name: "v_m_1", label: "2"),
      (name: "v_m_2", label: "3"),
    ),
    custom-edges: (
      (from: "m_0", to: "m_1", label: "+1"),
      (from: "m_1", to: "m_2", label: "+1"),

      (from: "m_0", to: "v_m_0", label: "*"),
      (from: "m_1", to: "v_m_1", label: "*"),
      (from: "m_2", to: "v_m_2", label: "*"),

      (from: "v_m_0", to: "m_0", label: "\&"),
      (from: "v_m_1", to: "m_1", label: "\&"),
      (from: "v_m_2", to: "m_2", label: "\&"),
    ),
  ),
))

#pagebreak()

// step 3

#program-trace((
  (
    code: "",
    vars: (
      q: (val: "m_0", points-to: "m_0"),
      p: (val: "m_0", points-to: "m_0"),
      x: (val: "a_p", points-to: "a_p"),
    ),
    custom-nodes: (
      (name: "m_0", label: "m_0"),
      (name: "m_1", label: "m_1"),
      (name: "m_2", label: "m_2"),

      (name: "v_m_0", label: "1"),
      (name: "v_m_1", label: "2"),
      (name: "v_m_2", label: "3"),
    ),
    custom-edges: (
      (from: "m_0", to: "m_1", label: "+1"),
      (from: "m_1", to: "m_2", label: "+1"),

      (from: "m_0", to: "v_m_0", label: "*"),
      (from: "m_1", to: "v_m_1", label: "*"),
      (from: "m_2", to: "v_m_2", label: "*"),

      (from: "v_m_0", to: "m_0", label: "\&"),
      (from: "v_m_1", to: "m_1", label: "\&"),
      (from: "v_m_2", to: "m_2", label: "\&"),
    ),
  ),
))

#pagebreak()

// step 4

#program-trace((
  (
    code: "",
    vars: (
      q: (val: "m_0", points-to: "m_0"),
      p: (val: "m_0", points-to: "m_0"),
      x: (val: "a_p", points-to: "a_p"),
    ),
    custom-nodes: (
      (name: "m_0", label: "m_0"),
      (name: "m_1", label: "m_1"),
      (name: "m_2", label: "m_2"),

      (name: "v_m_0", label: "2"),
      (name: "v_m_1", label: "2"),
      (name: "v_m_2", label: "3"),
    ),
    custom-edges: (
      (from: "m_0", to: "m_1", label: "+1"),
      (from: "m_1", to: "m_2", label: "+1"),

      (from: "m_0", to: "v_m_0", label: "*"),
      (from: "m_1", to: "v_m_1", label: "*"),
      (from: "m_2", to: "v_m_2", label: "*"),

      (from: "v_m_0", to: "m_0", label: "\&"),
      (from: "v_m_1", to: "m_1", label: "\&"),
      (from: "v_m_2", to: "m_2", label: "\&"),
    ),
  ),
))

