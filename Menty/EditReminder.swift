import SwiftUI

struct EditReminder: View {
    @Binding var reminder: String
    @Binding var selectedDate: Date
    @State private var editedTitle: String
    @State private var editedDate: Date
    @Binding var isPresented: Bool
    
    init(reminder: Binding<String>, selectedDate: Binding<Date>, isPresented: Binding<Bool>) {
        _reminder = reminder
        _selectedDate = selectedDate
        _editedTitle = State(initialValue: "")
        _editedDate = State(initialValue: selectedDate.wrappedValue)
        _isPresented = isPresented
    }
    
    var body: some View {
        VStack {
            TextField("Reminder", text: $editedTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            DatePicker("Select Date", selection: $editedDate, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(GraphicalDatePickerStyle())
                .labelsHidden()
                .padding()
            
            Button(action: saveReminder) {
                Text("Save")
            }
            .padding()
        }
    }
    
    private func saveReminder() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        let formattedDate = dateFormatter.string(from: editedDate)
        
        reminder = "\(editedTitle) - \(formattedDate)"
        selectedDate = editedDate
        
        isPresented = false // Dismiss the view
    }
}
