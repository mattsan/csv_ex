defmodule CsvExTest do
  use ExUnit.Case
  doctest CsvEx

  describe "without headers" do
    setup do
      [
        expect: [
          ["abc", "def", "ghi"],
          ["123", "456", "789"],
          ["987", "654", "321"]
        ]
      ]
    end

    test "simple csv", %{expect: expect} do
      csv_string = """
      abc,def,ghi
      123,456,789
      987,654,321
      """

      assert CsvEx.load(csv_string) == expect
    end

    test "quoted cells", %{expect: expect} do
      csv_string = """
      "abc","def","ghi"
      "123","456","789"
      "987","654","321"
      """

      assert CsvEx.load(csv_string) == expect
    end

    test "quoted cells with commas and spaces" do
      csv_string = """
      "abc","def","ghi"
      "1,3","4 6","7,9"
      "9 7","6,4","3 1"
      """

      expect = [
        ["abc", "def", "ghi"],
        ["1,3", "4 6", "7,9"],
        ["9 7", "6,4", "3 1"]
      ]

      assert CsvEx.load(csv_string) == expect
    end
  end

  describe "with headers" do
    test "simple csv" do
      csv_string = """
      abc,def,ghi
      123,456,789
      987,654,321
      """

      expect = [
        %{"abc" => "123", "def" => "456", "ghi" => "789"},
        %{"abc" => "987", "def" => "654", "ghi" => "321"}
      ]

      assert CsvEx.load(csv_string, headers: true) == expect
    end

    test "headers as atom" do
      csv_string = """
      abc,def,ghi
      123,456,789
      987,654,321
      """

      expect = [
        %{abc: "123", def: "456", ghi: "789"},
        %{abc: "987", def: "654", ghi: "321"}
      ]

      assert CsvEx.load(csv_string, headers: :atom) == expect
    end
  end
end
