import SwiftUI
import UserNotifications

struct EditReminder: View {
    @Binding var reminder: Reminder
    @Binding var selectedDate: Date?
    @State private var editedTitle: String
    @State private var editedDate: Date?
    @Binding var isPresented: Bool
    @State private var isDateToggledOn: Bool // Added property to track the toggle state
    
    init(reminder: Binding<Reminder>, selectedDate: Binding<Date?>, isPresented: Binding<Bool>) {
        _reminder = reminder
        _selectedDate = selectedDate
        _editedTitle = State(initialValue: reminder.wrappedValue.title)
        _editedDate = State(initialValue: reminder.wrappedValue.date)
        _isPresented = isPresented
        _isDateToggledOn = State(initialValue: reminder.wrappedValue.date != nil) // Initialize the toggle state
    }
    
    var body: some View {
        VStack {
            TextField("Reminder", text: $editedTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Toggle("Date", isOn: $isDateToggledOn) // Add the Toggle control
                .padding(.horizontal)
            
            if isDateToggledOn || reminder.date != nil { // Check the toggle state
                let nonOptionalSelectedDate = Binding<Date>(
                    get: {
                        reminder.date ?? selectedDate ?? Date()
                    },
                    set: { newValue in
                        if selectedDate != nil {
                            selectedDate = newValue
                        } else {
                            reminder.date = newValue
                        }
                        editedDate = newValue // Update editedDate
                    }
                )
                
                DatePicker("Select Date", selection: nonOptionalSelectedDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .labelsHidden()
                    .padding()
                    .onAppear {
                        editedDate = reminder.date ?? selectedDate
                    }
            }
            
            Button(action: saveReminder) {
                Text("Save")
            }
            .padding()
        }
        .onAppear {
            editedTitle = reminder.title
            editedDate = reminder.date ?? selectedDate
        }
    }
    
    private func saveReminder() {
        reminder.title = editedTitle
        
        if isDateToggledOn { // Check the toggle state
            if let editedDate = editedDate {
                reminder.date = editedDate
            } else {
                // Set a default date value
                let defaultDate = Date().addingTimeInterval(3600) // Default date: 1 hour from the current time
                reminder.date = defaultDate
                editedDate = defaultDate
            }
        } else {
            reminder.date = nil // Date was toggled off, so set it to nil
            NotificationManager.cancelNotification(withIdentifier: reminder.id.uuidString) // Cancel the existing notification
        }
        
        isPresented = false // Dismiss the view
        
        if let unwrappedDate = reminder.date {
            let notificationTitle = "\(reminder.title) - \(formatDate(unwrappedDate))"
            NotificationManager.scheduleNotification(for: notificationTitle, at: unwrappedDate, withIdentifier: reminder.id.uuidString)
        }
    }

    
    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
}
