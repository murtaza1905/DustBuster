// Sources/Managers/SystemMonitor.swift
import Foundation
import Combine
import Darwin

/// Manages system resource monitoring (RAM, Disk, CPU).
class SystemMonitor: ObservableObject {
    // Yüzde değerleri (0.0 – 1.0) – Gauge için
    @Published var memoryUsage: Double = 0.0
    @Published var diskUsage: Double = 0.0
    @Published var cpuUsage: Double = 0.0

    // RAM detayları (UI için hazır string'ler)
    @Published var memoryUsedString: String = "-"
    @Published var memoryFreeString: String = "-"
    @Published var memoryTotalString: String = "-"

    // Disk detayları
    @Published var diskUsedString: String = "-"
    @Published var diskFreeString: String = "-"
    @Published var diskTotalString: String = "-"

    // CPU detayları (çekirdek bazlı)
    @Published var cpuBusyCores: Int = 0
    @Published var cpuTotalCores: Int = 1
    @Published var cpuBusyString: String = "-"   // "Meşgul: X çekirdek"
    @Published var cpuIdleString: String = "-"   // "Boşta: Y çekirdek"
    @Published var cpuTotalString: String = "-"  // "Toplam: Z çekirdek"

    private var timer: Timer?
    
    // CPU delta hesaplaması için önceki tick değerleri (core bazlı)
    private var previousCPUTicks: [(user: UInt64, system: UInt64, idle: UInt64, nice: UInt64)]?
    
