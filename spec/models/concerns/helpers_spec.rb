require 'rails_helper'

describe Helpers, type: :helper do

  include DataHelpers
  include SparqlHelpers

  def sub_dir
    return "models/concerns/helpers"
  end
  
  it "simple hash, I" do
    actual = {a: "a", b: "b"}
    expected = actual
    expect(actual).to hash_equal(expected)
  end

  it "simple hash, II, different" do
    actual = {a: "a", b: "1"}
    expected = {a: "a", b: "b"}
    expect(actual).to_not hash_equal(expected)
  end

  it "simple hash, different order, I" do
    actual = {a: "a", b: "b"}
    expected = {b: "b", a: "a"}
    expect(actual).to hash_equal(expected)
  end

  it "simple hash, different order, II, different" do
    actual = {a: "a", b: "b"}
    expected = {b: "b", a: "c"}
    expect(actual).to_not hash_equal(expected)
  end

  it "lengths different, I" do
    actual = {a: "a", b: "b", c: "X"}
    expected = {b: "b", a: "a"}
    expect(actual).to_not hash_equal(expected)
  end

  it "lengths different, II" do
    actual = {a: "a", b: "b", c: [1, 2, 3]}
    expected = {b: "b", a: "a", c: [3, 4] }
    expect(actual).to_not hash_equal(expected)
  end

  it "array of hash" do
    actual = [{a: "a", b: "b"}, {a: "a", b: "b"}]
    expected = [{a: "a", b: "b"}, {a: "a", b: "b"}]
    expect(actual).to hash_equal(expected)
  end

  it "array of hash, different order, I" do
    actual = [{a: "1", b: "2"}, {a: "a", b: "b"}]
    expected = [{a: "a", b: "b"}, {a: "1", b: "2"}]
    expect(actual).to hash_equal(expected)
  end

  it "array of hash, different order, II, different" do
    actual = [{a: "1", b: "3"}, {a: "a", b: "b"}]
    expected = [{a: "a", b: "b"}, {a: "1", b: "2"}]
    expect(actual).to_not hash_equal(expected)
  end

  it "array of hash containng array, I" do
    actual = [{a: "a", b: [{d: "d", e: "e"}]}, {a: "a", b: "b"}]
    expected = [{a: "a", b: [{d: "d", e: "e"}]}, {a: "a", b: "b"}]
    expect(actual).to hash_equal(expected)
  end

  it "array of hash containng array, II, different" do
    actual = [{a: "a", b: [{d: "d", e: "x"}]}, {a: "a", b: "b"}]
    expected = [{a: "a", b: [{d: "d", e: "e"}]}, {a: "a", b: "b"}]
    expect(actual).to_not hash_equal(expected)
  end

  it "compares sparql outputs I, exact match" do
    actual = read_sparql_file("to_sparql_result_1.txt")
    expected = read_sparql_file("to_sparql_expected.txt")
    expect(actual).to sparql_results_equal(expected)
  end

  it "compares sparql outputs II, missing triple" do
    actual = read_sparql_file("to_sparql_result_2.txt")
    expected = read_sparql_file("to_sparql_expected.txt")
    expect(actual).to_not sparql_results_equal(expected)
  end

  it "compares sparql outputs III, missing prefix" do
    actual = read_sparql_file("to_sparql_result_3.txt")
    expected = read_sparql_file("to_sparql_expected.txt")
    expect(actual).to_not sparql_results_equal(expected)
  end

  it "compares sparql outputs IV, missing INSERT DATA with blank lines" do
    actual = read_sparql_file("to_sparql_result_4.txt")
    expected = read_sparql_file("to_sparql_expected.txt")
    expect(actual).to_not sparql_results_equal(expected)
  end

  it "compares sparql outputs V, missing open brace" do
    actual = read_sparql_file("to_sparql_result_5.txt")
    expected = read_sparql_file("to_sparql_expected.txt")
    expect(actual).to_not sparql_results_equal(expected)
  end

  it "compares sparql outputs VI, missing closing brace" do
    actual = read_sparql_file("to_sparql_result_6.txt")
    expected = read_sparql_file("to_sparql_expected.txt")
    expect(actual).to_not sparql_results_equal(expected)
  end

  it "compares sparql outputs VII, triple ordering" do
    actual = read_sparql_file("to_sparql_result_7.txt")
    expected = read_sparql_file("to_sparql_expected.txt")
    expect(actual).to sparql_results_equal(expected)
  end

  it "compares sparql outputs VIII, predicate mismatch" do
    actual = read_sparql_file("to_sparql_result_8.txt")
    expected = read_sparql_file("to_sparql_expected.txt")
    expect(actual).to_not sparql_results_equal(expected)
  end

  it "compares sparql outputs IX, braces wrong order" do
    actual = read_sparql_file("to_sparql_result_9.txt")
    expected = read_sparql_file("to_sparql_expected.txt")
    expect(actual).to_not sparql_results_equal(expected)
  end

  it "compares sparql outputs X, INSERT DATA wrong order" do
    actual = read_sparql_file("to_sparql_result_10.txt")
    expected = read_sparql_file("to_sparql_expected.txt")
    expect(actual).to_not sparql_results_equal(expected)
  end

end