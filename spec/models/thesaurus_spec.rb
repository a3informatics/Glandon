require 'rails_helper'

describe Thesaurus do
  it "returns a list of unique identifiers" do
    sparql_result = '<?xml version="1.0"?>
      <sparql xmlns="http://www.w3.org/2005/sparql-results#">
        <head>
          <variable name="d"/>
          <variable name="e"/>
          <variable name="f"/>
          <variable name="g"/>
        </head>
        <results>
          <result>
            <binding name="d">
              <literal>CDISC Terminology</literal>
            </binding>
            <binding name="e">
              <literal>CDISC Terminology 2016-03-25</literal>
            </binding>
            <binding name="f">
              <uri>http://www.assero.co.uk/MDRItems#NS-CDISC</uri>
            </binding>
            <binding name="g">
              <literal datatype="http://www.w3.org/2001/XMLSchema#integer">44</literal>
            </binding>
          </result>
          <result>
            <binding name="d">
              <literal>CDISC Terminology</literal>
            </binding>
            <binding name="e">
              <literal>CDISC Terminology 2015-12-18</literal>
            </binding>
            <binding name="f">
              <uri>http://www.assero.co.uk/MDRItems#NS-CDISC</uri>
            </binding>
            <binding name="g">
              <literal datatype="http://www.w3.org/2001/XMLSchema#integer">43</literal>
            </binding>
          </result>
          <result>
            <binding name="d">
              <literal>CDISC Terminology</literal>
            </binding>
            <binding name="e">
              <literal>CDISC Terminology 2015-09-25</literal>
            </binding>
            <binding name="f">
              <uri>http://www.assero.co.uk/MDRItems#NS-CDISC</uri>
            </binding>
            <binding name="g">
              <literal datatype="http://www.w3.org/2001/XMLSchema#integer">42</literal>
            </binding>
          </result>
          <result>
            <binding name="d">
              <literal>CDISC Terminology</literal>
            </binding>
            <binding name="e">
              <literal>CDISC Terminology 2015-06-26</literal>
            </binding>
            <binding name="f">
              <uri>http://www.assero.co.uk/MDRItems#NS-CDISC</uri>
            </binding>
            <binding name="g">
              <literal datatype="http://www.w3.org/2001/XMLSchema#integer">41</literal>
            </binding>
          </result>
          <result>
            <binding name="d">
              <literal>CDISC Terminology</literal>
            </binding>
            <binding name="e">
              <literal>CDISC Terminology 2015-03-27</literal>
            </binding>
            <binding name="f">
              <uri>http://www.assero.co.uk/MDRItems#NS-CDISC</uri>
            </binding>
            <binding name="g">
              <literal datatype="http://www.w3.org/2001/XMLSchema#integer">40</literal>
            </binding>
          </result>
          <result>
            <binding name="d">
              <literal>CDISC Terminology</literal>
            </binding>
            <binding name="e">
              <literal>CDISC Terminology 2014-12-16</literal>
            </binding>
            <binding name="f">
              <uri>http://www.assero.co.uk/MDRItems#NS-CDISC</uri>
            </binding>
            <binding name="g">
              <literal datatype="http://www.w3.org/2001/XMLSchema#integer">39</literal>
            </binding>
          </result>
          <result>
            <binding name="d">
              <literal>CDISC Terminology</literal>
            </binding>
            <binding name="e">
              <literal>CDISC Terminology 2014-10-06</literal>
            </binding>
            <binding name="f">
              <uri>http://www.assero.co.uk/MDRItems#NS-CDISC</uri>
            </binding>
            <binding name="g">
              <literal datatype="http://www.w3.org/2001/XMLSchema#integer">38</literal>
            </binding>
          </result>
          <result>
            <binding name="d">
              <literal>CDISC Terminology</literal>
            </binding>
            <binding name="e">
              <literal>CDISC Terminology 2014-09-24</literal>
            </binding>
            <binding name="f">
              <uri>http://www.assero.co.uk/MDRItems#NS-CDISC</uri>
            </binding>
            <binding name="g">
              <literal datatype="http://www.w3.org/2001/XMLSchema#integer">37</literal>
            </binding>
          </result>
          <result>
            <binding name="d">
              <literal>CDISC Terminology</literal>
            </binding>
            <binding name="e">
              <literal>CDISC Terminology 2014-06-27</literal>
            </binding>
            <binding name="f">
              <uri>http://www.assero.co.uk/MDRItems#NS-CDISC</uri>
            </binding>
            <binding name="g">
              <literal datatype="http://www.w3.org/2001/XMLSchema#integer">36</literal>
            </binding>
          </result>
          <result>
            <binding name="d">
              <literal>CDISC Terminology</literal>
            </binding>
            <binding name="e">
              <literal>CDISC Terminology 2014-03-28</literal>
            </binding>
            <binding name="f">
              <uri>http://www.assero.co.uk/MDRItems#NS-CDISC</uri>
            </binding>
            <binding name="g">
              <literal datatype="http://www.w3.org/2001/XMLSchema#integer">35</literal>
            </binding>
          </result>
          <result>
            <binding name="d">
              <literal>CDISC Terminology</literal>
            </binding>
            <binding name="e">
              <literal>CDISC Terminology 2013-12-20</literal>
            </binding>
            <binding name="f">
              <uri>http://www.assero.co.uk/MDRItems#NS-CDISC</uri>
            </binding>
            <binding name="g">
              <literal datatype="http://www.w3.org/2001/XMLSchema#integer">34</literal>
            </binding>
          </result>
          <result>
            <binding name="d">
              <literal>CDISC_EXT</literal>
            </binding>
            <binding name="e">
              <literal>CDISC Extensions</literal>
            </binding>
            <binding name="f">
              <uri>http://www.assero.co.uk/MDRItems#NS-ACME</uri>
            </binding>
            <binding name="g">
              <literal datatype="http://www.w3.org/2001/XMLSchema#integer">1</literal>
            </binding>
          </result>
        </results>
      </sparql>'
    response = Typhoeus::Response.new(code: 200, body: sparql_result)
    Typhoeus.stub('http://192.168.2.101:3030/mdr/query').and_return(response)
  end
end
  