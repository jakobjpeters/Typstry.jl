
# Updating Dependencies

This guide discusses updating Typst_jll.jl,
Typstry.jl, and Typstry.jl's dependent packages.

## Typst_jll.jl

[Yggrasil](https://github.com/JuliaPackaging/Yggdrasil)
hosts the BinaryBuilder.jl recipes used to generate jll packages.
Upon merging changes to a recipe, the corresponding jll package is updated automatically.

1. Obtain the version number and commit hash of a
    [Typst release](https://github.com/typst/typst/releases)
1. Fork Yggrasil
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
    - Building a new version of Typst frequently requires
    [updating the build system's internal version of Rust](https://github.com/JuliaPackaging/Yggdrasil/pull/12421).
5. Wait until the pull request is merged

## Typstry.jl

Typst uses semantic versioning and currently has a major version of `0`.
As such, patch version updates should be available automatically in Typstry.jl
but minor version updates require updating the compatibility bound of Typst_jll.jl.
Either submit an issue to Typstry.jl or a pull request by
updating the `Project.toml` with the new version of Typst_jll.jl.
In general, Typstry.jl only supports the latest version of Typst.
However, previous versions may remain compatible until there is a feature requiring an update.

## Interoperable Packages

After a minor release of Typstry.jl,
[dependent packages](@ref package_interoperability)
require an update to their Typstry.jl compatibility bounds.
They may also require updates for any breaking changes in Typstry.jl.
