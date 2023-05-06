import SwiftUI

struct RemindersView: View {
    @State private var reminders: [String] = []
    @State private var newReminder: String = ""
    @State private var selectedDate = Date()
    @State private var showDatePicker = false
    @State private var showEditReminder = false
    @State private var editReminderIndex = 0
    
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
                ForEach(reminders.indices, id: \.self) { index in
                    let reminder = reminders[index]
                    let components = reminder.components(separatedBy: " - ")
                    let title = components[0]
                    
                    Button(action: {
                        showEditReminderView(for: index)
                    }) {
                        VStack(alignment: .leading) {
                                        Text(title)
                                            .font(.headline)
                                            .foregroundColor(.black) // Set title text color to black
                                        
                                        Text(formattedSelectedDate)
                                            .font(.subheadline)
                                            .foregroundColor(.blue) // Set date text color to blue
                                    }
                    }
                }
                .onDelete(perform: deleteReminder)
            }
        }
        .sheet(isPresented: $showEditReminder) {
            EditReminder(reminder: $reminders[editReminderIndex], selectedDate: $selectedDate, isPresented: $showEditReminder)
        }
    }
    
    private func showEditReminderView(for index: Int) {
        editReminderIndex = index
        showEditReminder = true
    }
    
    private func addReminder() {
        guard !newReminder.isEmpty else { return }
        
        let reminder = "\(newReminder)"
        reminders.append(reminder)
        newReminder = ""
        showDatePicker = false
        
        NotificationManager.scheduleNotification(for: reminder, at: selectedDate)
    }
    
    private func deleteReminder(at offsets: IndexSet) {
        reminders.remove(atOffsets: offsets)
    }
}
