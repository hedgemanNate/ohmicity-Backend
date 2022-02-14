import Cocoa

var a = [1,2,3,4,5,6,7,8,9]

for var x in a {
    if x == 3 {
        print("HIT")
        x = x + 3
    }
}

print(a)
