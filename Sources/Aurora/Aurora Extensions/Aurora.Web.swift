// Aurora framework for Swift
//
// The **Aurora.framework** contains a base for your project.
//
// It has a lot of extensions built-in to make development easier.
//
// - Version: 1.0
// - Copyright: [Wesley de Groot](https://wesleydegroot.nl) ([WDGWV](https://wdgwv.com))\
//  and [Contributors](https://github.com/AuroraFramework/Aurora.swift/graphs/contributors).
//
// Please note: this is a beta version.
// It can contain bugs, please report all bugs to https://github.com/AuroraFramework/Aurora.swift
//
// Thanks for using!
//
// Licence: Needs to be decided.

// MARK: Imports
import Foundation

// MARK: ...
private var auroraFrameworkWebDebug: Bool = false

/// <#Description#>
open class SimpleTimer {/*<--was named Timer, but since swift 3, NSTimer is now Timer*/
    typealias Tick = () -> Void
    var timer: Timer?
    var interval: TimeInterval /*in seconds*/
    var repeats: Bool
    var tick: Tick
    
    /// <#Description#>
    /// - Parameters:
    ///   - interval: <#interval description#>
    ///   - repeats: <#repeats description#>
    ///   - onTick: <#onTick description#>
    init(interval: TimeInterval, repeats: Bool = false, onTick: @escaping Tick) {
        self.interval = interval
        self.repeats = repeats
        self.tick = onTick
    }
    
    /// <#Description#>
    func start() {
        timer = Timer.scheduledTimer(
            timeInterval: interval,
            target: self,
            selector: #selector(update),
            userInfo: nil,
            repeats: true
        )
    }
    
    /// <#Description#>
    func stop() {
        if timer != nil {
            timer!.invalidate()
        }
    }
    
    /**
     * This method must be in the public or scope
     */
    @objc
    func update() {
        tick()
    }
}

public extension Aurora {
    /// <#Description#>
    /// - Parameters:
    ///   - forURL: <#forURL description#>
    ///   - completion: <#completion description#>
    func dataTaskHelper(forURL: URL?, completion: @escaping (String) -> Void) {
        let session = URLSession.shared
        let request = URLRequest.init(
            url: forURL ?? URL.init(string: "")!,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 10
        )
        
        let task = session.dataTask(
            with: request,
            completionHandler: { (data, response, _) -> Void in
                
                self.log("Got response")
                
                guard let data = data else {
                    self.log("Failed to decode data")
                    completion("Error")
                    return
                }
                
                var usedEncoding = String.Encoding.utf8 // Some fallback value
                if let encodingName = response?.textEncodingName {
                    let encoding = CFStringConvertEncodingToNSStringEncoding(
                        CFStringConvertIANACharSetNameToEncoding(encodingName as CFString)
                    )
                    if encoding != UInt(kCFStringEncodingInvalidId) {
                        usedEncoding = String.Encoding(rawValue: encoding)
                    }
                }
                
                DispatchQueue.main.async {
                    if let myString = String(data: data, encoding: usedEncoding) {
                        self.log("Unwrapped and returning")
                        completion(myString)
                    } else {
                        self.log("Failed to use the proper encoding")
                        // ... Error
                        completion("Error")
                    }
                }
        })
        task.resume()
    }
    
