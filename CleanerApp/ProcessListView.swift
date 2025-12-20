// Sources/Views/ProcessListView.swift
import SwiftUI

/// Çalışan uygulamaları gösteren ve kapatan ekran.
struct ProcessListView: View {
    @StateObject var manager = ProcessManager()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()
            list
            Divider()
            footer
        }
        .frame(minWidth: 600, minHeight: 400)
        .padding()
        .onAppear {
            manager.refresh()
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Çalışan Uygulamalar")
                    .font(.title2)
                    .bold()
                Text("Dock'ta görünen üçüncü parti uygulamaları buradan kapatabilirsin.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button {
                manager.refresh()
            } label: {
                Label("Yenile", systemImage: "arrow.clockwise")
            }
        }
        .padding(.bottom, 8)
    }

    // MARK: - Liste

    private var list: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if manager.processes.isEmpty {
                    Text("Şu anda listelenecek kullanıcı uygulaması yok.")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 40)
                } else {
                    ForEach(manager.processes) { process in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(process.name)
                                    .fontWeight(.medium)
                                HStack(spacing: 8) {
                                    if let bundle = process.bundleIdentifier {
                                        Text(bundle)
                                    }
                                    Text("PID: \(process.pid)")
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                            Spacer()
                            if process.isSystemProtected {
                                Text("Sistem")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            } else {
                                HStack(spacing: 6) {
                                    Button {
                                        manager.terminate(process, force: false)
                                    } label: {
                                        Text("Kapat")
                                    }
                                    .buttonStyle(.bordered)

                                    Button {
                                        manager.terminate(process, force: true)
                                    } label: {
                                        Text("Zorla Kapat")
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 4)
                        
                        Divider()
                    }
                }
            }
        }
    }

    // MARK: - Footer

    private var footer: some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.yellow)
                .font(.caption)
            VStack(alignment: .leading, spacing: 2) {
                Text("Kapat: Uygulamaya normal çıkış isteği gönderir (Cmd+Q ile aynı).")
                Text("Zorla Kapat: Uygulama yanıt vermiyorsa kullanılır; kaydedilmemiş veriler kaybolabilir.")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.top, 4)
    }
}
