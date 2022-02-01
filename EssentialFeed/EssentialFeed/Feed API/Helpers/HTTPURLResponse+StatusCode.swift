//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeed
//
//  Created by MK on 01/02/22.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }
    
    var isOK: Bool {
        statusCode == HTTPURLResponse.OK_200
    }
}
