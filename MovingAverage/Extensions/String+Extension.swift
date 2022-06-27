import Foundation

extension String {
    
    public var yearMonth: String {
        var string = self
        let i = self.index(self.startIndex, offsetBy: 4)
        string.insert("/", at: i)
        return string
    }
}
