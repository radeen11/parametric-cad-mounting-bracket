"""Repeatable mesh inspection for the default OpenSCAD design."""
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
MODEL = ROOT / "cad/gusseted_bracket.scad"
EXPORT = ROOT / "exports/gusseted_bracket.stl"


def main():
    assert MODEL.is_file(), "Missing parametric OpenSCAD source"
    source = MODEL.read_text()
    for key in ("module bracket()", "module raw_bracket()", "hole_x_spacing", "gussets_enabled"):
        assert key in source, f"Missing design control: {key}"

    try:
        import trimesh
    except ImportError:
        raise SystemExit("Install trimesh: python3 -m pip install trimesh")

    EXPORT.parent.mkdir(parents=True, exist_ok=True)
    # Always regenerate from current source to avoid validating a stale STL.
    subprocess.run(["openscad", "-o", str(EXPORT), str(MODEL)], check=True)
    mesh = trimesh.load(EXPORT, force="mesh")
    assert mesh.is_watertight, "Not watertight"
    assert len(mesh.split()) == 1, "Expected one connected solid"
    size = mesh.bounds[1] - mesh.bounds[0]
    assert all(abs(a-b) < 0.02 for a, b in zip(size, (80, 65, 70))), size
    print(f"PASS: watertight single solid, 80 × 65 × 70 mm; volume {mesh.volume:.1f} mm³")
    print(f"Triangle faces: {len(mesh.faces)}")


if __name__ == "__main__":
    main()
