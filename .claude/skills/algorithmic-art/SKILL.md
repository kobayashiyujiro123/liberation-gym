---
name: algorithmic-art
description: Creating algorithmic art using p5.js with seeded randomness and interactive parameter exploration. Use this when users request creating art using code, generative art, algorithmic art, flow fields, or particle systems. Create original algorithmic art rather than copying existing artists' work.
tools: Read, Write, Bash
---

# Algorithmic Art

Algorithmic philosophies are computational aesthetic movements expressed through code. Output .md files (philosophy), .html files (interactive viewer), and .js files (generative algorithms).

Two-step process:
1. Algorithmic Philosophy Creation (.md file)
2. Express by creating p5.js generative art (.html + .js files)

## ALGORITHMIC PHILOSOPHY CREATION

Create an ALGORITHMIC PHILOSOPHY (not static images or templates) interpreted through:
- Computational processes, emergent behavior, mathematical beauty
- Seeded randomness, noise fields, organic systems
- Particles, flows, fields, forces
- Parametric variation and controlled chaos

### HOW TO GENERATE AN ALGORITHMIC PHILOSOPHY

**Name the movement** (1-2 words): "Organic Turbulence" / "Quantum Harmonics" / "Emergent Stillness"

**Articulate the philosophy** (4-6 paragraphs):
- Computational processes and mathematical relationships
- Noise functions and randomness patterns
- Particle behaviors and field dynamics
- Temporal evolution and system states
- Parametric variation and emergent complexity

**Guidelines:**
- Avoid redundancy - each algorithmic aspect mentioned once
- Emphasize craftsmanship - the algorithm should appear meticulously crafted
- Leave creative space for interpretive implementation choices

### PHILOSOPHY EXAMPLES

**"Organic Turbulence"** - Flow fields driven by layered Perlin noise. Thousands of particles following vector forces, trails accumulating into organic density maps.

**"Quantum Harmonics"** - Particles on a grid with phase values evolving through sine waves. Phase interference creates bright nodes and voids.

**"Recursive Whispers"** - Branching structures that subdivide recursively. L-systems with golden ratios and subtle noise perturbations.

**"Field Dynamics"** - Vector fields from mathematical functions. Particles flowing along field lines, showing ghost-like evidence of invisible forces.

**"Stochastic Crystallization"** - Randomized circle packing or Voronoi tessellation. Random points evolving through relaxation algorithms.

## P5.JS IMPLEMENTATION

### TECHNICAL REQUIREMENTS

**Seeded Randomness (Art Blocks Pattern)**:
```javascript
let seed = 12345;
randomSeed(seed);
noiseSeed(seed);
```

**Parameter Structure**:
```javascript
let params = {
  seed: 12345,
  // Add parameters that control YOUR algorithm:
  // Quantities, Scales, Probabilities, Ratios, Angles, Thresholds
};
```

**Canvas Setup**:
```javascript
function setup() {
  createCanvas(1200, 1200);
}

function draw() {
  // Your generative algorithm
}
```

### CRAFTSMANSHIP REQUIREMENTS

- **Balance**: Complexity without visual noise
- **Color Harmony**: Thoughtful palettes, not random RGB
- **Composition**: Visual hierarchy and flow even in randomness
- **Performance**: Smooth execution, optimized for real-time
- **Reproducibility**: Same seed ALWAYS produces identical output

### OUTPUT FORMAT

1. **Algorithmic Philosophy** - Markdown explaining the generative aesthetic
2. **Single HTML Artifact** - Self-contained interactive generative art

### INTERACTIVE ARTIFACT FEATURES

**1. Parameter Controls**
- Sliders for numeric parameters
- Color pickers for palette colors
- Real-time updates when parameters change
- Reset button to restore defaults

**2. Seed Navigation**
- Display current seed number
- Previous/Next buttons to cycle through seeds
- Random button for random seed
- Input field to jump to specific seed

**3. Single Artifact Structure**
```html
<!DOCTYPE html>
<html>
<head>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/p5.js/1.7.0/p5.min.js"></script>
  <style>/* All styling inline */</style>
</head>
<body>
  <div id="canvas-container"></div>
  <div id="controls"><!-- All parameter controls --></div>
  <script>
    // ALL p5.js code inline
    // Parameter objects, classes, functions
    // setup() and draw()
    // UI handlers
  </script>
</body>
</html>
```

## ESSENTIAL PRINCIPLES

- **ALGORITHMIC PHILOSOPHY**: Creating a computational worldview expressed through code
- **PROCESS OVER PRODUCT**: Beauty emerges from the algorithm's execution
- **PARAMETRIC EXPRESSION**: Ideas communicate through mathematical relationships
- **ARTISTIC FREEDOM**: Provide creative implementation room
- **PURE GENERATIVE ART**: LIVING ALGORITHMS, not static images
- **EXPERT CRAFTSMANSHIP**: Meticulously crafted, refined through deep expertise
