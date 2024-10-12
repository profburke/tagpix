//
//  TagManager.swift
//  TagPix
//
//  Created by Matthew Burke on 10/11/24.
//

import CoreNFC
import Foundation

enum TagError: Error {
    case general
}

class TagManager: NSObject, NFCNDEFReaderSessionDelegate {
    private var readerSession: NFCNDEFReaderSession?
    private var data: Data?

    // TODO: fill in the following method
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {}
    // Following method is deliberately implemented, but empty
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {}

    func write(data: Data) {
        guard NFCNDEFReaderSession.readingAvailable else {
            print("This device does not support tag scanning/writing.")
            return
        }

        self.data = data

        readerSession = NFCNDEFReaderSession(delegate: self,
                                             queue: nil,
                                             invalidateAfterFirstRead: true)
        readerSession?.alertMessage = "Get closer to the tag to write!"
        readerSession?.begin()
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [any NFCNDEFTag]) {
        if tags.count > 1 {
            let retryInterval = DispatchTimeInterval.milliseconds(500)
            session.alertMessage = "Detected more than 1 tag. Please remove all tags and try again."

            // backing off Swift 6/strict concurrency checks due to
            // this ...
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                session.restartPolling()
            })
            return
        }

        guard let tag = tags.first else {
            print("Not able to get first tag.")
            session.alertMessage = "Not able to get tag, please try again."
            return
        }

        // and this ...
        // https://forums.swift.org/t/how-do-i-solve-task-isolated-value-passed-as-strongly-transferred-parameter-warning/73870/2
        Task {
            do {
                try await session.connect(to: tag)
                let (status, _) = try await tag.queryNDEFStatus()

                switch status {
                case .notSupported:
                    session.alertMessage = "Tag is not NDEF compliant."
                case .readOnly:
                    session.alertMessage = "Tag is read-only."
                case .readWrite:
                    guard let data else {
                        print("should there be an error message here?")
                        return
                    }

                    let message = try createNDEFMessage(data: data)
                    try await tag.writeNDEF(message)

                    // callback?()

                @unknown default:
                    session.alertMessage = "Unknown NDEF tag status."
                }

                session.invalidate()
            } catch (let error) {
                print("Failed with error: \(error.localizedDescription)")
                session.alertMessage = "Failed to write to tag."
                session.invalidate()
            }
        }
    }

    enum NFCError: Error {
        case recordCreation
    }

    private func createNDEFMessage(data: Data) throws -> NFCNDEFMessage {
        guard let type = "application/octet-stream".data(using: .utf8) else {
            throw NFCError.recordCreation
        }

        let payload = NFCNDEFPayload(format: .media,
                                     type: type,
                                     identifier: Data(),
                                     payload: data,
                                     chunkSize: 0)

        return NFCNDEFMessage(records: [payload])

    }
}
