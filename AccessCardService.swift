import UIKit
import SwiftProtobuf

internal class AccessCardService {
    
    static func service() -> AccessCardService {
        return AccessCardService()
    }
    
    init() {}
    
    func fetchAccessCard(_ aid: String, completion: @escaping (_ card: DoorCardInfo?, _ error: Error?)-> Void ) {
        var builder = QueryDoorCardRequest()
        builder.aid = aid
        builder.cplc = GreatBridge.cplc
        builder.deviceInfo = HTTPParameter.deeviceInfo()
        var data: Data
        do {
            data = try builder.serializedData()
        } catch let error {
            completion(nil, error);
            return
        }
        let parameters = ["req": data.base64EncodedString(), "cplc": GreatBridge.cplc]
        NPHTTPClient.client().rpcpost("api/%@/doorCard/query/byAid", host:NPAuthHost(), parameters: parameters) { (data, error) in
            if let error = error {
                completion(nil, error);
                return
            }
            
            do {
                let response = try QueryDoorCardInfoResponse(serializedData: data!)
                print("doorCard/update \(response.result) desc: \(response.errorDesc)")
                if response.result != NPRPCResultOk {
                    completion(nil, OakError.serverError(code: Int(response.result), localizedDescription: response.errorDesc))
                    return
                }

                if response.cardInfoList.count == 0 {
                    completion(nil, OakError.serverError(code: Int(response.result), localizedDescription: "card count is 0."))
                    return
                }
                completion(response.cardInfoList.first, nil);
                
            } catch let error {
                completion(nil, error);
            }
        }
    }
    
    func fetchAccessCards(_ completion: @escaping (_ cards: [DoorCardInfo]?, _ error: OakError?)-> Void ) {
        var data: Data
        do {
            data = try HTTPParameter.deeviceInfo().serializedData()
        } catch {
            completion(nil, OakError.protocolbufferError);
            return
        }
        let parameters = ["req": data.base64EncodedString(), "cplc": GreatBridge.cplc]
        NPHTTPClient.client().rpcget("api/%@/doorCard/list", host:NPAuthHost(), parameters: parameters) { (data, error) in
            if let _ = error {
                completion(nil, OakError.httpError);
                return
            }
            
            do {
                let response = try QueryDoorCardInfoResponse(serializedData: data!);
                print("doorCard/update \(response.result) desc: \(response.errorDesc)")
                if response.result != NPRPCResultOk {
                    completion(nil, OakError.serverError(code: Int(response.result), localizedDescription: response.errorDesc));
                    return
                }
                completion(response.cardInfoList, nil);
            } catch {
                completion(nil, OakError.protocolbufferError);
            }
        }
    }
    
    func updateAccessCard(_ card: DoorCardInfo, completion: @escaping (Error?)-> Void ) {
        var builder = UpdateDoorCardRequest()
        builder.cplc = GreatBridge.cplc
        builder.cardInfo.append(card)
        builder.productID = card.productID
        var data: Data
        do {
            data = try builder.serializedData()
        } catch let error {
            completion(error);
            return
        }

        NPHTTPClient.client().rpcpost("api/%@/doorCard/update", host:NPAuthHost(), parameters: ["req": data.base64EncodedString()]) { (data, error) in
            if let error = error {
                completion(error.asOakError);
                return
            }
            
            do {
                let response = try CommonResponse(serializedData: data!);
                 if response.result != NPRPCResultOk {
                    completion(OakError.serverError(code: Int(response.result), localizedDescription: response.errorDesc));
                    return
                }
            } catch let error {
                completion(error);
            }
            completion(nil);
        }
    }
}
