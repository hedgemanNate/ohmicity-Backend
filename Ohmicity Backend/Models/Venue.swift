//
//  Venue.swift
//  Ohmicity Backend
//
//  Created by Nate Hedgeman on 6/2/21.
//

import Foundation
import Cocoa
import FirebaseFirestore

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

struct BusinessFullData: Codable, Equatable {
    static func == (lhs: BusinessFullData, rhs: BusinessFullData) -> Bool {
        return lhs.venueID == rhs.venueID
    }
    
    var venueID: String?
    var name: String?
    var address: String?
    var phoneNumber: Int?
    var hours: Hours?
    var logo: Data?
    var shows: [Show] = []
    var ratings: [Rating] = []
    var stars: Int = 0
    var customer: Bool = false
    var ohmPick: Bool = false
    var website: String?
    var businessType: [BusinessType] = []
    
    init(name: String, address: String, phoneNumber: Int, website: String) {
        
        let venueID = Firestore.firestore().collection(FireStoreReferenceManager.businessFullDataPath.className).document().documentID
        
        self.venueID = venueID
        self.name = name
        self.address = address
        self.phoneNumber = phoneNumber
        self.website = website
    }

    
    private init?(venueID: String, dictionary: [String: Any]) {
        guard let venueID = dictionary["venueID"] as? String,
              let name = dictionary["name"] as? String,
              let address = dictionary["address"] as? String,
              let phoneNumber = dictionary["phoneNumber"] as? Int,
              let logo = dictionary["logo"] as? Data,
              let hours = dictionary["hours"] as? Hours,
              let shows = dictionary["shows"] as? [Show],
              let ratings = dictionary["ratings"] as? [Rating],
              let customer = dictionary["customer"] as? Bool,
              let ohmPick = dictionary["ohmPick"] as? Bool,
              let website = dictionary["website"] as? String,
              let businessType = dictionary["businessType"] as? [BusinessType] else {return}
        
        self.venueID = venueID
        self.name = name
        self.address = address
        self.phoneNumber = phoneNumber
        self.logo = logo
        self.hours = hours
        self.shows = shows
        self.ratings = ratings
        self.customer = customer
        self.ohmPick = ohmPick
        self.website = website
        self.businessType = businessType
    }
    
    mutating func addBusinessHours(textField: NSTextField, textFieldNumber: Int) {
            
        switch textFieldNumber {
        case 1:
            self.hours?.monday = textField.stringValue
            print("Monday Set")
        case 2:
            self.hours?.tuesday = textField.stringValue
            print("Tuesday Set")
        case 3:
            self.hours?.wednesday = textField.stringValue
            print("Wednesday Set")
        case 4:
            self.hours?.thursday = textField.stringValue
            print("Thursday Set")
        case 5:
            self.hours?.friday = textField.stringValue
            print("Friday Set")
        case 6:
            self.hours?.saturday = textField.stringValue
            print("Saturday Set")
        case 7:
            self.hours?.sunday = textField.stringValue
            print("Sunday Set")
        default:
            return print("No Schedule Set")
        }
    }
    
    mutating func addAndRemoveBusinessType(button: NSButton, typeNumber: Int) {
        //NOTES: Used with a loop function and number counter to check the state (on/off) of all buttons in the array. The loop adds the next button into this function along with the Business Type current number on the counter. Which decides which Business Type is added/removed to/from the Businesses BusinessType Array.
        switch typeNumber {
        case 1:
            if button.state == .on {
                businessType.append(BusinessType.Resturant)
            } else if button.state == .off {
                businessType.removeAll(where: {$0 == BusinessType.Resturant})
            }
        case 2:
            if button.state == .on {
                businessType.append(BusinessType.Bar)
            } else if button.state == .off {
                businessType.removeAll(where: {$0 == BusinessType.Bar})
            }
        case 3:
            if button.state == .on {
                businessType.append(BusinessType.Club)
            } else if button.state == .off {
                businessType.removeAll(where: {$0 == BusinessType.Club})
            }
        case 4:
            if button.state == .on {
                businessType.append(BusinessType.Outdoors)
            } else if button.state == .off {
                businessType.removeAll(where: {$0 == BusinessType.Outdoors})
            }
        case 5:
            if button.state == .on {
                businessType.append(BusinessType.LiveMusic)
            } else if button.state == .off {
                businessType.removeAll(where: {$0 == BusinessType.LiveMusic})
            }
        case 6:
            if button.state == .on {
                businessType.append(BusinessType.Family)
            } else if button.state == .off {
                businessType.removeAll(where: {$0 == BusinessType.Family})
            }
        default:
            break
        }
    }
}


struct BusinessBasicData: Codable, Equatable, MutatingProtocolForBusinessData {
    var venueID: String
    var name: String
    var logo: Data?
    var stars: Int
    //var shows: [Show] //To Query which places has shows today
}

struct Rating: Codable {
    var ratingID: String
    let userID: String
    var stars: Int
    var review: String?
    
    init(ratingID: String, userID: String, stars: Int, review: String) {
        
        let ratingID = Firestore.firestore().collection("ratingData").document().documentID
        
        self.ratingID = ratingID
        self.userID = userID
        self.stars = stars
        self.review = review
    }
    
    private init?(ratingID: String, dictionary: [String : Any]) {
        guard let userID = dictionary["userID"] as? String,
              let stars = dictionary["stars"] as?  Int,
              let review = dictionary["review"] as? String else {return nil}
        
        self.ratingID = ratingID
        self.userID = userID
        self.stars = stars
        self.review = review
    }
}

struct Hours: Codable, Equatable {
    var monday: String = " "
    var tuesday: String = " "
    var wednesday: String = " "
    var thursday: String = " "
    var friday: String = " "
    var saturday: String = " "
    var sunday: String = " "
    
    init(mon: String, tues: String, wed: String, thur: String, fri: String, sat: String, sun: String) {
        self.monday = mon
        self.tuesday = tues
        self.wednesday = wed
        self.thursday = thur
        self.friday = fri
        self.saturday = sat
        self.sunday = sun
    }
    
    private init?(dictionary: [String : Any]) {
        guard let mon = dictionary["monday"] as? String,
              let tues = dictionary["tuesday"] as? String,
              let wed = dictionary["wednesday"] as? String,
              let thur = dictionary["thursday"] as? String,
              let fri = dictionary["friday"] as? String,
              let sat = dictionary["saturday"] as? String,
              let sun = dictionary["sunday"] as? String else {return nil}
        
        self.monday = mon
        self.tuesday = tues
        self.wednesday = wed
        self.thursday = thur
        self.friday = fri
        self.saturday = sat
        self.sunday = sun
    }
}
