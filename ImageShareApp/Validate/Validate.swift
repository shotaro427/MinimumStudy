//
//  Validate.swift
//  ImageShareApp
//
//  Created by 田内　翔太郎 on 2019/08/25.
//  Copyright © 2019 田内　翔太郎. All rights reserved.
//


//
///**
// Validation rule for userId.
// */
//public struct ValidationRuleUserId: ValidationRule {
//    public typealias InputType = String
//    public var error: Error
//    public let lengthRule: ValidationRuleLength
//    public let patternRule: ValidationRulePattern
//    public init(error: Error) {
//        self.error = error
//        self.lengthRule = ValidationRuleLength(min: 0, max: 16, error: self.error as! ValidationError)
//        self.patternRule = ValidationRulePattern(pattern: CharacterTypeValidationPattern.alphaNumeric, error: self.error)
//    }
//    /**
//
//     Validates the input.
//
//     - Parameters:
//     - input: Input to validate.
//
//     - Returns:
//     true: valid, false: inValid
//
//     */
//    public func validate(input: String?) -> Bool {
//        return self.lengthRule.validate(input: input) && self.patternRule.validate(input: input)
//    }
//}
