import SwiftUI

struct RemindersView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var reminders: [String] = []
    @State private var newReminder: String = ""
    @State private var selectedDate = Date()
    @State private var showDatePicker = false
    @State private var showEditReminder = false
    @State private var editReminderIndex = 0
    @State private var showAddReminder = false
    
    private var formattedSelectedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: selectedDate)
    }
    
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
                        let components = reminder.components(separatedBy: " - ")
                        let title = components[0]
                        
                        Button(action: {
                            showEditReminderView(for: index)
                        }) {
                            VStack(alignment: .leading) {
                                Text(title)
                                    .font(.headline)
                                    .foregroundColor(titleTextColor)
                                
                                Text(formattedSelectedDate)
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .onDelete(perform: deleteReminder)
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
                        DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
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
            EditReminder(reminder: $reminders[editReminderIndex], selectedDate: $selectedDate, isPresented: $showEditReminder)
        }
    }
    
    private func showEditReminderView(for index: Int) {
        editReminderIndex = index
        showEditReminder = true
    }
    
    private func addReminder() {
        guard !newReminder.isEmpty else { return }
        
        let reminder = "\(newReminder) - \(formattedSelectedDate)"
        reminders.append(reminder)
        newReminder = ""
        showDatePicker = false
        
        NotificationManager.scheduleNotification(for: reminder, at: selectedDate)
    }
    
    private func deleteReminder(at offsets: IndexSet) {
        reminders.remove(atOffsets: offsets)
    }
}
