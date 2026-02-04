import SwiftUI

public struct DateFieldView: View {
    public let label: String
    @Binding public var date: Date

    public init(label: String, date: Binding<Date>) {
        self.label = label
        self._date = date
    }

    public var body: some View {
        DatePicker(label, selection: $date, displayedComponents: [.date, .hourAndMinute])
    }
}
