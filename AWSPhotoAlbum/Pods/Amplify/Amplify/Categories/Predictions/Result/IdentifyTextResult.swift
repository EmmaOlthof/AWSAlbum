//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

public struct IdentifyTextResult: IdentifyResult {
    public let fullText: String?
    public let words: [IdentifiedWord]?
    public let rawLineText: [String]?
    public let identifiedLines: [IdentifiedLine]?

    public init(fullText: String?,
                words: [IdentifiedWord]?,
                rawLineText: [String]?,
                identifiedLines: [IdentifiedLine]?) {
        self.fullText = fullText
        self.words = words
        self.rawLineText = rawLineText
        self.identifiedLines = identifiedLines
    }
}
