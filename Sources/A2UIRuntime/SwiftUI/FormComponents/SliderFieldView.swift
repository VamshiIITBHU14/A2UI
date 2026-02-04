import SwiftUI

public struct SliderFieldView: View {
    public let label: String
    public let min: Double
    public let max: Double
    public let step: Double
    @Binding public var value: Double

    public init(label: String, min: Double, max: Double, step: Double, value: Binding<Double>) {
        self.label = label
        self.min = min
        self.max = max
        self.step = step
        self._value = value
    }

    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(label)
                Spacer()
                Text(String(format: "%.0f", value))
                    .foregroundStyle(.secondary)
            }
            Slider(value: $value, in: min...max, step: step)
        }
    }
}