    /// <#Description#>
    /// - Parameter url: <#url description#>
    /// - Returns: <#description#>
    func getSiteAsText(url: URL) -> String {
        log("getSiteAsText init(url: \"\(url)\")")
        var returnString: String = ""
        
        self.dataTaskHelper(forURL: url) { (dataTaskString) in
            if self.detailedLogging {
                self.log("Return: \(dataTaskString)")
            }
            returnString = dataTaskString
        }
        
        //        while(returnString==""){}
        
        log("After the datatask = \(returnString)")
        
        //        if (returnString != "Error") {
        //            return returnString
        //        } else {
        do {
            let myHTMLString = try NSString(
                contentsOf: url,
                encoding: String.Encoding.utf8.rawValue
            )
            
            return myHTMLString as String
        } catch _ {
            do {
                let myHTMLString = try NSString(
                    contentsOf: url,
                    encoding: String.Encoding.utf16.rawValue
                )
                
                return myHTMLString as String
            } catch _ {
                do {
                    let myHTMLString = try NSString(
                        contentsOf: url,
                        encoding: String.Encoding.isoLatin1.rawValue
                    )
                    
                    return myHTMLString as String
                } catch _ {
                    do {
                        let myHTMLString = try NSString(
                            contentsOf: url,
                            encoding: String.Encoding.isoLatin2.rawValue
                        )
                        
                        return myHTMLString as String
                    } catch {
                        do {
                            let myHTMLString = try NSString(
                                contentsOf: url,
                                encoding: String.Encoding.utf32.rawValue
                            )
                            
                            return myHTMLString as String
                        } catch let error {
                            if returnString != "" {
                                return returnString
                            }
                            
                            return "Decoding Error: \(error.localizedDescription)"
                        }
                    }
                }
            }
        }
        //        }
    }
    /**
     Get data as (plain) text
     
     - Parameter url: the URL of the file
     
     - Returns: the contents of the file
     */
    func getDataAsText(_ url: String, _ post: [String: String]? = ["nothing": "send"]) -> String {
        log("Init.")
        if let myURL = URL(string: url) {
            if post == ["nothing": "send"] {
                log("get site as text")
                return getSiteAsText(url: myURL)
            } else {
                var waiting = true
                var data = ""
                var request = URLRequest(url: myURL)
                request.httpMethod = "POST"
                request.setValue("application/x-www-form-urlencoded",
                                 forHTTPHeaderField: "Content-Type")
                
                var httpBody = ""
                var idx = 0
                for (key, val) in post! {
                    if idx == 0 {
                        httpBody.append(contentsOf:
                            "\(key)=\(val.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)")
                    } else {
                        httpBody.append(contentsOf:
                            "&\(key)=\(val.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)")
                    }
                    idx += 1
                }
                request.httpBody = httpBody.data(using: .utf8)
                
                let session = URLSession.shared
                session.dataTask(with: request) { (sitedata, _, _) in
                    if let sitedata = sitedata {
                        data = String(data: sitedata, encoding: .utf8)!
                        waiting = false
                    } else {
                        data = "Error"
                        waiting = false
                    }
                    
                }.resume()
                
                while waiting {
                    Aurora.shared.log("Waiting...")
                }
                
                return data
            }
        } else {
            return "Error: \(url) doesn't appear to be a URL"
        }
    }
    
    /**
     Get data as Data
     
     - Parameter url: the URL of the file
     
     - Returns: the contents of the file
     */
    func getDataAsData(
        _ url: String,
        _ post: [String: String]? = ["nothing": "send"]
    ) -> Data {
        if let myURL = URL(string: url) {
            if post == ["nothing": "send"] {
                return getSiteAsText(url: myURL).data(using: .utf8)!
            } else {
                var waiting = true
                var data = "".data(using: .utf8)
                var request = URLRequest(url: myURL)
                request.httpMethod = "POST"
                request.setValue(
                    "application/x-www-form-urlencoded",
                    forHTTPHeaderField: "Content-Type"
                )
                
                var httpBody = ""
                var idx = 0
                for (key, val) in post! {
                    if idx == 0 {
                        httpBody.append(
                            contentsOf:
                            "\(key)=\(val.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
                        )
                    } else {
                        httpBody.append(
                            contentsOf:
                            "&\(key)=\(val.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
                        )
                    }
                    idx += 1
                }
                request.httpBody = httpBody.data(using: .utf8)
                
                let session = URLSession.shared
                session.dataTask(with: request) { (sitedata, _, _) in
                    if let sitedata = sitedata {
                        data = sitedata
                        waiting = false
                    } else {
                        data = "Error".data(using: .utf8)
                        waiting = false
                    }
                    
                }.resume()
                
                while waiting {
                    //                    Aurora.shared.log("Waiting...")
                }
                
                return data!
            }
        } else {
            return "Error: \(url) doesn't  URL".data(using: String.Encoding.utf8)!
        }
    }
    
    /**
     Remove all html elements from a string
     
     - Parameter html: The HTML String
     
     - Returns: the plain HTML String
     */
    func removeHTML(_ html: String) -> String {
        do {
            let regex: NSRegularExpression = try NSRegularExpression(
                pattern: "<.*?>",
                options: NSRegularExpression.Options.caseInsensitive
            )
            let range = NSRange(location: 0, length: html.count)
            let htmlLessString: String = regex.stringByReplacingMatches(
                in: html,
                options: [],
                range: range,
                withTemplate: ""
            )
            return htmlLessString
        } catch {
            Aurora.shared.log("Failed to parse HTML String")
            return html
        }
    }
    
    /**
     Newline to Break (br) [like-php]
     
     - Parameter html: the string
     
     - Returns: the string with <br /> tags
     */
    func nl2br(_ html: String) -> String {
        return html.replacingOccurrences(of: "\n", with: "<br />")
    }
    
    /**
     Break (br) to Newline [like-php (reversed)]
     
     - Parameter html: the html string to convert to a string
     
     - Returns: the string with line-breaks
     */
    func br2nl(_ html: String) -> String {
        return html.replacingOccurrences(of: "<br />", with: "\n") // html 4
            .replacingOccurrences(of: "<br/>", with: "\n") // invalid html
            .replacingOccurrences(of: "<br>", with: "\n") // html <=4
        // should be regex.
        // \<(b|B)(r|R)( )?(\/)?\>
    }
    
    /**
     Set debug
     
     - Parameter debugVal: Debugmode on/off
     */
    func setDebug(_ debugVal: Bool) {
        auroraFrameworkWebDebug = debugVal
    }
}
