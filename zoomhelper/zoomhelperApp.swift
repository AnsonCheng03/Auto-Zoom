//
//  zoomhelperApp.swift
//  zoomhelper
//
//  Created by Anson Cheng on 3/2/2022.
//

import SwiftUI
import Foundation

class FileDownloader {

    static func loadFileSync(url: URL, completion: @escaping (String?, Error?) -> Void)
    {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)

        if FileManager().fileExists(atPath: destinationUrl.path)
        {
            print("File already exists [\(destinationUrl.path)]")
            completion(destinationUrl.path, nil)
        }
        else if let dataFromURL = NSData(contentsOf: url)
        {
            if dataFromURL.write(to: destinationUrl, atomically: true)
            {
                print("file saved [\(destinationUrl.path)]")
                completion(destinationUrl.path, nil)
            }
            else
            {
                print("error saving file")
                let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
                completion(destinationUrl.path, error)
            }
        }
        else
        {
            let error = NSError(domain:"Error downloading file", code:1002, userInfo:nil)
            completion(destinationUrl.path, error)
        }
    }

    static func loadFileAsync(url: URL, completion: @escaping (String?, Error?) -> Void)
    {
        let documentsUrl =  FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!

        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)
        
        if FileManager().fileExists(atPath: destinationUrl.path)
        {
            print(shell("rm -f \(destinationUrl.path)"))
            //completion(destinationUrl.path, nil)
        }

            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let task = session.dataTask(with: request, completionHandler:
            {
                data, response, error in
                if error == nil
                {
                    if let response = response as? HTTPURLResponse
                    {
                        if response.statusCode == 200
                        {
                            if let data = data
                            {
                                if let _ = try? data.write(to: destinationUrl, options: Data.WritingOptions.atomic)
                                {
                                    completion(destinationUrl.path, error)
                                }
                                else
                                {
                                    completion(destinationUrl.path, error)
                                }
                            }
                            else
                            {
                                completion(destinationUrl.path, error)
                            }
                        }
                    }
                }
                else
                {
                    completion(destinationUrl.path, error)
                }
            })
            task.resume()
        }
    
}

@main
struct zoomhelperApp: App {
    
    struct AlertItem: Identifiable {
        var id = UUID()
        var title = Text("")
        var message: Text?
        var dismissButton: Alert.Button?
        var primaryButton: Alert.Button?
        var secondaryButton: Alert.Button?
    }
    @State var alertItem : AlertItem?
    
    var body: some Scene {
        WindowGroup {
            ContentView().alert(item: $alertItem) { alertItem in
                guard let primaryButton = alertItem.primaryButton, let secondaryButton = alertItem.secondaryButton else{
                    return Alert(title: alertItem.title, message: alertItem.message, dismissButton: alertItem.dismissButton)
                }
                return Alert(title: alertItem.title, message: alertItem.message, primaryButton: primaryButton, secondaryButton: secondaryButton)
            }.onAppear{
                //Check Update
                if let url = URL(string: "https://raw.githubusercontent.com/IT12666/Zoom_Update/main/Updater/mac.txt?\(String(Int.random(in: 1000000..<9999999)))") {
                    do {
                        let contents = try String(contentsOf: url).components(separatedBy: "\n")
                        print(contents)
                        
                        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                            //Must Update
                            if contents[1].compare(version, options: .numeric) == ComparisonResult.orderedDescending {
                                alertItem = AlertItem( title: Text(contents[3]), message: Text(contents[4]), dismissButton: .default(Text("即刻Update!"), action: {

                                    let url = URL(string: contents[5])
                                    FileDownloader.loadFileAsync(url: url!) { (path, error) in
                                        let randomInt = String(Int.random(in: 100000000..<999999999))
                                        print(shell("rm -rf /tmp/\(randomInt)"))
                                        print(shell("unzip -oq \(path!) -d /tmp/\(randomInt)"))
                                        print(shell("open /tmp/\(randomInt)"))
                                        print(shell("touch \"/tmp/\(randomInt)/請用新版覆蓋舊版\""))
                                        //print(shell("open \"\(String(describing: (Bundle.main.bundlePath)))\""))
                                        exit(0)
                                    }
                                    
                                    
                                }))}
                                
                             else {
                                print("version")
                                //Normal Update
                                if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                                    if contents[0].compare(version, options: .numeric) == ComparisonResult.orderedDescending {
                                        self.alertItem = AlertItem(title: Text(contents[3]), message: Text(contents[4]), primaryButton: .default(Text("即刻Update!"), action: {
                                            
                                                let url = URL(string: contents[5])
                                                FileDownloader.loadFileAsync(url: url!) { (path, error) in
                                                    let randomInt = String(Int.random(in: 1000000000..<9999999999))
                                                    print(shell("rm -rf /tmp/\(randomInt)"))
                                                    print(shell("unzip -oq \(path!) -d /tmp/\(randomInt)"))
                                                    print(shell("open /tmp/\(randomInt)"))
                                                    print(shell("touch \"/tmp/\(randomInt)/請用新版覆蓋舊版\""))
                                                    //print(shell("open \"\(String(describing: (Bundle.main.bundlePath)))\""))
                                                    exit(0)
                                                }
                                            
                                            }), secondaryButton: .cancel())
                                    }
                                }
                            }
                        
                        }
                    } catch {
                        // contents could not be loaded
                    }
                } else {
                    // the URL was bad!
                }
            }
        }
    }
}
