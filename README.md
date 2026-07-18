# rain.math.binary

Binary math logic not provided by the EVM or Solidity.

Currently exposes `LibCtPop` — efficient population count (number of 1 bits)
over a `uint256`.

## Install

Via [soldeer](https://soldeer.xyz):

```sh
forge soldeer install rain-math-binary~<version>
```

Versioned remappings end up in `dependencies/rain-math-binary-<version>/`.

## Develop

This repo uses [nix](https://nixos.org/download.html) for its dev shell. The
default shell is the slim `sol-shell` from
[rainix](https://github.com/rainlanguage/rainix) — no rust, node, or chromium.

```sh
nix develop          # enter the shell
forge soldeer install # install deps declared in foundry.toml
forge test
```

Tasks exposed via the shell:

- `rainix-sol-test` — `forge test`
- `rainix-sol-static` — slither
- `rainix-sol-legal` — `reuse lint`

Use the nix-pinned `forge` for all development to keep versions consistent.

## Publish

Push to `main`. The
[`Package Release`](.github/workflows/package-release.yaml) wrapper delegates
to rainix's reusable autopublish workflow with the package name
`rain-math-binary`.

## License

DecentraLicense 1.0 (DCL-1.0) — full text in
[`LICENSES/`](LICENSES/LicenseRef-DCL-1.0.txt). Roughly `CAL-1.0`
([opensource.org](https://opensource.org/license/cal-1-0)) plus user-data
disclosure obligations consistent with permissionless-blockchain assumptions.

This repo is [REUSE 3.2](https://reuse.software/spec-3.2/) compliant. Verify
locally:

```sh
nix develop -c rainix-sol-legal
```

## Contributions

Welcome under the same license. Contributors warrant that their contributions
are compliant.
