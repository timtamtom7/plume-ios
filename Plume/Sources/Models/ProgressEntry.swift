import Foundation

struct ProgressEntry: Identifiable, Equatable {
    let id: Int64
    let bookId: Int64
    let page: Int
    let date: Date

    var dayNumber: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: date, to: Date()).day ?? 0
    }
}
