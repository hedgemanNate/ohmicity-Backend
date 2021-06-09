import Cocoa

var str = "Hello, playground"


class Foo {
    var name = "foo"
    var age = 6
}

struct miniFoo {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

let senior = Foo()
let junior = miniFoo(name: senior.name)

print(junior.name)

senior.name = "nate"

print(junior.name)
