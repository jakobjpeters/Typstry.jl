
# Updating Typst_jll.jl and Typstry.jl

This tutorial demonstrates how to update the Typst_jll.jl used by Typstry.jl.

## Yggrasil

This repository hosts the BinaryBuilder.jl recipes used to generate jll packages.
Upon merging changes to a recipe, the corresponding jll package is updated automatically.

1. Obtain the version number and commit hash of a [Typst release](https://github.com/typst/typst/releases)
1. Fork [Yggrasil](https://github.com/JuliaPackaging/Yggdrasil)
2. Update the version number and commit hash in `Yggdrasil/T/Typst/build_tarballs.jl`

```julia
version = v"0.13.1"
sources = [GitSource(
    "https://github.com/typst/typst.git",
    "8dce676dcd691f75696719e0480cd619829846a9"
)]
```

3. Submit a pull request with these changes, titled `[Typst] Update version to $version`
4. Fix any build issues
5. Wait until the pull request is merged

## Typstry.jl

Typst uses semantic versioning and has a major version of `0`.
As such, patch version updates should be available automatically in Typstry.jl
but minor version updates require updating the compatibility bounds of Typst_jll.jl.
Either submit an issue to Typstry.jl or a pull request by
updating the `Project.toml` with the new version of Typst_jll.jl.
After a minor release of Typstry.jl,
[interoperable packages](@ref package_interoperability)
require an update to their Typstry.jl compatibility bounds.
They may also require updates for any breaking changes in Typstry.jl.
