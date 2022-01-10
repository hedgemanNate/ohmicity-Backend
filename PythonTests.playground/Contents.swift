import Cocoa

let time1 = Date() - 13000
let time2 = Date()

let this = time1.timeIntervalSinceReferenceDate - time2.timeIntervalSinceReferenceDate

print(this)
