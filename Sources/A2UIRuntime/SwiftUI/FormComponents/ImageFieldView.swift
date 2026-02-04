import SwiftUI
import PhotosUI

public struct ImageFieldView: View {
    public let label: String
    public let required: Bool
    @Binding public var data: Data?

    @State private var pickerItem: PhotosPickerItem?
    @State private var isLoading = false

    public init(label: String, required: Bool, data: Binding<Data?>) {
        self.label = label
        self.required = required
        self._data = data
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(label)
                if required { Text("*").foregroundStyle(.red) }
            }

            PhotosPicker(selection: $pickerItem, matching: .images) {
                HStack {
                    Image(systemName: "camera")
                    Text(data == nil ? "Add Photo" : "Replace Photo")
                }
            }
            .onChange(of: pickerItem) { newItem in
                guard let newItem else { return }
                load(item: newItem)
            }

            if isLoading {
                ProgressView()
            } else if let data, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Text("No photo selected")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func load(item: PhotosPickerItem) {
        isLoading = true
        Task {
            defer { isLoading = false }
            if let d = try? await item.loadTransferable(type: Data.self) {
                await MainActor.run { self.data = d }
            }
        }
    }
}
