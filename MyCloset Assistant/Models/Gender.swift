//
//  Gender.swift
//  StyleSense Assistant
//
//  Created by Michael Obi on 4/3/24.
//

import Foundation

enum Gender: Encodable, Decodable, Equatable {

  case female
  case male
  case other

}

extension Gender: CustomStringConvertible {

  var description: String {
    switch self {
    case .female:
      return "Female"
    case .male:
      return "Male"
    case .other:
      return "Other"
    }
  }

}
