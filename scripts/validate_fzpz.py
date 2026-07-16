#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import re
import sys
import zipfile
import xml.etree.ElementTree as ET
from collections import Counter

ROOT = Path(__file__).resolve().parents[1]
PARTS = ROOT / "parts"

def inches(value: str) -> float:
    match = re.fullmatch(r"\s*([0-9.]+)\s*in\s*", value or "")
    if not match:
        raise ValueError(value)
    return float(match.group(1))

def validate(path: Path) -> tuple[str, list[str]]:
    errors: list[str] = []
    with zipfile.ZipFile(path) as zf:
        if zf.testzip():
            return "", ["Corrupt ZIP"]
        names = zf.namelist()
        fzps = [name for name in names if name.startswith("part.") and name.endswith(".fzp")]
        if len(fzps) != 1:
            return "", [f"Expected one FZP, found {len(fzps)}"]
        root = ET.fromstring(zf.read(fzps[0]))
        module_id = root.attrib.get("moduleId", "")
        svg_ids: dict[str, set[str]] = {}
        prefixes = {
            "breadboardView": "svg.breadboard.",
            "iconView": "svg.icon.",
            "schematicView": "svg.schematic.",
            "pcbView": "svg.pcb.",
        }
        for view_name, prefix in prefixes.items():
            filename = root.find("views").find(view_name).find("layers").attrib["image"].split("/")[-1]
            archive_name = prefix + filename
            if archive_name not in names:
                errors.append(f"Missing {archive_name}")
                continue
            data = zf.read(archive_name)
            text = data.decode("utf-8")
            if "ns0:" in text or "ns1:" in text:
                errors.append(f"Unsafe namespace prefix in {archive_name}")
            svg = ET.fromstring(data)
            width = inches(svg.attrib["width"])
            height = inches(svg.attrib["height"])
            vb = [float(value) for value in svg.attrib["viewBox"].replace(",", " ").split()]
            if abs(vb[2] / width - 72.0) > 0.001:
                errors.append(f"{archive_name}: horizontal density is not 72 units/in")
            if abs(vb[3] / height - 72.0) > 0.001:
                errors.append(f"{archive_name}: vertical density is not 72 units/in")
            ids = [node.attrib["id"] for node in svg.iter() if "id" in node.attrib]
            duplicates = [key for key, count in Counter(ids).items() if count > 1]
            if duplicates:
                errors.append(f"{archive_name}: duplicate IDs {duplicates}")
            svg_ids[view_name] = set(ids)

        connectors = root.find("connectors")
        if connectors is not None:
            for connector in connectors.findall("connector"):
                cid = connector.attrib["id"]
                for view_name in ("breadboardView", "schematicView", "pcbView"):
                    svg_id = connector.find("views").find(view_name).find("p").attrib["svgId"]
                    if svg_id not in svg_ids.get(view_name, set()):
                        errors.append(f"{cid}: {svg_id} missing in {view_name}")
        return module_id, errors

def main() -> int:
    failed = False
    module_ids: dict[str, Path] = {}
    files = sorted(PARTS.rglob("*.fzpz"))
    for path in files:
        module_id, errors = validate(path)
        if module_id in module_ids:
            errors.append(f"Duplicate module ID also used by {module_ids[module_id]}")
        module_ids[module_id] = path
        if errors:
            failed = True
            print(f"FAIL {path.relative_to(ROOT)}")
            for error in errors:
                print(f"  - {error}")
        else:
            print(f"PASS {path.relative_to(ROOT)} [{module_id}]")
    print(f"\nValidated {len(files)} part(s).")
    return 1 if failed else 0

if __name__ == "__main__":
    sys.exit(main())
