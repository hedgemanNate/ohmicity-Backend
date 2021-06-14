import Cocoa
let daysArray = ["Sun,", "Mon,", "Tues,", "Wed,", "Thurs,", "Fri,", "Sat,", "Sun", "Mon", "Tues", "Wed", "Thurs", "Fri", "Sat"]

let monthArray = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

let dayNumberArray = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31"]

let yearArray = ["2017","2018","2019", "2020", "2021"]

let seperatorArray = ["to", "till", "-"]

let timeExtrasArray = [":", ".", ",",]

let commaArray = [","]



class foo {
    var name: String = "Nate"
    var fame: String = "Not Very"
}

var me = foo()

var array: [foo] = [me]

var ref: foo?

ref = array[0]

ref?.name = "Nathan"

print(array[0].name)
