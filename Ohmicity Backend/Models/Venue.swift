//
//  Venue.swift
//  Ohmicity Backend
//
//  Created by Nate Hedgeman on 6/2/21.
//

import Foundation
import Cocoa

enum BusinessType: String, Codable, Equatable {
    case Resturant
    case Bar
    case Club
    case Outdoors
    case LiveMusic = "Live Music"
    case Family = "Family Friendly"
}

protocol MutatingProtocolForBusinessData {
    //Empty for the purpose adding Hours to a business
}

class BusinessFullData: Codable, Equatable {
    static func == (lhs: BusinessFullData, rhs: BusinessFullData) -> Bool {
        return lhs.venueID == rhs.venueID
    }
    
    var venueID: String = UUID().uuidString
    var name: String
    var address: String
    var phoneNumber: Int
    var hours: Hours
    var logo: String?
    //var shows: [Show] = []
    var ratings: [Rating] = []
    var stars: Double = 0
    var customer: Bool = false
    var ohmPick: Bool = false
    var website: String?
    var businessType: [BusinessType] = []
    
    init(name: String, address: String, phoneNumber: Int, website: String) {
        
        self.name = name
        self.address = address
        self.phoneNumber = phoneNumber
        self.website = website
        self.hours = Hours()
    }
    
    func addBusinessHours(textField: NSTextField, textFieldNumber: Int) {
            
        switch textFieldNumber {
        case 1:
            self.hours.Monday = textField.stringValue
            print("Monday Set")
        case 2:
            self.hours.Tuesday = textField.stringValue
            print("Tuesday Set")
        case 3:
            self.hours.Wednesday = textField.stringValue
            print("Wednesday Set")
        case 4:
            self.hours.Thursday = textField.stringValue
            print("Thursday Set")
        case 5:
            self.hours.Friday = textField.stringValue
            print("Friday Set")
        case 6:
            self.hours.Saturday = textField.stringValue
            print("Saturday Set")
        case 7:
            self.hours.Sunday = textField.stringValue
            print("Sunday Set")
        default:
            return print("No Schedule Set")
        }
    }
    
    func addAndRemoveBusinessType(button: NSButton, genreNumber: Int) {
        switch genreNumber {
        case 1:
            if button.state == .on {
                self.businessType.append(BusinessType.Resturant)
            } else if button.state == .off {
                self.businessType.removeAll(where: {$0 == BusinessType.Resturant})
            }
        case 2:
            if button.state == .on {
                self.businessType.append(BusinessType.Bar)
            } else if button.state == .off {
                self.businessType.removeAll(where: {$0 == BusinessType.Bar})
            }
        case 3:
            if button.state == .on {
                self.businessType.append(BusinessType.Club)
            } else if button.state == .off {
                self.businessType.removeAll(where: {$0 == BusinessType.Club})
            }
        case 4:
            if button.state == .on {
                self.businessType.append(BusinessType.Outdoors)
            } else if button.state == .off {
                self.businessType.removeAll(where: {$0 == BusinessType.Outdoors})
            }
        case 5:
            if button.state == .on {
                self.businessType.append(BusinessType.LiveMusic)
            } else if button.state == .off {
                self.businessType.removeAll(where: {$0 == BusinessType.LiveMusic})
            }
        case 6:
            if button.state == .on {
                self.businessType.append(BusinessType.Family)
            } else if button.state == .off {
                self.businessType.removeAll(where: {$0 == BusinessType.Family})
            }
        default:
            break
        }
    }
}


struct BusinessBasicData: Codable, Equatable, MutatingProtocolForBusinessData {
    var venueID: String
    var name: String
    var logo: String?
    var stars: Double
    //var shows: [Show] //To Query which places has shows today
}

struct Rating: Codable {
    let userID: String
    var stars: Int
    var review: String?
}

struct Hours: Codable, Equatable {
    var Monday: String = " "
    var Tuesday: String = " "
    var Wednesday: String = " "
    var Thursday: String = " "
    var Friday: String = " "
    var Saturday: String = " "
    var Sunday: String = " "
}
