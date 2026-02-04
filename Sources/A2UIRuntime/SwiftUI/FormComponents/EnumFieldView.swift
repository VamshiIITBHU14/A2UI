import SwiftUI

public struct EnumFieldView: View {
    public let label: String
    public let options: [EnumOption]
    @Binding public var selection: String

    public init(label: String, options: [EnumOption], selection: Binding<String>) {
        self.label = label
        self.options = options
        self._selection = selection
    }

    public var body: some View {
        Picker(label, selection: $selection) {
            ForEach(options, id: \.value) { opt in
                Text(opt.label).tag(opt.value)
            }
        }
    }
}
