//
//  ContentView.swift
//  zoomhelper
//
//  Created by Anson Cheng on 3/2/2022.
//

import SwiftUI
import Foundation

struct BlueButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(5)
            .background(Color(red: 0, green: 0, blue: 0.5))
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
}

extension VerticalAlignment {
    private enum XAlignment : AlignmentID {
        static func defaultValue(in d: ViewDimensions) -> CGFloat {
            return d[VerticalAlignment.top]
        }
    }
    static let xAlignment = VerticalAlignment(XAlignment.self)
}

struct lessoninfo: Identifiable, Codable {
    var id = 0;
    var startdatetime = Date();
    var enddatetime = Date();
    var Zoomid = "1234567890";
    var Zoompwd = "123456";
    var Notes = "Notes";
    var activated = false;
}

private func toggleSidebar() {
    NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
}

func shell(_ command: String, application: String = "/bin/zsh", arguments: String = "-c") -> String {
    let task = Process(); let pipe = Pipe();
    task.standardOutput = pipe; task.standardError = pipe;
    task.arguments = [arguments, command]
    task.launchPath = application
    task.launch()
    return String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)!
}

func showFolder() -> URL?
{
    let panel = NSOpenPanel()
    panel.allowsMultipleSelection = false
    panel.canChooseDirectories = false
    if panel.runModal() == .OK {
        return panel.url ?? nil
    }
    return nil
}

func Datetime_switcher (date: Date, type: String = "EEEE") -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "zh_Hant_HK")
    dateFormatter.dateFormat = type
    return dateFormatter.string(from: date)
}

extension Date {
    func adddate(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date? {
        let components = DateComponents(year: years, month: months, day: days, hour: hours, minute: minutes, second: seconds)
        return Calendar.current.date(byAdding: components, to: self)
    }
    var midnight:Date{
        let cal = Calendar(identifier: .gregorian)
        return cal.startOfDay(for: self)
    }
    func isBetween(_ date1: Date, and date2: Date) -> Bool {
        return (min(date1, date2) ... max(date1, date2)).contains(self)
    }
}

extension Array where Element: Encodable {
    func saveToFile(fileName: URL) throws {
        do {
            let data = try JSONEncoder().encode(self)
            if FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first != nil {
                try data.write(to: fileName)
            } else {
                print("err(printtofile)")
            }
        } catch {
            throw error
        }
    }
}

func readFile(fileName: URL) throws -> [lessoninfo] {
    do {
            let data = try Data(contentsOf: fileName)
            let decoded = try JSONDecoder().decode([lessoninfo].self, from: data)
            return decoded;
    } catch {
        throw error
    }
}

struct ContentView: View {

    struct AlertItem: Identifiable {
        var id = UUID()
        var title = Text("")
        var message: Text?
        var dismissButton: Alert.Button?
        var primaryButton: Alert.Button?
        var secondaryButton: Alert.Button?
    }
    @State var alertItem : AlertItem?
    @State var MainPageSelection: Int = 1;
    @State var selectedPage : Int = 0;
    @State var AddZoomState : Int = 0;
    @State var AdvSettingsState : Int = 0;

    
    let timer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
    
    @State var EntryZoomid: String = ""
    @State var EntryZoompwd: String = ""
    @State var EntryNotes: String = ""
    @State var EntryWeekday: Int = 0;
    @State var EntryStartT: Date = Date();
    @State var EntryEndT: Date = Date();
    @State var lessons:[lessoninfo]? = [];

    
    @State var thisweekday:[String] = [Datetime_switcher(date: Date()),Datetime_switcher(date: Date().adddate(days: 1)!),Datetime_switcher(date: Date().adddate(days: 2)!),Datetime_switcher(date: Date().adddate(days: 3)!),Datetime_switcher(date: Date().adddate(days: 4)!),Datetime_switcher(date: Date().adddate(days: 5)!),Datetime_switcher(date: Date().adddate(days: 6)!)];
    @State var CurrectSelectDate: Int = 0;
    @State var AdvSettAutoQuitZoom: Bool = true;
    
