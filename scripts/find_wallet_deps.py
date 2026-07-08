import re
import os
import collections

roots = [
    "lib/services/evolve_engine.dart",
    "lib/services/app_performance.dart",
    "lib/services/platform_detect_stub.dart",
    "lib/services/platform_detect_io.dart",
    "lib/services/platform_detect_web.dart",
    "lib/services/device_locale_resolver.dart",
    "lib/services/locale_store.dart",
    "lib/services/locale_store_factory.dart",
    "lib/services/locale_store_io.dart",
    "lib/services/locale_store_stub.dart",
    "lib/services/locale_store_web.dart",
    "lib/services/locale_store_memory.dart",
    "lib/services/app_update_check.dart",
]

pat = re.compile(r"import\s+'([^']+)'|import\s+\"([^\"]+)\"")
queue = collections.deque(roots)
seen = set()

while queue:
    rel = queue.popleft()
    if rel in seen:
        continue
    seen.add(rel)
    path = rel.replace("/", os.sep)
    if not os.path.isfile(path):
        continue
    with open(path, encoding="utf-8") as f:
        text = f.read()
    for m in pat.finditer(text):
        imp = m.group(1) or m.group(2)
        if imp.startswith("package:") or imp.startswith("dart:"):
            continue
        base = os.path.dirname(rel)
        target = os.path.normpath(os.path.join(base, imp)).replace("\\", "/")
        if not target.startswith("lib/"):
            continue
        queue.append(target)

for s in sorted(seen):
    print(s)
print(f"TOTAL={len(seen)}", flush=True)