#import "@preview/diagraph:0.3.6": *

#let mkgraph(vars, custom-nodes: (), custom-edges: ()) = {
  let code = "digraph {\n  layout=neato\n node[fontsize=18, shape=circle,math=true,fixedsize=true, width=0.55, height=0.55]\n  edge[lmath=true, fontsize=15]\n"
  
  // Store length to calculate offset for custom nodes
  let vars-len = vars.len()

  // Use enumerate to get an index 'i' for calculation
  for (i, (name, info)) in vars.pairs().enumerate() {
    let a = "a_" + name
    let v = "v_" + name
    
    // Calculate unique IDs for the 3 nodes generated per variable
    let id-name = i * 3
    let id-a = i * 3 + 1
    let id-v = i * 3 + 2

    code += name + " -> " + a + " [headlabel=\"\\&\", labeldistance = 2.0];\n"
    code += a + " -> " + v + " [headlabel=\"*\", labeldistance = 2.3];\n"
    code += v + " -> " + a + " [headlabel=\"\&\", labeldistance = 2.3];\n"
    
    // Add xlabel to all three nodes
    code += name + "[xlabel=\"" + str(id-name) + "\"]\n"
    code += a + "[xlabel=\"" + str(id-a) + "\"]\n"
    code += v + "[label=\"" + str(info.val) + "\", xlabel=\"" + str(id-v) + "\"]\n"

    if "points-to" in info {
      code += v + " -> " + info.points-to + "[headlabel=\"=>\", labeldistance = 2.4];\n"
    }
  }

  // Continue numbering for custom nodes
  for (j, node) in custom-nodes.enumerate() {
    let id = vars-len * 3 + j
    code += node.name + "[label=\"" + str(node.label) + "\", xlabel=\"" + str(id) + "\"]\n"
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

