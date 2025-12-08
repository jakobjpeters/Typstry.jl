# Terminal Images

Some terminals implement protocols that enable direct image rendering. If the current terminal
supports a given protocol, simply load the corresponding package in the REPL to automatically render
values of type [`AbstractTypst`](@ref) and [`TypstString`](@ref).

## [ITerm2Images.jl](https://github.com/eschnett/ITerm2Images.jl)

- [✓] [wezterm](https://github.com/wezterm/wezterm)
- [?] [iTerm2](https://iterm2.com/index.html)
    - Very likely to work, but not yet confirmed.
- [❌] [rio](https://github.com/raphamorim/rio)
    - Rio claims to support the iTerm2 image protocol, but fails to render anything.
- others?

## [KittyTerminalImages.jl](https://github.com/simonschoelly/KittyTerminalImages.jl)

- [✓] [wezterm](https://github.com/wezterm/wezterm)
- [?] [ghostty](https://ghostty.org/)
- [?] [kitty](https://github.com/kovidgoyal/kitty)
    - Very likely to work, but not yet confirmed.
- [?] [konsole](https://apps.kde.org/konsole/)
- [?] [st](https://st.suckless.org/patches/kitty-graphics-protocol/)
- [?] [Warp](https://docs.warp.dev/)
- [?] [wayst](https://github.com/91861/wayst)
- others?

## [SixelTerm.jl](https://github.com/eschnett/SixelTerm.jl)

- [✓] [wezterm](https://github.com/wezterm/wezterm)
- [?] [contour](https://github.com/contour-terminal/contour)
- [?] [iTerm2](https://iterm2.com/index.html)
- [?] [konsole](https://apps.kde.org/konsole/)
- [?] [mintty](https://github.com/mintty/mintty)
- [?] [mlterm](https://sourceforge.net/projects/mlterm/)
- [?] [msys2](https://www.msys2.org/)
- [?] [Windows Terminal](https://github.com/microsoft/terminal)
- [?] [wsltty](https://github.com/mintty/wsltty)
- [?] [xterm](https://invisible-island.net/xterm/)
- others?
