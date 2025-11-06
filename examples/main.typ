#import "@preview/diagraph:0.3.6": *

#let mkgraph(vars, custom-nodes: (), custom-edges: ()) = {
  let code = "digraph {\n  layout=neato\n  node[shape=circle, math=true]\n  edge[lmath=true, labeldistance=5.0]\n"
  
  for (name, info) in vars {
    let a = "a_" + name
    let v = "v_" + name
    code += name + " -> " + a + " [label=\"\\&\"];\n"
    code += a + " -> " + v + " [label=\"*\"];\n"
    code += name + " -> " + v + " [label=\"r\"];\n"
    code += v + "[label=\"" + str(info.val) + "\"]\n"
    
    code += a + "[style=filled, fillcolor=\"#56B4E9\"]\n"  // Light blue
    code += v + "[label=\"" + str(info.val) + "\", style=filled, fillcolor=\"#E69F00\"]\n"  // Orange
     

    if "points-to" in info {
      code += v + " -> " + info.points-to + "[style=\"dashed\"];\n"
    }
  }

  for node in custom-nodes {
    code += node.name + "[label=\"" + str(node.label) + "\"]\n"
  }
  
  for edge in custom-edges {
    let label-part = if "label" in edge { " [label=\"" + edge.label + "\"]" } else { "" }
    code += edge.from + " -> " + edge.to + label-part + ";\n"
  }
  
  code += "}"
  render(code)
}

#let program-trace(states) = {
  for (i, state) in states.enumerate() {
    mkgraph(state.vars, custom-nodes: state.at("custom-nodes", default: ()), custom-edges: state.at("custom-edges", default: ()))
    
    if i < states.len() - 1 {
      align(center)[
        #text(size: 1em)[#sym.arrow.b] 
        #states.at(i + 1).code
      ]
    }
  }
}

== Example 1

```c
int x = 10, y = 20;
int* p = &x;
int* q = &y;
*p = *q;
q = p;
*q = 50;
```

#program-trace((
  (
    code: "",
    vars: (
      x: (val: "bot"),
      y: (val: "bot"),
      p: (val: "bot"),
      q: (val: "bot"),
    )
  ),
  (
    code: "int x = 10, y = 20;",
    vars: (
      x: (val: "10"),
      y: (val: "20"),
      p: (val: "bot"),
      q: (val: "bot"),
    )
  ),
  (
    code: "int* p = &x;",
    vars: (
      x: (val: "10"),
      y: (val: "20"),
      p: (val: "a_x", points-to: "a_x"),
      q: (val: "bot"),
    )
  ),
  (
    code: "int* q = &y;",
    vars: (
      x: (val: 10),
      y: (val: 20),
      p: (val: "a_x", points-to: "a_x"),
      q: (val: "a_y", points-to: "a_y"),
    )
  ),
  (
    code: "*p = *q;",
    vars: (
      x: (val: 20),
      y: (val: 20),
      p: (val: "a_x", points-to: "a_x"),
      q: (val: "a_y", points-to: "a_y"),
    )
  ),
  (
    code: "q = p;",
    vars: (
      x: (val: 10),
      y: (val: 20),
      p: (val: "a_x", points-to: "a_x"),
      q: (val: "a_x", points-to: "a_x"),
    )
  ),
  (
    code: "*q = 50;",
    vars: (
      x: (val: 50),
      y: (val: 20),
      p: (val: "a_x", points-to: "a_x"),
      q: (val: "a_x", points-to: "a_x"),
    )
  ),
))

== Example 2

```c
int x = 5, y = 7;
int *p = &x;
*p = y;
```


#program-trace((
  (
    code: "",
    vars: (
      x: (val: "bot"),
      y: (val: "bot"),
      p: (val: "bot"),
    )
  ),
  (
    code: "int x = 5, y = 7;",
    vars: (
      x: (val: 5),
      y: (val: 7),
      p: (val: "bot"),
    )
  ),
  (
    code: "int *p = &x;",
    vars: (
      x: (val: 5),
      y: (val: 7),
      p: (val: "a_x", points-to: "a_x"),
    )
  ),
  (
    code: "*p = y;",
    vars: (
      x: (val: 7),
      y: (val: 7),
      p: (val: "a_x", points-to: "a_x"),
    )
  ),
))

== Example 3

```c
int p[] = {2, 4, 6, 8};
int *q = p;
int r = *(q + 2);
```

