/**@file
* @brief Swift-HTML-Parser
* @author _tid_
* Edited by Jonathan Jungck and Anthony Minardo.
*/
import Foundation

func ConvXmlCharToString(str: UnsafePointer<xmlChar>) -> String! {
    if str != nil {
        return String.fromCString(UnsafeMutablePointer<CChar>(str))
    }
    return ""
}

/**
* HTMLParser
*/
public class HTMLParser {
    private var _doc     : htmlDocPtr = nil
    private var rootNode : HTMLNode?
    public var htmlString : String = ""
    
    /**
    * HTML tag
    */
    public var html : HTMLNode? {
        return rootNode?.findChildTag("html")
    }
    
    /**
    * HEAD tag
    */
    public var head : HTMLNode? {
        return rootNode?.findChildTag("head")
    }
    
    /**
    * BODY tag
    */
    public var body : HTMLNode? {
        return rootNode?.findChildTag("body")
    }
    
    /**
    * @param[in] html  HTML文字列
    * @param[in] error エラーがあれば返します
    */
    public init(html: String, inout error: NSError?) {
        if html.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            self.htmlString = html
            let cfenc : CFStringEncoding = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)
            let cfencstr : CFStringRef   = CFStringConvertEncodingToIANACharSetName(cfenc)
            
            let cur : [CChar]? = html.cStringUsingEncoding(NSUTF8StringEncoding)
            let url : String = ""
            let enc = CFStringGetCStringPtr(cfencstr, 0)
            let optionHtml : CInt = 1
            
            if let ucur = cur {
                _doc = htmlReadDoc(UnsafePointer<CUnsignedChar>(ucur), url, enc, optionHtml)
                rootNode  = HTMLNode(doc: _doc)
            } else {
                error = NSError(domain: "HTMLParserdomain", code: 1, userInfo: nil)
            }
        } else {
            error = NSError(domain: "HTMLParserdomain", code: 1, userInfo: nil)
        }
    }
    
    public init(html: String, encoding : UInt, inout error: NSError?) {
        if html.lengthOfBytesUsingEncoding(encoding) > 0 {
            self.htmlString = html
            let cfenc : CFStringEncoding = CFStringConvertNSStringEncodingToEncoding(encoding)
            let cfencstr : CFStringRef   = CFStringConvertEncodingToIANACharSetName(cfenc)
            
            let cur : [CChar]? = html.cStringUsingEncoding(encoding)
            let url : String = ""
            let enc = CFStringGetCStringPtr(cfencstr, 0)
            let optionHtml : CInt = 1
            
            if let ucur = cur {
                _doc = htmlReadDoc(UnsafePointer<CUnsignedChar>(ucur), url, enc, optionHtml)
                rootNode  = HTMLNode(doc: _doc)
            } else {
                error = NSError(domain: "HTMLParserdomain", code: 1, userInfo: nil)
            }
        } else {
            error = NSError(domain: "HTMLParserdomain", code: 1, userInfo: nil)
        }
    }
    
    deinit {
        xmlFreeDoc(_doc)
    }
}
