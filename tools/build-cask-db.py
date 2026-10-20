#!/usr/bin/env python3
"""
Homebrew Cask tanımlarından (Casks/**/*.rb) DustBuster'ın gömülü kalıntı veritabanını üretir.

Kullanım:
    python3 tools/build-cask-db.py /path/to/homebrew-cask > Core/Sources/DustBusterCore/Resources/cask-zap.json

Her cask için saklananlar:
    t  token                        ("google-chrome")
    n  isimler                      (["Google Chrome"])
    a  .app dosya adları            (["Google Chrome.app"])
    q  uninstall quit: bundle ID'leri
    l  uninstall/zap launchctl etiketleri
    p  uninstall pkgutil kimlikleri
    z  zap { trash: [...], delete: [...], rmdir: [...] }

Yalnızca zap bilgisi veya launchctl etiketi taşıyan cask'ler yazılır.
"""
import json
import os
import re
import subprocess
import sys
from datetime import date

STRING_RE = re.compile(r'"((?:\\.|[^"\\])*)"|\'((?:\\.|[^\'\\])*)\'')


class Tok:
    __slots__ = ("kind", "val")

    def __init__(self, kind, val):
        self.kind, self.val = kind, val

    def __repr__(self):
        return f"{self.kind}:{self.val!r}"


def tokenize(text, start):
    """Ruby DSL'inin stanza içinde kullanılan alt kümesini token'lara ayırır."""
    i, n = start, len(text)
    toks = []
    while i < n:
        c = text[i]
        if c in " \t\r\n":
            i += 1
            continue
        if c == "#" and not (i + 1 < n and text[i + 1] == "{"):
            while i < n and text[i] != "\n":
                i += 1
            continue
        if c in '"\'':
            m = STRING_RE.match(text, i)
            if not m:
                toks.append(Tok("err", c)); i += 1; continue
            raw = m.group(1) if m.group(1) is not None else m.group(2)
            raw = raw.replace('\\"', '"').replace("\\'", "'").replace("\\\\", "\\")
            toks.append(Tok("str", raw))
            i = m.end()
            continue
        if c in "[]{},:":
            toks.append(Tok(c, c)); i += 1; continue
        if c == "=" and text.startswith("=>", i):
            toks.append(Tok("=>", "=>")); i += 2; continue
        if c == "/":
            j = i + 1
            while j < n and text[j] != "/":
                if text[j] == "\\":
                    j += 1
                j += 1
            toks.append(Tok("regex", text[i + 1:j]))
            i = j + 1
            while i < n and text[i].isalpha():
                i += 1
            continue
        if c.isalpha() or c == "_":
            j = i
            while j < n and (text[j].isalnum() or text[j] in "_?!"):
                j += 1
            toks.append(Tok("id", text[i:j]))
            i = j
            continue
        if c.isdigit() or c == "-":
            j = i + 1
            while j < n and (text[j].isalnum() or text[j] == "."):
                j += 1
            toks.append(Tok("num", text[i:j]))
            i = j
            continue
        toks.append(Tok("other", c))
        i += 1
    return toks


class Parser:
    def __init__(self, toks):
        self.toks, self.i = toks, 0

    def peek(self, k=0):
        j = self.i + k
        return self.toks[j] if j < len(self.toks) else Tok("eof", None)

    def take(self):
        t = self.peek(); self.i += 1; return t

    def value(self):
        t = self.peek()
        if t.kind == "str":
            self.take(); return t.val
        if t.kind == "regex":
            self.take(); return {"regex": t.val}
        if t.kind == ":":
            self.take(); s = self.take(); return {"sym": s.val}
        if t.kind == "num":
            self.take(); return t.val
        if t.kind == "id":
            self.take(); return {"id": t.val}
        if t.kind == "[":
            self.take()
            items = []
            while self.peek().kind not in ("]", "eof"):
                items.append(self.value())
                if self.peek().kind == ",":
                    self.take()
            self.take()
            return items
        if t.kind == "{":
            self.take()
            d = {}
            while self.peek().kind not in ("}", "eof"):
                k = self.value()
                if self.peek().kind in ("=>", ":"):
                    self.take()
                v = self.value()
                d[str(k if not isinstance(k, dict) else k.get("sym", k))] = v
                if self.peek().kind == ",":
                    self.take()
            self.take()
            return d
        self.take()
        return None

    def kv_pairs(self):
        """key: value (, key: value)* — virgül yoksa biter."""
        out = {}
        while True:
            k = self.peek()
            if k.kind != "id" or self.peek(1).kind != ":":
                break
            self.take(); self.take()
            out[k.val] = self.value()
            if self.peek().kind == ",":
                self.take()
                continue
            break
        return out


