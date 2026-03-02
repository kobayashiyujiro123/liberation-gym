---
name: slack-gif-creator
description: Knowledge and utilities for creating animated GIFs optimized for Slack. Provides constraints, validation, and animation concepts. Use when users request animated GIFs for Slack like "make me a GIF of X doing Y for Slack."
tools: Read, Write, Bash
---

# Slack GIF Creator

A toolkit providing utilities and knowledge for creating animated GIFs optimized for Slack.

## Slack Requirements

**Dimensions:**
- Emoji GIFs: 128x128 (recommended)
- Message GIFs: 480x480

**Parameters:**
- FPS: 10-30 (lower is smaller file size)
- Colors: 48-128 (fewer = smaller file size)
- Duration: Keep under 3 seconds for emoji GIFs

## Core Workflow

```python
from PIL import Image, ImageDraw
import imageio

# 1. Generate frames
frames = []
for i in range(12):
    frame = Image.new('RGB', (128, 128), (240, 248, 255))
    draw = ImageDraw.Draw(frame)
    # Draw your animation using PIL primitives
    frames.append(frame)

# 2. Save as GIF
imageio.mimsave('output.gif', [f for f in frames], fps=10, loop=0)
```

## Drawing Graphics

### Working with User-Uploaded Images
```python
from PIL import Image
uploaded = Image.open('file.png')
```

### Drawing from Scratch
```python
from PIL import ImageDraw
draw = ImageDraw.Draw(frame)

# Circles/ovals
draw.ellipse([x1, y1, x2, y2], fill=(r, g, b), outline=(r, g, b), width=3)

# Polygons (stars, triangles)
draw.polygon(points, fill=(r, g, b), outline=(r, g, b), width=3)

# Lines
draw.line([(x1, y1), (x2, y2)], fill=(r, g, b), width=5)

# Rectangles
draw.rectangle([x1, y1, x2, y2], fill=(r, g, b), outline=(r, g, b), width=3)
```

### Making Graphics Look Good
- **Use thicker lines** - Always `width=2` or higher
- **Add visual depth** - Gradients, layered shapes
- **Make shapes interesting** - Highlights, rings, patterns
- **Pay attention to colors** - Vibrant, complementary
- **Be creative** - Polished, not placeholder graphics

## Animation Concepts

### Shake/Vibrate
Offset position with `math.sin()` or `math.cos()`. Add small random variations.

### Pulse/Heartbeat
Scale size with `math.sin(t * frequency * 2 * math.pi)`. Scale between 0.8-1.2.

### Bounce
Use easing functions. `ease_in` for falling, `bounce_out` for landing.

### Spin/Rotate
`image.rotate(angle, resample=Image.BICUBIC)`. Sine wave for wobble.

### Fade In/Out
Adjust alpha channel or use `Image.blend()`.

### Slide
Move from off-screen to position with `ease_out` for smooth stop.

### Zoom
Scale and crop. Can add motion blur.

### Explode/Particle Burst
Particles with random angles and velocities. Add gravity (`vy += constant`). Fade over time.

## Easing Functions

```python
import math

def ease_out(t):
    return 1 - (1 - t) ** 3

def ease_in(t):
    return t ** 3

def ease_in_out(t):
    return 3 * t**2 - 2 * t**3 if t < 0.5 else 1 - (-2*t + 2)**3 / 2

def bounce_out(t):
    if t < 1/2.75:
        return 7.5625 * t * t
    elif t < 2/2.75:
        t -= 1.5/2.75
        return 7.5625 * t * t + 0.75
    elif t < 2.5/2.75:
        t -= 2.25/2.75
        return 7.5625 * t * t + 0.9375
    else:
        t -= 2.625/2.75
        return 7.5625 * t * t + 0.984375

def interpolate(start, end, t, easing='linear'):
    easings = {'linear': lambda t: t, 'ease_in': ease_in,
               'ease_out': ease_out, 'ease_in_out': ease_in_out,
               'bounce_out': bounce_out}
    return start + (end - start) * easings[easing](t)
```

## Optimization Strategies

1. **Fewer frames** - Lower FPS or shorter duration
2. **Fewer colors** - 48 instead of 128
3. **Smaller dimensions** - 128x128 instead of 480x480
4. **Remove duplicates** - Skip identical frames
5. **Emoji mode** - Auto-optimize for 128x128

## Dependencies

```bash
pip install pillow imageio numpy
```
