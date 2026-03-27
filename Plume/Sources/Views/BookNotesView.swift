import SwiftUI

// MARK: - Book Notes View
struct BookNotesView: View {
    let book: Book
    @EnvironmentObject var noteStore: NoteStore
    @State private var showingAddNote: Bool = false
    @State private var selectedNote: Note?
    @State private var noteToDelete: Note?
    @State private var showingDeleteAlert: Bool = false

    private var bookNotes: [Note] {
        noteStore.notesForBook(book)
    }

    var body: some View {
        ZStack {
            Color.plumeBackground
                .ignoresSafeArea()

            if bookNotes.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(bookNotes) { note in
                            NoteCard(note: note)
                                .onTapGesture {
                                    selectedNote = note
                                }
                                .contextMenu {
                                    Button {
                                        selectedNote = note
                                    } label: {
                                        Label("View & Edit", systemImage: "pencil")
                                    }

                                    Button {
                                        copyNote(note)
                                    } label: {
                                        Label("Copy Text", systemImage: "doc.on.doc")
                                    }

                                    Divider()

                                    Button(role: .destructive) {
                                        noteToDelete = note
                                        showingDeleteAlert = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle("Notes")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddNote = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.plumeAccent)
                }
                .accessibilityLabel("Add note")
            }
        }
        .sheet(isPresented: $showingAddNote) {
            AddNoteSheet(book: book)
        }
        .sheet(item: $selectedNote) { note in
            EditNoteSheet(note: note)
        }
        .alert("Delete Note?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let note = noteToDelete {
                    noteStore.deleteNote(note)
                }
            }
        } message: {
            if let note = noteToDelete {
                Text("Delete this note from \"\(String(note.text.prefix(50)))\"? This cannot be undone.")
            }
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.plumeAccent.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: "note.text")
                    .font(.system(size: 40))
                    .foregroundColor(.plumeAccent.opacity(0.6))
            }

            VStack(spacing: 8) {
                Text("No notes yet")
                    .font(.custom("Georgia-Bold", size: 20))
                    .foregroundColor(.plumeTextPrimary)

                Text("Capture your thoughts, reactions,\nand insights as you read.")
                    .font(.system(size: 14))
                    .foregroundColor(.plumeTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            Button {
                showingAddNote = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add First Note")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.plumeAccent)
                .cornerRadius(10)
            }
            .padding(.top, 8)

            Spacer()
        }
        .padding(.horizontal, 32)
    }

    private func copyNote(_ note: Note) {
        var text = note.text
        if let page = note.pageNumber {
            text += "\n(Page \(page))"
        }
        text += "\n— \(note.bookAuthor), \(note.bookTitle)"
        UIPasteboard.general.string = text
    }
}

// MARK: - Note Card
struct NoteCard: View {
    let note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(note.text)
                .font(.system(size: 15))
                .foregroundColor(.plumeTextPrimary)
                .lineSpacing(4)
                .lineLimit(6)
                .multilineTextAlignment(.leading)

            Divider()

            HStack(spacing: 8) {
                if let page = note.pageNumber {
                    Label("p. \(page)", systemImage: "book")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.plumeTextSecondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.plumeTextSecondary.opacity(0.1))
                        .cornerRadius(4)
                }

                if let chapter = note.chapterTitle, !chapter.isEmpty {
                    Text(chapter)
                        .font(.system(size: 11))
                        .foregroundColor(.plumeTextSecondary)
                        .lineLimit(1)
                }

                Spacer()

                Text(note.updatedAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 11))
                    .foregroundColor(.plumeTextSecondary.opacity(0.7))
            }
        }
        .padding(14)
        .background(Color.plumeSurface)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Note: \(note.text)\(note.pageNumber.map { " on page \($0)" } ?? "")")
    }
}

// MARK: - Add Note Sheet
struct AddNoteSheet: View {
    let book: Book
    @EnvironmentObject var noteStore: NoteStore
    @EnvironmentObject var streakStore: StreakStore
    @Environment(\.dismiss) private var dismiss

    @State private var noteText: String = ""
    @State private var pageNumber: String = ""
    @State private var chapterTitle: String = ""
    @State private var showingError: Bool = false
    @State private var errorMessage: String = ""

    private var canSave: Bool {
        !noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.plumeBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Book context
                        HStack(spacing: 12) {
                            CoverImageView(book: book, size: CGSize(width: 40, height: 60))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(book.title)
                                    .font(.custom("Georgia-Bold", size: 14))
                                    .foregroundColor(.plumeTextPrimary)
                                    .lineLimit(1)

                                Text(book.author)
                                    .font(.system(size: 12))
                                    .foregroundColor(.plumeTextSecondary)
                                    .lineLimit(1)
                            }

                            Spacer()
                        }
                        .padding(14)
                        .background(Color.plumeSurface)
                        .cornerRadius(10)

                        // Note text
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your Note")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.plumeTextSecondary)

