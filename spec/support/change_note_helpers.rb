module ChangeNoteHelpers
  
  def create_change_note(user_reference, description, reference, sid)
    allow(Time).to receive(:now).and_return(Time.parse("Jan 1 12:00:00 2000"))
    allow(SecureRandom).to receive(:uuid).and_return(sid)
    item = Annotation::ChangeNote.create(user_reference: user_reference, description: description, reference: reference)
  end

end