import SwiftUI

/// Çalışan uygulamaları gösteren ve kapatan ekran.
struct ProcessListView: View {
    @StateObject var manager = ProcessManager()

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.lg) {
            listCard
            NoticeBanner(text: "Kapat, uygulamaya normal çıkış isteği gönderir (⌘Q ile aynı). Zorla Kapat yalnızca yanıt vermeyen uygulamalar içindir; kaydedilmemiş veriler kaybolabilir.", kind: .info)
        }
        .pageLayout()
        .navigationSubtitle("Dock'ta görünen üçüncü parti uygulamalar")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    manager.refresh()
                } label: {
                    Label("Yenile", systemImage: "arrow.clockwise")
                }
            }
        }
        .onAppear {
            manager.refresh()
        }
    }

    private var listCard: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            CardHeader("Çalışan Uygulamalar", systemImage: "rectangle.stack.badge.person.crop") {
                if !manager.processes.isEmpty {
                    Tag(text: "\(manager.processes.count) uygulama")
                }
            }

            if manager.processes.isEmpty {
                EmptyState(systemImage: "rectangle.stack", title: "Listelenecek uygulama yok",
                           message: "Dock'ta görünen üçüncü parti uygulama çalışmıyor.")
            } else {
                List(manager.processes) { process in
                    HStack(spacing: DS.Spacing.md) {
                        Image(systemName: "app.fill")
                            .symbolRenderingMode(.hierarchical)
                            .font(.title3)
                            .foregroundStyle(process.isSystemProtected ? Color.secondary : Color.accentColor)
                            .frame(width: 24)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(process.name)
                                .font(.body.weight(.medium))
                            HStack(spacing: 6) {
                                if let bundle = process.bundleIdentifier {
                                    Text(bundle)
                                    Text("·")
                                }
                                Text("PID \(process.pid)")
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                        }

                        Spacer()

                        if process.isSystemProtected {
                            Tag(text: "Sistem", tone: .neutral, systemImage: "lock.fill")
                        } else {
                            HStack(spacing: DS.Spacing.sm) {
                                Button("Kapat") {
                                    manager.terminate(process, force: false)
                                }
                                .buttonStyle(.bordered)

                                Button("Zorla Kapat") {
                                    manager.terminate(process, force: true)
                                }
                                .buttonStyle(.bordered)
                                .tint(.red)
                            }
                            .controlSize(.small)
                        }
                    }
                    .padding(.vertical, 6)
                }
                .listStyle(.inset)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 260, maxHeight: 560)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.inner, style: .continuous))
            }
        }
        .cardSurface()
    }
}
