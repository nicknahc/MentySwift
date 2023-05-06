import SwiftUI

struct EditReminder: View {
    @Binding var reminder: Reminder
    @Binding var selectedDate: Date
    @State private var editedTitle: String
    @State private var editedDate: Date
    @Binding var isPresented: Bool
    
    init(reminder: Binding<Reminder>, selectedDate: Binding<Date>, isPresented: Binding<Bool>) {
        _reminder = reminder
        _selectedDate = selectedDate
        _editedTitle = State(initialValue: reminder.wrappedValue.title)
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
        .onAppear {
            editedTitle = reminder.title
            editedDate = selectedDate
        }
    }
    
    private func saveReminder() {
        reminder.title = editedTitle
        selectedDate = editedDate
        
        isPresented = false // Dismiss the view
    }
}
