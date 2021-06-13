import Cocoa
let daysArray = ["Sun,", "Mon,", "Tues,", "Wed,", "Thurs,", "Fri,", "Sat,", "Sun", "Mon", "Tues", "Wed", "Thurs", "Fri", "Sat"]

let monthArray = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

let dayNumberArray = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31"]

let yearArray = ["2017","2018","2019", "2020", "2021"]

let seperatorArray = ["to", "till", "-"]

let timeExtrasArray = [":", ".", ",",]

let commaArray = [","]

func fixShowTime(showTime: String) {
    var date = showTime
    var modifiedDate = date.components(separatedBy: " ")

    let hasDay: Bool = !Set(modifiedDate).isDisjoint(with: Set(daysArray))
    let hasYear: Bool = !Set(modifiedDate).isDisjoint(with: Set(yearArray))
    let hasSeperator: Bool = !Set(modifiedDate).isDisjoint(with: Set(seperatorArray))

    if hasDay {
        let set = Set(modifiedDate).intersection(daysArray)
        let setResult = Array(set)
        modifiedDate.removeAll(where: {$0 == setResult[0]})
        date = modifiedDate.joined(separator: " ")
    }

    if hasYear {
        let set = Set(modifiedDate).intersection(yearArray)
        let setResult = Array(set)
        modifiedDate.removeAll(where: {$0 == setResult[0]})
        date = modifiedDate.joined(separator: " ")
    }

    if hasSeperator {
        let set = Set(modifiedDate).intersection(seperatorArray)
        let setResult = Array(set)
        modifiedDate.removeAll(where: {$0 == setResult[0]})
        date = modifiedDate.joined(separator: " ")
    }

    if !date.contains(",") {
        modifiedDate[1] = "\(modifiedDate[1] + ",")"
        date = modifiedDate.joined(separator: " ")
    }

    //These Two To Make Date & Time
    let simiCleanDate = date.replacingOccurrences(of: "-", with: " ")
    let simiCleanDateArray = simiCleanDate.components(separatedBy: " ")

    var almostDate = simiCleanDateArray.prefix(2)



    almostDate.append("2021")

    let cleanDate = almostDate.joined(separator: " ")

    let almostTime = simiCleanDateArray[2]
    var simiCleanTime = almostTime.replacingOccurrences(of: "[\n:pmPMAa]", with: "", options: .regularExpression, range: nil)

    let timeNumber = Int(simiCleanTime)
    var cleanTime = ""

    switch timeNumber! {
    case 1...12:
        cleanTime = "\(timeNumber!)pm"
    case 100...1200:
        simiCleanTime.removeLast(2)
        cleanTime = "\(simiCleanTime)pm"
    default:
        break
    }

    print("\(cleanDate) \(cleanTime)")
}

//fixShowTime(showTime: "Sun, July 25\n2-6pm")


var date = "Sun, July 25 6pm-8am"
var date2 = date.replacingOccurrences(of: "\n", with: " ")
var modifiedDate = date2.components(separatedBy: " ")

let hasDay: Bool = !Set(modifiedDate).isDisjoint(with: Set(daysArray))
let hasYear: Bool = !Set(modifiedDate).isDisjoint(with: Set(yearArray))
let hasSeperator: Bool = !Set(modifiedDate).isDisjoint(with: Set(seperatorArray))

if hasDay {
    let set = Set(modifiedDate).intersection(daysArray)
    let setResult = Array(set)
    modifiedDate.removeAll(where: {$0 == setResult[0]})
    date = modifiedDate.joined(separator: " ")
}

if hasYear {
    let set = Set(modifiedDate).intersection(yearArray)
    let setResult = Array(set)
    modifiedDate.removeAll(where: {$0 == setResult[0]})
    date = modifiedDate.joined(separator: " ")
}

if hasSeperator {
    let set = Set(modifiedDate).intersection(seperatorArray)
    let setResult = Array(set)
    modifiedDate.removeAll(where: {$0 == setResult[0]})
    date = modifiedDate.joined(separator: " ")
}

if !date.contains(",") {
    modifiedDate[1] = "\(modifiedDate[1] + ",")"
    date = modifiedDate.joined(separator: " ")
}

//These Two To Make Date & Time
let simiCleanDate = date.replacingOccurrences(of: "-", with: " ")
let simiCleanDateArray = simiCleanDate.components(separatedBy: " ")

var almostDate = simiCleanDateArray.prefix(2)



almostDate.append("2021")

let cleanDate = almostDate.joined(separator: " ")
var cleanTime = "No Time"
simiCleanDateArray[1]

if simiCleanDateArray.count >= 3 {
    let almostTime = simiCleanDateArray[2]
    var simiCleanTime = almostTime.replacingOccurrences(of: "[\n:pmPMAa]", with: "", options: .regularExpression, range: nil)

    let timeNumber = Int(simiCleanTime)
    

    switch timeNumber! {
    case 1...12:
        cleanTime = "\(timeNumber!)pm"
    case 100...1200:
        simiCleanTime.removeLast(2)
        cleanTime = "\(simiCleanTime)pm"
    default:
        break
    }
}



print("\(cleanDate) \(cleanTime)")

