import Cocoa

let this = "this"
let that = "That"

let result = this.caseInsensitiveCompare(that)

if result == .orderedDescending {
    print("true")
} else {
    print("false")
}





