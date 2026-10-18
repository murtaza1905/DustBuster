// Sources/Views/LargeFilesView.swift
import SwiftUI

struct LargeFilesView: View {
    @EnvironmentObject var viewModel: LargeFilesViewModel
    @State private var showDeleteAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            controls
            fileList
            errorBanner
            footer
        }
        .padding()
        .alert("Seçili dosyaları silmek istiyor musun?",
               isPresented: $showDeleteAlert) {
            Button("İptal", role: .cancel) { }
            Button("Sil", role: .destructive) {
                viewModel.deleteSelected()
            }
        } message: {
            Text("Dosyalar kalıcı olarak silinmez; macOS Çöp Kutusu'na taşınır.")
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Büyük Dosyalar")
                .font(.title)
                .bold()

            Text("250 MB ve üzerindeki dosyaları bulup silebilirsin.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Kontroller

    private var controls: some View {
        HStack {
            Text("Eşik: 250 MB ve üzeri")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Button {
                viewModel.scheduleScan()
            } label: {
                HStack(spacing: 6) {
                    if viewModel.isScanning {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                    Text("Yeniden Tara")
                }
            }
            .disabled(viewModel.isScanning)
        }
    }

    // MARK: - File List

    private var fileList: some View {
        List {
            if viewModel.items.isEmpty {
                Section {
                    if viewModel.isScanning {
                        HStack(spacing: 8) {
                            ProgressView()
                                .controlSize(.small)
                            Text("Tarama yapılıyor...")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 12)
                    } else {
                        Text("250 MB ve üzerinde dosya bulunamadı.")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 12)
                    }
                }
            } else {
                Section {
                    ForEach($viewModel.items) { $item in
                        FileRowView(item: $item)
                    }
                }
            }
        }
        .listStyle(.inset)
        .frame(minHeight: 200, maxHeight: 420)
    }

    // MARK: - Footer

    private var footer: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Seçili dosya sayısı: \(viewModel.selectedCount)")
                    .font(.subheadline)

                Text("Toplam boyut: \(viewModel.selectedSizeString)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(role: .destructive) {
                showDeleteAlert = true
            } label: {
                Label("Seçilenleri Sil", systemImage: "trash")
            }
            .disabled(!viewModel.hasSelectedItems || viewModel.isDeleting)
        }
        .padding(.top, 8)
    }
    
    // MARK: - Error Banner
    
    private var errorBanner: some View {
        Group {
            if !viewModel.deleteErrors.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Çöp Kutusu'na taşınamayan dosyalar:")
                        .font(.subheadline)
                        .foregroundColor(.red)
                    ForEach(viewModel.deleteErrors, id: \.self) { message in
                        Text(message)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .truncationMode(.middle)
                    }
                }
                .padding(.top, 4)
            }
        }
    }
}

// MARK: - File Row View

private struct FileRowView: View {
    @Binding var item: LargeFileItem
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "doc.fill")
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(1)

                Text(item.path)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(item.displaySize)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Toggle("", isOn: $item.isSelected)
                    .labelsHidden()
                    .toggleStyle(.checkbox)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}
