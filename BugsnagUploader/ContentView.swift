//
//  ContentView.swift
//  BugsnagUploader
//
//  Created by Justin Nipper on 5/9/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var isTargeted: Bool = false
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Drag Symbols to Upload")
                .font(.largeTitle)
                .padding()
            Spacer()
            Image(systemName: "folder.circle.fill")
                .font(.largeTitle)
                .imageScale(.large)
                .foregroundStyle(.cyan)
                .padding()
            Spacer()
            
        }
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
        .onDrop(of: [.item], isTargeted: $isTargeted, perform: { providers in
            guard let provider = providers.first else { return false }
            
            _ = provider.loadDataRepresentation(for: .item) { data, error in
                if error == nil, let data {
                    DispatchQueue.main.async {
                        print(data.description)
                        Task {
                            await uploadFile(data: data)
                        }
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
            }
        }
        .animation(.default, value: isTargeted)
        .padding()
    }
}



func uploadFile(data: Data) async {
    let url = URL(string: "https://upload.bugsnag.com")!
    var request = URLRequest(url: url)
    let boundary = "Boundary-\(UUID().uuidString)"
    request.httpMethod = "POST"
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    
    let httpBody = NSMutableData()
    httpBody.appendString(convertFormField(named: "apiKey", value: "d78570a7f97bfb30fe696ceb84d7312e", using: boundary))
    
    httpBody.append(convertFileData(fieldName: "dsym", fileName: "zipFile", mimeType: "application/octet-stream", fileData: data, using: boundary))
    httpBody.appendString("--\(boundary)--")
    
    request.httpBody = httpBody as Data
    
    do {
        let (data, _) = try await URLSession.shared.data(for: request)
        print("GOT DATA: \(String(data: data, encoding: .utf8) ?? "NOT")")
    } catch {
        print(error)
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
    ContentView()
}
