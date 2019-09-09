require 'rails_helper'

describe Thesaurus do

  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers

  def sub_dir
    return "models/thesaurus/submission"
  end

  before :all do
    schema_files = 
    [
      "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", 
      "ISO11179Concepts.ttl", "BusinessOperational.ttl", "thesaurus.ttl"
    ]
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    load_versions((1..59))
    @status_map = {:~ => :not_present, :- => :no_change, :C => :created, :U => :updated, :D => :deleted}
  end

  after :all do
    delete_all_public_test_files
  end

  def load_version(version)
    load_data_file_into_triple_store("cdisc/ct/CT_V#{version}.ttl")
  end

  def load_versions(range)
    range.each {|n| load_version(n)}
  end

  def check_submission(actual, expected)
    result = true
    expected.each do |version|
puts "***** A: #{actual[:items].count}, E: #{version[:expected].count} *****"
      version[:expected].each do |expect|
        if actual[:items].key?(expect[:key])
          item = actual[:items][expect[:key]]
          index = actual[:versions].index(expected[:date])
          if !index.nil?
            status = item[:status][index]
            correct = expect[:notation] == status[:notation] && expect[:previous] == status[:previous]
            puts colourize("Mismatch for #{expect[:key]}, date: #{expect[:date]} found '#{status[:previous]}' -> '#{status[:notation]}', expected '#{expect[:previous]}' -> '#{expect[:notation]}'", "red") if !correct
            puts colourize("Match for #{expect[:key]}, date: #{expect[:date]} found '#{status[:previous]}' -> '#{status[:notation]}', expected '#{expect[:previous]}' -> '#{expect[:notation]}'", "green") if correct
            result = result && correct
          else
            puts colourize("Date not found for #{expect[:key]}, date: #{expect[:date]} nothing found, expected '#{expect[:previous]}' -> '#{expect[:notation]}'", "red") if !correct
            result = result && correct
          end
        else
          puts colourize("No result found for expected #{expect[:key]}, date: #{expect[:date]}. Expected '#{expect[:previous]}' -> '#{expect[:notation]}'", "red") if !correct
          result = result && correct
        end
      end
    end
    result
  end

  it "submission changes" do
    expected =
    [
      { version: 1, count: 0, date: "2007-03-60", expected: [] },
      { version: 2, count: 0, date: "2007-04-20", expected:
        [ 
          {key: :C65047_C64809, previous: "NA", notation: "SODIUM" }
        ]
      },
      { version: 3, count: 0, date: "2007-04-26", expected:
        [
          { key: :C66737_C49687, previous: "Phase IIIA Trial", notation: "Phase IIIaTrial" }
        ]
      },
      { version: 4, count: 0, date: "2007-05-31", expected:
        [ 
          { key: :C66790_C43234, previous: "Not reported", notation: "NOT REPORTED" },
          { key: :C67152_C20587, previous: "Age Span",     notation: "Age Group" }
        ]
      },
      { version: 5, count: 0, date: "2007-06-05", expected: [] }, # No changes
      { version: 6, count: 0, date: "2008-01-15", expected: [] }, # No changes
      { version: 7, count: 0, date: "2008-01-25", expected: [] }, # No changes
      { version: 8, count: 0, date: "2008-08-26", expected: [] }, # No changes
      { version: 9, count: 0, date: "2008-09-22", expected: [] }, # No changes
      { version: 10, count: 0, date: "2008-09-24", expected: [] }, # No changes
      { version: 11, count: 0, date: "2008-09-30", expected: [] }, # No changes
      { version: 12, count: 0, date: "2008-10-09", expected: [] }, # No changes
      { version: 13, count: 0, date: "2008-10-15", expected: [] }, # No changes
      { version: 14, count: 0, date: "2009-02-17", expected: [] }, # No changes
      { version: 15, count: 0, date: "2009-02-18", expected:
        [ 
          { key: :C78735_C42708, previous: "PARENT", notation: "CHILD" }
        ]
      },
      { version: 16, count: 0, date: "2009-05-01", expected:
        [ 
          { key: :C78735_C42708, previous: "PARENT", notation: "CHILD" },
          { key: :C67154_C74761, previous: "Albumin/Creatinine Ratio", notation: "Albumin/Creatinine" }
        ]      
      },
      { version: 17, count: 0, date: "2009-07-06", expected:
        [ 
          { key: :C78735_C42708, previous: "PARENT", notation: "CHILD" },
          { key: :C67154_C64798, previous: "Ery. Mean Corpuscular HB Concentration", notation: "Ery. Mean Corpuscular HGB Concentration" }
        ]
      },
      { version: 18, count: 0, date: "2009-10-06", expected:
        [ 
          { key: :C78735_C42708, previous: "PARENT", notation: "CHILD" }
        ]
      },
      { version: 19, count: 0, date: "2010-03-05", expected: [] }, # No changes
      { version: 20, count: 0, date: "2010-04-08", expected:
        [
          { key: :C85491_C86641, previous: "PEDIOCOCCUS SPECIES", notation: "PEDIOCOCCUS" }
        ]
      },
      { version: 21, count: 0, date: "2010-07-02", expected:
        [
          { key: :C76351_C74573, previous: "TYPE5", notation: "TYPEV" }
        ]
      },
      { version: 22, count: 0, date: "2010-10-06", expected:
        [
          { key: :C85491_C86456, previous: "KLEBSIELLA PNEUMONIAE SUBSP. OZAENAE", notation: "KLEBSIELLA OZAENAE" }
        ]
      },
      { version: 23, count: 0, date: "2010-10-22", expected: [] }, # No changes
      { version: 24, count: 0, date: "2011-01-07", expected: [] }, # No changes
      { version: 25, count: 0, date: "2011-04-08", expected: 
        [
          { key: :C67154_C51951, notation: "Platelets", previous: "Platelet" }
        ]
      },
      { version: 26, count: 0, date: "2011-06-10", expected: [] }, # No changes
      { version: 27, count: 0, date: "2011-07-22", expected: [] }, # No changes
      { version: 28, count: 0, date: "2011-12-09", expected:
        [
          { key: :C67154_C92241, previous: "Mycobacterium tuberculosis IFN Gamma Response", notation: "M. tuberculosis IFN Gamma Response" },
          { key: :C66786_C64377, previous: "SCG", notation: "SRB" }
        ]
      },
      { version: 29, count: 0, date: "2012-03-23", expected:
        [ 
          {key: :C74456_C32973, previous: "THYROID GLAND, RIGHT LOBE", notation: "THYROID GLAND, LEFT LOBE" }
        ]
      },
      { version: 30, count: 0, date: "2012-06-29", expected:
        [
          { key: :C78425_C38258, previous: "INTRAPERITEONEAL", notation: "INTRAPERITONEAL" }
        ]
      },
      { version: 31, count: 0, date: "2012-08-03", expected: [] },
      { version: 32, count: 0, date: "2012-12-21", expected: [] },
      { version: 33, count: 0, date: "2013-04-12", expected: [] },
      { version: 34, count: 0, date: "2013-06-28", expected: [] },
      { version: 35, count: 0, date: "2013-10-04", expected: [] },
      { version: 36, count: 0, date: "2013-12-20", expected:
        [ 
          {key: :C67154_C96666, previous: "Herpes Simplex Virus 1/2 IgM Antibody", notation: "Herpes Simplex Virus 1 IgG Antibody" },
          {key: :C67154_C96697, previous: "Herpes Simplex Virus 1 IgG Antibody", notation: "Herpes Simplex Virus 1/2 IgG Antibody" }
        ]
      },
      { version: 37, count: 0, date: "2014-03-28", expected: [] },
      { version: 38, count: 0, date: "2014-06-27", expected:
        [ 
          { key: :C101859_C17998,  previous: "Unknown", notation: "UNKNOWN" },
          { key: :C101841_C100040, previous: "TIMI-0", notation: "GRADE 0" }
        ]
      },
      { version: 39, count: 0, date: "2014-09-26", expected: [] },
      { version: 40, count: 0, date: "2014-10-06", expected: [] },
      { version: 41, count: 0, date: "2014-12-19", expected:
        [ 
          { key: :C101841_C100040,   previous: "GRADE 0",          notation: "TIMI GRADE 0"},
          { key: :C66737_C15600,     previous: "Phase I Trial",    notation: "PHASE I TRIAL"},
          { key: :C71620_C48500,     previous: "IN",               notation: "in"},
          { key: :C101840_C77271,    previous: "Killip CLASS III", notation: "KILLIP CLASS III"}
        ]
      },
      { version: 42, count: 0, date: "2015-03-27", expected: [] },
      { version: 43, count: 0, date: "2015-06-26", expected:
        [ 
          { key: :C103330_C17953, previous: "Education Level", notation: "Level of Education Attained"}
        ]
      },
      { version: 44, count: 0, date: "2015-09-25", expected:
        [ 
          { key: :C111342_C111467, previous: "CSS0904B", notation: "CSS0904A"}
        ]
      },
      { version: 45, count: 0, date: "2015-12-18", expected:
        [ 
          { key: :C71620_C66965,     previous: "per sec",                              notation: "/sec"},
          { key: :C71620_C66967,     previous: "per min",                              notation: "/min"},
          { key: :C100129_C102121,   previous: "SF36 v2.0 ACUTE",                      notation: "SF36 V2.0 ACUTE"},
          { key: :C100129_C100775,   previous: "SF36 v1.0 STANDARD",                   notation: "SF36 V1.0 STANDARD"}
        ]
      },
      { version: 46, count: 0, date: "2016-03-25", expected: [] },
      { version: 47, count: 0, date: "2016-06-24", expected: [] },
      { version: 48, count: 0, date: "2016-09-30", expected: [] },
      { version: 49, count: 0, date: "2016-12-16", expected:
        [ 
          { key: :C128689_C43823,    previous: "BHUTANESE",                            notation: "BARBADIAN"},
          { key: :C67154_C106514,    previous: "Cytokeratin Fragment 21-1",            notation: "Cytokeratin 19 Fragment 21-1"},
          { key: :C101847_C116146,   previous: "LATELOSS",                             notation: "LLMLOSS"},
          { key: :C71620_C122230,    previous: "ugeq/L",                               notation: "ugEq/L"}
        ]
      },
      { version: 50, count: 0, date: "2017-03-31", expected: 
        [ 
          { key: :C65047_C116210,    previous: "PRA",                                  notation: "PRAB"},
          { key: :C106650_C106926,   previous: "ADL03-Select items Without Help",      notation: "ADL03-Select Items Without Help"},
          { key: :C100153_C101013,   previous: "FPSR1-How Much do you Hurt",           notation: "FPSR1-How Much Do You Hurt"},
          { key: :C112450_C112688,   previous: "SGRQ02-If You Have Ever Held a job",   notation: "SGRQ02-If You Have Ever Held a Job"}
        ]
      },
      { version: 51, count: 0, date: "2017-06-30", expected:
        [ 
          { key: :C85491_C112031,    previous: "FILOVIRUS",                            notation: "FILOVIRIDAE"},
          { key: :C100129_C100763,   previous: "CGI",                                  notation: "CGI GUY"},
          { key: :C124298_C125992,   previous: "BRUGGERMAN MRD 2010",                  notation: "BRUGGEMANN MRD 2010"},
          { key: :C124298_C126013,   previous: "HARTMANN PANCREATIC CANCER 2012",      notation: "HARTMAN PANCREATIC CANCER 2012"}
        ]
      },
      { version: 52, count: 0, date: "2017-09-29", expected:
        [ 
          { key: :C74456_C12774,     previous: "ARTERY, PULMONARY",          notation: "PULMONARY ARTERY BRANCH"},
          { key: :C120528_C128982,   previous: "Mycobacterium Tuberculosis", notation:  "Mycobacterium tuberculosis"}
        ]
      },
      { version: 53, count: 0, date: "2017-12-22", expected: 
        [ 
          { key: :C120528_C128983, previous: "Mycobacterium Tuberculosis Complex",   notation: "Mycobacterium tuberculosis Complex"}
        ]
      },    
      { version: 54, count: 0, date: "2018-03-30", expected: 
        [
          { key: :C120528_C132416, notation: "Microbial Organism Identification", previous: "Microbial Organism Detected" }
        ]
      },
      { version: 55, count: 0, date: "2018-06-29", expected:
        [
          { key: :C100129_C147585, notation: "FACIT-FATIGUE 13-Item V4", previous: "FACIT-FATIGUE V4" }
        ]
      },
      { version: 56, count: 0, date: "2018-09-28", expected: 
        [
          { key: :C100129_C147585, previous: "FACIT-FATIGUE 13-Item V4",  notation: "FACIT-FATIGUE 13-ITEM V4" },
          { key: :C71620_C77535,   previous: "NIU",                       notation: "RFU" }
        ]
      },
      { version: 57, count: 0, date: "2018-12-21", expected: 
        [
          { key: :C67154_C81958, previous: "Antithrombin",  notation: "Antithrombin Activity" }, 
          { key: :C65047_C81958, previous: "ANTHRM",        notation: "ANTHRMA" } 
        ]
      },
      { version: 58, count: 0, date: "2019-03-29", expected: 
        [
          { key: :C67154_C154736,   previous: "E-selectin",                 notation: "E-Selectin" },
          { key: :C67154_C154753,   previous: "Calcium, Albumin Corrected", notation: "Calcium Corrected for Albumin" },
          { key: :C127265_C154862,  previous: "HETEROSEXUAL CONTACT",       notation: "OPPOSITE-SEX SEXUAL CONTACT" },
          { key: :C127265_C154863,  previous: "HOMOSEXUAL CONTACT",         notation: "SAME-SEX SEXUAL CONTACT" }
        ]
      },
      { version: 59, count: 0, date: "2019-06-28", expected: 
        [ 
          { key: :C119069_C119174,  previous: "DLQI-Score",             notation: "DLQI1-Score" },
          { key: :C85491_C117361,   previous: "PNEUMOCYSTIS JIROVECI",  notation: "PNEUMOCYSTIS JIROVECII" }
        ]
      }
    ]    
    result = true
    first = 1
    last = 59
    (first..(last-1)).each do |version|
      puts "***** V#{version}, #{expected.find{|x| x[:version] == version}[:date]} *****"
      ct = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V#{version}#TH"))
      actual = ct.submission(1)
      next_result = check_submission(actual, expected.find{|x| x[:version] == version})
      check_file_actual_expected(actual, sub_dir, "submission_expected_#{version}.yaml", equal_method: :hash_equal)
      result = result && next_result
    end
    expect(result).to be(true)
  end

end