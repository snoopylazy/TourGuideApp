import os
import re
from collections import defaultdict, deque


def main() -> None:
    root = os.path.join(os.getcwd(), "lib")
    all_darts: list[str] = []
    for dp, _, fs in os.walk(root):
        for f in fs:
            if f.endswith(".dart"):
                rel = os.path.relpath(os.path.join(dp, f), root).replace("\\", "/")
                all_darts.append(rel)

    imp_re = re.compile(r"^\s*import\s+['\"]([^'\"]+)['\"]\s*;", re.M)

    def resolve(from_path: str, imp: str) -> str | None:
        if imp.startswith("dart:"):
            return None
        if imp.startswith("package:"):
            if imp.startswith("package:tourguideapp/"):
                rel = imp[len("package:tourguideapp/") :]
                if rel.startswith("lib/"):
                    rel = rel[4:]
                return rel if rel.endswith(".dart") else None
            return None
        if imp.startswith("./") or imp.startswith("../"):
            base = os.path.dirname(from_path)
            joined = os.path.normpath(os.path.join(base, imp)).replace("\\", "/")
            return joined if joined.endswith(".dart") else None
        if imp.endswith(".dart") and not imp.startswith("/"):
            base = os.path.dirname(from_path)
            joined = os.path.normpath(os.path.join(base, imp)).replace("\\", "/")
            return joined
        return None

    imports: dict[str, list[str]] = defaultdict(list)
    for rel in all_darts:
        p = os.path.join(root, rel)
        try:
            txt = open(p, "r", encoding="utf-8").read()
        except Exception:
            continue
        for imp in imp_re.findall(txt):
            target = resolve(rel, imp)
            if target and target in all_darts:
                imports[rel].append(target)

    start = "main.dart"
    seen: set[str] = set()
    q: deque[str] = deque([start])
    while q:
        cur = q.popleft()
        if cur in seen:
            continue
        seen.add(cur)
        for dep in imports.get(cur, []):
            if dep not in seen:
                q.append(dep)

    unused = sorted(set(all_darts) - seen)
    print(f"TOTAL_DARTS {len(all_darts)}")
    print(f"REACHABLE {len(seen)}")
    print(f"UNUSED {len(unused)}")
    for u in unused:
        print(u)


if __name__ == "__main__":
    main()


