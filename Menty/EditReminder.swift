import SwiftUI
import UserNotifications

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
        _editedDate = State(initialValue: reminder.wrappedValue.date)
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
        reminder.date = editedDate
        
        isPresented = false // Dismiss the view
        
        let notificationTitle = "\(reminder.title) - \(formatDate(reminder.date))"
        NotificationManager.cancelNotification(withIdentifier: reminder.id.uuidString)
        NotificationManager.scheduleNotification(for: notificationTitle, at: reminder.date, withIdentifier: reminder.id.uuidString)
    }

    
    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
}
