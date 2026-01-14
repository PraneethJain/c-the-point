#import "@preview/diagraph:0.3.6": *

#let mkgraph(vars, custom-nodes: (), custom-edges: ()) = {
  let code = "digraph {\n  layout=neato\n node[fontsize=18, shape=circle,math=true,fixedsize=true, width=0.55, height=0.55]\n  edge[lmath=true]\n"
  
  for (name, info) in vars {
    let a = "a_" + name
    let v = "v_" + name
    code += name + " -> " + a + " [headlabel=\"\\&\", labeldistance = 2.0];\n"
    code += a + " -> " + v + " [headlabel=\"*\", labeldistance = 2.3];\n"
    code += v + " -> " + a + " [headlabel=\"\&\", labeldistance = 2.3];\n"
    code += v + "[label=\"" + str(info.val) + "\"]\n"
    
    code += a + "[fontcolor=\"#56B4E9\"]\n"  // Light blue
    code += v + "[label=\"" + str(info.val) + "\",  fontcolor=\"#A65F00\"]\n"  // Orange

    if "points-to" in info {
      code += v + " -> " + info.points-to + "[style=\"dashed\", headlabel=\"=>\", labeldistance = 2.4];\n"
    }
  }

  for node in custom-nodes {
    code += node.name + "[label=\"" + str(node.label) + "\"]\n"
  }
  
  for edge in custom-edges {
    let label-part = if "label" in edge { " [headlabel=\"" + edge.label + "\", labeldistance = 2.0]" } else { "" }
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
        #text(size: 3em)[#sym.arrow.b] 
        #box(stroke: black, inset: 10pt)[#states.at(i + 1).code]
      ]
    }
  }
}

