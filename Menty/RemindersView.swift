import SwiftUI
import UserNotifications

struct RemindersView: View {
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
        
        scheduleNotification(for: reminder, at: selectedDate)
    }
    
    private func deleteReminder(at offsets: IndexSet) {
        reminders.remove(atOffsets: offsets)
    }
    
    private func scheduleNotification(for reminder: String, at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = reminder
        content.sound = UNNotificationSound.default
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
}
