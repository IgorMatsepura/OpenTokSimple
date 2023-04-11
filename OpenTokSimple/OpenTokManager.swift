//
//  OpenTokManager.swift
//  OpenTokSimple
//
//  Created by Igor Matsepura on 11.04.2023.
//

import Foundation
import OpenTok

final class OpenTokManager : NSObject, ObservableObject {


    private let apiKey = "47696441"
    private let sessionId = "2_MX40NzY5NjQ0MX5-MTY4MTIwNTYzMzUyNn5SbzNRMS9ZUmgzM1BobmxhMGdYZytXRG1-fn4"
    private let token = "T1==cGFydG5lcl9pZD00NzY5NjQ0MSZzaWc9NzUzMTFlZDUwMGI4OTIzZjMzNDczMDUxYTk4ZmMxZmIzMGY3NmJmZjpzZXNzaW9uX2lkPTJfTVg0ME56WTVOalEwTVg1LU1UWTRNVEl3TlRZek16VXlObjVTYnpOUk1TOVpVbWd6TTFCb2JteGhNR2RZWnl0WFJHMS1mbjQmY3JlYXRlX3RpbWU9MTY4MTIwNTY0OSZub25jZT0wLjM4NDY0ODM2MTI0MzUzNDMmcm9sZT1wdWJsaXNoZXImZXhwaXJlX3RpbWU9MTY4MTIwOTI1NyZpbml0aWFsX2xheW91dF9jbGFzc19saXN0PQ=="
    
    private lazy var session: OTSession = {
        return OTSession(apiKey: apiKey, sessionId: sessionId, delegate: self)!
    }()
    
    private lazy var publisher: OTPublisher = {
        let settings = OTPublisherSettings()
        settings.name = UIDevice.current.name
        return OTPublisher(delegate: self, settings: settings)!
    }()
    
    private var subscriber: OTSubscriber?
    @Published var pubView: UIView?
    @Published var subView: UIView?
    @Published var error: OTErrorWrapper?
    
    public func setup() {
        doConnect()
    }
    
    private func doConnect() {
        var error: OTError?
        defer {
            processError(error)
        }
        session.connect(withToken: token, error: &error)
    }
    
    private func doPublish() {
        var error: OTError?
        defer {
            processError(error)
        }
        
        session.publish(publisher, error: &error)
        
        if let view = publisher.view {
            DispatchQueue.main.async {
                self.pubView = view
            }
        }
    }
    
    
    private func doSubscribe(_ stream: OTStream) {
        var error: OTError?
        defer {
            processError(error)
        }
        subscriber = OTSubscriber(stream: stream, delegate: self)
        session.subscribe(subscriber!, error: &error)
    }
    
    private func cleanupSubscriber() {
        DispatchQueue.main.async {
            self.subView = nil
        }
    }
    
    
    private func cleanupPublisher() {
        DispatchQueue.main.async {
            self.pubView = nil
        }
    }
    
    private func processError(_ error: OTError?) {
        if let err = error {
            DispatchQueue.main.async {
                let message = "OpenTok error: \(String(describing: error?.localizedDescription))"
                self.error = OTErrorWrapper(error: err, message: message)
            }
        }
    }
}


extension OpenTokManager: OTSessionDelegate {
  
    func sessionDidConnect(_ session: OTSession) {
            print("Session connected")
            doPublish()
        }
        
        func sessionDidDisconnect(_ session: OTSession) {
            print("Session disconnected")
        }
        
        func session(_ session: OTSession, didFailWithError error: OTError) {
            print("session Failed to connect: \(error.localizedDescription)")
        }
        
        func session(_ session: OTSession, streamCreated stream: OTStream) {
            print("Session streamCreated: \(stream.streamId)")
            doSubscribe(stream)
        }
        
        func session(_ session: OTSession, streamDestroyed stream: OTStream) {
            print("Session streamDestroyed: \(stream.streamId)")
            if let subStream = subscriber?.stream, subStream.streamId == stream.streamId {
                cleanupSubscriber()
            }
        }
    
    
}


extension OpenTokManager: OTPublisherDelegate {
    func publisher(_ publisher: OTPublisherKit, streamCreated stream: OTStream) {
        print("Publishing")
    }
    
    func publisher(_ publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
        cleanupPublisher()
        if let subStream = subscriber?.stream, subStream.streamId == stream.streamId {
            cleanupSubscriber()
        }
    }
    
    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        print("Publisher failed: \(error.localizedDescription)")
    }
}



extension OpenTokManager: OTSubscriberDelegate {
    
    func subscriberDidConnect(toStream subscriberKit: OTSubscriberKit) {
        if let view = subscriber?.view {
            DispatchQueue.main.async {
                self.subView = view
            }
        }
    }
    
    func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print("Subscriber failed: \(error.localizedDescription)")
    }
}
