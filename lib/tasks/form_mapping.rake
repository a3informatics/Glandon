namespace :form do

  desc "Form"

  def mapping(uri)
    query_string = %Q{
      SELECT ?item ?domain_prefix ?sdtm_var_name ?domain_long_name ?sdtm_topic_name ?sdtm_topic_sub WHERE                       
      {  
        {              
          ?sdtm_domain bd:basedOnClass/bd:includesColumn ?topic_var .                                     
          ?topic_var bd:classifiedAs/isoC:prefLabel "Topic"^^xsd:string .           
          ?sdtm_domain bd:includesColumn ?sdtm_topic_var .                                     
          ?sdtm_topic_var bd:basedOnClassVariable|bd:basedOnIgVariable/bd:basedOnClassVariable ?topic_var .           
          ?sdtm_topic_var bd:name ?sdtm_topic_name .            
          ?topic_var bd:isA ?canonical_reference .                                     
          ?bc_root bc:identifiedBy/bc:hasComplexDatatype/bc:hasProperty ?bc_identifier .                      
          ?bc_identifier bc:isA ?canonical_reference .                        
          ?bc_identifier bc:hasCodedValue/bo:reference/th:notation ?sdtm_topic_sub .                                 
          ?sdtm_domain bd:prefix ?domain_prefix .                                                    
          ?sdtm_domain isoC:label ?domain_long_name .                      
          {                                               
            SELECT ?item ?bc_root ?sdtm_domain_var ?sdtm_var_name ?sdtm_domain WHERE                               
            {                                          
              #{uri.to_ref} bf:hasGroup/bf:hasSubGroup* ?group .                                                     
              ?group bf:ordinal ?gord .                                                     
              ?group bf:hasItem ?item .               
              ?item bf:ordinal ?pord .               
              ?item bf:hasProperty ?op_ref1 .               
              ?group bf:hasItem/bf:hasProperty ?op_ref1 .                                                                    
              ?op_ref1 bo:reference ?bc_property .                              
              ?bc_property bc:isA ?ref .                                                                    
              ?sdtm_domain_var bd:isA ?ref .                                                                    
              ?sdtm_domain_var bd:name ?sdtm_var_name .                          
              ?sdtm_domain bd:includesColumn ?sdtm_domain_var .                                                  
              ?sdtm_domain ^bo:theSubject ?assoc .                                                 
              ?bc_root ^bo:associatedWith ?assoc .                                                 
              ?bc_root (bc:hasItem/bc:hasComplexDatatype/bc:hasProperty) ?bc_property .                      
            } ORDER BY ?gord ?pord                                        
          }
        } UNION
        {
          ?col bd:name ?sdtm_var_name .           
          ?dataset bd:includesColumn ?col .           
          ?dataset bd:prefix ?domain_prefix .           
          ?dataset isoC:label ?domain_long_name .
          BIND ( "" as ?sdtm_topic_name )
          BIND ( "" as ?sdtm_topic_sub )
          {              
            SELECT ?group ?item ?sdtm_var_name ?gord ?pord WHERE             
            {                
              #{uri.to_ref} bf:hasGroup/bf:hasSubGroup* ?group .                                                                        
              ?group bf:ordinal ?gord .               
              ?group (bf:hasItem)+ ?item .               
              ?item bf:mapping ?sdtm_var_name .               
              ?item bf:ordinal ?pord .             
            } ORDER BY ?gord ?pord            
          }         
        }                                   
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :isoI, :isoT, :isoR, :th, :bf, :bo, :bd, :bc])
    items = query_results.by_object_set([:item, :domain_prefix, :sdtm_var_name, :domain_long_name, :sdtm_topic_name, :sdtm_topic_sub])
    display_results("Form Mapping", items, ["Item", "Prefix", "Variable", "Domain", "Topic", "Submission"], [60, 0, 0, 0, 0, 0])
    items
  end

  # Actual rake task
  task :mapping => :environment do
    
    include RakeDisplay
    include RakeFile

    ARGV.each { |a| task a.to_sym do ; end }
    abort("A single URI should be supplied") if ARGV.count == 1
    abort("Only a single parameter (a URI) should be supplied") unless ARGV.count == 2
    uri_s = URI.parse(ARGV[1])
    abort("URI does not look valid: #{uri_s}") unless uri_s.is_a?(URI::HTTP) && !uri_s.host.nil?
    uri = Uri.new(uri: ARGV[1])
    mapping(uri)
  end

end