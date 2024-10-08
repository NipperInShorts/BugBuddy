//
//  UploadView.swift
//  BugBuddy
//
//  Created by Justin Nipper on 5/13/24.
//

import SwiftUI

class AlertView: ObservableObject {
    
    @Published var alertTitle: String = ""
    @Published var alertPresented: Bool = false
    @Published var alertMessage: String = ""
    
}

struct UploadView: View {
    @Environment(\.modelContext) private var dataModel
    @EnvironmentObject var navigationState: NavigationStateManager
    
    @ObservedObject private var alertModel = AlertView()
    
    private let total: Double = 1
    
    @State private var isTargeted: Bool = false
    @State private var progress: Double = 0
    @State private var uploadTask: URLSessionUploadTask?
    @State private var observation: NSKeyValueObservation?
    @State private var showProgress: Bool = false
    @State private var processingFile: Bool = false
    @State private var fileProgress: Double = 0
    

    @State private var buttonTitle: String = "OK"
    
    var greeting: String {
        if let state = navigationState.selectionState {
            switch state {
            case .accounts(let account):
                return "Drop dSYM file to Upload\n to \(account.title)"
                
            case .settings:
                return "Drop dSYM file to Upload"
            }
        }
        return "Drop dSYM file to Upload"
    }
    
    var body: some View {
        VStack {
            Text(greeting)
                .frame(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .multilineTextAlignment(.center)
                .font(.title)
                .padding(.top)
            Spacer()
            VStack(alignment: .center) {
                Spacer()
                if showProgress {
                    ProgressView("Uploading...", value: progress, total: total)
                        .progressViewStyle(.linear)
                        .padding()
                } else if processingFile {
                    ProgressView("Validating file...", value: fileProgress, total: total)
                        .progressViewStyle(.circular)
                        .padding()
                } else {
                    Image(systemName: "folder.circle.fill")
                        .font(.largeTitle)
                        .imageScale(.large)
                        .foregroundStyle(.cyan)
                }
                Spacer()
            }
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
            .onDrop(of: [.item], isTargeted: $isTargeted, perform: { providers in
                processingFile = true
                fileProgress = 0.1
                guard let provider = providers.first else {
                    fileProgress = 1.0
                    processingFile = false
                    return false
                }
                fileProgress = 0.6
                _ = provider.loadDataRepresentation(for: .item) { data, error in
                    if error == nil, let data {
                        DispatchQueue.main.async {
                            Task { @MainActor in
                                fileProgress = 1.0
                                processingFile.toggle()
                                showProgress.toggle()
                                await uploadFile(data: data)
                            }
                        }
                    } else {
                        Task { @MainActor in
                            fileProgress = 1.0
                            processingFile = false
                            
                            alertModel.alertTitle = "Error Processing Files"
                            alertModel.alertMessage = error?.localizedDescription ?? "Unable to process files.\n Try again"
                            alertModel.alertPresented.toggle()
                        }
                        
                    }
                }
                return true
            })
            .overlay {
                if isTargeted {
                    ZStack {
                        Color.black.opacity(0.7)
                        
                        VStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 60))
                            Text("Drop your files here...")
                        }
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .animation(.default, value: isTargeted)
            .padding()
        }
        .alert(alertModel.alertTitle, isPresented: $alertModel.alertPresented, actions: {
            Button(buttonTitle) {
                alertModel.alertPresented.toggle()
            }
        }, message: {
            Text(alertModel.alertMessage)
        })
    }
    
    private func uploadFile(data: Data) async {
        var account: Account?
        var apiKey: String = ""
        
        if let state = navigationState.selectionState {
            switch state {
            case .accounts(let enumAccount):
                account = enumAccount
            case .settings:
                break;
            }
        }
        
        if let account = account {
            
            do {
                apiKey = try account.getApiKey(account: account.title)
            } catch {
            }
            let url = URL(string: "https://upload.bugsnag.com")!
            var request = URLRequest(url: url)
            let boundary = "Boundary-\(UUID().uuidString)"
            request.httpMethod = "POST"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            let httpBody = NSMutableData()
            httpBody.appendString(convertFormField(named: "apiKey", value: apiKey, using: boundary))
            
            httpBody.append(convertFileData(fieldName: "dsym", fileName: "zipFile", mimeType: "application/octet-stream", fileData: data, using: boundary))
            httpBody.appendString("--\(boundary)--")
            
            uploadTask = URLSession.shared.uploadTask(with: request, from: httpBody as Data) { data, response, error in
                if let httpResponse = response as? HTTPURLResponse {
                    Task { @MainActor in
                        if httpResponse.statusCode == 401 {
                            alertModel.alertTitle = "Error Uploading Files"
                            alertModel.alertMessage = "Unauthorized.\nValidate API Key and try again"
                            alertModel.alertPresented = true
                        }
                        
                    }
                }
                if error != nil {
                    Task { @MainActor in
                        alertModel.alertTitle = "Error Uploading Files"
                        alertModel.alertMessage = error?.localizedDescription ?? "Unable to upload files.\n Try again."
                        alertModel.alertPresented = true
                    }
                }
                guard data != nil else {  return }
                DispatchQueue.main.async {
                    alertModel.alertTitle = "All done!"
                    alertModel.alertMessage = "Files uploaded!"
                    alertModel.alertPresented = true
                    
                    reset()
                }
            }
            
            observation = uploadTask?.progress.observe(\.fractionCompleted, changeHandler: { observationProgress, _ in
                Task { @MainActor in
                    progress = observationProgress.fractionCompleted
                }
            })
            
            uploadTask?.resume()
        }
    }
    
    private func reset() {
        observation?.invalidate()
        uploadTask?.cancel()
        showProgress.toggle()
        progress = 0
        
    }
}


func convertFormField(named name: String, value: String, using boundary: String) -> String {
    var fieldString = "--\(boundary)\r\n"
    fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
    fieldString += "\r\n"
    fieldString += "\(value)\r\n"
    
    return fieldString
}

func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
    let data = NSMutableData()
    
    data.appendString("--\(boundary)\r\n")
    data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
    data.appendString("Content-Type: \(mimeType)\r\n\r\n")
    data.append(fileData)
    data.appendString("\r\n")
    
    return data as Data
}

extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}


#Preview {
    UploadView()
        .environmentObject(NavigationStateManager())
        .modelContainer(for: [Account.self])
}