                            TextEditor(text: $noteText)
                                .font(.system(size: 16))
                                .foregroundColor(.plumeTextPrimary)
                                .lineSpacing(4)
                                .frame(minHeight: 180)
                                .padding(12)
                                .background(Color.plumeSurface)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.plumeTextSecondary.opacity(0.15), lineWidth: 1)
                                )
                                .overlay(alignment: .topLeading) {
                                    if noteText.isEmpty {
                                        Text("Write your thoughts, reactions, analysis...")
                                            .font(.system(size: 16))
                                            .foregroundColor(.plumeTextSecondary.opacity(0.5))
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 20)
                                            .allowsHitTesting(false)
                                    }
                                }
                                .accessibilityLabel("Note text")
                        }

                        // Optional metadata
                        VStack(spacing: 12) {
                            FormField(title: "Page Number (optional)", text: $pageNumber, placeholder: "42", keyboard: .numberPad)
                            FormField(title: "Chapter / Section (optional)", text: $chapterTitle, placeholder: "Chapter 3 — The Road")
                        }

                        Spacer(minLength: 32)

                        Button {
                            saveNote()
                        } label: {
                            HStack {
                                Image(systemName: "note.text.badge.plus")
                                Text("Save Note")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(canSave ? Color.plumeAccent : Color.plumeTextSecondary)
                            .cornerRadius(10)
                        }
                        .disabled(!canSave)
                        .accessibilityLabel("Save note")
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Add Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.plumeAccent)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func saveNote() {
        let trimmed = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Please write something in your note."
            showingError = true
            return
        }

        let page: Int? = Int(pageNumber)
        let chapter: String? = chapterTitle.isEmpty ? nil : chapterTitle

        _ = noteStore.addNote(
            text: trimmed,
            bookTitle: book.title,
            bookAuthor: book.author,
            bookId: book.id,
            pageNumber: page,
            chapterTitle: chapter
        )

        // Record reading activity
        streakStore.recordReadingActivity(notesAdded: 1)
        dismiss()
    }
}

// MARK: - Edit Note Sheet
struct EditNoteSheet: View {
    let note: Note
    @EnvironmentObject var noteStore: NoteStore
    @Environment(\.dismiss) private var dismiss

    @State private var noteText: String = ""
    @State private var pageNumber: String = ""
    @State private var chapterTitle: String = ""
    @State private var showingUnsavedAlert: Bool = false

    private var canSave: Bool {
        !noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var hasChanges: Bool {
        noteText != note.text ||
        pageNumber != (note.pageNumber.map { String($0) } ?? "") ||
        chapterTitle != (note.chapterTitle ?? "")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.plumeBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Book context
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(note.bookTitle)
                                    .font(.custom("Georgia-Bold", size: 14))
                                    .foregroundColor(.plumeTextPrimary)
                                    .lineLimit(1)

                                Text(note.bookAuthor)
                                    .font(.system(size: 12))
                                    .foregroundColor(.plumeTextSecondary)
                                    .lineLimit(1)

                                Text("Created \(note.createdAt.formatted(date: .abbreviated, time: .shortened))")
                                    .font(Theme.fontCaption)
                                    .foregroundColor(.plumeTextSecondary.opacity(0.7))
                            }

                            Spacer()
                        }
                        .padding(14)
                        .background(Color.plumeSurface)
                        .cornerRadius(10)

                        // Note text
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your Note")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.plumeTextSecondary)

                            TextEditor(text: $noteText)
                                .font(.system(size: 16))
                                .foregroundColor(.plumeTextPrimary)
                                .lineSpacing(4)
                                .frame(minHeight: 180)
                                .padding(12)
                                .background(Color.plumeSurface)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.plumeTextSecondary.opacity(0.15), lineWidth: 1)
                                )
                                .overlay(alignment: .topLeading) {
                                    if noteText.isEmpty {
                                        Text("Write your thoughts...")
                                            .font(.system(size: 16))
                                            .foregroundColor(.plumeTextSecondary.opacity(0.5))
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 20)
                                            .allowsHitTesting(false)
                                    }
                                }
                        }

                        // Optional metadata
                        VStack(spacing: 12) {
                            FormField(title: "Page Number (optional)", text: $pageNumber, placeholder: "—", keyboard: .numberPad)
                            FormField(title: "Chapter / Section (optional)", text: $chapterTitle, placeholder: "—")
                        }

                        Spacer(minLength: 32)

                        Button {
                            saveNote()
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Save Changes")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(canSave ? Color.plumeAccent : Color.plumeTextSecondary)
                            .cornerRadius(10)
                        }
                        .disabled(!canSave)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Edit Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        if hasChanges {
                            showingUnsavedAlert = true
                        } else {
                            dismiss()
                        }
                    }
                    .foregroundColor(.plumeAccent)
                }
            }
            .alert("Discard Changes?", isPresented: $showingUnsavedAlert) {
                Button("Discard", role: .destructive) {
                    dismiss()
                }
                Button("Keep Editing", role: .cancel) {}
            } message: {
                Text("You have unsaved changes. Are you sure you want to discard them?")
            }
            .onAppear {
                noteText = note.text
                pageNumber = note.pageNumber.map { String($0) } ?? ""
                chapterTitle = note.chapterTitle ?? ""
            }
        }
    }

    private func saveNote() {
        let trimmed = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        noteStore.updateNote(note, newText: trimmed)
        dismiss()
    }
}

#Preview {
    AddNoteSheet(book: .sample)
        .environmentObject(NoteStore())
        .environmentObject(StreakStore())
}
