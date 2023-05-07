import SwiftUI

struct Reminder: Identifiable {
    let id = UUID()
    var title: String
    var date: Date? // New property to store the date
    
    init(title: String, date: Date?) {
        self.title = title
        self.date = date
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
                    ForEach(reminders) { reminder in
                        VStack(alignment: .leading) {
                            Text(reminder.title)
                                .font(.headline)
                                .foregroundColor(titleTextColor)
                            
                            if let date = reminder.date {
                                Text(formatDate(date))
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            } else {
                                EmptyView() // Hide the text when no date is selected
                            }

                        }
                        .onTapGesture {
                            showEditReminderView(for: reminder)
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
                    
                    Button(action: {
                        showDatePicker.toggle()
                    }) {
                        Text("Select Date")
                    }
                    .padding(.bottom, 16)
                    
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
