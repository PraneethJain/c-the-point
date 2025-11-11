#import "@preview/diagraph:0.3.6": *
#import "@preview/cetz:0.4.2"
#import "graph-fns.typ": mkgraph, program-trace

= C the Point: Making sense of pointers in C

== Background:  Why are C pointers hard to understand?

Many of us have struggled to understand pointers in C.  This can be
attributed to at least two different reasons.  First, the syntax of C,
specially when declaring pointers is awkward and unintuitive.  Second,
most of us lack a robust mental model of C's semantics that represents
our understanding of how C manipulates pointers.


== The unintuitive syntax of C

The first unintuitive thing in C, is that the type of a variable is
written _before_ the name of the variable.  So, C insists that we
write `int x` instead of the more intuitive `x int`.  It gets worse
when we have pointers.   So, `int *p` looks strange when compared to
`p *int`.  One way to think of the type declaration for `p` is to
consider navigating from `p` on a `*` and ending up at `int`.   This
idea of navigation is central to the model we present but C's syntax
doesn't quite align with this model of thinking. 

== Traditional Box and pointer models of C

Before we introduce the new model, let us consider one of the most
common mental models employed by students of C programming.   It is
called the _box and pointer_ model. 

In this model, boxes are memory locations and the boxes contain
values.  Unfortunately, the box and pointer diagram fails to capture
adequate information to yield an unambiguous answer.  Here's an
example, the C statement `int x = 5` is represented as the box diagram

#raw-render(```dot
digraph {
 x -> b
 x[shape=text,color=none]
 b[shape=text,label=5]
 }
```)

This states that the meaning of `x` is the box.  Notice that the box
itself is labeled `x`.  This results in conflating `x` with its
address, so, there is no way to denote `&x`, which is another value,
namely the address of `x`.

This
notation conflates the variable `x` with the box (or address) it
denotes because the addre Adding the statement `int *p = &x;` results
in the following diagram: Now, to find the value of `*p`, we follow
the pointer in the box labeled `p`.  This takes us to the box
containing 5.  The value of `*p` is therefore 5.  This looks fine
until we add



#raw-render(```dot
digraph {
// x -> b
// x[shape=text,color=none]
 b[shape=text,label=5]
 p -> c
 p[shape=text,color=none]
 c[shape=text,label="a_x"] 
 }
```, xlabels:("b":"x"))


Now, imagine we wish to derive the  value of `*p`, which is 5.  For
this, we would start from `p`, then go to the box it points to, pick
up the value in the box, namely $a_x$, and then go to $x$









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