def flatten_strings(v):
    if v is None:
        return []
    if isinstance(v, str):
        return [v]
    if isinstance(v, list):
        out = []
        for x in v:
            out.extend(flatten_strings(x))
        return out
    if isinstance(v, dict):
        if "regex" in v or "sym" in v or "id" in v:
            return []
        out = []
        for x in v.values():
            out.extend(flatten_strings(x))
        return out
    return []


def clean_path(p):
    p = re.sub(r"#\{[^}]*\}", "*", p)
    p = p.replace("**", "*")
    return p.strip()


STANZA_RE = re.compile(r"(?m)^[ \t]*(zap|uninstall)[ \t]+")
APP_RE = re.compile(r'(?m)^[ \t]*app[ \t]+"((?:\\.|[^"\\])*)"')
NAME_RE = re.compile(r'(?m)^[ \t]*name[ \t]+"((?:\\.|[^"\\])*)"')
TOKEN_RE = re.compile(r'(?m)^cask[ \t]+"([^"]+)"')


def parse_cask(text):
    m = TOKEN_RE.search(text)
    if not m:
        return None
    token = m.group(1)
    names = [n for n in NAME_RE.findall(text)]
    apps = []
    for a in APP_RE.findall(text):
        a = clean_path(a)
        base = a.split("/")[-1]
        if base and base not in apps:
            apps.append(base)

    quit_ids, launchctl, pkgutil = [], [], []
    zap = {"trash": [], "delete": [], "rmdir": []}

    for sm in STANZA_RE.finditer(text):
        kind = sm.group(1)
        toks = tokenize(text, sm.end())
        pairs = Parser(toks).kv_pairs()
        if kind == "uninstall":
            quit_ids += flatten_strings(pairs.get("quit"))
            launchctl += flatten_strings(pairs.get("launchctl"))
            pkgutil += flatten_strings(pairs.get("pkgutil"))
            # uninstall içinde de trash/delete olabilir
            zap["trash"] += [clean_path(p) for p in flatten_strings(pairs.get("trash"))]
            zap["delete"] += [clean_path(p) for p in flatten_strings(pairs.get("delete"))]
        else:
            launchctl += flatten_strings(pairs.get("launchctl"))
            for key in ("trash", "delete", "rmdir"):
                zap[key] += [clean_path(p) for p in flatten_strings(pairs.get(key))]

    # pkg ile kurulan cask'lerde .app adı "uninstall delete:" içinde geçer
    for p in zap["delete"] + zap["trash"]:
        m2 = re.match(r"^/Applications/(?:Utilities/)?([^/]+\.app)$", p)
        if m2 and m2.group(1) not in apps:
            apps.append(m2.group(1))

    def dedupe(xs):
        seen, out = set(), []
        for x in xs:
            if x and x not in seen:
                seen.add(x); out.append(x)
        return out

    rec = {
        "t": token,
        "n": dedupe(names),
        "a": dedupe(apps),
        "q": dedupe(quit_ids),
        "l": dedupe(launchctl),
        "p": dedupe(pkgutil),
        "z": {k: dedupe(v) for k, v in zap.items()},
    }
    has_paths = any(rec["z"].values())
    if not has_paths and not rec["l"]:
        return None
    return rec


def main():
    if len(sys.argv) < 2:
        print(__doc__, file=sys.stderr)
        sys.exit(2)
    root = sys.argv[1]
    casks_dir = os.path.join(root, "Casks")
    records = []
    errors = 0
    for dirpath, _, files in os.walk(casks_dir):
        for fn in sorted(files):
            if not fn.endswith(".rb"):
                continue
            path = os.path.join(dirpath, fn)
            try:
                with open(path, encoding="utf-8") as f:
                    text = f.read()
                rec = parse_cask(text)
                if rec:
                    records.append(rec)
            except Exception as e:  # noqa: BLE001
                errors += 1
                print(f"skip {path}: {e}", file=sys.stderr)
    records.sort(key=lambda r: r["t"])

    sha = "unknown"
    try:
        sha = subprocess.check_output(["git", "-C", root, "rev-parse", "--short", "HEAD"], text=True).strip()
    except Exception:  # noqa: BLE001
        pass

    out = {
        "schema": 1,
        "generated": date.today().isoformat(),
        "source": f"Homebrew/homebrew-cask@{sha}",
        "license": "BSD-2-Clause (Homebrew contributors)",
        "count": len(records),
        "casks": records,
    }
    json.dump(out, sys.stdout, ensure_ascii=False, separators=(",", ":"))
    print(f"casks={len(records)} errors={errors}", file=sys.stderr)


if __name__ == "__main__":
    main()
