import SwiftUI

struct ContentView: View {
    @State private var reminders: [String] = []
    @State private var newReminder: String = ""
    @State private var selectedDate = Date()
    @State private var showDatePicker = false
    
    private var formattedSelectedDate: String {
           let dateFormatter = DateFormatter()
           dateFormatter.dateStyle = .medium
           dateFormatter.timeStyle = .short
           return dateFormatter.string(from: selectedDate)
       }
    var body: some View {
        VStack {
            HStack {
                TextField("New Reminder", text: $newReminder)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: addReminder) {
                    Text("Add")
                }
            }
            .padding()
            
            Button(action: { showDatePicker.toggle() }) {
                      Text("Select Date")
                  }
                  
                  if showDatePicker {
                      DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                          .datePickerStyle(GraphicalDatePickerStyle())
                          .labelsHidden()
                          .padding()
                  }
                  
                  if showDatePicker && !newReminder.isEmpty {
                      Text("Selected Date: \(formattedSelectedDate)")
                          .padding()
                  }

            List {
                ForEach(reminders, id: \.self) { reminder in
                    Text(reminder)
                }
                .onDelete(perform: deleteReminder)
            }
        }
    }

    
    private func addReminder() {
        guard !newReminder.isEmpty else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        let formattedDate = dateFormatter.string(from: selectedDate)
        
        let reminder = "\(newReminder) - \(formattedDate)"
        reminders.append(reminder)
        newReminder = ""
        showDatePicker = false
    }


    
    private func deleteReminder(at offsets: IndexSet) {
        reminders.remove(atOffsets: offsets)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
