"""Route current audio streams, or save a WirePlumber default device."""
import json
import subprocess
import sys
import time


def run(*command):
    result = subprocess.run(command, capture_output=True, text=True, errors="replace", timeout=5)
    if result.returncode:
        detail = result.stderr.strip().splitlines()
        raise RuntimeError(detail[-1] if detail else f"{command[0]} failed.")
    return result.stdout


def graph():
    return json.loads(run("pw-dump"))


def properties(obj):
    return obj.get("info", {}).get("props", {})


def connected(objects, start, target, direction):
    edges = {}
    for obj in objects:
        if obj.get("type") != "PipeWire:Interface:Link":
            continue
        info = obj.get("info", {})
        a, b = info.get("output-node-id"), info.get("input-node-id")
        if direction == "input":
            a, b = b, a
        edges.setdefault(a, set()).add(b)
    pending, visited = [start], set()
    while pending:
        node = pending.pop()
        if node == target:
            return True
        if node not in visited:
            visited.add(node)
            pending.extend(edges.get(node, ()))
    return False


def apply(direction, action, name):
    if direction not in ("input", "output") or action not in ("select", "default"):
        raise ValueError("Choose input/output and select/default.")
    objects = graph()
    device_class = "Audio/Sink" if direction == "output" else "Audio/Source"
    target = next((obj for obj in objects if obj.get("type") == "PipeWire:Interface:Node"
                   and properties(obj).get("node.name") == name
                   and properties(obj).get("media.class") == device_class), None)
    if target is None:
        raise ValueError("That audio device is no longer available.")
    # wpctl expects a PipeWire global ID, not a PulseAudio index/object serial.
    if action == "default":
        run("wpctl", "set-default", str(target["id"]))
    stream_class = "Stream/Output/Audio" if direction == "output" else "Stream/Input/Audio"
    streams = [obj for obj in objects if obj.get("type") == "PipeWire:Interface:Node"
               and properties(obj).get("media.class") == stream_class]
    linked = {obj["id"] for obj in streams if any(
        link.get("type") == "PipeWire:Interface:Link"
        and obj["id"] in (link.get("info", {}).get("input-node-id"),
                          link.get("info", {}).get("output-node-id")) for link in objects)}
    for stream in streams:
        # The session manager understands node names and handles native PipeWire
        # and PulseAudio clients alike. Internal Bluetooth/filter streams stay put.
        run("pw-metadata", "-n", "default", str(stream["id"]), "target.object", name, "Spa:String")
    deadline = time.monotonic() + 2
    while linked:
        current = graph()
        ids = {obj["id"] for obj in current if obj.get("type") == "PipeWire:Interface:Node"}
        if target["id"] not in ids:
            raise RuntimeError("The audio device disconnected while switching.")
        linked = {sid for sid in linked if sid in ids and not connected(current, sid, target["id"], direction)}
        if linked and time.monotonic() >= deadline:
            raise RuntimeError("Some applications could not switch to this device.")
        if linked:
            time.sleep(0.05)
    return {"name": name}


if __name__ == "__main__":
    try:
        if len(sys.argv) != 4:
            raise ValueError("Usage: audio.py input|output select|default NODE_NAME")
        print(json.dumps(apply(*sys.argv[1:])))
    except (OSError, ValueError, RuntimeError, subprocess.TimeoutExpired) as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
