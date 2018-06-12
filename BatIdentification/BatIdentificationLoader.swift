//
//  BatIdentificationLoader.swift
//  BatIdentification
//
//  Created by Richard Beattie on 6/5/18.
//  Copyright © 2018 Richard Beattie. All rights reserved.
//

import Foundation
import OAuth2

extension Data {
    
    mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
        if let data = string.data(using: encoding) {
            append(data)
        }
    }
}

enum RequestErrors: Error{
    
    case RuntimeError(String)
    case ConnectionError
    case ResponseError
    
    
}

//Handles authorization and requests with the BatIdentification service

class BatIdentificationLoader: OAuth2DataLoader {
    
    static let shared = BatIdentificationLoader()
    
    let baseURL = URL(string: NSLocalizedString("api.url", tableName: "Common", comment: ""))!
    
    private init(){
        
        let oauth = OAuth2CodeGrant(settings: [
            "client_id": "8KCVSRHGKPRS5R9Y6OYP41MDIB1KM1O9",
            "client_secret": "813a546fd59a4220936d20f14543a38a8adc84fa6abd19d8ea0106569604a4d7459bc47b0e25775f",
            "authorize_uri": baseURL.absoluteString + "authorize.php",
            "token_uri": baseURL.absoluteString + "token.php",
            "redirect_uris": ["batidentification://oauth/callback"],
            "verbose": true,
        ])
        
        super.init(oauth2: oauth)
        
    }
    
    public func getToken(completionHandler: @escaping (_ status: Bool) -> ()){
    
        makeRequest(appendingPath: "verifyToken.php") { result in
            
            var dictResponse: OAuth2JSON?
            
            do{
                
                dictResponse = try result()
                
            }catch _{
                
                completionHandler(false)
                
            }
            
            guard let dict = dictResponse else{
                completionHandler(false)
                return
            }
            
            if (dict["success"] as? Bool) != nil{
                completionHandler(true)
            }else{
                completionHandler(false)
            }
            
        }
        
    }
    
    public func getCallInformation(completionHandler: @escaping (() throws -> (BatCall?)) -> ()){
        
        makeRequest(appendingPath: "call.php") { result in
            
            var dictResponse: OAuth2JSON?
            
            do{
                
                dictResponse = try result()
                
            }catch let error{
                
                completionHandler({throw error})
                
            }
            
            guard let dict = dictResponse else{
                completionHandler({throw RequestErrors.ResponseError})
                return
            }
            
            //Check to see if error is present in the dict
            
            if dict["error"] != nil{
                completionHandler({throw RequestErrors.RuntimeError(dict["error_description"] as! String)})
                return
            }
            
            //Extract the information and create BatCall instance
            
            let unwrappedCallURL = NSURL(string: dict["call_url"] as! String)
            
            guard let callURL = unwrappedCallURL else{
                completionHandler({throw RequestErrors.ResponseError})
                return
            }
            
            let call = BatCall(url: callURL, identifer: dict["identifier"] as! String)
            
            completionHandler({return call})
            
        }
        
    }
    
    public func uploadFiles(spec: String, time_expansion: String, analysing_id: String){
        
        let parameters = ["analysing_id": analysing_id]
        let files = ["spectrogram": spec, "time_expansion": time_expansion]
        let boundary = "Boundary-\(UUID().uuidString)"
        
        var req = oauth2.request(forURL: baseURL.appendingPathComponent("analyzed.php"))
        req.httpMethod = "POST"
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        do{
            
            let body = try createBody(with: parameters, files: files, boundary: boundary)
            req.httpBody = body
            print("All ok")
            
        }catch let error{
            
            //Handle error
            print("Something went wrong when creating the body")
            print(error)
            return
            
        }
        
        let loader = OAuth2DataLoader(oauth2: oauth2)
        loader.perform(request: req){ response in
            
            do{
                
                let dict = try response.responseJSON()
                DispatchQueue.main.async{
                    
                    print(dict)
                    
                }
                
            }catch let error{
                
                DispatchQueue.main.async {
                    print(error)
                }
                
            }
            
        }
        
    }
    
    // For the callback we specifiy "() throws -> (OAuth2JSON?)" as the argument. This means that when the callback is implemented the returned value will be a function that can either throw or return a OAuth2JSON object. We just need to run it to see.
    
    func makeRequest(appendingPath: String, completionHandler: @escaping (() throws -> (OAuth2JSON?)) -> ()){
        
        let req = oauth2.request(forURL: baseURL.appendingPathComponent(appendingPath))
        
        let loader = OAuth2DataLoader(oauth2: oauth2)
        loader.perform(request: req) { response in
            do{
                let dict = try response.responseJSON()
                DispatchQueue.main.async {
                    completionHandler({return dict})
                }
            }catch _{
                DispatchQueue.main.async{
                    completionHandler({throw RequestErrors.ConnectionError})
                }
            }
        }
    }
    
    //Turns two arrays of name : values into a correctly formated post body
    
    private func createBody(with parameters: [String: String]?, files: [String: String]?, boundary: String) throws -> Data{
        
        var body = Data()
        
        if parameters != nil{
            for (key, value) in parameters! {
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.append("\(value)\r\n")
            }
        }
        
        if(files != nil){
            for (key, value) in files!{
                
                let url = URL(fileURLWithPath: value)
                let filename = url.lastPathComponent
                let data = try Data(contentsOf: url)
                let mimetype = mimeType(for: value)
                
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(filename)\"\r\n")
                body.append("Content-Type: \(mimetype)\r\n\r\n")
                body.append(data)
                body.append("\r\n")
                
            }
        }
        
        body.append("--\(boundary)\r\n")
        return body
        
    }
    
    // Returns the mimetype of a file
    
    private func mimeType(for path: String) -> String{
        
        let url = URL(fileURLWithPath: path)
        let pathExtension = url.pathExtension
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimeType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue(){
                return mimeType as String
            }
        }
        
        return "application/octet-stream"
        
    }
    
}
