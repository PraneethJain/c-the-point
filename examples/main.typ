#import "@preview/diagraph:0.3.6": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import "graph-fns.typ": mkgraph, program-trace

#let eqmod(x) = $attach(=, b: #x)$
#let neqmod(x) = $attach(!=, b: #x)$

= Now you C the point!: Making sense of pointers in C

== Background:  Why are C pointers hard to understand?

Many of us have struggled to understand pointers in C.  This can be
attributed to at least two different reasons.  First, the syntax of C,
specially when declaring pointers is awkward and unintuitive.  Second,
most of us lack a robust mental model of C's semantics that represents
our understanding of how C manipulates pointers.


== The unintuitive syntax of C

C insists that we write `int x` instead of the more intuitive `x int`.
It gets worse when we have pointers.  So, `int *p` looks strange when
compared to `p *int`.  One way to think of the type declaration for
`p` is to consider navigating from `p` on a `*` and end up at `int`.
This idea of navigation is central to the model we present but C's
syntax doesn't quite align with this model of thinking if we are used
to reading things from left to right (which is the case with many
Indo-European languages, but not scripts for Arabic, Persian, Urdu and
Hebrew).

== Traditional Box and pointer models of C

Before we introduce the new model, let us consider one of the most
common mental models employed by students of C programming.  It is
called the _box and pointer_ model.  In this model, boxes are memory
locations and the boxes contain values.

=== Example 1: Conflating a variable with its address
Consider the the C statement `int x = 5` is represented as the box
diagram

#diagram(
  spacing: 5em,
  node-stroke: 1pt,
  node-fill: none,

  node((0,0), [5], name: <A>, width: 4em, height: 2em),
  node((rel: (0, -0.3), to: <A>), [x], stroke: none, fill: none),
)

Notice that the box (an address) is itself labeled `x`.  This results
in conflating `x` with its address, so, there is no way to distinguish
`x` from `&x`, namely the address of `x`.  So, `printf("%p", &x);`
will print a value that is neither `x` nor `5`.

=== Example 2: Reasoning with equality violated

Here is another example: Now consider the C fragment ```c int x = 5;
int y = 5;```.  Clearly, `x` and `y` both now denote the value 5.
We write this as $x eqmod(c) y$.  Now think of `&` as an operator,
that takes a value and returns its address.  So `&x` returns the
address of `x`.  So we have $x eqmod(c) y$ but $\&x neqmod(c) \&y$.
This is counter-intuitive to logical reasoning because it violates the
priniciple of substitution: when $e_1=e_2$, then if we any expression
containing $e_1$, replacing $e_1$ with $e_2$ should make no
difference.

== Path Model

The alternative mental model we propose is motivated by the need to be
able to do simple mathematical reasoning involving function
application and mathematical equality.  Our mental models are now
represented as labelled directed graphs.  A graph is simply a
collection of vertices and an edge relation between vertices.  In
addition, each edge is labelled.  Reasoning corresponds to traversing
paths in the graph.

For the sake of simplicity, let us assume we only have `int` the
primitive type.  

 1. There are three kinds of vertices: variable vertices, addresses
 vertices and value vertices.
 
 2. Values vertices are integer value vertices or addresses value
 vertices.  There could be multiple vertices with the same value.

 3. Uninitialized values are denoted by $bot$.

 4. There is an arrow labelled `&` between a variable node and its
 address.

 5. There is an arrow labelled `*` between the address and its value.
 The `*`-labelled arrow captures the relation that an address _stores_
 a value.

 6. There is a back arrow labelled `&` between the value and
 its address.  A `&`-labelled  arrow captures the relation that a
 value is stored in an address.  

 7. A value may occur multiple times stored at different addresses.

 8. There is a derived edge labelled `r` which is the composition of
 the `&` and the `*` edges.

 9. The labels on arrows may be thought of as maps that take the
 (tail) of the arrow to its head.  


The memory graph evolves as the C program statements execute.

The best way to understand the path model is through
examples

// Coming to pointers, adding the statement `int *p = &x;` results in the
// following diagram:

// #diagram(
//   spacing: 5em,
//   node-stroke: 1pt,
//   node-fill: none,

//   node((0,0), [5], name: <A>, width: 4em, height: 2em),
//   node((rel: (0, -0.3), to: <A>), [x], stroke: none, fill: none),

//   node((1,0), [], name: <B>, width: 4em, height: 2em, layer: -1),
//   node((rel: (0, -0.3), to: <B>), [p], stroke: none, fill: none),


//   edge(<B>, <A>, "-|>", layer: 1, snap-to: (none, auto))
// )

// Now, imagine we wish to derive the  value of `*p`, which is 5.  For
// this, we would start from `p`, then go to the box it refers to and
// follow the pointer in the box, then go to content of the box.   Now
// consider the C expression `&*p`, which is equal to `&x`.  


== Example 3: Executing a simple fragment of code

Consider the program fragment.

```c int x; x=5 ```

The initial graph has three nodes: the variable x, its address $a_x$
and the (initial) value bottom.

#mkgraph((x: (val: "bot")))




== Example 4

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

== Example 5

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


== Example 6

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


== Example 7

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

== Example 8

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

== Example 9

```c
int p[] = {1, 2, 3};
int x = *(p + 2);
```


#program-trace((
  (
    code: "",
    vars: (
      p: (val: "bot"),
      x: (val: "bot"),
    )
  ),
  (
    code: "int p[] = {1, 2, 3};",
    vars: (
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
    ),
  ),
  (
    code: "int x = *(p + 2);",
    vars: (
      p: (val: "m_0", points-to: "m_0"),
      x: (val: "3"),
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
    ),
  ),
))

