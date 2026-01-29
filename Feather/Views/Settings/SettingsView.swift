import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            // Header ESign Style
            Section {
                HStack(spacing: 15) {
                    Image(systemName: "signature")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color(hex: "0096FF"))
                        .cornerRadius(18)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("XSign Pro")
                            .font(.title2.bold())
                        Text("Phiên bản ESign Remake")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 10)
            }
            
            // Nhóm tính năng
            Section(header: Text("Chức năng")) {
                NavigationLink(destination: CertificatesView()) {
                    Label("Quản lý chứng chỉ", systemImage: "doc.text.badge.plus")
                }
                NavigationLink(destination: InstallationView()) {
                    Label("Cài đặt ký", systemImage: "gear.badge.checkmark")
                }
            }
            
            // Nhóm liên hệ
            Section(header: Text("Thông tin")) {
                Link(destination: URL(string: "https://t.me/dothaisonfpt")!) {
                    HStack {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(Color(hex: "0096FF"))
                            .frame(width: 24)
                        Text("Telegram Developer")
                            .foregroundColor(.primary)
                        Spacer()
                    }
                }
                
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray)
                        .frame(width: 24)
                    Text("Tác giả")
                    Spacer()
                    Text("ThaiSon")
                        .foregroundColor(.secondary)
                }
            }
            
            // Nhóm Reset
            Section {
                NavigationLink(destination: ResetView()) {
                    Text("Xóa tất cả dữ liệu")
                        .foregroundColor(.red)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Cài đặt")
    }
}
