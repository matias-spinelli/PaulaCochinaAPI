//
//  AuthPayload.swift
//  PaulaCochinaAPI
//
//  Created by Matías Spinelli on 11/09/2025.
//

import JWT

struct AuthPayload: JWTPayload {
    var uid: String
    var email: String
    var exp: ExpirationClaim

    func verify(using signer: JWTSigner) throws {
        try exp.verifyNotExpired()
    }
}
