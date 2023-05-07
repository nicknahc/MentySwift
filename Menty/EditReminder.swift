import SwiftUI
import UserNotifications

struct EditReminder: View {
    @Binding var reminder: Reminder
    @Binding var selectedDate: Date?
    @State private var editedTitle: String
    @State private var editedDate: Date?
    @Binding var isPresented: Bool
    
    init(reminder: Binding<Reminder>, selectedDate: Binding<Date?>, isPresented: Binding<Bool>) {
        _reminder = reminder
        _selectedDate = selectedDate
        _editedTitle = State(initialValue: reminder.wrappedValue.title)
        _editedDate = State(initialValue: reminder.wrappedValue.date)
        _isPresented = isPresented
    }
    
    var body: some View {
        VStack {
            TextField("Reminder", text: $editedTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            if selectedDate != nil || reminder.date != nil {
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
        
        if let editedDate = editedDate {
            reminder.date = editedDate
        }
        
        isPresented = false // Dismiss the view
        
        let unwrappedDate = reminder.date ?? Date()
        let notificationTitle = "\(reminder.title) - \(formatDate(unwrappedDate))"
        NotificationManager.cancelNotification(withIdentifier: reminder.id.uuidString)
        NotificationManager.scheduleNotification(for: notificationTitle, at: unwrappedDate, withIdentifier: reminder.id.uuidString)
    }

    
    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
}
