import SwiftUI

struct Reminder: Identifiable {
    let id = UUID()
    var title: String
    var date: Date?
    var isEditable: Bool // New property to track the edit state
    
    init(title: String, date: Date?, isEditable: Bool = false) {
        self.title = title
        self.date = date
        self.isEditable = isEditable
    }
}


struct RemindersView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var reminders: [Reminder] = []
    @State private var newReminder: String = ""
    @State private var selectedDate: Date?
    @State private var showDatePicker = false
    @State private var showEditReminder = false
    @State private var editReminderIndex = 0
    @State private var showAddReminder = false
    
    private var titleTextColor: Color {
        return colorScheme == .light ? .black : .white
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all)
            VStack {
                List {
                    ForEach(reminders.indices, id: \.self) { index in
                        let reminder = reminders[index]
                        HStack {
                            if reminder.isEditable {
                                TextField("Reminder", text: $reminders[index].title)
                                    .font(.headline)
                                    .foregroundColor(titleTextColor)
                                    .onSubmit {
                                        // Save the updated title when editing is complete
                                        reminders[index].isEditable = false
                                        saveReminder(reminders[index])
                                    }
                            } else {
                                VStack(alignment: .leading) {
                                    Text(reminder.title)
                                        .font(.headline)
                                        .foregroundColor(titleTextColor)
                                    if let date = reminder.date {
                                        Text(formatDate(date))
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .onTapGesture {
                                    // Enable editing when the title is tapped
                                    reminders[index].isEditable = true
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                                .onTapGesture {
                                    showEditReminderView(for: reminder)
                                }
                        }

                        .swipeActions {
                            Button(action: {
                                deleteReminder(reminder)
                            }) {
                                Image(systemName: "trash")
                            }
                            .tint(.red)
                        }
                    }



                }


                
                Spacer()
                
                if showAddReminder {
                    HStack {
                        TextField("New Reminder", text: $newReminder)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: addReminder) {
                            Text("Add")
                        }
                        .padding(.leading)
                    }
                    .padding()
                    
                    if !showDatePicker {
                        Button(action: {
                            showDatePicker.toggle()
                        }) {
                            Text("Select Date")
                        }
                        .padding(.bottom, 16)
                    }
                    
                    if showDatePicker {
                        DatePicker("Select Date", selection: Binding<Date>(
                            get: {
                                selectedDate ?? Date()
                            },
                            set: {
                                selectedDate = $0
                            }), displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .labelsHidden()
                            .padding()
                    }
                }

                
                Button(action: {
                    showAddReminder.toggle()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.blue)
                }
                .padding(.bottom, 16)
            }
        }
        .colorScheme(.dark)
        .sheet(isPresented: $showEditReminder) {
            EditReminder(reminder: $reminders[editReminderIndex], selectedDate: Binding<Date?>(
                get: { selectedDate },
                set: { date in
                    if let date = date {
                        selectedDate = date
                    }
                }
            ), isPresented: $showEditReminder)
        }
    }
    
    private func saveReminder(_ reminder: Reminder) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index] = reminder
            // Update any necessary data or perform actions related to saving the reminder
        }
    }

    
    private func showEditReminderView(for reminder: Reminder) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            editReminderIndex = index
            showEditReminder = true
        }
    }
    
    private func addReminder() {
        guard !newReminder.isEmpty else { return }
        
        let reminder = Reminder(title: newReminder, date: selectedDate)
        
        if let date = selectedDate {
            NotificationManager.scheduleNotification(for: "\(reminder.title) - \(formatDate(date))", at: date, withIdentifier: reminder.id.uuidString)
        }
        
        reminders.append(reminder)
        newReminder = ""
        selectedDate = nil // Reset the selected date after adding a reminder
        showDatePicker = false
    }









    private func deleteReminder(_ reminder: Reminder) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            let deletedReminder = reminders[index]
            NotificationManager.cancelNotification(withIdentifier: deletedReminder.id.uuidString)
            reminders.remove(at: index)
        }
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else {
            return "No Date"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
    }
