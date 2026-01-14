#import "@preview/diagraph:0.3.6": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import "graph-fns.typ": mkgraph, program-trace

#let eqmod(x) = $attach(=, b: #x)$
#let neqmod(x) = $attach(!=, b: #x)$

= Now you C the point!:    Making sense of pointers in C

== Background:  Why are C pointers hard to understand?

To understand a C program, one needs to be equipped with a
clear mental model of how memory is represented and
manipulated by the program.  The model need not be exactly
how memory is represented in hardware.  Instead, it suffices
to build a symbolic or visual, but robust model of memory.


Without a clear mental model, understanding pointers can be
tricky.  The beginning student of C is also burdened with at
least least two other hurdles: C's awkward syntax and its
confusing semantics.  The field of semantics is concerned
with building _mental models_ of how a program runs, and, in
the case of C, how it represents and manipulates memory.  So
far, it has been considered hard to build and visualise
clear mental models of C programs and there is no standard
way of doing so.  This is particularly acutely felt when
declaring and using pointers.


== The unintuitive syntax of C

Consider the declaration `int x`.  We would like to think of `int` as
the set of all integers and `x` as a variable denoting a member of
that set, in which case `x int` would make more sense.  It gets worse
when we have pointers.  How do we interpret `int *p`?  One way is to
consider navigating (again, right to left!) this declaration by
starting from `p`, traversing the `*` and ending up at `int`.  This
idea of navigation is central to the model we present, but unless
carefully defined, it doesn't always work!


== C violates basic reasoning with equality

Here is an example that shows how simple equational reasoning fails
in C.  Consider the C fragment

```c int x = 5;
int y = 5;```

Clearly, `x` and `y` both now denote the value 5 according
to the semantics of C.  We write this as $x eqmod(C) y$.
Now think of `&` as an operator, that takes a variable and
returns its address.  So `&x` returns the address of `x`.
So we have $x eqmod(C) y$ but $\&x neqmod(C) \&y$.  This is
counter-intuitive because it violates a fundamental
principle of mathematical reasoning:

*Principle of Substitution*: If $e_1=e_2$, then, in any expression $e$
containing $e_1$, replacing $e_1$ with $e_2$ in $e$ should make no
difference.



== Traditional Box and pointer models of C

The traditional mental model for C is called the _box and
pointer_ model.  In this model, boxes are memory locations
and the boxes contain values.  However, this model has its
own problems, as illustrated by the following example.  The
C statement `int x = 5;` is represented as the box diagram

#diagram(
  spacing: 5em,
  node-stroke: 1pt,
  node-fill: none,

  node((0,0), [5], name: <A>, width: 4em, height: 2em),
  node((rel: (0, -0.3), to: <A>), [x], stroke: none, fill: none),
)

Notice that the box (an address) is itself labeled `x`.  This results
in conflating `x` with its address.  There is no way to distinguish
`x` from `&x`, namely the address of `x`.  So, `printf("%p", &x);`
will print a value that is neither `x` nor `5`.   

== Graph Model

We propose a new mental model for understanding pointers in
C.  This model is motivated by the need to be able to do
simple mathematical reasoning involving function application
and mathematical equality.  Our mental models are now
represented as _graphs_.

=== Graphs and Functions

A graph is simply a collection of vertices and arrows between the
vertices.  In addition, each vertex and arrow is labelled.  Graphs are
used to represent a variety of things in computer science.  We use a
graph to represent function application.  So, if $f(x) = y$, then this
is represented as an arrow from $x$ to $y$ labelled $f$.

A path corresponds to a composition of function applications.


The state of the memory is modelled as a graph.  This graph
evolves as each statement is executed.  The model may be
described by the following set of rules (To keep our model
simple, let us assume we only have `int` as the primitive
type)

 1. *Vertices:* Vertices have labels.  There could be multiple vertices
    with the same label.

 2. *Vertex labels:* A vertex label is one of the following:
      - _Variable_:  $x,y, z, p$, etc.
	  - _Value_: one of 
	  - _Variable address_:   $a_x$, $a_y$, etc.
	  - _Memory address_:  $m_0, m_1$, etc.
	  - _Integer_:  $0, 1, -1$, etc.
	  - _Undefined_: $bot$ (also called `bottom`)

 3. *Vertex classification:* Vertices are classified into
 
     - *Variable vertex:* a vertex whose label is a variable.
	 
	 - *Address vertex:* a vertex which is the source of a `*` arrow.  It
       is labelled either by a variable or a memory address.
	   
	 - *Value vertex:* a vertex which is the destination of a `*` arrow.
       It is by a value label (See 6.)

 3. *Variable vertices represent program variables*: For every program
    variable $x$, there is a unique variable vertex, whose label is $x$.

 5. *& Forward Arrow and Variable Address vertices:* For every variable
    vertex labelled $x$, there is an edge labelled `&` emanating from
    that vertex to a unique address vertex labelled with the address
    $a_x$.  Such a vertex, which is the destination of a `&` forward
    arrow is called a _variable address vertex_.  

 6. *Value label:* A value label is either an integer, a variable
     address, a memory address, or undefined ($bot$).

 7. * `*` Arrow and Address Vertices:* There is an arrow labelled `*`
     from every address vertex to a value vertex.  This models the
     intuition that the address _stores_ a value.

 8. * `&` Back Arrow:* for every arrow labelled `*` there is a _back_
    arrow labelled `&` from the value vertex to the corresponding
    address vertex.  This captures the notion that the value is
    contained or pointed to by the address.  *To reduce clutter, this
    arrow is not displayed.*

 9. * => Arrow:* For each value vertex labelled with an address, there
    is an edge labelled `=>` to an address vertex with the same label.

 10. * `r` Arrow:* For every variable there is an arrow from the variable
    labelled `r` to a value vertex, obtained as the composition of the
    arrows `&` and `*`.  This denotes the notion that a variable has a
    value.

The memory graph evolves as the C program statements
execute.  The best way to understand the path model is through examples.

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


== Example 1: A simple declaration

Consider the program fragment

```c int x; ```

The initial graph has three nodes: the variable x, its address $a_x$
and the (initial) value `undefined`.   

#mkgraph((x: (val: "bot")))

Note the single variable address vertex is denoted in blue.


#pagebreak()
== Example 2: Pointer declaration, address-of and  assignment

```c
int x = 5, y = 7;
int *p = &x;
*p = y;
```

As the initial step, small triangular graphs created for the
declarations of each program variable: `x`, `y` and `p`.

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
#pagebreak()

== Example 3

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

#pagebreak()

== Example 4

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


#pagebreak()
== Example 5

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

#pagebreak()
== Example 6

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

#pagebreak()

== Example 7

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

