require 'rails_helper'

describe BiomedicalConceptPolicy do

  subject { described_class.new(user, biomedical_concept) }
  let (:biomedical_concept) { BiomedicalConcept.new }

  context "for a reader" do

    let(:user) {User.new}

    it "should check out the reader"

=begin
    it { should permit(:index) }
    it { should permit(:show) }
    it { should permit(:view) }
    it { should permit(:list) }
    it { should permit(:history) }

    it { should_not permit(:create) }
    it { should_not permit(:new) }
    it { should_not permit(:update) }
    it { should_not permit(:edit) }
    it { should_not permit(:clone) }
    it { should_not permit(:upgrade) }
    it { should_not permit(:destroy) }
    it { should_not permit(:export_json) }
    it { should_not permit(:export_ttl) }
    it { should_not permit(:import) }
=end
  
  end

  context "for a curator" do

    it "should check out the curator"

=begin
    it { should permit(:index) }
    it { should permit(:show) }
    it { should permit(:view) }
    it { should permit(:list) }
    it { should permit(:history) }
    it { should permit(:create) }
    it { should permit(:new) }
    it { should permit(:update) }
    it { should permit(:edit) }
    it { should permit(:clone) }
    it { should permit(:upgrade) }
    it { should permit(:destroy) }
    it { should permit(:export_json) }
    it { should permit(:export_ttl) }
    
    it { should_not permit(:import) }
=end

  end

  context "for a content admin" do

    it "should check out the content admin"

=begin
    it { should permit(:index) }
    it { should permit(:show) }
    it { should permit(:view) }
    it { should permit(:list) }
    it { should permit(:history) }
    it { should permit(:create) }
    it { should permit(:new) }
    it { should permit(:update) }
    it { should permit(:edit) }
    it { should permit(:clone) }
    it { should permit(:upgrade) }
    it { should permit(:destroy) }
    it { should permit(:export_json) }
    it { should permit(:export_ttl) }
    it { should permit(:import) }
=end

  end

  describe "for a system admin" do

    it "should check out the system admin"

  end

end


