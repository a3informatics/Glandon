require 'rails_helper'
require 'rake'

describe 'V3.1.0 schema migration' do
  
  before :all do
    Rake.application.rake_require "tasks/v3_2_0_schema"
    Rake::Task.define_task(:environment)
  end

  def sub_dir
    return "tasks/v3_2_0/schema"
  end

  def old_version_triples
    %Q{
      <http://www.assero.co.uk/ISO11179Types> owl:versionInfo \"Created with TopBraid Composer\"^^xsd:string .
      <http://www.assero.co.uk/ISO11179Concepts> owl:versionInfo \"Created with TopBraid Composer\"^^xsd:string .
      <http://www.assero.co.uk/ISO11179Registration> owl:versionInfo \"Created with TopBraid Composer\"^^xsd:string .
      <http://www.assero.co.uk/BusinessForm> owl:versionInfo \"Created with TopBraid Composer\"^^xsd:string .
      <http://www.s-cubed.dk/ComplexDatatypes#> rdf:type owl:Ontology .
      <http://www.assero.co.uk/BiomedicalConcept#BiomedicalConcept> rdfs:subClassOf <http://www.assero.co.uk/ISO11179Concepts#Concept> ;
    }
  end

  describe 'schema' do
    
    before :each do
      # Set of schema files pre migration
      schema_files = 
      [
        "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", 
        "ISO11179Concepts.ttl", "business_operational.ttl", "annotations.ttl", "complex_datatype.ttl",
        "framework.ttl", "BusinessForm.ttl", "biomedical_concept.ttl", "BusinessDomain.ttl", 
        "thesaurus.ttl"
      ]
      clear_triple_store
      schema_files.each {|x| load_local_file_into_triple_store(sub_dir, x)}
      @rdf_type = Uri.new(uri: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type")
      @owl_version_info = Uri.new(uri: "http://www.w3.org/2002/07/owl#versionInfo")
      @skos_def = Uri.new(uri: "http://www.w3.org/2004/02/skos/core#definition")
      @rdfs_label = Uri.new(uri: "http://www.w3.org/2000/01/rdf-schema#label")
      @rdfs_sub_class_of = Uri.new(uri: "http://www.w3.org/2000/01/rdf-schema#subClassOf")
    end

    def expected_triple_count
      1461
    end

    def check_triple(triples, predicate, value)
      expect(triples.find{|x| x[:p] == predicate.to_s}[:o]).to eq(value)
    end

    def check_deletion
      expect(Sparql::Utility.new.ask?(old_version_triples, [:owl])).to be(false)
    end

    def check_migrations  
      # Check sample of new triples
      [
        { 
          subject: Uri.new(uri: "http://www.assero.co.uk/Annotations"),
          label: "Annotation Schema"
        }, 
        { 
          subject: Uri.new(uri: "http://www.assero.co.uk/BiomedicalConcept"),
          label: "Biomedical Concept Schema"
        }, 
        { 
          subject: Uri.new(uri: "http://www.assero.co.uk/BusinessForm"),
          label: "Form Schema"
        }, 
        { 
          subject: Uri.new(uri: "http://www.assero.co.uk/BusinessOperational"),
          label: "Operational Schema"
        },
        { 
          subject: Uri.new(uri: "http://www.s-cubed.dk/ComplexDatatypes"),
          label: "Complex Datatype Schema"
        }, 
        { 
          subject: Uri.new(uri: "http://www.s-cubed.dk/Framework"),
          label: "Framework Schema"
        }, 
        {
          subject: Uri.new(uri: "http://www.assero.co.uk/ISO11179Concepts"),
          label: "ISO11179 Concepts Schema"
        },
        { 
          subject: Uri.new(uri: "http://www.assero.co.uk/ISO11179Identification"),
          label: "ISO11179 Identification Schema"
        }, 
        { 
          subject: Uri.new(uri: "http://www.assero.co.uk/ISO11179Registration"),
          label: "ISO11179 Registration Schema"
        }, 
        { 
          subject: Uri.new(uri: "http://www.assero.co.uk/ISO11179Types"),
          label: "ISO11179 Types Schema"
        }, 
        { 
          subject: Uri.new(uri: "http://www.assero.co.uk/Thesaurus"),
          label: "Thesaurus Schema"
        }
      ].each do |x|
        triples = triple_store.subject_triples(x[:subject], true)
        check_triple(triples, @rdf_type, "http://www.w3.org/2002/07/owl#Ontology")
        check_triple(triples, @owl_version_info, "v3.2.0")
        check_triple(triples, @rdfs_label, x[:label])  
      end
      # Check for the change in sub class for BCs
      triples = triple_store.subject_triples(Uri.new(uri: "http://www.assero.co.uk/BiomedicalConcept#BiomedicalConcept"), true)
      check_triple(triples, @rdfs_sub_class_of, "http://www.assero.co.uk/BusinessOperational#Component")
      triples = triple_store.subject_triples(Uri.new(uri: "http://www.assero.co.uk/BiomedicalConcept#Assessment"), true)
      check_triple(triples, @rdfs_sub_class_of, "http://www.assero.co.uk/BusinessOperational#Component")
    end

    def check_still_old
      expect(Sparql::Utility.new.ask?(old_version_triples, [:owl])).to be(true)
    end

    def mark_done
      Sparql::Update.new.sparql_update(%Q{DELETE DATA {#{old_version_triples}}}, "", [:owl])
    end

    let :run_rake_task do
      Rake::Task["v3_2_0:schema"].reenable
      Rake.application.invoke_task "v3_2_0:schema"
    end

    # Used to find new schema triple count, dont' delete
    # it "new triple count" do
    #   schema_files = [
    #     "annotations_migration_20200720.ttl",
    #     "biomedical_concept_migration_20200720.ttl",
    #     "business_form_migration_20200720.ttl",
    #     "business_operational_migration_20200720.ttl",
    #     "complex_datatype_migration_20200720.ttl",
    #     "framework_migration_20200720.ttl",
    #     "iso11179_concepts_migration_20200720.ttl",
    #     "iso11179_identification_migration_20200720.ttl",
    #     "iso11179_registration_migration_20200720.ttl",
    #     "iso11179_types_migration_20200720.ttl",
    #     "thesaurus_migration_20200720.ttl"
    #   ]
    #   load_files(schema_files, [])
    #   expect(triple_store.triple_count).to eq(22)
    # end

    it "add V3.2.0 schema" do
      # Definitions, check triple store count
      expected = 22 - 4 # Number of extra triples. Minus due to ontology triples that already existed
      base = triple_store.triple_count
      expect(base).to eq(expected_triple_count)

      # Old triples check
      check_still_old

      # Run migration
      run_rake_task

      # Check results
      expect(triple_store.triple_count).to eq(base + expected)
      check_deletion
      check_migrations  
    end

    it "won't run second time" do
      mark_done
      expect{run_rake_task}.to raise_error(SystemExit, "Schema migration not required")
    end

    it 'add V3.2.0 schema, exception first upload' do
      # Definitions, check triple store count
      expected = -7 # Number of extra triples, only deleted.
      base = triple_store.triple_count
      expect(base).to eq(expected_triple_count)

      # Old triples check
      check_still_old

      # Run migration
      expect_any_instance_of(Sparql::Upload).to receive(:send).and_raise("ERROR")
      expect{run_rake_task}.to raise_error(SystemExit, /Schema migration error, step: 2/)
        
      # Check triple count, no change and updated triples, should still be old version
      expect(triple_store.triple_count).to eq(base + expected)
      check_deletion
    end

    it 'add V3.2.0 schema, exception second upload' do
      # Definitions, check triple store count
      expected = -7 # Number of extra triples, only deleted.
      base = triple_store.triple_count
      expect(base).to eq(expected_triple_count)

      # Old triples check
      check_still_old

      # Run migration
      call_count = 0
      allow_any_instance_of(Sparql::Upload).to receive(:send) do
        call_count += 1
        call_count == 2 ? raise("ERROR") : ""
      end
      expect{run_rake_task}.to raise_error(SystemExit, /Schema migration error, step: 3/)
        
      # Check triple count, no change and updated triples, should still be old version
      expect(triple_store.triple_count).to eq(base + expected)
      check_deletion
    end

    it 'add V3.2.0 schema, exception last upload' do
      # Definitions, check triple store count
      expected = -7 # Number of extra triples, only deleted.
      base = triple_store.triple_count
      expect(base).to eq(expected_triple_count)

      # Old triples check
      check_still_old

      # Run migration
      call_count = 0
      allow_any_instance_of(Sparql::Upload).to receive(:send) do
        call_count += 1
        call_count == 11 ? raise("ERROR") : ""
      end
      expect{run_rake_task}.to raise_error(SystemExit, /Schema migration error, step: 12/)
        
      # Check triple count, no change and updated triples, should still be old version
      expect(triple_store.triple_count).to eq(base + expected)
      check_deletion
    end

    it 'add V3.2.0 schema, exception seventh upload' do
      # Definitions, check triple store count
      expected = -7 # Number of extra triples, only deleted.
      base = triple_store.triple_count
      expect(base).to eq(expected_triple_count)

      # Old triples check
      check_still_old

      # Run migration
      call_count = 0
      allow_any_instance_of(Sparql::Upload).to receive(:send) do
        call_count += 1
        call_count == 7 ? raise("ERROR") : ""
      end
      expect{run_rake_task}.to raise_error(SystemExit, /Schema migration error, step: 8/)
        
      # Check triple count, no change and updated triples, should still be old version
      expect(triple_store.triple_count).to eq(base + expected)
      check_deletion
    end

    it 'add V3.2.0 schema, exception update' do
      # Definitions, check triple store count
      expected = 0 # No change
      base = triple_store.triple_count
      expect(base).to eq(expected_triple_count)

      # Old triples check
      check_still_old

      # Run migration
      expect_any_instance_of(Sparql::Update).to receive(:sparql_update).and_raise("ERROR")
      expect{run_rake_task}.to raise_error(SystemExit, /Schema migration error, step: 1/)
        
      # Check triple count, no change, updated triples should still be old and new triples 
      # should be present
      expect(triple_store.triple_count).to eq(base + expected)
      check_still_old
    end

    it 'add V3.2.0 schema, success checks fail I' do
      base = triple_store.triple_count
      expect(base).to eq(expected_triple_count)

      # Run migration
      call_index = -1
      result = [1438, 1200] # Two calls expected, initial count and updated count.
      allow_any_instance_of(Sparql::Utility).to receive(:triple_count) do |arg|
        call_index += 1
        result[call_index]
      end
      expect{run_rake_task}.to raise_error(SystemExit, /Schema migration not succesful, checks failed/)
    end

    it 'add V3.2.0 schema, success checks fail II' do
      base = triple_store.triple_count
      expect(base).to eq(expected_triple_count)

      # Run migration
      call_index = -1
      result = 
      [
        true,  true,  true, true,  true,  true, # Triples present check
        false, false, true, false, false, false # Triples deleted check
      ] 
      allow_any_instance_of(Sparql::Utility).to receive(:ask?) do |arg|
        call_index += 1
        result[call_index]
      end
      expect{run_rake_task}.to raise_error(SystemExit, /Schema migration not succesful, checks failed/)
    end

  end

end