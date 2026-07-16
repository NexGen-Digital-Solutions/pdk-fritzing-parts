# PDK Fritzing Parts

A practical Fritzing library for laying out PDK Red Series access-control panels.

It includes the Red Max enclosure, the current Red expanders, the Red Aux 8,
the WiMAC and PoE daughtercards, and the Altronix eFlow102NB used in the Red Max.

## About Fritzing and PDK

[Fritzing](https://fritzing.org/) is an electronics-design application for
documenting prototypes, creating wiring diagrams, and laying out circuit
boards. It is available for Windows, macOS, and Linux from the official
[Fritzing download page](https://fritzing.org/releases).

PDK (ProdataKey) provides cloud-based access-control software and hardware,
including controllers, readers, credentials, wireless devices, and related
peripherals. Visit the [PDK website](https://www.prodatakey.com/) to explore
its current products and find official product information.

## Install the complete library

Download the Windows installer package, extract it, close Fritzing, and run:

```text
Install PDK Fritzing Library.cmd
```

The installer adds all eight parts and creates a **PDK Access Control** bin in
the Parts pane. It uses your normal Fritzing user library, does not require
administrator rights, and backs up files before replacing anything.

Individual `.fzpz` files are also available under `parts/` for manual import.

## Included parts

| Part | Part number | Current footprint |
|---|---|---:|
| PDK Red Max Enclosure | `RMAX` | 14.25 × 18.25 in |
| Altronix eFlow102NB | `eFlow102NB` | 5.4273 × 3.1752 in |
| PDK Red 1 Expander (R1E) | `R1E` | 2.1466 × 2.6013 in |
| PDK Red 2 Expander (R2E) | `R2E` | 3.0869 × 2.5901 in |
| PDK Red 4 Expander (R4E) | `R4E` | 3.0518 × 2.7302 in |
| PDK Red Aux 8 (A8) | `A8` | 3.0895 × 2.8192 in |
| PDK WiMAC Module | `WiMAC` | 0.6923 × 1.1122 in |
| PDK Red Series PoE Module | `PoE Module` | 1.7231 × 1.0194 in |

## What the parts are for

These parts are built for panel layouts, wiring diagrams, proposal drawings,
and installation planning. Place the Red Max enclosure first, send it to the
back, and arrange the boards over its mounting pattern.

The controller boards are calibrated to the Red Max stud locations. The WiMAC
and PoE modules are sized from PDK's installation graphics so their footprints
match the mounted positions shown in the manuals.

Electrical names for the daughtercard header pins remain generic because a
verified factory pinout has not been published in this project.

## Accuracy

The library prioritizes the details that matter in a panel drawing:

- Overall enclosure size
- Board mounting-hole alignment
- Terminal order and labeling
- Jumper and OSDP locations
- Daughtercard placement and footprint

These are not fabrication-ready PCB footprints or substitutes for current PDK
and Altronix installation instructions.

## Contributing

Measurements, better board images, verified pinouts, and additional PDK parts
are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for the project standards.

## License

Original work in this repository is available under the [MIT License](LICENSE).
Third-party trademarks, product imagery, manuals, and manufacturer artwork are
not covered by that license; see [NOTICE.md](NOTICE.md) for details.

## Disclaimer

This is an unofficial community project. It is not affiliated with or endorsed
by PDK, ProdataKey, Fritzing, or Altronix. Product names, trademarks, logos,
and manufacturer artwork belong to their respective owners. See [NOTICE.md](NOTICE.md)
for details.
