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
    @State private var isEditingTitle = false

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
                        VStack(alignment: .leading) { // Wrap the content in a VStack
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
                                    Text(reminder.title)
                                        .font(.headline)
                                        .foregroundColor(titleTextColor)
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
                            
                            if let date = reminder.date { // Check if the date exists
                                Text(formatDate(date)) // Display the formatted date
                                    .foregroundColor(.secondary) // Adjust the color if needed
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
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                            .frame(alignment: .trailing) // Set a fixed width and alignment
                            .padding(.leading)
                        Text("Date")
                            .font(.headline)
                            .foregroundColor(titleTextColor)
                            .frame(width: 80, alignment: .leading)
                        
                        Toggle("", isOn: $showDatePicker)
                            .padding(.trailing)
                    }
                
                    if let selectedDate = selectedDate {
                        HStack {
                            Text(formatDate(selectedDate))
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 8) // Add a top padding for spacing
                    }

                    if showDatePicker {
                        DatePicker("", selection: Binding<Date>(
                            get: {
                                selectedDate ?? Date()
                            },
                            set: {
                                selectedDate = $0
                            }), displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .labelsHidden()
                            .padding(.horizontal)
                            .padding(.bottom) // Add a bottom padding for spacing
                        
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
            if let date = reminder.date {
                NotificationManager.scheduleNotification(for: "\(reminder.title) - \(formatDate(date))", at: date, withIdentifier: reminder.id.uuidString)
            }
        }
        isEditingTitle = false
        reminders.indices.forEach { index in
            reminders[index].isEditable = false
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
