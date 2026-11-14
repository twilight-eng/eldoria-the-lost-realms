# ELDORIA: THE LOST REALMS

A fresh, browser-playable third-person fantasy RPG prototype. Serve this directory over HTTP (for example, `python3 -m http.server 8000`) and open `http://localhost:8000`. The game loads Three.js from jsDelivr, so an internet connection is required.

## Controls

- **PC:** WASD/arrows move; drag the mouse to orbit; left click attacks; right mouse button or Q guards; Space jumps; Shift dodges; E interacts; Esc opens the journal.
- **Touch:** fixed left-side joystick moves; drag the right side to look; on-screen buttons jump, strike, guard, dodge and interact. Portrait and landscape layouts are supported.

Explore the vale, activate the glowing waystone, fight roaming sentinels, gather drops and save/load progress from the journal.

## Scope and limitations

This is a playable prototype built from procedural Three.js geometry and locally implemented gameplay. The character uses a custom articulated mesh with procedural movement poses, not motion-captured animation. Terrain collisions, gravity, jumping, enemy pursuit/knockback and movement are implemented in game logic; there is no general rigid-body physics engine, physical mass/friction simulation, or water-body interaction. Water is a translucent animated-looking surface with ripples, not a reflection-rendered fluid simulation. Lighting, fog, wind-swaying vegetation and a simple daylight shift are present; there are no detailed imported PBR texture assets, dynamic clouds, rain system, full quest/dialogue framework, or native Android package. Mobile play is through the responsive browser interface.
