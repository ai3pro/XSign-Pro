import SwiftUI
import CoreData
import UniformTypeIdentifiers
import NimbleViews

// Enum để lọc App (Đã ký vs File nhập)
enum LibraryScope {
    case signed
    case imported
    
    var title: String {
        switch self {
        case .signed: return "Đã ký"
        case .imported: return "Quản lý tệp"
        }
    }
}

struct LibraryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var downloadManager = DownloadManager.shared
    
    var scope: LibraryScope // Biến để biết đang ở tab nào
    
    @State private var isImporting = false
    
    // Lấy dữ liệu
    @FetchRequest(
        entity: Signed.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Signed.date, ascending: false)]
    ) var signedApps: FetchedResults<Signed>
    
    @FetchRequest(
        entity: Imported.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Imported.date, ascending: false)]
    ) var importedApps: FetchedResults<Imported>

    var body: some View {
        List {
            // Logic hiển thị danh sách tùy theo Tab
            if scope == .signed {
                if signedApps.isEmpty {
                    emptyView(text: "Chưa có ứng dụng nào được ký")
                } else {
                    ForEach(signedApps, id: \.self) { app in
                        AppRow(name: app.name, version: app.version, bundleID: app.bundleID, icon: app.icon)
                    }
                    .onDelete(perform: deleteSigned)
                }
            } else {
                // Tab Files (Imported)
                if importedApps.isEmpty {
                    emptyView(text: "Chưa nhập file IPA nào")
                } else {
                    ForEach(importedApps, id: \.self) { app in
                        AppRow(name: app.name, version: app.version, bundleID: app.bundleID, icon: app.icon)
                    }
                    .onDelete(perform: deleteImported)
                }
            }
        }
        .listStyle(.plain) // Style phẳng giống ESign
        .navigationTitle(scope.title)
        .toolbar {
            if scope == .imported {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isImporting = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        // Logic nhập file
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.item], // Chấp nhận mọi file
            allowsMultipleSelection: true
        ) { result in
            if case .success(let urls) = result {
                for url in urls {
                    guard url.startAccessingSecurityScopedResource() else { continue }
                    defer { url.stopAccessingSecurityScopedResource() }
                    let id = "Import_\(UUID().uuidString)"
                    let dl = downloadManager.startArchive(from: url, id: id)
                    try? downloadManager.handlePachageFile(url: url, dl: dl)
                }
            }
        }
    }
    
    // View hiển thị khi trống
    func emptyView(text: String) -> some View {
        VStack(spacing: 15) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .listRowSeparator(.hidden)
        .padding(.top, 50)
    }
    
    // Hàm xóa
    func deleteSigned(offsets: IndexSet) {
        withAnimation {
            offsets.map { signedApps[$0] }.forEach(viewContext.delete)
            try? viewContext.save()
        }
    }
    
    func deleteImported(offsets: IndexSet) {
        withAnimation {
            offsets.map { importedApps[$0] }.forEach(viewContext.delete)
            try? viewContext.save()
        }
    }
}

// Component dòng ứng dụng giống ESign
struct AppRow: View {
    let name: String?
    let version: String?
    let bundleID: String?
    let icon: Data?
    
    var body: some View {
        HStack(spacing: 15) {
            // Icon
            if let data = icon, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .frame(width: 58, height: 58)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 0.5))
            } else {
                Image(systemName: "app.fill")
                    .resizable()
                    .frame(width: 58, height: 58)
                    .foregroundColor(Color(hex: "0096FF"))
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            }
            
            // Thông tin text
            VStack(alignment: .leading, spacing: 4) {
                Text(name ?? "Unknown App")
                    .font(.headline)
                    .lineLimit(1)
                
                HStack {
                    Text(version ?? "1.0")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(4)
                    
                    Text(bundleID ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }
            Spacer()
            
            // Nút trạng thái (Giả lập giống ESign)
            Button(action: {}) {
                Text("Ký")
                    .font(.caption.bold())
                    .foregroundColor(Color(hex: "0096FF"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(hex: "0096FF").opacity(0.1))
                    .cornerRadius(15)
            }
        }
        .padding(.vertical, 6)
    }
}