    // ByteCountFormatter - tutarlı birim için
    private let byteFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file  // GB (1000 bazlı, Finder ile uyumlu)
        formatter.includesUnit = true
        formatter.isAdaptive = true
        return formatter
    }()
    
    init() {
        cpuTotalCores = ProcessInfo.processInfo.activeProcessorCount
        startMonitoring()
    }
    
    deinit {
        stopMonitoring()
    }
    
    func startMonitoring() {
        // 2 saniyede bir güncelle
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.updateMetrics()
        }
        updateMetrics() // İlk değer
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateMetrics() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let (memPercent, memUsed, memTotal) = self.getMemoryUsage()
            let (diskPercent, diskUsed, diskTotal) = self.getDiskUsage()
            let (cpuPercent, busyCores, totalCores) = self.getCPUUsage()
            
            let memFree = max(memTotal - memUsed, 0)
            let diskFree = max(diskTotal - diskUsed, 0)
            
            // Tutarlı formatlama
            let memUsedStr  = self.byteFormatter.string(fromByteCount: memUsed)
            let memFreeStr  = self.byteFormatter.string(fromByteCount: memFree)
            let memTotalStr = self.byteFormatter.string(fromByteCount: memTotal)
            
            let diskUsedStr  = self.byteFormatter.string(fromByteCount: diskUsed)
            let diskFreeStr  = self.byteFormatter.string(fromByteCount: diskFree)
            let diskTotalStr = self.byteFormatter.string(fromByteCount: diskTotal)
            
            // CPU çekirdek string'leri (3 satır, diğer kartlarla tutarlı)
            let idleCores = totalCores - busyCores
            let cpuBusyStr  = "Meşgul: \(busyCores) çekirdek"
            let cpuIdleStr  = "Boşta: \(idleCores) çekirdek"
            let cpuTotalStr = "Toplam: \(totalCores) çekirdek"
            
            DispatchQueue.main.async {
                // Gauge yüzdeleri
                self.memoryUsage = memPercent
                self.diskUsage   = diskPercent
                self.cpuUsage    = cpuPercent

                // RAM string'leri
                self.memoryUsedString  = memUsedStr
                self.memoryFreeString  = memFreeStr
                self.memoryTotalString = memTotalStr

                // Disk string'leri
                self.diskUsedString  = diskUsedStr
                self.diskFreeString  = diskFreeStr
                self.diskTotalString = diskTotalStr

                // CPU değerleri
                self.cpuBusyCores   = busyCores
                self.cpuTotalCores  = totalCores
                self.cpuBusyString  = cpuBusyStr
                self.cpuIdleString  = cpuIdleStr
                self.cpuTotalString = cpuTotalStr
            }
        }
    }
    
    // MARK: - Memory Usage
    /// Dönen değer: (yüzde, kullanılan byte, toplam byte)
    /// Activity Monitor ile uyumlu: Active + Wired + Compressed
    private func getMemoryUsage() -> (Double, Int64, Int64) {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)

        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }

        let totalBytes = Int64(ProcessInfo.processInfo.physicalMemory)

        if result == KERN_SUCCESS {
            let pageSize = UInt64(vm_kernel_page_size)

            // Activity Monitor ile uyumlu hesaplama
            let active     = UInt64(stats.active_count) * pageSize
            let wired      = UInt64(stats.wire_count) * pageSize
            let compressed = UInt64(stats.compressor_page_count) * pageSize

            // Used = Active + Wired + Compressed (Activity Monitor formülü)
            let used = active + wired + compressed

            let usedBytes = Int64(used)
            let percent = totalBytes > 0 ? Double(used) / Double(totalBytes) : 0.0
            return (min(max(percent, 0.0), 1.0), usedBytes, totalBytes)
        }

        return (0.0, 0, totalBytes)
    }
    
    // MARK: - Disk Usage
    /// Dönen değer: (yüzde, kullanılan byte, toplam byte)
    /// Finder ile uyumlu: Purgeable space dahil
    private func getDiskUsage() -> (Double, Int64, Int64) {
        let fileURL = URL(fileURLWithPath: "/")
        do {
            let values = try fileURL.resourceValues(forKeys: [
                .volumeTotalCapacityKey,
                .volumeAvailableCapacityForImportantUsageKey
            ])

            if let total = values.volumeTotalCapacity,
               let available = values.volumeAvailableCapacityForImportantUsage {
                let totalInt64 = Int64(total)
                let used = totalInt64 - available
                let percent = totalInt64 > 0 ? Double(used) / Double(totalInt64) : 0.0
                return (min(max(percent, 0.0), 1.0), used, totalInt64)
            }
        } catch {
            print("Error retrieving disk usage: \(error)")
        }
        return (0.0, 0, 0)
    }
    
    // MARK: - CPU Usage (host_processor_info ile gerçek kullanım)
    /// Dönen değer: (yüzde 0-1, meşgul çekirdek sayısı, toplam çekirdek sayısı)
    private func getCPUUsage() -> (Double, Int, Int) {
        var numCPUs: natural_t = 0
        var cpuInfo: processor_info_array_t?
        var numCPUInfo: mach_msg_type_number_t = 0
        
        let result = host_processor_info(
            mach_host_self(),
            PROCESSOR_CPU_LOAD_INFO,
            &numCPUs,
            &cpuInfo,
            &numCPUInfo
        )
        
        guard result == KERN_SUCCESS, let info = cpuInfo else {
            return (0.0, 0, ProcessInfo.processInfo.activeProcessorCount)
        }
        
        defer {
            // Belleği serbest bırak
            let size = vm_size_t(numCPUInfo) * vm_size_t(MemoryLayout<integer_t>.size)
            vm_deallocate(mach_task_self_, vm_address_t(bitPattern: info), size)
        }
        
        let coreCount = Int(numCPUs)
        var currentTicks: [(user: UInt64, system: UInt64, idle: UInt64, nice: UInt64)] = []
        
        // Her çekirdek için tick değerlerini oku
        for i in 0..<coreCount {
            let offset = Int32(i) * CPU_STATE_MAX
            let user   = UInt64(info[Int(offset + CPU_STATE_USER)])
            let system = UInt64(info[Int(offset + CPU_STATE_SYSTEM)])
            let idle   = UInt64(info[Int(offset + CPU_STATE_IDLE)])
            let nice   = UInt64(info[Int(offset + CPU_STATE_NICE)])
            currentTicks.append((user, system, idle, nice))
        }
        
        // İlk çağrıda önceki değer yoksa 0% göster
        guard let prevTicks = previousCPUTicks, prevTicks.count == coreCount else {
            previousCPUTicks = currentTicks
            return (0.0, 0, coreCount)
        }
        
        // Her çekirdek için kullanım hesapla
        var totalUsage: Double = 0.0
        var busyCores = 0
        let busyThreshold = 0.10  // %10 eşik
        
        for i in 0..<coreCount {
            let prev = prevTicks[i]
            let curr = currentTicks[i]
            
            let deltaUser   = curr.user - prev.user
            let deltaSystem = curr.system - prev.system
            let deltaIdle   = curr.idle - prev.idle
            let deltaNice   = curr.nice - prev.nice
            
            let deltaTotal = deltaUser + deltaSystem + deltaIdle + deltaNice
            let deltaUsed  = deltaUser + deltaSystem + deltaNice  // idle hariç
            
            var coreUsage: Double = 0.0
            if deltaTotal > 0 {
                coreUsage = Double(deltaUsed) / Double(deltaTotal)
            }
            
            totalUsage += coreUsage
            
            if coreUsage >= busyThreshold {
                busyCores += 1
            }
        }
        
        // Önceki değerleri güncelle
        previousCPUTicks = currentTicks
        
        // Ortalama CPU kullanımı
        let avgUsage = coreCount > 0 ? totalUsage / Double(coreCount) : 0.0
        
        return (min(max(avgUsage, 0.0), 1.0), busyCores, coreCount)
    }
}
