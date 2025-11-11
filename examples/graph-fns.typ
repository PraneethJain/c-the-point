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

