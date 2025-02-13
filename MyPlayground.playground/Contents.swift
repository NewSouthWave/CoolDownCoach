import UIKit

var time1 = Date()
var time2 = Date(timeIntervalSinceNow: 432523)

print(time1)
print(time2)
print(Int(time2.timeIntervalSince(time1)))
