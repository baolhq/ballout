# Ballout

Yet another Breakout clone with Love2D while I'm learning the framework. Featuring collision detection, input text field, 2D physics, font caching.

## Player Manual

1. Move your paddle with `Arrow keys` or `A` and `D`
2. Go back or exit with <code>Esc</code>
3. Pause and resume with <code>Space</code>
4. Restart the game with <code>Enter</code>

## Building

### Dependencies

Before you begin, make sure you have the following installed:

- Lua 5.1 or higher
- Love2D
- Python 3

After you have Python installed on your system, add these following packages for building cross-platforms:

```sh
pip3 install setuptools
pip3 install makelove
```

Then run this command to build

```sh
makelove --config build_config.toml
```

### Installation

Clone the repository:

```sh
git clone https://github.com/baolhq/ballout.git
cd ballout && code .
```

## Executing

To build and run the project:

- Press `Ctrl+Shift+B` to build using the provided `build_config.toml`, this will generate executables at `/bin` directory
- Or skip to run the project simply with `F5`

## Project Structure

```sh
/ballout
├── main.lua                # Entry point
├── conf.lua                # Startup configurations
├── build_config.toml       # Setup for cross-platforms building
├── /lib                    # Third-party libraries
├── /src                    # Game source code
│   ├── entities/           # Game entities
│   ├── global/             # Global variables
│   ├── managers/           # Manage screens, inputs, game states etc..
│   ├── screens/            # Game screens
│   └── util/               # Helper functions
├── /res                    # Static resources
│   ├── img/                # Sprites, textures etc..
│   ├── audio/              # Sound effects
│   └── font/               # Recommended fonts
├── /.vscode                # VSCode launch, debug and build setup
└── /bin                    # Build output
```

## License

This project is licensed under the [MIT License](LICENSE.md). Feel free to customize it whatever you want.