#program-trace((
  (
    code: "",
    vars: (
      p: (val: "bot"),
      q: (val: "bot"),
      r: (val: "bot"),
    )
  ),
  (
    code: "int p[] = {2, 4, 6, 8};",
    vars: (
      p: (val: "m_0", points-to: "m_0"),
      q: (val: "bot"),
      r: (val: "bot"),
    ),
    custom-nodes: (
      (name: "m_0", label: "m_0"),
      (name: "m_1", label: "m_1"),
      (name: "m_2", label: "m_2"),
      (name: "m_3", label: "m_3"),

      (name: "v_m_0", label: "2"),
      (name: "v_m_1", label: "4"),
      (name: "v_m_2", label: "6"),
      (name: "v_m_3", label: "8"),
    ),
    custom-edges: (
      (from: "m_0", to: "m_1", label: "+1"),
      (from: "m_1", to: "m_2", label: "+1"),
      (from: "m_2", to: "m_3", label: "+1"),

      (from: "m_0", to: "v_m_0", label: "*"),
      (from: "m_1", to: "v_m_1", label: "*"),
      (from: "m_2", to: "v_m_2", label: "*"),
      (from: "m_3", to: "v_m_3", label: "*"),
    ),
  ),
  (
    code: "int *q = p;",
    vars: (
      p: (val: "m_0", points-to: "m_0"),
      q: (val: "m_0", points-to: "m_0"),
      r: (val: "bot"),
    ),
    custom-nodes: (
      (name: "m_0", label: "m_0"),
      (name: "m_1", label: "m_1"),
      (name: "m_2", label: "m_2"),
      (name: "m_3", label: "m_3"),

      (name: "v_m_0", label: "2"),
      (name: "v_m_1", label: "4"),
      (name: "v_m_2", label: "6"),
      (name: "v_m_3", label: "8"),
    ),
    custom-edges: (
      (from: "m_0", to: "m_1", label: "+1"),
      (from: "m_1", to: "m_2", label: "+1"),
      (from: "m_2", to: "m_3", label: "+1"),

      (from: "m_0", to: "v_m_0", label: "*"),
      (from: "m_1", to: "v_m_1", label: "*"),
      (from: "m_2", to: "v_m_2", label: "*"),
      (from: "m_3", to: "v_m_3", label: "*"),
    ),
  ),
  (
    code: "int r = *(q + 2);",
    vars: (
      p: (val: "m_0", points-to: "m_0"),
      q: (val: "m_0", points-to: "m_0"),
      r: (val: 6),
    ),
    custom-nodes: (
      (name: "m_0", label: "m_0"),
      (name: "m_1", label: "m_1"),
      (name: "m_2", label: "m_2"),
      (name: "m_3", label: "m_3"),

      (name: "v_m_0", label: "2"),
      (name: "v_m_1", label: "4"),
      (name: "v_m_2", label: "6"),
      (name: "v_m_3", label: "8"),
    ),
    custom-edges: (
      (from: "m_0", to: "m_1", label: "+1"),
      (from: "m_1", to: "m_2", label: "+1"),
      (from: "m_2", to: "m_3", label: "+1"),

      (from: "m_0", to: "v_m_0", label: "*"),
      (from: "m_1", to: "v_m_1", label: "*"),
      (from: "m_2", to: "v_m_2", label: "*"),
      (from: "m_3", to: "v_m_3", label: "*"),
    ),
  ),
))


== Example 4

```c
int s = 3;
int *t = &s;
int **p = &t;
int *q = *p;
*q = 10;
```

#program-trace((
  (
    code: "",
    vars: (
      s: (val: "bot"),
      t: (val: "bot"),
      p: (val: "bot"),
      q: (val: "bot"),
    )
  ),
  (
    code: "int s = 3;",
    vars: (
      s: (val: "3"),
      t: (val: "bot"),
      p: (val: "bot"),
      q: (val: "bot"),
    )
  ),
  (
    code: "int *t = &s;",
    vars: (
      s: (val: "3"),
      t: (val: "a_s", points-to: "a_s"),
      p: (val: "bot"),
      q: (val: "bot"),
    )
  ),
  (
    code: "int **p = &t;",
    vars: (
      s: (val: "3"),
      t: (val: "a_s", points-to: "a_s"),
      p: (val: "a_t", points-to: "a_t"),
      q: (val: "bot"),
    )
  ),
  (
    code: "int *q = *p;",
    vars: (
      s: (val: "3"),
      t: (val: "a_s", points-to: "a_s"),
      p: (val: "a_t", points-to: "a_t"),
      q: (val: "a_s", points-to: "a_s"),
    )
  ),
  (
    code: "*q = 10;",
    vars: (
      s: (val: "10"),
      t: (val: "a_s", points-to: "a_s"),
      p: (val: "a_t", points-to: "a_t"),
      q: (val: "a_s", points-to: "a_s"),
    )
  ),
))

