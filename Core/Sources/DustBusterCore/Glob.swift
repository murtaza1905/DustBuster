import Foundation

/// `*` ve `?` destekleyen, büyük/küçük harfe duyarsız basit joker eşleştirici ve
/// `ScanFileSystem` üzerinde çalışan yol genişletici (Homebrew zap kalıpları için).
public enum Glob {
    public static func matches(_ pattern: String, _ name: String) -> Bool {
        let p = Array(pattern.lowercased())
        let s = Array(name.lowercased())
        var pi = 0, si = 0
        var starP = -1, starS = -1
        while si < s.count {
            if pi < p.count && (p[pi] == "?" || p[pi] == s[si]) {
                pi += 1; si += 1
            } else if pi < p.count && p[pi] == "*" {
                starP = pi; starS = si
                pi += 1
            } else if starP >= 0 {
                pi = starP + 1
                starS += 1
                si = starS
            } else {
                return false
            }
        }
        while pi < p.count && p[pi] == "*" { pi += 1 }
        return pi == p.count
    }

    public static func hasWildcard(_ s: String) -> Bool {
        s.contains("*") || s.contains("?")
    }

    /// "~/Library/Caches/com.google.Chrome.helper.*" gibi bir kalıbı var olan yollara açar.
    /// Joker içermeyen kalıp, yol diskte varsa kendisi olarak döner.
    public static func expand(pattern: String, home: String, fs: ScanFileSystem) -> [String] {
        var pat = pattern
        if pat == "~" { pat = home }
        else if pat.hasPrefix("~/") { pat = home + String(pat.dropFirst(1)) }
        guard pat.hasPrefix("/") else { return [] }

        let components = pat.split(separator: "/", omittingEmptySubsequences: true).map(String.init)
        guard !components.isEmpty else { return [] }

        // "…/Caches/*" gibi son bileşeni neredeyse salt joker olan kalıplar bir klasörün tamamını
        // sahiplenir; veritabanı temizliği bunları eler, burada da ikinci bir emniyet.
        if let last = components.last, hasWildcard(last) {
            let literal = last.filter { $0 != "*" && $0 != "?" }
            if literal.count < 3 { return [] }
        }

        if !components.contains(where: hasWildcard) {
            return fs.exists(pat) ? [pat] : []
        }

        var current: [String] = ["/"]
        for (index, component) in components.enumerated() {
            let isLast = index == components.count - 1
            var next: [String] = []
            for base in current {
                if hasWildcard(component) {
                    guard let names = fs.contents(ofDirectory: base) else { continue }
                    for name in names where matches(component, name) {
                        let candidate = join(base, name)
                        if isLast || fs.isDirectory(candidate) { next.append(candidate) }
                    }
                } else {
                    let candidate = join(base, component)
                    if isLast ? fs.exists(candidate) : fs.isDirectory(candidate) {
                        next.append(candidate)
                    }
                }
            }
            current = next
            if current.isEmpty { break }
        }
        return current.sorted()
    }

    private static func join(_ base: String, _ name: String) -> String {
        base == "/" ? "/" + name : base + "/" + name
    }
}