    func Zoomoperation (operation : Int = 0, Zoomid: String = "", Zoompwd : String = "") {
        //0: Close Meeting; Else: Start Meeting
        
        if(operation == 0 || AdvSettAutoQuitZoom == true) {
            print(shell("killall zoom.us"))
        }
            
        if(operation == 0) {return;}
        DispatchQueue.main.async {
            print(shell("open \"zoommtg://zoom.us/join?confno="+Zoomid+"&pwd="+Zoompwd+"\""));
        }
    }
    
    var body: some View {
        switch(MainPageSelection) {
        case 1:
            VStack{
                Text("??????Program Work??? ????????????????????????").frame(height: 50).font(.system(size: 16, weight: .semibold, design: .rounded))
                TabView(selection: $selectedPage) {
                    VStack {
                        HStack{
                            Image("P1")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 600)
                            VStack{
                                VStack{
                                    HStack{
                                        Text("1")
                                            .fontWeight(.bold)
                                            .font(.title)
                                            .foregroundColor(.purple)
                                            .padding()
                                            .border(Color.purple, width: 5)
                                        Text("Login?????????Account???").font(.system(size: 14, weight: .semibold, design: .rounded))
                                    }
                                }.frame(height:300)
                                HStack{
                                    Spacer()
                                    Button("???Zoom") {
                                        print(shell("open zoommtg://"))
                                    }.buttonStyle(BlueButton())
                                    Spacer()
                                    Button("?????????") {
                                        selectedPage+=1
                                    }.buttonStyle(BlueButton())
                                    Spacer()
                                }
                            }.frame(width: 300)
                        }
                    }.tag(0)
                    VStack {
                        HStack{
                            Image("P2")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 600)
                            VStack{
                                VStack{
                                    HStack{
                                        Text("2")
                                            .fontWeight(.bold)
                                            .font(.title)
                                            .foregroundColor(.purple)
                                            .padding()
                                            .border(Color.purple, width: 5)
                                        Text("?????????").font(.system(size: 14, weight: .semibold, design: .rounded))
                                    }
                                    Text("??????->??????->??????????????????????????????????????????")
                                }.frame(height:300)
                                HStack{
                                    Spacer()
                                    Button("?????????") {
                                        selectedPage-=1
                                    }.buttonStyle(BlueButton())
                                    Spacer()
                                    Button("?????????") {
                                        selectedPage+=1
                                    }.buttonStyle(BlueButton())
                                    Spacer()
                                }
                            }.frame(width: 300)
                        }
                    }.tag(1)
                        VStack {
                            HStack{
                                Image("P3")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 600)

                                VStack{
                                    VStack{
                                        HStack{
                                            Text("3")
                                                .fontWeight(.bold)
                                                .font(.title)
                                                .foregroundColor(.purple)
                                                .padding()
                                                .border(Color.purple, width: 5)
                                            Text("?????????Mic&Cam").font(.system(size: 14, weight: .semibold, design: .rounded))
                                        }
                                        Text("??????->??????->????????????????????????????????????????????????\n??????->??????->?????????????????????????????????")
                                    }.frame(height:300)
                                    HStack{
                                        Spacer()
                                        Button("?????????") {
                                            selectedPage-=1
                                        }.buttonStyle(BlueButton())
                                        Spacer()
                                        Button("????????????") {
                                            MainPageSelection = 0;
                                        }.buttonStyle(BlueButton())
                                        Spacer()
                                    }
                                }.frame(width: 300)
                        }
                    }.tag(2)
                }.frame(width: 1000, height: 500)
            }
        case 2:
            VStack{
                Text("????????????").frame(height: 50).font(.system(size: 16, weight: .semibold, design: .rounded))
                TabView(selection: $selectedPage) {
                    VStack {
                        HStack{
                            Image("P1")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 600)
                            VStack{
                                VStack{
                                    HStack{
                                        Text("1")
                                            .fontWeight(.bold)
                                            .font(.title)
                                            .foregroundColor(.purple)
                                            .padding()
                                            .border(Color.purple, width: 5)
                                        Text("Login?????????Account???").font(.system(size: 14, weight: .semibold, design: .rounded))
                                    }
                                }.frame(height:300)
                                Button("?????????") {
                                    selectedPage+=1
                                }.buttonStyle(BlueButton())
                            }.frame(width: 300)
                        }
                    }.tag(0)
                    VStack {
                        HStack{
                            Image("P2")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 600)
                            VStack{
                                VStack{
                                    HStack{
                                        Text("2")
                                            .fontWeight(.bold)
                                            .font(.title)
                                            .foregroundColor(.purple)
                                            .padding()
                                            .border(Color.purple, width: 5)
                                        Text("?????????").font(.system(size: 14, weight: .semibold, design: .rounded))
                                    }
                                    Text("??????->??????->??????????????????????????????????????????")
                                }.frame(height:300)
                                Button("?????????") {
                                    selectedPage+=1
                                }.buttonStyle(BlueButton())
                            }.frame(width: 300)
                        }
                    }.tag(1)
                        VStack {
                            HStack{
                                Image("P3")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 600)

                                VStack{
                                    VStack{
                                        HStack{
                                            Text("3")
                                                .fontWeight(.bold)
                                                .font(.title)
                                                .foregroundColor(.purple)
                                                .padding()
                                                .border(Color.purple, width: 5)
                                            Text("?????????Mic&Cam").font(.system(size: 14, weight: .semibold, design: .rounded))
                                        }
                                        Text("??????->??????->????????????????????????????????????????????????\n??????->??????->?????????????????????????????????")
                                    }.frame(height:300)
                                    Button("????????????") {
                                        MainPageSelection = 0;
                                    }.buttonStyle(BlueButton())
                                }.frame(width: 300)
                        }
                    }.tag(2)
                }.frame(width: 1000, height: 500)
            }
        default:
            NavigationView {
                HStack{
                    Spacer(minLength: 20)
                    VStack {
                        Spacer()
                        Text("????????????MacOS App ???????????????bug????\n\n??????????????????????????????tg @Anc2003 \n ?????? Email Anson.12666@gmail.com \n\n ???????????????????????????????").multilineTextAlignment(.center)
                        Divider()
                        Text("Offical Website\nhttps://it12666.github.io/Zoom_Update/").multilineTextAlignment(.center)
                        Divider()
                        Text("?????????????????????????????????????????????\n????????????????????????\n??????????????????????").multilineTextAlignment(.center)
                        Image("Payme")
                            .resizable()
                            .scaledToFit()
                        Text("https://payme.hsbc/anson03").multilineTextAlignment(.center)
                        Spacer()
                    }
                    Spacer(minLength: 20)
                }.frame(minWidth:300, maxWidth:400)
                
                VStack {
                    Spacer()
                    VStack {
                        VStack{
                            HStack{
                                VStack{
                                    HStack{
                                        Spacer(minLength: 25)
                                        switch (AddZoomState) {
                                            case 0:
                                                TextField("??? ZoomID ?????? Zoom Link", text: $EntryZoomid)
                                                    .padding(10)
                                                    .frame(height: 25)
                                                    .textFieldStyle(PlainTextFieldStyle())
                                                    .background(Color(NSColor.controlBackgroundColor))
                                                    .cornerRadius(16)
                                                Button("?????????") {
                                                    if(EntryZoomid.filter("0123456789".contains) != "") {
                                                        if(EntryZoomid.lowercased().contains("zoom")) {
                                                            if(EntryZoomid.contains("=")) {
                                                                EntryZoompwd = String( EntryZoomid.split(separator: "=")[1])
                                                            }
                                                            EntryZoomid = (EntryZoomid+"?").split(separator: "?")[0].filter("0123456789".contains)
                                                            AddZoomState+=2
                                                        }
                                                        else {
                                                            AddZoomState+=1
                                                        }
                                                    }
                                                }.buttonStyle(BlueButton())
                                            case 1:
                                                TextField("??????", text: $EntryZoompwd)
                                                    .padding(10)
                                                    .frame(height: 25)
                                                    .textFieldStyle(PlainTextFieldStyle())
                                                    .background(Color(NSColor.controlBackgroundColor))
                                                    .cornerRadius(16)
                                                Button("?????????") {
                                                    AddZoomState+=1
                                                }.buttonStyle(BlueButton())
                                            case 2:
                                                TextField("??????(?????????)", text: $EntryNotes)
                                                    .padding(10)
                                                    .frame(height: 25)
                                                    .textFieldStyle(PlainTextFieldStyle())
                                                    .background(Color(NSColor.controlBackgroundColor))
                                                    .cornerRadius(16)
                                                Button("?????????") {
                                                    EntryStartT=Date()
                                                    AddZoomState+=1
                                                }.buttonStyle(BlueButton())
                                            case 3:
                                                Picker(selection: $EntryWeekday , label: Text("???????????????")) {
                                                    ForEach (0..<7) { i in
                                                        Text(Datetime_switcher(date: Date().adddate(days: i)!)).tag(i)
                                                    }
                                                    Text("??????").tag(7)
                                                }
                                            DatePicker("???????????????", selection: $EntryStartT, displayedComponents: .hourAndMinute)
                                                .labelsHidden()
                                            Spacer(minLength: 25)
                                                Button("??????") {
                                                    
                                                    lessons?.append( lessoninfo(id: (lessons!.count),  startdatetime: EntryStartT.adddate(days: EntryWeekday) ?? EntryStartT, enddatetime: EntryEndT.adddate(days: EntryWeekday) ?? EntryStartT, Zoomid: EntryZoomid.filter("0123456789".contains),  Zoompwd: String(EntryZoompwd.filter { !" \n\t\r".contains($0) }), Notes: EntryNotes))
                                                    
                                                    lessons!.sort { (lhs, rhs) in return lhs.startdatetime < rhs.startdatetime }
                                                    
                                                    for i in lessons!.indices {
                                                        lessons![i].id = i;
                                                    }
                                                    
                                                    EntryZoomid = ""
                                                    EntryZoompwd = ""
                                                    EntryNotes = ""
                                                    EntryWeekday = 0
                                                    AddZoomState=0
                                                }.buttonStyle(BlueButton())
                                            default:
                                            Button("????????????????????????") {
                                               EntryZoomid = ""
                                               EntryZoompwd = ""
                                               EntryNotes = ""
                                               EntryWeekday = 0
                                               AddZoomState=0
                                           }.buttonStyle(BlueButton())
                                        }
                                        Spacer(minLength: 20)
                                    }
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        Spacer()
                        Picker(selection: $CurrectSelectDate , label: Text("")) {
                            Text("????????????").tag(0)
                            ForEach (1..<7) { i in
                                Text(Datetime_switcher(date: Date().adddate(days: i)!)+"??????").tag(i)
                            }
                            Text("??????????????????").tag(7)
                        }
                        Spacer()
                        Button("???Zoom") {
                            Zoomoperation(operation: 0)
                        }.buttonStyle(BlueButton())
                        Spacer()
                        
                        Button("Load?????????") {
                            let location = showFolder()
                            if((location) != nil) {
                                do {
                                    lessons = try readFile(fileName: location!)
                                } catch {print(error)}
                            }
                            
                            for i in lessons!.indices {
                                while(!(lessons![i].startdatetime.isBetween(Date(), and: Date().adddate(days: 7)!))) {
                                    if(lessons![i].startdatetime < Date()) {
                                        lessons![i].startdatetime = lessons![i].startdatetime.adddate(days: 7)!
                                    } else {
                                        lessons![i].startdatetime = lessons![i].startdatetime.adddate(days: -7)!
                                    }
                                }
                            }
                            
                            lessons!.sort { (lhs, rhs) in return lhs.startdatetime < rhs.startdatetime }
                            
                            for i in lessons!.indices {
                                lessons![i].activated = false;
                                lessons![i].id = i;
                            }
                            
                            
                
                        }.buttonStyle(BlueButton())
                        Spacer()
                        Button("Save????????????") {
                            let savePanel = NSSavePanel()
                                savePanel.canCreateDirectories = true
                                savePanel.showsTagField = false
                                savePanel.nameFieldStringValue = "Backup.txt"
                                savePanel.level = .modalPanel
                                savePanel.begin {
                                    if $0 == .OK {
                                        do {
                                            try lessons?.saveToFile(fileName: savePanel.url!)
                                        } catch {print(error)}
                                    }
                                }
                        }.buttonStyle(BlueButton())
                        Spacer()
                        
                    }
                    
                    List {
                        ForEach(lessons ?? [], id: \.id) {
                            lesson in
                            Group {
                                if(CurrectSelectDate == 7 || thisweekday[CurrectSelectDate] == Datetime_switcher(date: lesson.startdatetime)) {
                                    HStack{
                                        VStack{
                                            HStack(alignment: .center) {
                                                Label("", systemImage: String(lesson.id)+".circle")
                                                
                                                DatePicker(selection: .constant(lesson.startdatetime), displayedComponents: .hourAndMinute, label: {Text("Start") }).disabled(true)
                                              //  DatePicker(selection: .constant(lesson.enddatetime), displayedComponents: .hourAndMinute, label: { Text("End") }).disabled(true)
                                            }
                                            
                                            HStack {
                                                let activated = [true: "???",false: "?????????"]
                                                
                                                if(lesson.activated == false) {
                                                    EmptyView()
                                                } else {
                                                HStack(alignment: .xAlignment) {
                                                    Image(systemName: "s.circle").alignmentGuide(.xAlignment) { $0.height / 2.0 }
                                                    Text(activated[lesson.activated]!).alignmentGuide(.xAlignment) {($0.height - ($0[.lastTextBaseline] - $0[.firstTextBaseline])) / 2}
                                                }
                                                }
                                                
                                                HStack(alignment: .xAlignment) {
                                                    Image(systemName: "t.circle").alignmentGuide(.xAlignment) { $0.height / 2.0 }
                                                    Text(Datetime_switcher(date: lesson.startdatetime)).alignmentGuide(.xAlignment) {($0.height - ($0[.lastTextBaseline] - $0[.firstTextBaseline])) / 2}
                                                }
                                                
                                                if(lesson.Notes=="") {
                                                    EmptyView()
                                                } else {
                                                HStack(alignment: .xAlignment) {
                                                    Image(systemName: "n.circle").alignmentGuide(.xAlignment) { $0.height / 2.0 }
                                                    Text(lesson.Notes).alignmentGuide(.xAlignment) {($0.height - ($0[.lastTextBaseline] - $0[.firstTextBaseline])) / 2}
                                                }
                                                }
                                                
                                                HStack(alignment: .xAlignment) {
                                                    Image(systemName: "i.circle").alignmentGuide(.xAlignment) { $0.height / 2.0 }
                                                    Text(lesson.Zoomid).alignmentGuide(.xAlignment) {($0.height - ($0[.lastTextBaseline] - $0[.firstTextBaseline])) / 2}
                                                }
                                                
                                                if(lesson.Zoompwd=="") {
                                                    EmptyView()
                                                } else {
                                                HStack(alignment: .xAlignment) {
                                                    Image(systemName: "p.circle").alignmentGuide(.xAlignment) { $0.height / 2.0 }
                                                    Text(lesson.Zoompwd).alignmentGuide(.xAlignment) {($0.height - ($0[.lastTextBaseline] - $0[.firstTextBaseline])) / 2}
                                                }
                                                }
                                                Spacer()
                                                Button("???") {
                                                    if let index:Int = lessons?.firstIndex(where: {$0.id == lesson.id}) {
                                                        lessons?.remove(at: index)
                                                        
                                                        for i in lessons!.indices {
                                                            lessons![i].id = i;
                                                        }
                                                    }
                                                    
                                                }
                                                /*
                                                Button("???") {
                                                    /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
                                                }
                                                 */
                                                Button("??????") {
                                                    Zoomoperation(operation: 1, Zoomid: lesson.Zoomid, Zoompwd: lesson.Zoompwd)
                                                    lessons?[lesson.id].activated = true;
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    EmptyView()
                                }
                            }
                        }
                    }.onReceive(timer) { _ in
                        //Auto Run Zoom
                        for i in lessons!.indices {
                            //Run Next Lesson
                            if(!lessons![i].activated && Datetime_switcher(date: Date(),type: "EEEEHH:mm") == Datetime_switcher(date: lessons![i].startdatetime,type: "EEEEHH:mm")) {
                                lessons![i].activated = true
                                Zoomoperation(operation: 1, Zoomid: lessons![i].Zoomid, Zoompwd: lessons![i].Zoompwd)
                            }
                        }
                    }
                    
                    HStack {
                        switch(AdvSettingsState) {
                        case 0:
                            Spacer(minLength: 5)
                            /*
                             
                             Button("????????????") {
                                selectedPage = 0;
                                MainPageSelection=2
                           }.buttonStyle(BlueButton())
                             
                            Spacer(minLength: 5)
                             
                             */
                            Button("????????????") {
                                selectedPage = 0;
                                MainPageSelection=1
                           }.buttonStyle(BlueButton())
                            Spacer(minLength: 5)
                            Button("????????????") {
                                AdvSettingsState=1
                           }.buttonStyle(BlueButton())
                            Spacer(minLength: 5)
                        case 1:
                            Spacer(minLength: 5)
                            Toggle("???????????????????????????????????????Zoom", isOn: $AdvSettAutoQuitZoom).toggleStyle(SwitchToggleStyle(tint: .red))
                            Spacer(minLength: 30)
                            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String { Text("v. "+version) }
                            Spacer(minLength: 30)
                            Button("?????????") {
                                AdvSettingsState=0
                           }.buttonStyle(BlueButton())
                            Spacer(minLength: 5)
                        default:
                            Button("??????") {
                                AdvSettingsState=0
                           }.buttonStyle(BlueButton())
                        }
                    }
                    
                    
                    
                    Spacer()
                }.frame(minWidth: 550)
            }.toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: toggleSidebar, label: { // 1
                        Image(systemName: "sidebar.leading")
                    })
                }
            }.alert(item: $alertItem) { alertItem in
                guard let primaryButton = alertItem.primaryButton, let secondaryButton = alertItem.secondaryButton else{
                    return Alert(title: alertItem.title, message: alertItem.message, dismissButton: alertItem.dismissButton)
                }
                return Alert(title: alertItem.title, message: alertItem.message, primaryButton: primaryButton, secondaryButton: secondaryButton)
            }.onAppear {
                if let pathComponent = NSURL(fileURLWithPath: "/Applications").appendingPathComponent("zoom.us.app") {
                    let filePath = pathComponent.path
                    let fileManager = FileManager.default
                    if fileManager.fileExists(atPath: filePath) {
                        //Success
                    } else {
                        alertItem = AlertItem( title: Text("???????????????Zoom???"), dismissButton: .default(Text("??????Zoom!"), action: {
                            print(shell("open https://zoom.us/client/latest/Zoom.pkg"))
                            NSApplication.shared.terminate(nil)
                        }))
                    }
                } else {
                    self.alertItem = AlertItem(title: Text("????????????????????????????????????Zoom"), primaryButton: .default(Text("??????App"), action: {
                        NSApplication.shared.terminate(nil)
                                    }), secondaryButton: .cancel())
                }
            }.frame(minWidth: 850)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
