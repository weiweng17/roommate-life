from pathlib import Path
import re, sys
root=Path(__file__).resolve().parents[1]
required=['project.godot','scenes/Main.tscn','src/Main.gd','src/core/iso.gd','src/core/room_model.gd','src/core/prop_def.gd','src/core/actor_body.gd','src/room/room_factory.gd','src/life/resident_state.gd','src/life/resident_brain.gd','export_presets.cfg']
missing=[p for p in required if not (root/p).exists()]
if missing:
    print('Missing:',*missing,sep='\n- '); sys.exit(1)
proj=(root/'project.godot').read_text()
assert 'run/main_scene="res://scenes/Main.tscn"' in proj
scene=(root/'scenes/Main.tscn').read_text()
assert 'res://src/Main.gd' in scene
factory=(root/'src/room/room_factory.gd').read_text()
for action in ['sleep','eat','shower','computer','chat','relax']:
    assert f'"interact_id":"{action}"' in factory
assert factory.count('interact_offset') >= 6
print('Roommate Life structural sanity check: OK')