== Example 5

```c
int q[] = {1, 2, 3, 4, 5};
int *p = q;
*(p + 2) = *(p + 4);
```


#program-trace((
  (
    code: "",
    vars: (
      p: (val: "bot"),
      q: (val: "bot"),
    )
  ),
  (
    code: "int q[] = {1, 2, 3, 4, 5};",
    vars: (
      p: (val: "bot"),
      q: (val: "m_0", points-to: "m_0"),
    ),
    custom-nodes: (
      (name: "m_0", label: "m_0"),
      (name: "m_1", label: "m_1"),
      (name: "m_2", label: "m_2"),
      (name: "m_3", label: "m_3"),
      (name: "m_4", label: "m_4"),

      (name: "v_m_0", label: "1"),
      (name: "v_m_1", label: "2"),
      (name: "v_m_2", label: "3"),
      (name: "v_m_3", label: "4"),
      (name: "v_m_4", label: "5"),
    ),
    custom-edges: (
      (from: "m_0", to: "m_1", label: "+1"),
      (from: "m_1", to: "m_2", label: "+1"),
      (from: "m_2", to: "m_3", label: "+1"),
      (from: "m_3", to: "m_4", label: "+1"),

      (from: "m_0", to: "v_m_0", label: "*"),
      (from: "m_1", to: "v_m_1", label: "*"),
      (from: "m_2", to: "v_m_2", label: "*"),
      (from: "m_3", to: "v_m_3", label: "*"),
      (from: "m_4", to: "v_m_4", label: "*"),
    ),
  ),
  (
    code: "int *p = q;",
    vars: (
      p: (val: "m_0", points-to: "m_0"),
      q: (val: "m_0", points-to: "m_0"),
    ),
    custom-nodes: (
      (name: "m_0", label: "m_0"),
      (name: "m_1", label: "m_1"),
      (name: "m_2", label: "m_2"),
      (name: "m_3", label: "m_3"),
      (name: "m_4", label: "m_4"),

      (name: "v_m_0", label: "1"),
      (name: "v_m_1", label: "2"),
      (name: "v_m_2", label: "3"),
      (name: "v_m_3", label: "4"),
      (name: "v_m_4", label: "5"),
    ),
    custom-edges: (
      (from: "m_0", to: "m_1", label: "+1"),
      (from: "m_1", to: "m_2", label: "+1"),
      (from: "m_2", to: "m_3", label: "+1"),
      (from: "m_3", to: "m_4", label: "+1"),

      (from: "m_0", to: "v_m_0", label: "*"),
      (from: "m_1", to: "v_m_1", label: "*"),
      (from: "m_2", to: "v_m_2", label: "*"),
      (from: "m_3", to: "v_m_3", label: "*"),
      (from: "m_4", to: "v_m_4", label: "*"),
    ),
  ),
  (
    code: "*(p + 2) = *(p + 4);",
    vars: (
      p: (val: "m_0", points-to: "m_0"),
      q: (val: "m_0", points-to: "m_0"),
    ),
    custom-nodes: (
      (name: "m_0", label: "m_0"),
      (name: "m_1", label: "m_1"),
      (name: "m_2", label: "m_2"),
      (name: "m_3", label: "m_3"),
      (name: "m_4", label: "m_4"),

      (name: "v_m_0", label: "1"),
      (name: "v_m_1", label: "2"),
      (name: "v_m_2", label: "5"),
      (name: "v_m_3", label: "4"),
      (name: "v_m_4", label: "5"),
    ),
    custom-edges: (
      (from: "m_0", to: "m_1", label: "+1"),
      (from: "m_1", to: "m_2", label: "+1"),
      (from: "m_2", to: "m_3", label: "+1"),
      (from: "m_3", to: "m_4", label: "+1"),

      (from: "m_0", to: "v_m_0", label: "*"),
      (from: "m_1", to: "v_m_1", label: "*"),
      (from: "m_2", to: "v_m_2", label: "*"),
      (from: "m_3", to: "v_m_3", label: "*"),
      (from: "m_4", to: "v_m_4", label: "*"),
    ),
  ),
))
